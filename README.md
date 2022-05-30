<p  align="center">
<img  src="http://developers.sw.com.mx/wp-content/uploads/2017/05/foxpro-icon.fw_-100x100.png">
</p>
<p  align="center">
<img  src="http://sw.com.mx/images/logo.png">
</p>

# Instalación del SDK

Integrar en nuestro proyecto el archivo sw-services.prg el cual contiene los métodos a ser utilizados para los servicios REST.


## Uso del SDK


## Autenticación
El servicio de Autenticación es utilizado principalmente para obtener el  **token**  el cual será utilizado para poder timbrar nuestro CFDI (xml) ya emitido (sellado), para poder utilizar este servicio es necesario que cuente con un  **usuario**  y  **contraseña** para posteriormente obtenga el token, usted puede utilizar los que están en este ejemplo para el ambiente de  **Pruebas**.

**Obtener Token**
```vb
SET PROCEDURE TO 'sw-services.prg' ADDITIVE
cURL = 'http://services.test.sw.com.mx'
cUser = 'demo'
cPassword = '123456789'
Response = Authentication(cURL, cUser, cPassword)
messagebox(Response) && respuesta del servicio web
GetTokenValue(Response) && obtener solo el valor de data->token
```
## Timbrado

### Timbrar CFDI Sellado
El método de timbrado recibe el contenido de un **XML** ya emitido (sellado) en formato **String** y un string con la versión a la cual se estará enviando. Este valor puede ser "[V1](https://developers.sw.com.mx/knowledge-base/timbrado-version-1/)", "[V2](https://developers.sw.com.mx/knowledge-base/timbrado-version-2/)", "[V3](https://developers.sw.com.mx/knowledge-base/timbrado-version-3/)", "[V4](https://developers.sw.com.mx/knowledge-base/timbrado-version-4/)". Para una completa referencia de las respuestas de cada versión de timbrado, acudir al enlace.

**Ejemplo de timbrado**
```vb
SET PROCEDURE TO 'sw-services.prg' ADDITIVE
cURL = 'http://services.test.sw.com.mx/'
cUser = 'demo'
cPassword = '123456789'
cXML = STRCONV(FILETOSTR(GETFILE('xml')),11)
cToken = GetTokenValue(Authentication(cURL, cUser, cPassword))
cVersion = 'V3'
cResponse= Stamp(cURL, cToken, cXML, cVersion)
? cResponse
MESSAGEBOX(cResponse)
```

### Timbrar CFDI sin Sello
El método de timbrado recibe el contenido de un **XML** sin sellar en formato **String** y un string con la versión a la cual se estará enviando. Este valor puede ser "[V1](https://developers.sw.com.mx/knowledge-base/timbrado-version-1/)", "[V2](https://developers.sw.com.mx/knowledge-base/timbrado-version-2/)", "[V3](https://developers.sw.com.mx/knowledge-base/timbrado-version-3/)", "[V4](https://developers.sw.com.mx/knowledge-base/timbrado-version-4/)". Para una completa referencia de las respuestas de cada versión de timbrado, acudir al enlace.

**Ejemplo de timbrado**
```vb
SET PROCEDURE TO 'sw-services.prg' ADDITIVE
cURL = 'http://services.test.sw.com.mx/'
cUser = 'demo'
cPassword = '123456789'
cXML = STRCONV(FILETOSTR(GETFILE('xml')),11)
cToken = GetTokenValue(Authentication(cURL, cUser, cPassword))
cVersion = 'V3'
cResponse= Issue(cURL, cToken, cXML, cVersion)
? cResponse
MESSAGEBOX(cResponse)
```

## Cancelación
**Cancelacion**  Se utiliza para cancelar documentos xml y se puede hacer mediante varios metodos  **Cancelación CSD**,  **Cancelación PFX**,  **Cancelacion XML**  y  **Cancelación UUID**.

### Cancelación por CSD
Como su nombre lo indica, este método recibe todos los elementos que componen el CSD los cuales son los siguientes:

- Certificado (.cer) en  **Base64**
- Key (.key) en  **Base64**
- Password del archivo key
- UUID
- RFC emisor
- Motivo
- Foliosustituci�n

**Ejemplo de uso**

```vb
SET PROCEDURE TO 'sw-services.prg' ADDITIVE
cURL = 'http://services.test.sw.com.mx/'
cUser = 'demo'
cPassword = '123456789'
cToken = GetTokenValue(Authentication(cURL, cUser, cPassword))
cPfx = STRCONV(FILETOSTR(GETFILE('cer')), 13)
cKey = STRCONV(FILETOSTR(GETFILE('key')), 13)
cPasswordCsd = '12345678a'
cUUID = '5d42df44-0b9f-4bb6-8bf0-3622cb3b2543'
cRFC = 'LAN8507268IA'
cMotivo = '02'
cFosustitucion = ' '
cResponse= CancelationByCSD(cURL, cToken, cUUID, cCer, cKey, cRFC, cPasswordCsd, cMotivo, cFosustitucion)
? cResponse
MESSAGEBOX(cResponse)
```

