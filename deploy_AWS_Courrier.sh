#!/bin/bash

CONFIG_FILE="config.json"
DOCKER_JUST_INSTALLED=false

# ── Wrapper: usa sudo para docker si el usuario aun no esta en el grupo ────────
docker_cmd() {
  if groups "$USER" | grep -q '\bdocker\b'; then
    docker "$@"
  else
    sudo docker "$@"
  fi
}

docker_image_exists() {
  local IMAGE_NAME="$1"
  [ -n "$(docker_cmd image ls -q --filter "reference=$IMAGE_NAME")" ]
}

docker_container_exists() {
  local CONTAINER_NAME="$1"
  [ -n "$(docker_cmd ps -a -q -f "name=^${CONTAINER_NAME}$")" ]
}

# ── Dependencias ───────────────────────────────────────────────────────────────
check_jq() {
  if command -v jq >/dev/null 2>&1; then
    echo "JQ instalado OK"
    return 0
  fi
  echo "JQ no instalado, instalando..."
  sudo apt install -y jq
  echo "JQ instalado correctamente"
}

check_docker() {
  if command -v docker >/dev/null 2>&1; then
    echo "Docker instalado OK"
    return 0
  fi
  echo "Docker no instalado, instalando..."
  sudo apt update && sudo apt install -y docker.io && sudo systemctl enable docker && sudo systemctl start docker
  sudo usermod -aG docker "$USER"
  DOCKER_JUST_INSTALLED=true
  echo "Docker instalado correctamente"
  echo "NOTA: Se agrego $USER al grupo docker. Los comandos docker se ejecutaran con sudo en esta sesion."
}

# ── Banner de requisitos ───────────────────────────────────────────────────────
print_requirements() {
  echo ""
  echo "============================================================"
  echo "  REQUISITOS PREVIOS PARA EJECUTAR ESTE DEPLOYER"
  echo "============================================================"
  echo ""
  echo "  Los siguientes archivos deben estar en el mismo directorio"
  echo "  desde donde ejecutas este script:"
  echo ""
  echo "  [1] config.json"
  echo "      Configuracion del microservicio (credenciales, repo, imagen)."
  echo "      Si no existe, se creara interactivamente ahora."
  echo ""
  echo "  [2] appsettings.json"
  echo "      Configuracion de la aplicacion .NET Core."
  echo "      Solo requerido en el PRIMER despliegue (cuando no existe"
  echo "      repo local). En redespliegues se preserva el del repo anterior."
  echo "      Si no esta en este directorio, se te pedira la ruta."
  echo ""
  echo "  [3] appsettings.common.json"
  echo "      Configuracion compartida entre microservicios."
  echo "      Solo requerido en el PRIMER despliegue. En redespliegues"
  echo "      se preserva automaticamente del repo anterior."
  echo "      Si no esta en este directorio, se te pedira la ruta."
  echo ""
  echo "============================================================"
  echo ""
}

# ── Resolucion interactiva de archivos locales ─────────────────────────────────
resolve_local_file() {
  local LABEL="$1"       # nombre descriptivo para mostrar al usuario
  local DEFAULT="$2"     # ruta por defecto a intentar primero

  if [ -f "$DEFAULT" ]; then
    echo "$DEFAULT"
    return 0
  fi

  echo "" >&2
  echo "AVISO: No se encontro $LABEL en $(pwd)" >&2
  while true; do
    read -p "Ingresa la ruta completa a $LABEL: " INPUT >&2
    INPUT="${INPUT/#\~/$HOME}"
    if [ -f "$INPUT" ]; then
      echo "$INPUT"
      return 0
    else
      echo "ERROR: No se encontro el archivo en '$INPUT', intenta de nuevo." >&2
    fi
  done
}

