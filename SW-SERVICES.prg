********************************************************************************
* Nombre del Archivo: sw-services.PRG
*
* Propiedad:      SW Smarter
* Derechos de Autor: (c) 2025, SW Smarter. Todos los derechos reservados.
* VersiÛn:        0.0.5.1
*
* DescripciÛn:    Contiene la lÛgica principal para la gestiÛn de servicios 
* de timbrado, cancelaciÛn y obtenciÛn de tokens.
********************************************************************************

LOCAL oErr as EXCEPTION

&& Consulta de Etatus SAT
Function EstatusCFDI(cURL,cRfcEmisor, cRfcReceptor, cTotal, cUUID, c8Fe)
    IF NOT ValidarURL(cURL)
        RETURN "Error: la URL debe iniciar con https://"
    ENDIF

	sRequest = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">' + ;
'<soapenv:Header/>' + ;
'<soapenv:Body>' + ;
'<tem:Consulta>' + ;
'<tem:expresionImpresa><![CDATA[?re='+cRfcEmisor+'&rr='+cRfcReceptor+'&tt='+cTotal+'&id='+cUUID+'&fe='+c8Fe+']]></tem:expresionImpresa>' +;
'</tem:Consulta>' + ;
'</soapenv:Body>' + ;
'</soapenv:Envelope>'
	sURL = cURL+'?wsdl'
	Try
		oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
		With oHTTP
			.Open ("POST", sURL, .F.)
			.setRequestHeader('SOAPAction', 'http://tempuri.org/IConsultaCFDIService/Consulta')
			.setRequestHeader('Content-Type', 'text/xml;charset="utf-8"')
			.Send (sRequest)
		Endwith
		_Estatus = oHTTP.responseText

	Catch To oErr

		_Estatus = "Error, sucedio un problema en la funci√≥n EstatusCFDI" + sp + sp + ;
			"[  Error: ] " + Str(oErr.ErrorNo) + sp + ;
			"[  LineNo: ] " + Str(oErr.Lineno) + sp + ;
			"[  Message: ] " + oErr.Message + sp + ;
			"[  Procedure: ] " + oErr.Procedure + sp + ;
			"[  Details: ] " + oErr.Details + sp + ;
			"[  StackLevel: ] " + Str(oErr.StackLevel) + sp + ;
			"[  LineContents: ] " + oErr.LineContents

	Endtry

	Return _Estatus

&& Autenticacion V2
FUNCTION Authentication(cURL, cUser, cPassword)

    LOCAL cService, sp, oHTTP, cBody, _token

    cService = '/v2/security/authenticate'
    cURL = cURL + cService
    sp = CHR(13) + CHR(10)
    IF NOT ValidarURL(cURL)
        RETURN "Error: la URL debe iniciar con https://"
    ENDIF
    TRY
        oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
        cBody = '{' + ;
                '"user":"' + cUser + '",' + ;
                '"password":"' + cPassword + '"' + ;
                '}'

        WITH oHTTP
            .open("POST", cURL, .F.)
            .setRequestHeader("Content-Type", "application/json")
        ENDWITH

 
        oHTTP.Send(cBody)

        _token = oHTTP.responseText

    CATCH TO oErr
        _token = "Error, sucediÛ un problema en la funciÛn Authentication" + sp + sp + ;
                 "[  Error: ] " + STR(oErr.ErrorNo) + sp + ;
                 "[  LineNo: ] " + STR(oErr.LineNo) + sp + ;
                 "[  Message: ] " + oErr.Message + sp + ;
                 "[  Procedure: ] " + oErr.Procedure + sp + ;
                 "[  Details: ] " + oErr.Details + sp + ;
                 "[  StackLevel: ] " + STR(oErr.StackLevel) + sp + ;
                 "[  LineContents: ] " + oErr.LineContents
    ENDTRY

    RETURN _token

FUNCTION GetTokenValue(response)
TRY
  jsonResponse = json_decode(response)
  dataValue = jsonResponse.get ('data')
  tokenValue = dataValue.get ('token')
CATCH TO oErr
	sp = CHR(13)+CHR(10)
	tokenValue = "Error, sucedio un problema en la funci√≥n GetTokenValue" + sp + sp + ;
				  "[  Error: ] " + STR(oErr.ErrorNo) + sp + ;
	    		  "[  LineNo: ] " + STR(oErr.LineNo) + sp + ; 
	    		  "[  Message: ] " + oErr.Message + sp + ; 
	    		  "[  Procedure: ] " + oErr.Procedure + sp + ; 
	    		  "[  Details: ] " + oErr.Details + sp + ; 
	    		  "[  StackLevel: ] " + STR(oErr.StackLevel) + sp + ; 
	    		  "[  LineContents: ] " + oErr.LineContents
ENDTRY
RETURN tokenValue


&&Timbrado
FUNCTION Stamp(cURL, cToken, cXML, cVersion)

	StampVersion = LOWER(cVersion)
	xml =  cXML
	cService = '/cfdi33/stamp/'
	
	sp = CHR(13)+CHR(10)
	_bound = "AaB03x"
    sUrl = cURL + cService + cVersion 
    body = '--' + _bound + sp + 'Content-Disposition: form-data; name=xml; filename=xml' + sp + 'Content-Transfer-Encoding: binary'+ sp+sp+xml+sp +'--'+ _bound + '--' + sp
    IF NOT ValidarURL(cURL)
        RETURN "Error: la URL debe iniciar con https://"
    ENDIF
  	TRY  
	    oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
		
		WITH oHTTP
			 .open ("POST", sUrl, .F.)
			 .setRequestHeader ('Authorization', 'bearer '+ cToken)
			 .setRequestHeader ('Content-Type', 'multipart/form-data; boundary=' + _bound)
			 .setRequestHeader ('Content-Length', Len(body))
			 .send (body)
		ENDWITH
		
		StampV = oHTTP.responseText
	
  	CATCH TO oErr
	   
		 StampV = "Error, sucedio un problema en la funci√≥n Stamp" + sp + sp + ;
				  "[  Error: ] " + STR(oErr.ErrorNo) + sp + ;
	    		  "[  LineNo: ] " + STR(oErr.LineNo) + sp + ; 
	    		  "[  Message: ] " + oErr.Message + sp + ; 
	    		  "[  Procedure: ] " + oErr.Procedure + sp + ; 
	    		  "[  Details: ] " + oErr.Details + sp + ; 
	    		  "[  StackLevel: ] " + STR(oErr.StackLevel) + sp + ; 
	    		  "[  LineContents: ] " + oErr.LineContents

  	ENDTRY	
	
