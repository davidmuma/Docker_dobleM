<p align="center">
  <a href="https://github.com/davidmuma/EPG_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
  <a href="https://github.com/davidmuma/Canales_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
  <a href="https://github.com/davidmuma/Docker_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
</p>

<h2 align="center">
  Grupo de telegram: <a href="https://tttttt.me/EPG_dobleM">dobleM</a>
</h2>

Nuevo script para docker, funciones especiales respecto al anterior script:

Todo se hace desde el propio contenedor, por lo que funciona independientemente del sistema anfitrión que se use

Ahora las listas de canales se actualizan solas cada vez que se detecta que hay una versión nueva

Solución al problema del borrado del grabber cuando se actualiza la imagen del contenedor 

El script se auto actualiza si detecta que hay una versión más reciente 

### Novedad de la versión 33, nuevo fichero dobleMconfig.ini, con la posibilidad de añadir listas IPTV personales a tvheadend ###

***
- <a href="https://kinolien.github.io/gitzip/?download=https://github.com/davidmuma/Docker_dobleM/blob/main/files/dobleMconfig.ini">dobleMconfig.ini</a>
- <a href="https://kinolien.github.io/gitzip/?download=https://github.com/davidmuma/Docker_dobleM/blob/main/files/dobleMdocker.sh">dobleMdocker.sh</a>
- <a href="https://kinolien.github.io/gitzip/?download=https://github.com/davidmuma/Docker_dobleM/blob/main/files/dobleMcron.sh">dobleMcron.sh</a>
***
NOTA:
<a href="https://www.linuxserver.io/blog/2019-09-14-customizing-our-containers">linuxserver</a>
a cambiado la forma de usar scritps personalizados, ahora la carpeta custom-cont-init.d ya no está en /config y hay que mapearla como una carpeta normal
Ejemplo: /home/tvheadend/scripts:/custom-services.d
***
Instalación:
1. Descarga los tres ficheros
2. Modifica el fichero dobleMconfig.ini con tu configuración y guardalo
3. Copia los tres ficheros a la carpeta mapeada (ejemplo: /home/tvheadend/scripts)
4. Reinicia el contenedor
5. Configura tus adaptadores en tvheadend y asigna "Red DVB-S" (este paso solo hay que realizarlo la primera vez)
***
Script automatizado de instalación y actualización de Streamlink (gracias cgomesu) para poder usar las listas de TDTChannels y Pluto, copiar en la carpeta /config/custom-cont-init.d:
- <a href="https://kinolien.github.io/gitzip/?download=https://github.com/davidmuma/Docker_dobleM/blob/main/files/streamlink_for_tvh_container.sh">streamlink_for_tvh_container.sh</a>
***

Tutorial contenedores docker en Synology:
- <a href="https://github.com/davidmuma/Docker_dobleM/blob/main/Varios/tvdocker.md">tvheadend</a>
- <a href="https://github.com/davidmuma/Docker_dobleM/blob/main/Varios/osdocker.md">oscam</a>
- <a href="https://github.com/davidmuma/Docker_dobleM/blob/main/Varios/ostv.md">vincular oscam + tvheadend</a>
- <a href="https://github.com/davidmuma/Docker_dobleM/blob/main/Varios/andocker.md">antennas</a>
#
<a href="https://www.paypal.me/EPGdobleM"><img src="http://www.webgrabplus.com/sites/default/files/styles/thumbnail/public/badges/donation.png" style="height: auto !important;width: auto !important;" ></a>  
Si te gusta mi trabajo, apóyame con una pequeña donación.