### Cancelación por PFX
Como su nombre lo indica, este método un PFX que se genera a partir de los archivos CSD.

Necesario:
- PFX (.pfx) en  **Base64**
- Password del archivo PFX
- UUID
- RFC emisor
- Motivo
- Foliosustituci�n

**Ejemplo de uso**

```vb
SET PROCEDURE TO 'sw-services.prg' ADDITIVE
cURL = 'http://services.test.sw.com.mx/'
cUser = 'demo'
cPassword = '123456789'
cToken = GetTokenValue(Authentication(cURL, cUser, cPassword))
cPfx = STRCONV(FILETOSTR(GETFILE('pfx')), 13)
cPasswordCsd = '12345678a'
cUUID = '5d42df44-0b9f-4bb6-8bf0-3622cb3b2543'
cRFC = 'LAN8507268IA'
cMotivo = '01'
cFosustitucion = '0e6eba79-b61c-42f1-8935-471909450b9a'
cResponse= CancelationByPFX(cURL, cToken, cUUID, cPfx, cRFC, cPassword, cMotivo, cFosustitucion)
? cResponse
MESSAGEBOX(cResponse)
```

### Cancelación por XML
Como su nombre lo indica, este método un XML que se genera con los UUID que se desean cancelar y después se sella utilizando el estándar *xmldsig*.

Necesario:
-   XML

**Ejemplo de uso**

```vb
SET PROCEDURE TO 'sw-services.prg' ADDITIVE
cURL = 'http://services.test.sw.com.mx/'
cUser = 'demo'
cPassword = '123456789'
cToken = GetTokenValue(Authentication(cURL, cUser, cPassword))
cXml = STRCONV(FILETOSTR(GETFILE('xml')),11)
cResponse= CancelationByXML(cURL, cToken, cXML)
? cResponse
MESSAGEBOX(cResponse)
```

### Cancelación por UUID
Como su nombre lo indica, este método solo recibe un UUID y Rfc Emisor, pero será necesario almacenar los CSD en el administrador de timbres. [Aquí](https://developers.sw.com.mx/knowledge-base/como-subir-mis-certificados-al-administrador-de-timbres/) una guía.

Necesario:
-   UUID
-   RFC emisor
- Motivo
- Foliosustituci�n

**Ejemplo de uso**

```vb
SET PROCEDURE TO 'sw-services.prg' ADDITIVE
cURL = 'http://services.test.sw.com.mx/'
cUser = 'demo'
cPassword = '123456789'
cToken = GetTokenValue(Authentication(cURL, cUser, cPassword))
cPfx = STRCONV(FILETOSTR(GETFILE('pfx')), 13)
cPasswordCsd = '12345678a'
cUUID = '5d42df44-0b9f-4bb6-8bf0-3622cb3b2543'
cRFC = 'LAN8507268IA'
cMotivo = '02'
cFosustitucion = ' '
cResponse= CancelationByPFX(cURL, cToken, cUUID, cPfx, cRFC, cPassword, Motivo, cFosustitucion)
? cResponse
MESSAGEBOX(cResponse)
```
# Consulta de Saldos
Este servicio recibe el token y genera los elementos que componen la consulta de saldos.
Se obtiene un JSON de respuesta con los datos de la consulta realizada.
```vb
SET PROCEDURE TO 'sw-services.prg' ADDITIVE
cURL = 'http://services.test.sw.com.mx'
cUser = 'demo'
cPassword = '123456789'
cToken = GetTokenValue(Authentication(cURL, cUser, cPassword))
Respuesta = AccountBalance(cURL, cToken)
? Respuesta 
MESSAGEBOX(Respuesta)
```

# Validaciones
Validaciones varias que son de utilidad.
## Validacion XML
Este servicio verifica integridad, estatus en el SAT, estructura válida.
```vb
SET PROCEDURE TO 'sw-services.prg' ADDITIVE
cURL = 'http://services.test.sw.com.mx'
cUser = 'demo'
cPassword = '123456789'
cXML = STRCONV(FILETOSTR(GETFILE('xml')),11)
cToken = GetTokenValue(Authentication(cURL, cUser, cPassword))
Respuesta = ValidateXML(cURL, cToken, cXML)
? Respuesta 
MESSAGEBOX(Respuesta)
```


# Consulta Estatus SAT
Este método recibe RFC emisor, RFC receptor, total y UUID de la factura a la cual consultaremos su Estatus en el SAT. Se retorna un string (Xml) con la respuesta del servicio del SAT.

**Ejemplo de uso**
```vb
SET PROCEDURE TO 'sw-services.prg' ADDITIVE
cURL = 'https://consultaqr.facturaelectronica.sat.gob.mx/ConsultaCFDIService.svc'
cRfcEmisor = 'LSO1306189R5'
cRfcReceptor = 'XAXX010101000'
cTotal = '603.20'
cUUID = '1fe614f5-74c5-4792-8456-eef4e6afebf2'
cSello = 'HD7zg=='
xmlResponse = EstatusCFDI(cUrl, cRfcEmisor, cRfcReceptor, cTotal, cUUID, cSello)
? xmlResponse
MESSAGEBOX(xmlResponse)
```