RETURN StampV


&&TimbradoRetencion (REST)
FUNCTION StampRet(cURL, cToken, cXML)
    LOCAL sUrl, sp, _bound, body, oHTTP, StampRetV

    sp = CHR(13)+CHR(10)
    _bound = "AaB03x" 
    sUrl = cURL + "/retencion/stamp/v3"

    body = "--" + _bound + sp + ;
           "Content-Disposition: form-data; name=xml; filename=xml" + sp + ;
           "Content-Transfer-Encoding: binary" + sp + sp + ;
           cXML + sp + ;
           "--" + _bound + "--" + sp

    IF NOT ValidarURL(cURL)
        RETURN "Error: la URL debe iniciar con https://"
    ENDIF
    
    TRY
        oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")

        WITH oHTTP
            .open("POST", sUrl, .F.)
            .setRequestHeader("Authorization", "bearer " + cToken)
            .setRequestHeader("Content-Type", "multipart/form-data; boundary=" + _bound)
            .setRequestHeader("Content-Length", LEN(body))
            .send(body)
        ENDWITH

        StampRetV = oHTTP.responseText

    CATCH TO oErr
        StampRetV = "Error, sucediÛ un problema en la funciÛn StampRetV3" + sp + sp + ;
                    "[  Error: ] " + STR(oErr.ErrorNo) + sp + ;
                    "[  LineNo: ] " + STR(oErr.LineNo) + sp + ;
                    "[  Message: ] " + oErr.Message + sp + ;
                    "[  Procedure: ] " + oErr.Procedure + sp + ;
                    "[  Details: ] " + oErr.Details + sp + ;
                    "[  StackLevel: ] " + STR(oErr.StackLevel) + sp + ;
                    "[  LineContents: ] " + oErr.LineContents
    ENDTRY

    RETURN StampRetV
    
   &&Emision-Timbrado
FUNCTION Issue(cURL, cToken, cXML, cVersion)

	StampVersion = LOWER(cVersion)
	xml =  cXML
	cService = '/cfdi33/issue/'
	
	sp = CHR(13)+CHR(10)
	_bound = "AaB03x"
    sUrl = cURL + cService + cVersion 
    body = '--' + _bound + sp + 'Content-Disposition: form-data; name=xml; filename=xml' + sp + 'Content-Transfer-Encoding: binary'+ sp+sp+xml+sp +'--'+ _bound + '--' + sp

    IF NOT ValidarURL(cURL)
        RETURN "Error: la URL debe iniciar con https://"
    ENDIF
    
  	TRY  
		oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
		
		WITH oHTTP
			 .open ("POST", sUrl, .F.)
			 .setRequestHeader ('Authorization', 'bearer '+ cToken)
			 .setRequestHeader ('Content-Type', 'multipart/form-data; boundary=' + _bound)
			 .setRequestHeader ('Content-Length', Len(body))
			 .send (body)
		ENDWITH

		_Issue = oHTTP.responseText
		
  	CATCH TO oErr
	   
		 _Issue= "Error, sucedio un problema en la funci√≥n Issue" + sp + sp + ;
				  "[  Error: ] " + STR(oErr.ErrorNo) + sp + ;
	    		  "[  LineNo: ] " + STR(oErr.LineNo) + sp + ; 
	    		  "[  Message: ] " + oErr.Message + sp + ; 
	    		  "[  Procedure: ] " + oErr.Procedure + sp + ; 
	    		  "[  Details: ] " + oErr.Details + sp + ; 
	    		  "[  StackLevel: ] " + STR(oErr.StackLevel) + sp + ; 
	    		  "[  LineContents: ] " + oErr.LineContents

  	ENDTRY	
	
RETURN _Issue

&&Validacion de XML
FUNCTION ValidateXML(cURL, cToken, cXML)

	xml =  cXML
	cService = '/validate/cfdi'
	
	sp = CHR(13)+CHR(10)
	_bound = "AaB03x"
    sUrl = cURL + cService 
    body = '--' + _bound + sp + 'Content-Disposition: form-data; name=xml; filename=xml' + sp + 'Content-Transfer-Encoding: binary'+ sp+sp+xml+sp +'--'+ _bound + '--' + sp

    IF NOT ValidarURL(cURL)
        RETURN "Error: la URL debe iniciar con https://"
    ENDIF
    
  	TRY  
		oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
		
		WITH oHTTP
			 .open ("POST", sUrl, .F.)
			 .setRequestHeader ('Authorization', 'bearer '+ cToken)
			 .setRequestHeader ('Content-Type', 'multipart/form-data; boundary=' + _bound)
			 .setRequestHeader ('Content-Length', Len(body))
			 .send (body)
		ENDWITH
		
		_Validate = oHTTP.responseText
	
  	CATCH TO oErr
	   
		_Validate = "Error, sucedio un problema en la funci√≥n ValidateXML" + sp + sp + ;
				  "[  Error: ] " + STR(oErr.ErrorNo) + sp + ;
	    		  "[  LineNo: ] " + STR(oErr.LineNo) + sp + ; 
	    		  "[  Message: ] " + oErr.Message + sp + ; 
	    		  "[  Procedure: ] " + oErr.Procedure + sp + ; 
	    		  "[  Details: ] " + oErr.Details + sp + ; 
	    		  "[  StackLevel: ] " + STR(oErr.StackLevel) + sp + ; 
	    		  "[  LineContents: ] " + oErr.LineContents

  	ENDTRY	
	
