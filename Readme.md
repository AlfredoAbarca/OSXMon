# MACMon

## Monitoreo de Eventos en MAC para realizar ThreatHunting. 

**MACMon** nace de la necesidad de monitorear los eventos que suceden en un equipo con sistema Operativo OS X para detectar amenazas tanto de usuarios malintencionados como de aquellas piezas de malware diseñadas para evadir los controles tradicionales de seguridad (AV, Control de Aplicaciones, etc...) 

Antes de entrar en los detalles técnicos y alcance de la herramienta quiero agradecer a **Jonathan Levin**, ya que sin su aplicación [Supraudit](http://newosxbook.com/tools/supraudit.html) este proyecto no hubiera sido posible, si tienen alguna duda, comentario, u observación de esta gran aplicación no duden en contactarlo a través de su foro en su sitio web [NewOSXBook](http://newosxbook.com/forum/index.php).

 # ¿ThreatHunting.... qué es?
 Sin entrar en tanto detalle el **ThreatHunting** es, como su nombre lo indica, la búsqueda de amenazas en un equipo de computo o servidor a través de la obervación de la actividad que se sucita en un determinado momento.  

Hay muchas herramientas hoy en día que nos ayudan a este tipo de actividades como los sandboxes o analizadores de malware, los honeypots, entre otras.... Sin embargo cuando estamos en un escenario empresarial donde tenemos miles de endpoints que proteger y monitorear, esta tarea no se vuelve sencilla.

Para equipos con sistema operativo Windows, existe la herramienta Sysmon, cuya implementación en el entorno empresarial es relativamente sencilla además que hay una buena cantidad de artículos que tratan este tema. 

Sin embargo no pasa lo mismo para equipos con S.O. MAC OS X y Linux, este último lo trataré mas adelante. Y de ahí surge la necesidad de realizar este proyecto. 

## Estructura del ambiente
Básicamente para realizar el monitoreo centralizado de amenazas me apoyé en 2 elementos básicos: 

 * **Supraudit:** 
Una aplicación para volcar los eventos del S.O. en pantalla o en un archivo de texto en la terminal.  Por su diseño, esta aplicación puede mostrar los siguientes eventos: 

	

	 - Conexiones de Red
	 - Todo tipo de operaciones relacionadas con    archivos.   
	 - Todos los procesos en ejecución (con su linea de comandos) ;)
	
* **SIEM:** 
En mi implementación utilice la versión gratuita de [**Splunk**](https://www.splunk.com/en_us/download/splunk-light.html) para la realización de los dashboards y alertas finales, aunque bien, podría utilizar cualquier producto diseñado para este fin. 

Así que lo que verá en este artículo será lo relacionado a este SIEM.

## Requerimientos previos e instaladores.
Para poder ejecutar y comenzar a utilizar este monitoreo recomiendo lo necesario: 

* Descargar la última versión de la herramienta de [Supraudit](http://newosxbook.com/tools/supraudit.html) del sitio oficial del desarrollador. 
* Descargar el [Splunk Universal Forwarder](https://www.splunk.com/es_es/download/universal-forwarder.html) para MAC
* Configurar el Supraudit para auditar los eventos relevantes de acuerdo a las opciones que tiene la misma aplicación y guardar los eventos en un archivo dentro del equipo. 
* Configurar el forwarder para leer estos archivos y enviarlos al SIEM. 

### O

>Si ud. no está familiarizado con este sistema operativo no se preocupe, en [**mi repositorio**](https://github.com/AlfredoAbarca/OSXMon) de GitHub encontrará un instalador que realizará estas tareas por Ud. 

**NOTA IMPORTANTE:** Si decide utilizar mi script de instalación es importante que considere que debe desactivar previamente la función de [**System Integrity Protection**](https://www.macworld.co.uk/how-to/mac/how-turn-off-mac-os-x-system-integrity-protection-rootless-3638975/) de Apple, puesto que almaceno el ejecutable de Supraudit en la carpeta de /bin para evitar un posible tampering de este archivo posterior a su configuración, tras concluir la instalación puede activarlo nuevamente. 