# ── Configuracion ──────────────────────────────────────────────────────────────
create_config() {
  echo "Bienvenido, no encuentro tu configuracion de despliegue, empezemos"

  echo ""
  echo "=== Configuracion de Bitbucket ==="
  read -p "Ingresa tu usuario de bitbucket: " BITBUCKET_USER
  read -s -p "Ingresa tu contrasena de bitbucket: " BITBUCKET_PASSWORD
  echo ""

  echo ""
  echo "=== Configuracion del Microservicio ==="
  read -p "Ingresa el directorio donde se ubica tu dockerfile (ej: APIForzaDeliveryMicroservicioX.API): " DOCKERFILE
  read -p "Ingresa el directorio donde se ubica tu appsettings.json (ej: APIForzaDeliveryMicroservicioX.Configuration): " APPSETTINGS
  read -p "Ingresa el nombre del microservicio (ej: courier-api, ecommerce-api) en minuscula: " MICROSERVICE
  read -p "Ingresa el ambiente de despliegue (ej: dev, prod, qa) en minuscula: " TAG

  echo "Creando archivo de configuracion..."

  jq -n \
    --arg user "$BITBUCKET_USER" \
    --arg password "$BITBUCKET_PASSWORD" \
    --arg dockerfile "$DOCKERFILE" \
    --arg appsettings "$APPSETTINGS" \
    --arg microservice "$MICROSERVICE" \
    --arg tag "$TAG" \
    '{
      user: $user,
      password: $password,
      dockerfile: $dockerfile,
      appsettings: $appsettings,
      microservice: $microservice,
      tag: $tag
    }' > "$CONFIG_FILE"

  echo "Archivo de configuracion creado correctamente en $CONFIG_FILE"
}

# ── Despliegue ─────────────────────────────────────────────────────────────────
deploy_service() {
  read -p "Ingresa la rama que vas a desplegar: " BITBUCKET_BRANCH
  echo "Iniciando despliegue..."

  USER_BITBUCKET=$(jq -r '.user' "$CONFIG_FILE")
  PASSWORD=$(jq -r '.password' "$CONFIG_FILE")
  DOCKERFILE=$(jq -r '.dockerfile' "$CONFIG_FILE")
  APPSETTINGS=$(jq -r '.appsettings' "$CONFIG_FILE")
  MICROSERVICE=$(jq -r '.microservice' "$CONFIG_FILE")
  TAG=$(jq -r '.tag' "$CONFIG_FILE")

  MICROSERVICE_DIRECTORY="$HOME/fd-courier-serverless-microservice"
  APPSETTINGS_DEST="$HOME/fd-courier-serverless-microservice/WebApiForzaDelivery/$APPSETTINGS/appsettings.json"
  COMMON_DEST="$HOME/fd-courier-serverless-microservice/WebApiForzaDelivery/APIForzaDeliveryCommon.Shared/appsettings.common.json"

  if [ ! -d "$MICROSERVICE_DIRECTORY" ]; then
    # ── Primer despliegue: no existe repo local ──────────────────────────────
    echo "No detectado repositorio previamente descargado, clonando..."
    cd "$HOME"
    if ! git clone -b "$BITBUCKET_BRANCH" "https://$USER_BITBUCKET:$PASSWORD@bitbucket.org/cashlogisticsgroup/fd-courier-serverless-microservice.git"; then
      echo "ERROR: No se pudo clonar el repositorio. Verifica la rama y las credenciales."
      exit 1
    fi
    echo "Repositorio clonado correctamente"

    # Resolver appsettings.json
    APPSETTINGS_SOURCE=$(resolve_local_file "appsettings.json" "$(pwd)/appsettings.json")
    echo "Copiando appsettings.json..."
    cp -f "$APPSETTINGS_SOURCE" "$APPSETTINGS_DEST"
    echo "appsettings.json copiado correctamente"

    # Resolver appsettings.common.json
    COMMON_SOURCE=$(resolve_local_file "appsettings.common.json" "$(pwd)/appsettings.common.json")
    echo "Copiando appsettings.common.json..."
    cp -f "$COMMON_SOURCE" "$COMMON_DEST"
    echo "appsettings.common.json copiado correctamente"

    mount_service

  else
    # ── Redespliegue: existe repo local, preservar appsettings ──────────────
    echo "Iniciando proceso de clonacion de repositorio..."
    TEMP_DIR=$(mktemp -d "$HOME/temp_XXXXXX")

    cd "$TEMP_DIR"
    if ! git clone -b "$BITBUCKET_BRANCH" "https://$USER_BITBUCKET:$PASSWORD@bitbucket.org/cashlogisticsgroup/fd-courier-serverless-microservice.git"; then
      echo "ERROR: No se pudo clonar el repositorio. Verifica la rama y las credenciales."
      rm -rf "$TEMP_DIR"
      exit 1
    fi

    TEMP_APPSETTINGS="$TEMP_DIR/fd-courier-serverless-microservice/WebApiForzaDelivery/$APPSETTINGS/appsettings.json"
    TEMP_COMMON="$TEMP_DIR/fd-courier-serverless-microservice/WebApiForzaDelivery/APIForzaDeliveryCommon.Shared/appsettings.common.json"

    # Preservar appsettings.json del repo anterior, o pedirlo si no existe
    if [ -f "$APPSETTINGS_DEST" ]; then
      echo "Preservando appsettings.json del repo anterior..."
      cp -f "$APPSETTINGS_DEST" "$TEMP_APPSETTINGS"
    else
      echo "AVISO: No se encontro appsettings.json en el repo anterior."
      APPSETTINGS_SOURCE=$(resolve_local_file "appsettings.json" "$(pwd)/appsettings.json")
      cp -f "$APPSETTINGS_SOURCE" "$TEMP_APPSETTINGS"
    fi
    echo "appsettings.json listo"

    # Preservar appsettings.common.json del repo anterior, o pedirlo si no existe
    if [ -f "$COMMON_DEST" ]; then
      echo "Preservando appsettings.common.json del repo anterior..."
      cp -f "$COMMON_DEST" "$TEMP_COMMON"
    else
      echo "AVISO: No se encontro appsettings.common.json en el repo anterior."
      COMMON_SOURCE=$(resolve_local_file "appsettings.common.json" "$(pwd)/appsettings.common.json")
      cp -f "$COMMON_SOURCE" "$TEMP_COMMON"
    fi
    echo "appsettings.common.json listo"

    rm -rf "$MICROSERVICE_DIRECTORY"
    mv -f "$TEMP_DIR/fd-courier-serverless-microservice" "$HOME/"
    rm -rf "$TEMP_DIR"

    echo "Proceso de clonacion exitoso"
    mount_service
  fi
}