RETURN _Validate 
 

****** METODOS DE CANCELACION *******    
&&CancelationByCSD
FUNCTION CancelationByCSD(cURL, cToken, cUUID, cCer, cKey, cRFC, cPassword, motivo, fosustitucion)

	sVersion = '/cfdi33/cancel/csd/'
	sURL = cURL + sVersion
	sp = CHR(13)+CHR(10)
	   
	body = ''
	
		body = 		'{'
    	body = body + 	'"uuid": "' + cUUID + '", ' 
		body = body + 	'"password": "' + cPassword + '", ' 
 		body = body + 	'"rfc": "' + cRFC + '", '
 		body = body + 	'"motivo": "' + motivo + '", ' 
 		body = body + 	'"foliosustitucion": "' + fosustitucion + '", '  
 		body = body + 	'"b64Cer": "' + cCer + '", ' 
 		body = body + 	'"b64Key": "' + cKey + '"' 
 		body = body + '}'   

    IF NOT ValidarURL(cURL)
        RETURN "Error: la URL debe iniciar con https://"
    ENDIF
     
	TRY 
	 	oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
	 
		WITH oHTTP
		 	.open ("POST", sUrl, .F.) 
		 	.setRequestHeader ('Authorization', 'bearer '+ cToken) 
			.setRequestHeader ('Content-Type',  'application/json') 
			.send (body)
		ENDWITH
		_Cancelation = oHTTP.responseText 
	 
	 CATCH TO oErr
	   
	   _Cancelation = "Error, sucedio un problema en la funci√≥n CancelationByCSD" + sp + sp + ;
					  "[  Error: ] " + STR(oErr.ErrorNo) + sp + ;
		    		  "[  LineNo: ] " + STR(oErr.LineNo) + sp + ; 
		    		  "[  Message: ] " + oErr.Message + sp + ; 
		    		  "[  Procedure: ] " + oErr.Procedure + sp + ; 
		    		  "[  Details: ] " + oErr.Details + sp + ; 
		    		  "[  StackLevel: ] " + STR(oErr.StackLevel) + sp + ; 
		    		  "[  LineContents: ] " + oErr.LineContents

	ENDTRY
	
RETURN _Cancelation



&&CancelationByXML
FUNCTION CancelationByXML(cURL, cToken, cXML)

	sVersion = '/cfdi33/cancel/xml'
	sURL = cURL + sVersion
	sp = CHR(13)+CHR(10)
	_bound = '----WebKitFormBoundary7MA4YWxkTrZu0gW'   
	   
	 body = '--' + _bound + sp + 'Content-Disposition: form-data; name=xml; filename=xml' + sp + 'Content-Transfer-Encoding: binary'+ sp+sp+cXML+sp +'--'+ _bound + '--' + sp

    IF NOT ValidarURL(cURL)
        RETURN "Error: la URL debe iniciar con https://"
    ENDIF
	
	TRY 
	 	oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")   
	 
		WITH oHTTP
		 	.open ("POST", sUrl, .F.) 
		 	.setRequestHeader ('Authorization', 'bearer '+ cToken) 
			.setRequestHeader ('Content-Type',  'multipart/form-data; boundary=' + _bound ) 
			.send (body)
		ENDWITH
		_Cancelation = oHTTP.responseText 
	 
	 CATCH TO oErr
	   
	   _Cancelation = "Error, sucedio un problema en la funci√≥n CancelationByXML" + sp + sp + ;
					  "[  Error: ] " + STR(oErr.ErrorNo) + sp + ;
		    		  "[  LineNo: ] " + STR(oErr.LineNo) + sp + ; 
		    		  "[  Message: ] " + oErr.Message + sp + ; 
		    		  "[  Procedure: ] " + oErr.Procedure + sp + ; 
		    		  "[  Details: ] " + oErr.Details + sp + ; 
		    		  "[  StackLevel: ] " + STR(oErr.StackLevel) + sp + ; 
		    		  "[  LineContents: ] " + oErr.LineContents

	ENDTRY
	
RETURN _Cancelation 

&&CancelationByPFX
FUNCTION CancelationByPFX(cURL, cToken, cUUID, cPFX, cRFC, cPassword, motivo, fosustitucion)

	sVersion = '/cfdi33/cancel/pfx'
	sURL = cURL + sVersion
	sp = CHR(13)+CHR(10)
	     
	body = ''
	
		body = 		'{'
    	body = body + 	'"uuid": "' + cUUID + '", ' 
		body = body + 	'"password": "' + cPassword + '", ' 
 		body = body + 	'"rfc": "' + cRFC + '", '
 		body = body + 	'"motivo": "' + motivo + '", ' 
 		body = body + 	'"foliosustitucion": "' + fosustitucion + '", '  
 		body = body + 	'"b64Pfx": "' + cPFX + '"' 
 		body = body + '}'   

    IF NOT ValidarURL(cURL)
        RETURN "Error: la URL debe iniciar con https://"
    ENDIF
	 
	TRY 
	 	oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
	 
		WITH oHTTP
		 	.open ("POST", sUrl, .F.) 
		 	.setRequestHeader ('Authorization', 'bearer '+ cToken) 
			.setRequestHeader ('Content-Type',  'application/json')
			.send (body)
		ENDWITH
		_Cancelation = oHTTP.responseText 
	 
	 CATCH TO oErr
	   
	   _Cancelation = "Error, sucedio un problema en la funci√≥n CancelationByPFX" + sp + sp + ;
					  "[  Error: ] " + STR(oErr.ErrorNo) + sp + ;
		    		  "[  LineNo: ] " + STR(oErr.LineNo) + sp + ; 
		    		  "[  Message: ] " + oErr.Message + sp + ; 
		    		  "[  Procedure: ] " + oErr.Procedure + sp + ; 
		    		  "[  Details: ] " + oErr.Details + sp + ; 
		    		  "[  StackLevel: ] " + STR(oErr.StackLevel) + sp + ; 
		    		  "[  LineContents: ] " + oErr.LineContents

	ENDTRY
	
