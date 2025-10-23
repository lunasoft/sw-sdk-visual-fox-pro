# Visual Fox Pro
[![SW sapien](https://dka575ofm4ao0.cloudfront.net/pages-transactional_logos/retina/68712/SW_smarter-Servicios_web.png)](http://sw.com.mx/)

Librería NetStandard para el consumo de los servicios de SW sapien®.

## Contenido 

- [Compatibilidad](#Compatibilidad)
- [Dependencias](#Dependencias)
- [Documentación](#Documentación)
- [Instalación](#Instalación)
- [Implementación](#Implementación)
---

### Compatibilidad
- CFDI 4.0
- VFP 9.0
---

### Dependencias
- MSXML2.ServerXMLHTTP.6.0 (Esta versión (6.0) es necesaria para soportar el protocolo de seguridad TLS 1.2.)

---

### Documentación
* [Inicio Rápido](https://developers.sw.com.mx/knowledge-base/conoce-el-proceso-de-integracion-en-solo-7-pasos/)
* [Documentacion Oficial Servicios](http://developers.sw.com.mx)
---

### Instalación
Integrar en nuestro proyecto el archivo sw-services.prg el cual contiene los métodos a ser utilizados para los servicios REST.

---
### Implementación

La librería contara con los servicios principales como lo son Timbrado de CFDI, Cancelación, Consulta estatus CFDI, etc.

---
## Autenticaci&oacute;n ##
El servicio de Autenticación es utilizado principalmente para obtener el **token** el cual sera utilizado para poder usar nuestros servicios.

**Ejemplo de consumo de la librería para obtener token**
 ```vb
**Obtener Token**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definición de credenciales y URL
cURL = 'https://services.test.sw.com.mx'
cUser = 'demo'    && Usar variable de entorno o 'demo'
cPassword = 'password'  && Usar variable de entorno o '123456789'

* Llamada al servicio de Autenticación
Response = Authentication(cURL, cUser, cPassword)

* Mostrar la respuesta JSON completa del servicio web
messagebox(Response) 

* Obtener solo el valor del Token (requiere la función GetTokenValue)
cToken = GetTokenValue(Response) 

IF NOT EMPTY(cToken)
    WAIT WINDOW "Token listo para uso en Headers: " + cToken NOWAIT
ENDIF
```
---

## Timbrado ##

<details>
<summary>
Timbrado CFDI
</summary>

Este método recibe los siguientes parametros:
* XML previamente sellado
* Usuario y contraseña o Token
* Url Servicios SW
* Version de respuesta

**Ejemplo de consumo de la libreria para timbrar XML**
```vb
**Timbrado CFDI**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cToken = 'YOUR_BEARER_TOKEN'      && Token obtenido previamente
cURL = 'https://services.test.sw.com.mx'
cXML = '<cfdi:Comprobante ...>'     && Contenido del XML ya timbrado
cVersion = 'v4'                && Versión de respuesta que requieres

* Llamada al servicio de Timbrado
Response = Stamp(cURL, cToken, cXML, cVersion)

* Mostrar la respuesta del servicio web (XML timbrado o error JSON)
messagebox(Response) 

* NOTA: El XML debe ser leído en codificación UTF-8 antes de pasarse a la función Stamp.
```
</details>

<details>
<summary>
Timbrado de CFDI Retenciones
</summary>

Servicio REST para timbrar CFDI de retenciones previamente sellados.

Este método recibe los siguientes parametros:
* XML de retenciones previamente sellado
* Usuario y contraseña ó Token
* Url Servicios SW

**Ejemplo de consumo de la libreria para la CFDI de retenciones**
```vb
**Timbrado Retenciones**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cToken = 'YOUR_BEARER_TOKEN'      && Token obtenido previamente
cURL = 'https://services.test.sw.com.mx'
cXML = '<retenciones:Retenciones ...>' && Contenido del XML de Retención

* Llamada al servicio de Timbrado de Retenciones (siempre usa la versión v3)
Response = StampRet(cURL, cToken, cXML)

* Mostrar la respuesta del servicio web (XML timbrado o error JSON)
messagebox(Response)
```
</details>

<details>
<summary>
Emisión Timbrado
</summary>

**Emisión Timbrado** Realiza el sellado y timbrado de un comprobante o CFDI 4.0.

Este método recibe los siguientes parametros:
* XML del CFDI
* Usuario y contraseña ó Token
* Url Servicios SW
* Version de respuesta

**Ejemplo de consumo de la libreria para Emisión Timbrado**
```vb
**Emisión-Timbrado (Issue)**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cToken = 'YOUR_BEARER_TOKEN'      && Token obtenido previamente
cURL = 'https://services.test.sw.com.mx'
cXML = '<cfdi:Comprobante ...>'     && Contenido del XML sin sellar
cVersion = 'v1'                && Versión de respueta que requieres

* Llamada al servicio de Emisión-Timbrado
Response = Issue(cURL, cToken, cXML, cVersion)

* Mostrar la respuesta del servicio web (XML timbrado o error JSON)
messagebox(Response) 

* NOTA: El XML debe ser leído en codificación UTF-8 antes de pasarse a la función Issue.
```

</details>


***NOTA:*** Existen varias versiones de respuesta, las cuales son las siguientes:

| Version |                         Respuesta                             | 
|---------|---------------------------------------------------------------|
|  V1     | Devuelve el timbre fiscal digital                             | 
|  V2     | Devuelve el timbre fiscal digital y el CFDI timbrado          | 
|  V3     | Devuelve el CFDI timbrado                                     | 
|  V4     | Devuelve todos los datos del timbrado                         |

Para mayor referencia de estas versiones de respuesta, favor de visitar el siguiente [link](https://developers.sw.com.mx/knowledge-base/versiones-de-respuesta-timbrado/).

## Cancelación ##

Este servicio se utiliza para cancelar documentos xml y se puede hacer mediante varios metodos **Cancelación CSD**, **Cancelación PFX**, **Cancelacion por XML** y **Cancelación UUID**.

<details>
<summary>
Cancelacion por CSD
</summary>

Como su nombre lo indica, este método realiza la cancelacion mediante los CSD.

Este método recibe los siguientes parametros:
* Usuario y contraseña
* Url Servicios SW
* Certificado (.cer) en **Base64**
* Key (.key) en **Base64**
* RFC emisor
* Password del archivo key
* UUID
* Motivo
* Folio Sustitución (Si el motivo es 01)

**Ejemplo de consumo de la libreria para cancelar con CSD**
```vb
**CancelationByCSD**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables (usar datos reales)
cURL = 'https://services.test.sw.com.mx'
cToken = 'YOUR_BEARER_TOKEN'
cUUID = '12345678-ABCD-EFAB-CDEF-123456789012'
cRFC = 'XAXX010101000'
cPassword = 'password'
motivo = '02'                    && Motivo de cancelación (ej: '01', '02')
fosustitucion = ''               && UUID si el motivo es '01'
cCer = 'B64_CONTENIDO_DEL_CER'    && Contenido del .CER en Base64
cKey = 'B64_CONTENIDO_DEL_KEY'    && Contenido del .KEY en Base64

Response = CancelationByCSD(cURL, cToken, cUUID, cCer, cKey, cRFC, cPassword, motivo, fosustitucion)
messagebox(Response)
```
</details>

<details>
<summary>
Cancelacion por PFX
</summary>

Como su nombre lo indica, este método realiza la cancelacion mediante el PFX.

Este método recibe los siguientes parametros:
* Usuario y contraseña
* Url Servicios SW
* Archivo PFX en **Base64**
* RFC emisor
* Password (CSD)
* UUID
* Motivo
* Folio Sustitución

**Ejemplo de consumo de la libreria para cancelar con PFX**
```vb
**CancelationByPFX**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables (usar datos reales)
cURL = 'https://services.test.sw.com.mx'
cToken = 'YOUR_BEARER_TOKEN'
cUUID = '12345678-ABCD-EFAB-CDEF-123456789012'
cRFC = 'XAXX010101000'
cPassword = 'password'
motivo = '02'
fosustitucion = ''
cPFX = 'B64_CONTENIDO_DEL_PFX'    && Contenido del .PFX en Base64

Response = CancelationByPFX(cURL, cToken, cUUID, cPFX, cRFC, cPassword, motivo, fosustitucion)
messagebox(Response)
```
</details>

<details>
<summary>
Cancelacion por XML
</summary>

Como su nombre lo indica, este método realiza la cancelacion mediante el XML sellado con los UUID a cancelar.

Este método recibe los siguientes parametros:
* Usuario y contraseña
* Url Servicios SW
* XML sellado con los UUID a cancelar.

**Ejemplo de XML para Cancelar**
```xml
<Cancelacion xmlns="http://cancelacfd.sat.gob.mx"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" Fecha="2021-12-26T18:15:28" RfcEmisor="EKU9003173C9">
    <Folios>
        <Folio UUID="fe4e71b0-8959-4fb9-8091-f5ac4fb0fef8" Motivo="02" FolioSustitucion=""/>
    </Folios>
    <Signature xmlns="http://www.w3.org/2000/09/xmldsig#">
        <SignedInfo>
            <CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />
            <SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" />
            <Reference URI="">
                <Transforms>
                    <Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature" />
                </Transforms>
                <DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" />
                <DigestValue>XEdUtCptjdlz9DsYAP7nnU6MytU=</DigestValue>
            </Reference>
        </SignedInfo>
        <SignatureValue>ZnWh91e5tUc4/t1ZWnb3yOgB8zuCXNPioND+rv6aLOEwIw26/8sYYb+GT4wgyqlc09wOs32XTUwWoGQwtWMG8Euqq+4xJyobWvPCsX6CiURvD/Pd33xgkH92A0AGQxEMYGVT7wK+GFS2gDTYEYAXvZqzCe6+rXnlQvHML0TOOmhVu/wc8YrCbGt4z/F5sRxhjpa0eqwFEq4RmB4nkWjcD3Pnudn3XAI5NHIiOd8KVGVcDR+LvYvKj7h+18WxZgujpggYjbFN79i1jEsAEPDfgryUdTvjDw+KC7Mg+/ge6pssH42buEMIwVE4VX9Y3NtWSGTwdIK/8pxXk+Y5wyR6Gg==</SignatureValue>
        <KeyInfo>
            <X509Data>
                <X509IssuerSerial>
                    <X509IssuerName>OID.1.2.840.113549.1.9.2=responsable: ACDMA-SAT, OID.2.5.4.45=2.5.4.45, L=COYOACAN, S=CIUDAD DE MEXICO, C=MX, PostalCode=06370, STREET=3ra cerrada de cadiz, E=oscar.martinez@sat.gob.mx, OU=SAT-IES Authority, O=SERVICIO DE ADMINISTRACION TRIBUTARIA, CN=AC UAT</X509IssuerName>
                    <X509SerialNumber>292233162870206001759766198444326234574038512436</X509SerialNumber>
                </X509IssuerSerial>
                <X509Certificate>MIIFuzCCA6OgAwIBAgIUMzAwMDEwMDAwMDA0MDAwMDI0MzQwDQYJKoZIhvcNAQELBQAwggErMQ8wDQYDVQQDDAZBQyBVQVQxLjAsBgNVBAoMJVNFUlZJQ0lPIERFIEFETUlOSVNUUkFDSU9OIFRSSUJVVEFSSUExGjAYBgNVBAsMEVNBVC1JRVMgQXV0aG9yaXR5MSgwJgYJKoZIhvcNAQkBFhlvc2Nhci5tYXJ0aW5lekBzYXQuZ29iLm14MR0wGwYDVQQJDBQzcmEgY2VycmFkYSBkZSBjYWRpejEOMAwGA1UEEQwFMDYzNzAxCzAJBgNVBAYTAk1YMRkwFwYDVQQIDBBDSVVEQUQgREUgTUVYSUNPMREwDwYDVQQHDAhDT1lPQUNBTjERMA8GA1UELRMIMi41LjQuNDUxJTAjBgkqhkiG9w0BCQITFnJlc3BvbnNhYmxlOiBBQ0RNQS1TQVQwHhcNMTkwNjE3MTk0NDE0WhcNMjMwNjE3MTk0NDE0WjCB4jEnMCUGA1UEAxMeRVNDVUVMQSBLRU1QRVIgVVJHQVRFIFNBIERFIENWMScwJQYDVQQpEx5FU0NVRUxBIEtFTVBFUiBVUkdBVEUgU0EgREUgQ1YxJzAlBgNVBAoTHkVTQ1VFTEEgS0VNUEVSIFVSR0FURSBTQSBERSBDVjElMCMGA1UELRMcRUtVOTAwMzE3M0M5IC8gWElRQjg5MTExNlFFNDEeMBwGA1UEBRMVIC8gWElRQjg5MTExNk1HUk1aUjA1MR4wHAYDVQQLExVFc2N1ZWxhIEtlbXBlciBVcmdhdGUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCN0peKpgfOL75iYRv1fqq+oVYsLPVUR/GibYmGKc9InHFy5lYF6OTYjnIIvmkOdRobbGlCUxORX/tLsl8Ya9gm6Yo7hHnODRBIDup3GISFzB/96R9K/MzYQOcscMIoBDARaycnLvy7FlMvO7/rlVnsSARxZRO8Kz8Zkksj2zpeYpjZIya/369+oGqQk1cTRkHo59JvJ4Tfbk/3iIyf4H/Ini9nBe9cYWo0MnKob7DDt/vsdi5tA8mMtA953LapNyCZIDCRQQlUGNgDqY9/8F5mUvVgkcczsIgGdvf9vMQPSf3jjCiKj7j6ucxl1+FwJWmbvgNmiaUR/0q4m2rm78lFAgMBAAGjHTAbMAwGA1UdEwEB/wQCMAAwCwYDVR0PBAQDAgbAMA0GCSqGSIb3DQEBCwUAA4ICAQBcpj1TjT4jiinIujIdAlFzE6kRwYJCnDG08zSp4kSnShjxADGEXH2chehKMV0FY7c4njA5eDGdA/G2OCTPvF5rpeCZP5Dw504RZkYDl2suRz+wa1sNBVpbnBJEK0fQcN3IftBwsgNFdFhUtCyw3lus1SSJbPxjLHS6FcZZ51YSeIfcNXOAuTqdimusaXq15GrSrCOkM6n2jfj2sMJYM2HXaXJ6rGTEgYmhYdwxWtil6RfZB+fGQ/H9I9WLnl4KTZUS6C9+NLHh4FPDhSk19fpS2S/56aqgFoGAkXAYt9Fy5ECaPcULIfJ1DEbsXKyRdCv3JY89+0MNkOdaDnsemS2o5Gl08zI4iYtt3L40gAZ60NPh31kVLnYNsmvfNxYyKp+AeJtDHyW9w7ftM0Hoi+BuRmcAQSKFV3pk8j51la+jrRBrAUv8blbRcQ5BiZUwJzHFEKIwTsRGoRyEx96sNnB03n6GTwjIGz92SmLdNl95r9rkvp+2m4S6q1lPuXaFg7DGBrXWC8iyqeWE2iobdwIIuXPTMVqQb12m1dAkJVRO5NdHnP/MpqOvOgLqoZBNHGyBg4Gqm4sCJHCxA1c8Elfa2RQTCk0tAzllL4vOnI1GHkGJn65xokGsaU4B4D36xh7eWrfj4/pgWHmtoDAYa8wzSwo2GVCZOs+mtEgOQB91/g==</X509Certificate>
            </X509Data>
        </KeyInfo>
    </Signature>
</Cancelacion>
```
Para caso de motivo 01 deberá añadir el atributo "FolioSustitucion" dentro del Nodo <Folio>

Ejemplo de nodo Folio: 
```
<Folios>
    <Folio UUID="b374db50-a0a3-4028-9d01-32b93e2b925a" Motivo="01" FolioSustitucion="b3641a4b-7177-4323-aaa0-29bd34bf1ff8" />
</Folios>
```

**Ejemplo de consumo de la libreria para cancelar con XML**
```vb
**CancelationByXML**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cURL = 'https://services.test.sw.com.mx'
cToken = 'YOUR_BEARER_TOKEN'
cXML = '<Cancelacion ...>'      && Contenido del XML de Solicitud de Cancelación (firmado)

Response = CancelationByXML(cURL, cToken, cXML)
messagebox(Response)

* NOTA: El XML debe ser leído en codificación UTF-8 antes de pasarse a la función.
```
</details>

<details>
<summary>
Cancelacion por UUID
</summary>

Como su nombre lo indica, este método realiza la cancelacion mediante el UUID a cancelar.

Este método recibe los siguientes parametros:
* Usuario y contraseña
* Url Servicios SW
* RFC emisor
* UUID
* Motivo
* Folio Sustitución

 **Ejemplo de consumo de la libreria para cancelar con UUID**
```vb
**CancelationByUUID**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cURL = 'https://services.test.sw.com.mx'
cToken = 'YOUR_BEARER_TOKEN'
cUUID = '12345678-ABCD-EFAB-CDEF-123456789012'
cRFC = 'XAXX010101000'
motivo = '02'
fosustitucion = ''              && Opcional: Se usa si el motivo es '01'

Response = CancelationByUUID(cToken, cURL, cUUID, cRFC, motivo, fosustitucion)
messagebox(Response)
```
</details>

## Gestion de Usuarios

Estos métodos permiten a los distribuidores (Dealers) gestionar las cuentas de sus usuarios asociados: crear, modificar, consultar y eliminar.

<details>
<summary>
Crear Usuario
</summary>

Este método recibe los siguientes parámetros:
* Url Servicios SW
* Token (Bearer)
* Nombre del Usuario
* RFC (TaxId)
* Correo Electrónico (Email)
* Timbres Iniciales (Numérico)
* Ilimitado (Lógico: .T. o .F.)
* Contraseña (Password)
* Email de Notificación (Opcional)
* Teléfono (Opcional)

```vb
**Crear Usuario**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables (usar datos de prueba)
cToken = 'YOUR_DEALER_TOKEN'
cURL = 'https://api.test.sw.com.mx'
cName = 'Usuario Demo Nuevo'
cTaxId = 'XAXX010101000'
cEmail = 'demo_user@test.com'
nStamps = 100                     && Timbres iniciales
lUnlimited = .F.                  && TRUE (.T.) o FALSE (.F.)
cPassword = 'password123'
cNotificationEmail = ''           && Opcional
cPhone = ''                       && Opcional

* Llamada al servicio
Response = CreateUser(cURL, cToken, cName, cTaxId, cEmail, nStamps, lUnlimited, cPassword, cNotificationEmail, cPhone)
messagebox(Response)
```

</details>

<details>
<summary>
Obtener Usuario con un filtro de busqueda
</summary>
Este método recibe los siguientes parámetros:

* Url Servicios SW
* Token (Bearer)
* Clave de Filtro (Key: 'TaxId', 'Email', 'Name', 'Unlimited', 'IdUser', etc.) (Opcional)
* Valor de Filtro (Value) (Opcional)
* Página (Numérico)
* Elementos por Página (Numérico)
```vb
**Consultar Usuarios**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cToken = 'YOUR_DEALER_TOKEN'
cURL = 'https://api.test.sw.com.mx'
cFiltroKey = 'Email'              && Filtro a aplicar (ej: 'IdUser', 'TaxId', 'Email', 'Name')
cFiltroValue = 'test@example.com' 
nPage = 1
nPerPage = 10                     && Número de resultados por página

* Llamada al servicio
Response = ConsultarUsuarios(cURL, cToken, cFiltroKey, cFiltroValue, nPage, nPerPage)
messagebox(Response)
* NOTA: Si no se envian filtros, se buscara la informacion del usuario al que pertenece el token.
```

</details>

<details>
<summary>
Actualizar Usuario
</summary>

Este método recibe los siguientes parámetros:
* Url Servicios SW
* Token (Bearer)
* UUID del Usuario a modificar (UserID) - Requerido
* Nombre del Usuario (Opcional)
* RFC (TaxId) (Opcional)
* Email de Notificación (Opcional)
* Teléfono (Opcional)
* Ilimitado (Lógico: .T. o .F.) (Opcional)

```vb
**Actualizar Usuario**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cToken = 'YOUR_DEALER_TOKEN'
cURL = 'https://api.test.sw.com.mx'
cUserID = '1a2b3c4d-5e6f-7a8b-9c0d-1234567890ab'  && UUID del usuario a modificar

* Nuevos valores (pasar vacíos ("") para no modificar el campo)
cName = 'Nombre Completo Actualizado'
cTaxId = ''                                      && Dejar vacío para no modificar el RFC
cNotificationEmail = 'nuevo.notif@test.com'
cPhone = ''
lUnlimited = .T.                                 && TRUE (.T.) para habilitar timbres ilimitados

* Llamada al servicio
Response = UpdateUser(cURL, cToken, cUserID, cName, cTaxId, cNotificationEmail, cPhone, lUnlimited)
messagebox(Response)

* NOTA: Este método solo envía los campos que tienen contenido (no vacíos), permitiendo una actualización parcial.
```

</details>

<details>
<summary>
Eliminar Usuario
</summary>
Este método recibe los siguientes parámetros:

* Url Servicios SW
* Token (Bearer)
* UUID del Usuario a eliminar (UUID)

```vb
**Eliminar Usuario**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cToken = 'YOUR_DEALER_TOKEN'
cURL = 'https://api.test.sw.com.mx'
cUserID = '1a2b3c4d-5e6f-7a8b-9c0d-1234567890ab'  && UUID del usuario a eliminar

* Llamada al servicio
Response = DeleteUser(cURL, cToken, cUserID)
messagebox(Response)

* NOTA: Una eliminación exitosa generalmente retorna un status HTTP 204.
```

</details>

## Gestion de Timbres ##
Método mediante el cual puedes realizar la consulta de tu saldo para consumir los servicios de SW.

<details>
<summary>
Estado de cuenta de timbres
</summary>

Este método recibe los siguientes parámetros:

* Url Servicios SW
* Token (Bearer)


```vb
**Consultar Saldo de Timbres**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cToken = 'YOUR_BEARER_TOKEN'      && Token del usuario que CONSULTA su saldo
cURL = 'https://api.test.sw.com.mx'

* Llamada al servicio
Response = ConsultarBalanceTimbres(cURL, cToken)

* Mostrar la respuesta JSON con el saldo 
messagebox(Response)
```

</details>

<details>
<summary>
Añadir timbres
</summary>

Este método recibe los siguientes parámetros:

* Url Servicios SW
* Token (Bearer del Distribuidor)
* Método HTTP (String: 'POST' para agregar o 'DELETE' para eliminar)
* UUID del Usuario afectado (UUID)
* Cantidad de Timbres (Numérico)
* Comentario (String) (Opcional)


```vb
**Agregar Timbres**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cToken = 'YOUR_DEALER_TOKEN'      && Token del distribuidor (tu cuenta)
cURL = 'https://api.test.sw.com.mx'
cMethod = 'POST'                  && Se usa POST para AGREGAR timbres
cUUIDUsuario = '9d1a3c20-a94f-4d5e-9e4a-5b1234567890' 
nCantidad = 50                    && Cantidad de timbres a agregar
cComentario = 'Carga inicial del mes' 

* Llamada al servicio
Response = GestionarTimbres(cURL, cToken, cMethod, cUUIDUsuario, nCantidad, cComentario)

* Mostrar la respuesta del servicio (200 OK o error JSON)
messagebox(Response)
```

</details>

<details>
<summary>
Eliminar timbres
</summary>

Este método recibe los siguientes parámetros:

* Url Servicios SW
* Token (Bearer del Distribuidor)
* Método HTTP (String: 'POST' para agregar o 'DELETE' para eliminar)
* UUID del Usuario afectado (UUID)
* Cantidad de Timbres (Numérico)
* Comentario (String) (Opcional)

```vb
**Eliminar Timbres**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cToken = 'YOUR_DEALER_TOKEN'      && Token del distribuidor (tu cuenta)
cURL = 'https://api.test.sw.com.mx'
cMethod = 'DELETE'                && Se usa DELETE para ELIMINAR timbres
cUUIDUsuario = '9d1a3c20-a94f-4d5e-9e4a-5b1234567890' 
nCantidad = 10                    && Cantidad de timbres a eliminar
cComentario = 'Ajuste por cierre de mes' 

* Llamada al servicio
Response = GestionarTimbres(cURL, cToken, cMethod, cUUIDUsuario, nCantidad, cComentario)

* Mostrar la respuesta del servicio (200 OK o error JSON)
messagebox(Response)
```

</details>

## Validación ##

<details>
<summary>
Validación XML
</summary>

La función ValidateXML() se utiliza para verificar la estructura y sintaxis de un CFDI (XML) contra los esquemas del SAT

Este metodo recibe los siguientes parametros:
* Url Servicios SW
* Usuario y contraseña o token
* XML

**Ejemplo de consumo de la libreria para validación de XML**
```vb
**Validación de XML**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cToken = 'YOUR_BEARER_TOKEN'      && Token obtenido previamente
cURL = 'https://services.test.sw.com.mx'
cXML = '<cfdi:Comprobante ...>'     && Contenido del XML a validar

* Llamada al servicio de Validación
Response = ValidateXML(cURL, cToken, cXML)

* Mostrar la respuesta del servicio web (JSON con resultados de validación)
messagebox(Response) 

* NOTA: El XML debe ser leído en codificación UTF-8 antes de pasarse a la función.
```

</details>


## Consulta Estatus ##

<details>
<summary>
Consulta Estatus SAT
</summary>
Este servicio sirve para consultar el estatus de un CFDI antes y después de enviarlo a cancelar, con él sabremos sí puede ser cancelado de forma directa, o en caso de que se necesite consultar los CFDI relacionados para poder generar la cancelación.

:pushpin: ***NOTA:*** El servicio de consulta es de tipo SOAP y es proporcionado directamente por parte del SAT.

Este metodo recibe los siguientes parametros:
* Url Servicios SW
* Usuario y contraseña o token
* RFC Emisor
* RFC Receptor
* Total declarado en el comprobante
* UUID del comprobante
* Sello digital del emisor

**Ejemplo de consumo de la libreria para la consulta del estatus SAT**
```vb
**Consulta de Estatus SAT**
SET PROCEDURE TO 'sw-services.prg' ADDITIVE

* Definir variables
cURL = 'https://consultacfdi.a3t.mx/ConsultaCFDIService.svc'  && Endpoint del SAT (o proxy)
cRfcEmisor = 'XAXX010101000'
cRfcReceptor = 'BFE081010A00'
cTotal = '1000.23'               && Total del comprobante, debe ser con dos decimales exactos si no son 0s
cUUID = '12345678-ABCD-EFAB-CDEF-123456789012'
c8Fe = '12345678'                && Últimos 8 dígitos del sello del CFDI

* Llamada al servicio
Response = EstatusCFDI(cURL, cRfcEmisor, cRfcReceptor, cTotal, cUUID, c8Fe)

* Mostrar la respuesta (es un XML SOAP con el estado del CFDI)
messagebox(Response)
```
</details>


Para mayor referencia de un listado completo de los servicios favor de visitar el siguiente [link](http://developers.sw.com.mx/).

Si deseas contribuir a la libreria o tienes dudas envianos un correo a **soporte@sw.com.mx**.