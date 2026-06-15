Feature: Tracking Público API
  Vertical: Delivery
  Producto: Hermes Portal - GetTrackingPublic API
  Release: AGUST26
  Jira: https://cashlogisticsgroup.atlassian.net/browse/FDAPI-6287
  Product Owner: Braulio
  QA Lead: Carlos Gonzalez

  Background: Configurar ruta de templates
    Given La ruta de los request API es "Request_Plantilla/"

  @tracking_publico_exitoso
  Scenario Outline: Consulta de tracking público exitoso QA
    Given El usuario consulta el tracking publico API
      | request   | metodo   | staging   | CodApp   | SecretKey   | GuideSerie   | GuideNumber   | StatusCodeEsperado   | MensajeEsperado   | MilestoneTituloEsperado   | MilestoneDescripcionEsperada   |
      | <request> | <metodo> | <staging> | <CodApp> | <SecretKey> | <GuideSerie> | <GuideNumber> | <StatusCodeEsperado> | <MensajeEsperado> | <MilestoneTituloEsperado> | <MilestoneDescripcionEsperada> |

    Examples:
      | Escenario    | request                         | metodo              | staging                                      | CodApp                   | SecretKey                        | GuideSerie | GuideNumber | StatusCodeEsperado | MensajeEsperado | MilestoneTituloEsperado | MilestoneDescripcionEsperada                |
      | Incidencia 1 | plantilla_tracking_publico.json | GetTrackOrderDetail | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | FD         | 30775571    | 200                | Success         | Incidencia Validada     | Destinatario rechaza paquete                |
      | Incidencia 2 | plantilla_tracking_publico.json | GetTrackOrderDetail | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | FD         | 30775572    | 200                | Success         | Incidencia Validada     | Remitente solicita devolución               |
      | Incidencia 3 | plantilla_tracking_publico.json | GetTrackOrderDetail | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | FD         | 30775573    | 200                | Success         | Incidencia Validada     | Tiempo en inventario excedido en Exc        |
      | Incidencia 4 | plantilla_tracking_publico.json | GetTrackOrderDetail | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | FD         | 30775574    | 200                | Success         | Incidencia Validada     | Datos de dirección de entrega incorrectos   |
      | Incidencia 5 | plantilla_tracking_publico.json | GetTrackOrderDetail | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | FD         | 30775575    | 200                | Success         | Incidencia Validada     | No hay nadie en destino                     |
      | Incidencia 6 | plantilla_tracking_publico.json | GetTrackOrderDetail | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | FD         | 30775576    | 200                | Success         | Incidencia Validada     | Destinatario solicita otra fecha de entrega |
      | Incidencia 7 | plantilla_tracking_publico.json | GetTrackOrderDetail | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | FD         | 30775577    | 200                | Success         | Incidencia Validada     | No cumple requisito para entrega            |
      | Incidencia 8 | plantilla_tracking_publico.json | GetTrackOrderDetail | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | FD         | 30775578    | 200                | Success         | Incidencia Validada     | Tiempo de espera excedido en destino        |

  @tracking_publico_error
  Scenario Outline: Consulta de tracking público guia inexistente QA
    Given El usuario consulta el tracking publico API
      | request   | metodo   | staging   | CodApp   | SecretKey   | GuideSerie   | GuideNumber   | StatusCodeEsperado   | MensajeEsperado   |
      | <request> | <metodo> | <staging> | <CodApp> | <SecretKey> | <GuideSerie> | <GuideNumber> | <StatusCodeEsperado> | <MensajeEsperado> |

    Examples:
      | Escenario | request                         | metodo              | staging                                      | CodApp                   | SecretKey                        | GuideSerie | GuideNumber | StatusCodeEsperado | MensajeEsperado                                                                                                                        |
      | error     | plantilla_tracking_publico.json | GetTrackOrderDetail | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | FD         | 82008121    | 409                | Conflict - Ocurrio un inconveniente al ejecutar la transacción, por favor intente de nuevo, en caso persista contacte al Administrador |


  @tracking_publico_produccion
  Scenario Outline: Consulta de tracking público exitoso Producción
    Given El usuario consulta el tracking publico API
      | request   | metodo   | staging   | CodApp   | SecretKey   | GuideSerie   | GuideNumber   | StatusCodeEsperado   | MensajeEsperado   |
      | <request> | <metodo> | <staging> | <CodApp> | <SecretKey> | <GuideSerie> | <GuideNumber> | <StatusCodeEsperado> | <MensajeEsperado> |

    Examples:
      | Escenario | request                         | metodo              | staging                           | CodApp                    | SecretKey                        | GuideSerie | GuideNumber | StatusCodeEsperado | MensajeEsperado | MilestoneTituloEsperado | MilestoneDescripcionEsperada              |
      | exitoso   | plantilla_tracking_publico.json | GetTrackOrderDetail | https://apicore.forzadelivery.io/ | SICPXSAPIECOM250620241123 | sTMQdkrMTQxNGc3jo3795qvZvht8uRrf | FD         | 34432622    | 200                | Success         | Incidencia Validada     | Datos de dirección de entrega incorrectos |

  @tracking_publico_produccion_error
  Scenario Outline: Consulta de tracking público guia inexistente Producción
    Given El usuario consulta el tracking publico API
      | request   | metodo   | staging   | CodApp   | SecretKey   | GuideSerie   | GuideNumber   | StatusCodeEsperado   | MensajeEsperado   |
      | <request> | <metodo> | <staging> | <CodApp> | <SecretKey> | <GuideSerie> | <GuideNumber> | <StatusCodeEsperado> | <MensajeEsperado> |

    Examples:
      | Escenario | request                         | metodo              | staging                           | CodApp                    | SecretKey                        | GuideSerie | GuideNumber | StatusCodeEsperado | MensajeEsperado                                                                                                                        |
      | error     | plantilla_tracking_publico.json | GetTrackOrderDetail | https://apicore.forzadelivery.io/ | SICPXSAPIECOM250620241123 | sTMQdkrMTQxNGc3jo3795qvZvht8uRrf | FD         | 2390390     | 409                | Conflict - Ocurrio un inconveniente al ejecutar la transacción, por favor intente de nuevo, en caso persista contacte al Administrador |