RETURN _Cancelation


&&CancelationByUUID
FUNCTION CancelationByUUID(cToken, cURL, cUUID, cRFC, motivo, fosustitucion)

	sVersion = '/cfdi33/cancel/' + cRFC + '/' + cUUID + '/' + motivo
	IF NOT EMPTY(ALLTRIM(fosustitucion))            
	sVersion = sVersion + '/' + ALLTRIM(fosustitucion)    
	ENDIF
	sURL = cURL + sVersion
	sp = CHR(13)+CHR(10)
	
    IF NOT ValidarURL(cURL)
        RETURN "Error: la URL debe iniciar con https://"
    ENDIF
	
	TRY 
	 	oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")  
	 
		WITH oHTTP
		 	.open ("POST", sURL, .F.) 
			.setRequestHeader('Authorization', 'bearer '+ cToken)
			.setRequestHeader('Content-Type', 'application/json')
			.send ()
		ENDWITH
		_Cancelation = oHTTP.responseText 
	 
	 CATCH TO oErr
	   
	   _Cancelation = "Error, sucedio un problema en la funci√≥n CancelationByUUID" + sp + sp + ;
					  "[  Error: ] " + STR(oErr.ErrorNo) + sp + ;
		    		  "[  LineNo: ] " + STR(oErr.LineNo) + sp + ; 
		    		  "[  Message: ] " + oErr.Message + sp + ; 
		    		  "[  Procedure: ] " + oErr.Procedure + sp + ; 
		    		  "[  Details: ] " + oErr.Details + sp + ; 
		    		  "[  StackLevel: ] " + STR(oErr.StackLevel) + sp + ; 
		    		  "[  LineContents: ] " + oErr.LineContents  

	ENDTRY
	
RETURN _Cancelation

************ GESTION DE TIMBRES **************
&& ConsultarBalanceTimbres
FUNCTION ConsultarBalanceTimbres(cURLBase, cToken)
	LOCAL sURL, oHTTP, _Response, sp, sEndpoint
	
	sEndpoint = '/management/v2/api/users/balance'
	sURL = cURLBase + sEndpoint
	sp = CHR(13)+CHR(10)
	_Response = ''

	IF NOT ValidarURL(cURLBase)
		RETURN "Error: la URL debe iniciar con https://"
	ENDIF

	TRY	
	 	oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
	
		WITH oHTTP
		 	.open ("GET", sUrl, .F.) 
		 	.setRequestHeader ('Authorization', 'Bearer '+ cToken)
			.send () 
		ENDWITH
		_Response = oHTTP.responseText
	
	CATCH TO oErr
		_Response = "Error, sucedio un problema en la funciÛn ConsultarBalanceTimbres" + sp + sp + ;
					"[ Error: ] " + STR(oErr.ErrorNo) + sp + ;
					"[ LineNo: ] " + STR(oErr.LineNo) + sp + ;
					"[ Message: ] " + oErr.Message + sp + ;
					"[ Procedure: ] " + oErr.Procedure + sp + ;
					"[ Details: ] " + oErr.Details + sp + ;
					"[ StackLevel: ] " + STR(oErr.StackLevel) + sp + ;
					"[ LineContents: ] " + oErr.LineContents
	ENDTRY
	
RETURN _Response

&& GestionarTimbres (Agregar/Eliminar)
FUNCTION GestionarTimbres(cURLBase, cToken, cMethod, cUUID, nStamps, cComment)
	LOCAL sURL, oHTTP, body, _Response, sp, sVersion
	
	IF UPPER(cMethod) <> "POST" AND UPPER(cMethod) <> "DELETE"
		RETURN "Error: El par·metro cMethod debe ser 'POST' o 'DELETE'."
	ENDIF

	sVersion = '/management/v2/api/dealers/users/' + cUUID + '/stamps'
	sURL = cURLBase + sVersion
	sp = CHR(13)+CHR(10)
	_Response = ''
	
	
	body = '{'
	body = body + '"stamps": ' + TRANSFORM(nStamps) 
	
	IF VARTYPE(cComment) <> 'L' AND NOT EMPTY(cComment) 
		body = body + ', "comment": "' + cComment + '"'
	ENDIF
	
	body = body + '}'
	
	IF NOT ValidarURL(cURLBase)
		RETURN "Error: la URL debe iniciar con https://"
	ENDIF

	TRY	
	 	oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")
	
		WITH oHTTP
		 	.open (cMethod, sUrl, .F.) 
		 	.setRequestHeader ('Authorization', 'Bearer '+ cToken)
			.setRequestHeader ('Content-Type', 'application/json')
			.send (body)
		ENDWITH
		_Response = oHTTP.responseText
	
	CATCH TO oErr
		lcAccion = IIF(UPPER(cMethod) == 'POST', 'Agregar Timbres', 'Eliminar Timbres')
		_Response = "Error, sucedio un problema en la funciÛn " + lcAccion + sp + sp + ;
					"[ Error: ] " + STR(oErr.ErrorNo) + sp + ;
					"[ LineNo: ] " + STR(oErr.LineNo) + sp + ;
					"[ Message: ] " + oErr.Message + sp + ;
					"[ Procedure: ] " + oErr.Procedure + sp + ;
					"[ Details: ] " + oErr.Details + sp + ;
					"[ StackLevel: ] " + STR(oErr.StackLevel) + sp + ;
					"[ LineContents: ] " + oErr.LineContents
	ENDTRY
	
