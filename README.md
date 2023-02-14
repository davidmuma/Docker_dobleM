<p align="center">
  <a href="https://github.com/davidmuma/EPG_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
  <a href="https://github.com/davidmuma/Canales_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
  <a href="https://github.com/davidmuma/Docker_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
</p>

<h2 align="center">
  Grupo de telegram: <a href="https://tttttt.me/EPG_dobleM">dobleM</a>
</h2>

Nuevo script para docker, funciones especiales respecto al anterior script:

- Todo se hace desde el propio contenedor, por lo que funciona independientemente del sistema anfitrión que se use
- Ahora las listas de canales se actualizan solas cada vez que se detecta que hay una versión nueva
- Solución al problema del borrado del grabber cuando se actualiza la imagen del contenedor
- Novedad de la versión 33: nuevo fichero dobleMconfig.ini, con la posibilidad de añadir listas IPTV personales a tvheadend
- Novedad de la versión 35: modificado el script y el dobleMconfig.ini para poder usar los nuevos picons

***
Instalación:

1- Descarga los tres ficheros

  <a href="https://kinolien.github.io/gitzip/?download=https://github.com/davidmuma/Docker_dobleM/blob/main/files/dobleMconfig.ini">dobleMconfig.ini</a>

  <a href="https://kinolien.github.io/gitzip/?download=https://github.com/davidmuma/Docker_dobleM/blob/main/files/dobleMdocker.sh">dobleMdocker.sh</a>

  <a href="https://kinolien.github.io/gitzip/?download=https://github.com/davidmuma/Docker_dobleM/blob/main/files/dobleMcron.sh">dobleMcron.sh</a>

3- Modifica el fichero dobleMconfig.ini con tus preferencias (usar Notepad++ o similar)

4- Copia los tres ficheros a la carpeta mapeada (ejemplo: /home/tvheadend/scripts)

  NOTA:
  <a href="https://www.linuxserver.io/blog/2019-09-14-customizing-our-containers">linuxserver</a>
  a cambiado la forma de usar scritps personalizados, ahora la carpeta custom-cont-init.d ya no está en /config y hay que mapearla como una carpeta normal (ejemplo: /home/tvheadend/scripts:/custom-cont-init.d)
  
6- Reinicia el contenedor

7- Configura tus adaptadores en tvheadend y asigna "Red DVB-S" (este paso solo hay que realizarlo la primera vez)

***
Script automatizado de instalación y actualización de Streamlink (gracias cgomesu) para poder usar las listas de Pluto (o listas que lo requieran), copiar en la carpeta mapeada (ejemplo: /home/tvheadend/scripts)
- <a href="https://kinolien.github.io/gitzip/?download=https://github.com/davidmuma/Docker_dobleM/blob/main/files/streamlink_for_tvh_container.sh">streamlink_for_tvh_container.sh</a>
***

Tutorial contenedores docker en Synology:
- <a href="https://github.com/davidmuma/Docker_dobleM/blob/main/Varios/tvdocker.md">tvheadend</a>
- <a href="https://github.com/davidmuma/Docker_dobleM/blob/main/Varios/osdocker.md">oscam</a>
- <a href="https://github.com/davidmuma/Docker_dobleM/blob/main/Varios/ostv.md">vincular oscam + tvheadend</a>
- <a href="https://github.com/davidmuma/Docker_dobleM/blob/main/Varios/andocker.md">antennas</a>
#
<a href="https://www.paypal.me/EPGdobleM"><img src="http://www.webgrabplus.com/sites/default/files/styles/thumbnail/public/badges/donation.png" style="height: auto !important;width: auto !important;" ></a>  
Si te gusta mi trabajo puedes invitarme a un café ;-)
