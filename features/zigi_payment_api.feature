Feature: Zigi Payment Link API
  Vertical: Payments
  Producto: Generación de link de pago Zigi (CourierApp → ZigiPayment)
  Release: AGUST26
  Product Owner: Braulio
  QA Lead: Carlos Gonzalez

  Background: Configurar ruta de templates
    Given La ruta de los request API es "Request_Plantilla/"


  @zigi_payment_link_exitoso
  Scenario Outline: Generacion exitosa de link de pago Zigi
    Given El usuario genera un link de pago Zigi API
      | requestCourier   | requestZigi   | metodoCourier   | metodoZigi   | staging   | CodApp   | SecretKey   | Phone   | IdCountry   | GuideSerie   | GuideNumber   | Amount   | CollectValue   | CODValue   | GeneratedMethod   | PaymentId   | MensajeEsperado   |
      | <requestCourier> | <requestZigi> | <metodoCourier> | <metodoZigi> | <staging> | <CodApp> | <SecretKey> | <Phone> | <IdCountry> | <GuideSerie> | <GuideNumber> | <Amount> | <CollectValue> | <CODValue> | <GeneratedMethod> | <PaymentId> | <MensajeEsperado> |
    When El usuario completa el pago en Zigi
      | Nombre   | Apellido   | Email   | PhonePago   | Tarjeta   | Vencimiento   | CVV   | DPI   | Departamento   | Direccion   |
      | <Nombre> | <Apellido> | <Email> | <PhonePago> | <Tarjeta> | <Vencimiento> | <CVV> | <DPI> | <Departamento> | <Direccion> |

    Examples:
      | Escenario    | requestCourier              | requestZigi                       | metodoCourier                 | metodoZigi       | staging                                      | CodApp                   | SecretKey                        | Phone    | IdCountry | GuideSerie | GuideNumber | Amount | CollectValue | CODValue | GeneratedMethod | PaymentId | MensajeEsperado | Nombre    | Apellido    | Email                            | PhonePago | Tarjeta          | Vencimiento | CVV | DPI       | Departamento | Direccion                    |
      | link_pago_GT | plantilla_courier_info.json | plantilla_validate_link_zigi.json | GetCourierInfoWithoutTokenLog | ValidateLinkZigi | https://qa-apicore.forzadeliveryexpress.com/ | SIFDCAPIECOM230920201910 | SHyKQDB3K6dfHxR3Dbqw45CQMv65vgkX | 39992308 | GT        | FD         | 30776235    | 47.5   | 47.5         | 0        | CourierApp      | 12        | Link Creado\|Link ya generado - WhatsApp enviado exitosamente | carlosQA  | GonzalezQA  | carlos.fernandez@forzalatam.com  | 39992308  | 4012000000020071 | 12/29       | 123 | 110649494 | GUATEMALA    | Ciudad de Guatemala Zona 12  |