RETURN _Response




******** ADMINISTRACION DE USUARIOS ***********
&& Crear Usuarios
FUNCTION CreateUser(cBaseURL, cToken, cName, cTaxId, cEmail, nStamps, lUnlimited, cPassword, cNotificationEmail, cPhone)
    LOCAL cService, cURL, oHTTP, cBody, cResponse, sp
    sp = CHR(13) + CHR(10)
    cService = "/management/v2/api/dealers/users"
    cURL = cBaseURL + cService

    IF NOT ValidarURL(cURL)
        RETURN "Error: la URL debe iniciar con https://"
    ENDIF

    TRY
        oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")

        cBody = '{' + ;
                 '"name":"' + cName + '",' + ;
                 '"taxId":"' + cTaxId + '",' + ;
                 '"email":"' + cEmail + '",' + ;
                 '"stamps":' + TRANSFORM(nStamps) + ',' + ;
                 '"isUnlimited":' + IIF(lUnlimited, "true", "false") + ',' + ;
                 '"password":"' + cPassword + '"'

        IF NOT EMPTY(cNotificationEmail)
            cBody = cBody + ',"notificationEmail":"' + cNotificationEmail + '"'
        ENDIF
        IF NOT EMPTY(cPhone)
            cBody = cBody + ',"phone":"' + cPhone + '"'
        ENDIF

        cBody = cBody + '}'

        WITH oHTTP
            .open("POST", cURL, .F.)
            .setRequestHeader("Authorization", "Bearer " + cToken)
            .setRequestHeader("Content-Type", "application/json")
            .Send(cBody)
        ENDWITH

        cResponse = oHTTP.responseText

    CATCH TO oErr
        cResponse = "Error en Crear Usuario" + sp + ;
                    "[Error: ] " + STR(oErr.ErrorNo) + sp + ;
                    "[LineNo: ] " + STR(oErr.LineNo) + sp + ;
                    "[Message: ] " + oErr.Message
    ENDTRY

    RETURN cResponse
ENDFUNC

&& Actualizar Usuarios
FUNCTION UpdateUser(cBaseURL, cToken, cUserID, cName, cTaxId, cNotificationEmail, cPhone, lUnlimited)
    LOCAL cService, cURL, oHTTP, cBody, cResponse, sp
    
    sp = CHR(13) + CHR(10)
    
    cService = "/management/v2/api/dealers/users/" + cUserID
    cURL = cBaseURL + cService

    IF NOT ValidarURL(cBaseURL)
        RETURN '{"status":"error", "message":"Error: La URL base debe iniciar con https://"}'
    ENDIF

    TRY
        oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")

        cBody = '{ "iduser": "' + cUserID + '"'
        
        IF VARTYPE(cName) <> 'L' AND NOT EMPTY(cName)
            cBody = cBody + ',"name":"' + cName + '"'
        ENDIF
        
        IF VARTYPE(cTaxId) <> 'L' AND NOT EMPTY(cTaxId)
            cBody = cBody + ',"taxId":"' + cTaxId + '"'
        ENDIF

        IF VARTYPE(cNotificationEmail) <> 'L' AND NOT EMPTY(cNotificationEmail)
            cBody = cBody + ',"notificationEmail":"' + cNotificationEmail + '"'
        ENDIF

        IF VARTYPE(cPhone) <> 'L' AND NOT EMPTY(cPhone)
            cBody = cBody + ',"phone":"' + cPhone + '"'
        ENDIF
        
        IF VARTYPE(lUnlimited) = 'L' 
            cBody = cBody + ',"isUnlimited":' + IIF(lUnlimited, "true", "false")
        ELSE
            lIsUnlimited = IIF(VARTYPE(lUnlimited)='N' AND lUnlimited = 1, .T., .F.)
            cBody = cBody + ',"isUnlimited":' + IIF(lIsUnlimited, "true", "false")
        ENDIF
        

        cBody = cBody + '}'

        WITH oHTTP
            .open("PUT", cURL, .F.)
            .setRequestHeader("Authorization", "Bearer " + cToken)
            .setRequestHeader("Content-Type", "application/json")
            .Send(cBody)
        ENDWITH

        cResponse = oHTTP.responseText
        
        IF oHTTP.status = 200
        ELSE
            IF EMPTY(cResponse)
                 cResponse = '{"status":"error", "message":"Error en la actualizaciÛn. Servidor respondiÛ HTTP ' + TRANSFORM(oHTTP.status) + ' sin contenido."}'
            ENDIF
        ENDIF

    CATCH TO oErr
        cResponse = '{"status":"error", "message":"Error en la funciÛn UpdateUser. ' + ;
                    '[ Error: ] ' + STR(oErr.ErrorNo) + ' | ' + ;
                    '[ Message: ] ' + oErr.Message + '"}'
    ENDTRY

    RETURN cResponse
ENDFUNC