mount_service() {
  echo "Validando microservicio..."

  if docker_container_exists "$MICROSERVICE"; then
    echo "Encontrado contenedor $MICROSERVICE, eliminando..."
    docker_cmd stop "$MICROSERVICE" || true
    docker_cmd rm "$MICROSERVICE" || true
    echo "Contenedor anterior eliminado"
  else
    echo "No existe version anterior de: $MICROSERVICE"
  fi

  if docker_image_exists "$MICROSERVICE:$TAG"; then
    echo "Encontrada imagen anterior $MICROSERVICE:$TAG, eliminando..."
    docker_cmd rmi "$MICROSERVICE:$TAG" || true
    echo "Imagen anterior eliminada"
  else
    echo "No existe version anterior de imagen"
  fi

  echo "Construyendo imagen $MICROSERVICE:$TAG..."
  docker_cmd build \
    --no-cache \
    -f "$HOME/fd-courier-serverless-microservice/WebApiForzaDelivery/$DOCKERFILE/Dockerfile" \
    -t "$MICROSERVICE:$TAG" \
    "$HOME/fd-courier-serverless-microservice/WebApiForzaDelivery"

  if ! docker_image_exists "$MICROSERVICE:$TAG"; then
    echo "ERROR: La imagen no se construyo correctamente, abortando despliegue."
    exit 1
  fi

  echo "Imagen $MICROSERVICE:$TAG construida correctamente"

  # Limpiar imagenes dangling
  DANGLING=$(docker_cmd images -f "dangling=true" -q)
  if [ -n "$DANGLING" ]; then
    echo "Limpiando imagenes sin tag (dangling)..."
    docker_cmd rmi $DANGLING || true
    echo "Imagenes dangling eliminadas"
  else
    echo "No hay imagenes dangling para limpiar"
  fi

  echo "Levantando contenedor $MICROSERVICE..."
  docker_cmd run -d \
    --name "$MICROSERVICE" \
    --restart unless-stopped \
    -e TZ=America/Guatemala \
    -v /etc/localtime:/etc/localtime:ro \
    -p 8080:8080 \
    "$MICROSERVICE:$TAG"

  echo "Contenedor $MICROSERVICE desplegado correctamente"

  if [ "$DOCKER_JUST_INSTALLED" = true ]; then
    echo ""
    echo "============================================================"
    echo "  Docker fue instalado en esta sesion."
    echo "  Para correr docker sin sudo en el futuro, cierra sesion"
    echo "  y vuelve a conectarte al EC2."
    echo "============================================================"
  fi
}

# ── Main ───────────────────────────────────────────────────────────────────────
main() {
  print_requirements
  check_jq
  check_docker

  if [ ! -f "$CONFIG_FILE" ]; then
    create_config
  else
    echo "Encontrado archivo de configuracion: $CONFIG_FILE"
    read -p "Desea reconfigurar? 1 = si, 0 = no: " RECONFIG
    if [ "$RECONFIG" = "1" ]; then
      create_config
    fi
  fi

  deploy_service
}

main