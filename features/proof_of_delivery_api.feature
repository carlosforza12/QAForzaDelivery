Feature: Proof Of Delivery API
  Consulta de evidencia de entrega de guías vía API ProofOfDelivery

  Background: Configurar ruta de templates
    Given La ruta de los request API es "Request_Plantilla/"

  @proof_of_delivery
  Scenario Outline: Consulta de evidencia de entrega exitosa
    Given El usuario consulta la evidencia de entrega API
      | request   | metodo   | staging   | CodApp   | SecretKey   | GuideSerie   | GuideNumber   | StatusCodeEsperado   | MensajeEsperado   |
      | <request> | <metodo> | <staging> | <CodApp> | <SecretKey> | <GuideSerie> | <GuideNumber> | <StatusCodeEsperado> | <MensajeEsperado> |

    Examples:
      | Escenario | request                          | metodo          | staging                                      | CodApp                   | SecretKey                        | GuideSerie | GuideNumber | StatusCodeEsperado | MensajeEsperado               |
      | exitoso   | plantilla_proof_of_delivery.json | ProofOfDelivery | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | FD         | 30775499    | 200                | Operación realizada con éxito |

  @proof_of_delivery
  Scenario Outline: Consulta de evidencia de entrega - guia sin evidencia
    Given El usuario consulta la evidencia de entrega API
      | request   | metodo   | staging   | CodApp   | SecretKey   | GuideSerie   | GuideNumber   | StatusCodeEsperado   | MensajeEsperado   |
      | <request> | <metodo> | <staging> | <CodApp> | <SecretKey> | <GuideSerie> | <GuideNumber> | <StatusCodeEsperado> | <MensajeEsperado> |

    Examples:
      | Escenario | request                          | metodo          | staging                                      | CodApp                   | SecretKey                        | GuideSerie | GuideNumber | StatusCodeEsperado | MensajeEsperado                                                |
      | error     | plantilla_proof_of_delivery.json | ProofOfDelivery | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | FD         | 2390390     | 200                | No se encontró evidencia de entrega para la guía proporcionada |