&& Consultar Usuarios
FUNCTION ConsultarUsuarios(cBaseURL, cToken, cFiltroKey, cFiltroValue, nPage, nPerPage)
    LOCAL cService, cURL, oHTTP, cQueryParams, cResponse, sp
    
    sp = CHR(13) + CHR(10)
    cService = "/management/v2/api/dealers/users"
    cURL = cBaseURL + cService
    cQueryParams = ""
    
    IF VARTYPE(cFiltroKey) <> 'L' AND NOT EMPTY(cFiltroKey) AND NOT EMPTY(cFiltroValue)
        cQueryParams = cQueryParams + "?" + cFiltroKey + "=" + cFiltroValue
    ENDIF

    cQueryParams = cQueryParams + IIF(EMPTY(cQueryParams), "?", "&") + "Page=" + TRANSFORM(nPage)

    cQueryParams = cQueryParams + IIF(EMPTY(cQueryParams), "?", "&") + "PerPage=" + TRANSFORM(nPerPage)

    cURL = cURL + cQueryParams
    
    IF NOT ValidarURL(cBaseURL)
        RETURN '{"status":"error", "message":"Error: La URL base debe iniciar con https://"}'
    ENDIF

    TRY
        oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")

        WITH oHTTP
            .open("GET", cURL, .F.)  
            .setRequestHeader("Authorization", "Bearer " + cToken)
            .send()
        ENDWITH

        cResponse = oHTTP.responseText

        IF oHTTP.status <> 200
             cResponse = IIF(EMPTY(cResponse), '{"status":"error", "message":"Error en la consulta. Servidor respondiÛ HTTP ' + TRANSFORM(oHTTP.status) + ' sin contenido."}', cResponse)
        ENDIF

    CATCH TO oErr
        cResponse = '{"status":"error", "message":"Error en la funciÛn ConsultarUsuarios. ' + ;
                    '[ Error: ] ' + STR(oErr.ErrorNo) + ' | ' + ;
                    '[ Message: ] ' + oErr.Message + '"}'
    ENDTRY

    RETURN cResponse
ENDFUNC


&& Eliminar Usuarios
FUNCTION DeleteUser(cBaseURL, cToken, cUUID)
    LOCAL cService, cURL, oHTTP, cResponse, sp, nStatus
    
    sp = CHR(13) + CHR(10)
    
    cService = "/management/v2/api/dealers/users/" + cUUID
    cURL = cBaseURL + cService

    IF NOT ValidarURL(cBaseURL)
        RETURN '{"status":"error", "message":"Error: La URL base debe iniciar con https://"}'
    ENDIF

    TRY
        oHTTP = CreateObject("MSXML2.ServerXMLHTTP.6.0")

        WITH oHTTP
            .open("DELETE", cURL, .F.)
            .setRequestHeader("Authorization", "Bearer " + cToken)
            .send()
        ENDWITH

  
        nStatus = oHTTP.status
        cResponse = oHTTP.responseText

        * Manejo del CÛdigo 204 (No Content)
        IF nStatus = 204
            cResponse = '{"status":"success", "message":"Usuario ' + cUUID + ' eliminado correctamente (HTTP 204 No Content)."}'
        ELSE
            IF EMPTY(cResponse)
                 cResponse = '{"status":"error", "message":"Error en la eliminaciÛn. Servidor respondiÛ HTTP ' + TRANSFORM(nStatus) + ' sin contenido."}'
            ENDIF
        ENDIF

    CATCH TO oErr
        cResponse = '{"status":"error", "message":"Error en la funciÛn DeleteUser. ' + ;
                    '[ Error: ] ' + STR(oErr.ErrorNo) + ' | ' + ;
                    '[ Message: ] ' + oErr.Message + '"}'
    ENDTRY

    RETURN cResponse
ENDFUNC

&& Metodo para que solo acepte el protocolo HTTPS
FUNCTION ValidarURL(cURL)
    LOCAL lEsHttps
    lEsHttps = (UPPER(LEFT(ALLTRIM(cURL), 8)) == "HTTPS://")
    RETURN lEsHttps
ENDFUNC


************************************************************************************************
*																							   *
*			JSON Library																	   *
*																							   *
************************************************************************************************

lRunTest = .t.
if lRunTest
	testJsonClass()
endif
return


function json_encode(xExpr)
	if vartype(_json)<>'O'
		public _json
		_json = newobject('json')
	endif
return _json.encode(@xExpr)


function json_decode(cJson)
local retval
	if vartype(_json)<>'O'
		public _json
		_json = newobject('json')
	endif
	retval = _json.decode(cJson)
	if not empty(_json.cError)
		return null
	endif
return retval

function json_getErrorMsg()
return _json.cError


*
* recordToJson()
*
* Returns the json representation for current record
* Try it:
* 		use c:\mydir\mytable
*		cInfo = recordToJson()
*		? cInfo
*
function recordToJson
local nRecno,i,oObj, cRetVal
	if alias()==''
		return ''
	endif
	oObj = newObject('myObj')
	for i=1 to fcount()
		oObj.set(Field(i),eval(Field(i)))
	next
	cRetVal = json_encode(oObj)
	if not empty(json_getErrorMsg())
		cRetVal = 'ERROR:'+json_getErrorMsg()
	endif
return cRetVal




*
* tableToJson()
*
* Returns the json representation for current table
* Warning need to be changed for large table, because use dimension aInfo[reccount()]
* For large table should change to create the string record by record.
*
* Try it:
* 		use c:\mydir\mytable
*		cInfo = tableToJson()
*		? cInfo
*		_cliptext = strtran(cInfo, ',{"', ','+chr(13)+'{"')
*		Go to Any Editor and Paste the information
*
function tableToJson
local nRecno,i,oObj, cRetVal,nRec
	if alias()==''
		return ''
	endif
	nRecno = recno()
	nRec = 1
	dimension aInfo[1]
	scan		
		oObj = newObject('myObj')
		for i=1 to fcount()
			oObj.set(Field(i),eval(Field(i)))
		next
		dimension aInfo[nRec]
		aInfo[nRec] = oObj
		nRec = nRec+1
	endscan
	goto nRecno
	cRetVal = json_encode(@aInfo)
	if not empty(json_getErrorMsg())
		cRetVal = 'ERROR:'+json_getErrorMsg()
	endif
return cRetVal





