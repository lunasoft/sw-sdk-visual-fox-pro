<p align="center">
    <img src="http://developers.sw.com.mx/wp-content/uploads/2017/05/foxpro-icon.fw_-100x100.png">
</p>
<p align="center">
  <img src="http://sw.com.mx/images/logo.png">
</p>

# Uso de DLL c++ para Visual Foxpro


Pasos Previos
---------

* Para utilizar los servicios de SW con Delphi se debe tener primeramente el fichero DLL correspondiente a **sw-sdk-cpp.dll** y su dependencia **cpprest140d_2_9.dll**

* Este se puede encontrar en el repositorio de github correspondiente al proyecto **sw-sdk-cpp**  https://github.com/lunasoft/sw-sdk-cpp en la carpeta **Build**

* Otra alternativa seria clonar el proyecto y compilarse para generar el fichero DLL

Implementaci&oacute;n
---------
**Obtener Token**
<p align="center">
    <img src="http://developers.sw.com.mx/wp-content/uploads/2017/05/foxpro-one.png">
</p>
```visual foxpro

*Para utilizar los servicios de SW con Visual Foxpro se debe tener primeramente el fichero DLL *correspondiente a "sw-sdk-cpp.dll"
*Este se puede encontrar en el repositorio de github correspondiente al proyecto "sw-sdk-cpp"
*https://github.com/lunasoft/sw-sdk-cpp en la carpeta "Build"
* O en caso contrario se puede clonar el proyecto y compilarse para generar el fichero DLL
*Declaramos los metodos que importaremos de la DLL
*El fichero DLL debe estar en el mismo directorio en donde esta el fichero .exe de la aplicación VFP.
 
 
declare string Authentication in sw-sdk-cpp.dll string url, string _user, string pwd
 
base_url = "http://services.test.sw.com.mx/security/authenticate"
user = "demo"
password = "123456789"
resultado = Authentication (base_url ,user, password)
 
 
MESSAGEBOX(resultado)
```
**Timbrar V1**
<p align="center">
    <img src="http://developers.sw.com.mx/wp-content/uploads/2017/05/foxpro-three.png">
</p>
```visual foxpro
declare string Stamp in sw-sdk-cpp.dll string url, string _user, string pwd, string xml
 
url = thisform.auth.stamp.base_txt.Value
user_s ="demo"
pwd_s = "123456789"
xml_s = "path archivo xml"
 
*Codificamos el contenido del archivo si es necesario con las siguientes lineas de codigo
xml = FILETOSTR(xml_s) &&
xml = STRTRAN(xml,CHR(239)+CHR(187)+CHR(191),'') &&
xml = STRCONV(xml,9)
 
 
resultado = Stamp (url,user_s, pwd_s,xml)
 
 
MESSAGEBOX(resultado)

```


 