*
* json class
*
*
define class json as custom


	nPos=0
	nLen=0
	cJson=''
	cError=''


	*
	* Genera el codigo cJson para parametro que se manda
	*
	function encode(xExpr)
	local cTipo
		* Cuando se manda una arreglo, 
		if type('ALen(xExpr)')=='N'
			cTipo = 'A'
		Else
			cTipo = VarType(xExpr)
		Endif
		
		Do Case
		Case cTipo=='D'
			return '"'+dtos(xExpr)+'"'
		Case cTipo=='N'	
			return Transform(xExpr)
		Case cTipo=='L'	
			return iif(xExpr,'true','false')
		Case cTipo=='X'	
			return 'null'
		Case cTipo=='C'
			xExpr = allt(xExpr)
			xExpr = StrTran(xExpr, '\', '\\' )
			xExpr = StrTran(xExpr, '/', '\/' )
			xExpr = StrTran(xExpr, Chr(9),  '\t' )
			xExpr = StrTran(xExpr, Chr(10), '\n' )
			xExpr = StrTran(xExpr, Chr(13), '\r' )
			xExpr = StrTran(xExpr, '"', '\"' )
			return '"'+xExpr+'"'

		case cTipo=='O'
			local cProp, cJsonValue, cRetVal, aProp[1]
			=AMembers(aProp,xExpr)
			cRetVal = ''
			for each cProp in aProp
				*?? cProp,','
				*? cRetVal
				if type('xExpr.'+cProp)=='U' or cProp=='CLASS'
					* algunas propiedades pueden no estar definidas
					* como: activecontrol, parent, etc
					loop
				endif
				if type( 'ALen(xExpr.'+cProp+')' ) == 'N'
					*
					* es un arreglo, recorrerlo usando los [ ] y macro 
					*
					Local i,nTotElem
					cJsonValue = ''
					nTotElem = Eval('ALen(xExpr.'+cProp+')')
					For i=1 to nTotElem
						cmd = 'cJsonValue=cJsonValue+","+ this.encode( xExpr.'+cProp+'[i])'
						&cmd.
					Next
					cJsonValue = '[' + substr(cJsonValue,2) + ']'
				else
					*
					* es otro tipo de dato normal C, N, L
					*
					cJsonValue = this.encode( evaluate( 'xExpr.'+cProp ) )				
				endif
				if left(cProp,1)=='_'
					cProp = substr(cProp,2)
				endif
				cRetVal = cRetVal + ',' + '"' + lower(cProp) + '":' + cJsonValue
			next
			return '{' + substr(cRetVal,2) + '}'

		case cTipo=='A'
			local valor, cRetVal
			cRetVal = ''	
			for each valor in xExpr
				cRetVal = cRetVal + ',' +  this.encode( valor )
			next
			return  '[' + substr(cRetVal,2) + ']'
			
		endcase

	return ''





	*
	* regresa un elemento representado por la cadena json que se manda
	*
	
	function decode(cJson)
	local retValue
		cJson = StrTran(cJson,chr(9),'')
		cJson = StrTran(cJson,chr(10),'')
		cJson = StrTran(cJson,chr(13),'')
		cJson = this.fixUnicode(cJson)
		this.nPos  = 1
		this.cJson = cJson
		this.nLen  = len(cJson)
		this.cError = ''
		retValue = this.parsevalue()
		if not empty(this.cError)
			return null
		endif
		if this.getToken()<>null
			this.setError('Junk at the end of JSON input')
			return null
		endif
	return retValue
		
	
	function parseValue()
	local token
		token = this.getToken()
		if token==null
			this.setError('Nothing to parse')
			return null
		endif
		do case
		case token=='"'
			return this.parseString()
		case isdigit(token) or token=='-'
			return this.parseNumber()
		case token=='n'
			return this.expectedKeyword('null',null)
		case token=='f'
			return this.expectedKeyword('false',.f.)
		case token=='t'
			return this.expectedKeyword('true',.t.)
		case token=='{'
			return this.parseObject()
		case token=='['
			return this.parseArray()
		otherwise
			this.setError('Unexpected token')
		endcase
	return
		
	
	function expectedKeyword(cWord,eValue)
		for i=1 to len(cWord)
			cChar = this.getChar()
			if cChar <> substr(cWord,i,1)
				this.setError("Expected keyword '" + cWord + "'")
				return ''
			endif
			this.nPos = this.nPos + 1
		next
	return eValue
	

	function parseObject()
	local retval, cPropName, xValue
		retval = createObject('myObj')
		this.nPos = this.nPos + 1 && Eat {
		if this.getToken()<>'}'
			do while .t.
				cPropName = this.parseString()
				if not empty(this.cError)
					return null
				endif
				if this.getToken()<>':'
					this.setError("Expected ':' when parsing object")
					return null
				endif
				this.nPos = this.nPos + 1
				xValue = this.parseValue()
				if not empty(this.cError)
					return null
				endif				
				** Debug ? cPropName, type('xValue')
				retval.set(cPropName, xValue)
				if this.getToken()<>','
					exit
				endif
				this.nPos = this.nPos + 1
			enddo
		endif
		if this.getToken()<>'}'
			this.setError("Expected '}' at the end of object")
			return null
		endif
		this.nPos = this.nPos + 1
	return retval


	function parseArray()
	local retVal, xValue
		retval = createObject('MyArray')
		this.nPos = this.nPos + 1	&& Eat [
		if this.getToken() <> ']'
			do while .t.
				xValue = this.parseValue()
				if not empty(this.cError)
					return null
				endif
				retval.add( xValue )
				if this.getToken()<>','
					exit
				endif
				this.nPos = this.nPos + 1
			enddo
			if this.getToken() <> ']'
				this.setError('Expected ] at the end of array')
				return null
			endif
		endif
		this.nPos = this.nPos + 1
	return retval
	

	function parseString()
	local cRetVal, c
		if this.getToken()<>'"'
			this.setError('Expected "')
			return ''
		endif
		this.nPos = this.nPos + 1 	&& Eat "
		cRetVal = ''
		do while .t.
			c = this.getChar()
			if c==''
				return ''
			endif
			if c == '"'
				this.nPos = this.nPos + 1
				exit
			endif
			if c == '\'
				this.nPos = this.nPos + 1
				if (this.nPos>this.nLen)
					this.setError('\\ at the end of input')
					return ''
				endif
				c = this.getChar()
				if c==''
					return ''
				endif
				do case
				case c=='"'
					c='"'
				case c=='\'
					c='\'
				case c=='/'
					c='/'
				case c=='b'
					c=chr(8)
				case c=='t'
					c=chr(9)
				case c=='n'
					c=chr(10)
				case c=='f'
					c=chr(12)
				case c=='r'
					c=chr(13)
				otherwise
					******* FALTAN LOS UNICODE
					this.setError('Invalid escape sequence in string literal')
					return ''
				endcase
			endif
			cRetVal = cRetVal + c
			this.nPos = this.nPos + 1
		enddo
	return cRetVal
					

	**** Pendiente numeros con E
	function parseNumber()
	local nStartPos,c, isInt, cNumero
		if not ( isdigit(this.getToken()) or this.getToken()=='-')
			this.setError('Expected number literal')
			return 0
		endif
		nStartPos = this.nPos
		c = this.getChar()
		if c == '-'
			c = this.nextChar()
		endif
		if c == '0'
			c = this.nextChar()
		else
			if isdigit(c)
				c = this.nextChar()
				do while isdigit(c)
					c = this.nextChar()
				enddo
			else
				this.setError('Expected digit when parsing number')
				return 0
			endif
		endif
		
		isInt = .t.
		if c=='.'
			c = this.nextChar()
			if isdigit(c)
				c = this.nextChar()
				isInt = .f.
				do while isDigit(c)
					c = this.nextChar()
				enddo
			else
				this.setError('Expected digit following dot comma')
				return 0
			endif
		endif
		
		cNumero = substr(this.cJson, nStartPos, this.nPos - nStartPos)
	return val(cNumero)



	function getToken()
	local char1
		do while .t.
			if this.nPos > this.nLen
				return null
			endif
			char1 = substr(this.cJson, this.nPos, 1)
			if char1==' '
				this.nPos = this.nPos + 1
				loop
			endif
			return char1
		enddo
	return
	
		
		
	function getChar()
		if this.nPos > this.nLen
			this.setError('Unexpected end of JSON stream')
			return ''
		endif
	return substr(this.cJson, this.nPos, 1)
	
	function nextChar()
		this.nPos = this.nPos + 1
		if this.nPos > this.nLen
			return ''
		endif
	return substr(this.cJson, this.nPos, 1)
	
	function setError(cMsg)
		this.cError= 'ERROR parsing JSON at Position:'+allt(str(this.nPos,6,0))+' '+cMsg
	return 
	
	function getError()
	return this.cError


	function fixUnicode(cStr)
		cStr = StrTran(cStr,'\u00e1','√°')
		cStr = StrTran(cStr,'\u00e9','√©')
		cStr = StrTran(cStr,'\u00ed','√≠')
		cStr = StrTran(cStr,'\u00f3','√≥')
		cStr = StrTran(cStr,'\u00fa','√∫')
		cStr = StrTran(cStr,'\u00c1','√Å')
		cStr = StrTran(cStr,'\u00c9','√â')
		cStr = StrTran(cStr,'\u00cd','√ç')
		cStr = StrTran(cStr,'\u00d3','√ì')
		cStr = StrTran(cStr,'\u00da','√ö')
		cStr = StrTran(cStr,'\u00f1','√±')
		cStr = StrTran(cStr,'\u00d1','√ë')
	return cStr



enddefine





* 
* class used to return an array
*
define class myArray as custom
	nSize = 0
	dimension array[1]

	function add(xExpr)
		this.nSize = this.nSize + 1
		dimension this.array[this.nSize]
		this.array[this.nSize] = xExpr
	return

	function get(n)
	return this.array[n]

	function getsize()
	return this.nSize

enddefine



*
* class used to simulate an object
* all properties are prefixed with 'prop' to permit property names like: error, init
* that already exists like vfp methods
*
define class myObj as custom
Hidden ;
	ClassLibrary,Comment, ;
	BaseClass,ControlCount, ;
	Controls,Objects,Object,;
	Height,HelpContextID,Left,Name, ;
	Parent,ParentClass,Picture, ;
	Tag,Top,WhatsThisHelpID,Width
		
	function set(cPropName, xValue)
		cPropName = '_'+cPropName
		do case
		case type('ALen(xValue)')=='N'
			* es un arreglo
			local nLen,cmd,i
			this.addProperty(cPropName+'(1)')
			nLen = alen(xValue)
			cmd = 'Dimension This.'+cPropName+ ' [ '+Str(nLen,10,0)+']'
			&cmd.
			for i=1 to nLen
				cmd = 'This.'+cPropName+ ' [ '+Str(i,10,0)+'] = xValue[i]' 
				&cmd.
			next
			
		case type('this.'+cPropName)=='U'
			* la propiedad no existe, definirla
			this.addProperty(StrTran(cPropName, '-', '_' ),@xValue)
			
		otherwise
			* actualizar la propiedad
			local cmd
			cmd = 'this.'+cPropName+'=xValue'
			&cmd
		endcase
	return
	
	procedure get (cPropName)
		cPropName = '_'+cPropName
		If type('this.'+cPropName)=='U'
			return ''
		Else
			local cmd
			cmd = 'return this.'+cPropName
			&cmd
		endif
	return ''

enddefine





