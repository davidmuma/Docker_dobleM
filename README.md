<p align="center">
  <a href="https://github.com/davidmuma/EPG_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/EPG_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
  <a href="https://github.com/davidmuma/Canales_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
  <a href="https://github.com/davidmuma/Docker_dobleM"> <img src="https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/logo_dobleM.png" width="30%" height="30%"> </a>
</p>

<h2 align="center">
  Grupo de telegram: <a href="https://tttttt.me/EPG_dobleM">dobleM</a>
</h2>

Script especial para docker con lista de canales auto actualizable y solución al problema del borrado del grabber al actualizar la imagen del contenedor 

Versión del script: 1.2  (de momento solo funciona para instalar los canales satélite, pronto estará para los IPTV)
- <a href="https://kinolien.github.io/gitzip/?download=https://github.com/davidmuma/Docker_dobleM/blob/main/files/dobleMconfig.ini">dobleMconfig.ini</a>
- <a href="https://kinolien.github.io/gitzip/?download=https://github.com/davidmuma/Docker_dobleM/blob/main/files/dobleMdocker.sh">dobleMdocker.sh</a>
- <a href="https://kinolien.github.io/gitzip/?download=https://github.com/davidmuma/Docker_dobleM/blob/main/files/dobleMcron.sh">dobleMcron.sh</a>

Instalación: (Recomiendo hacer la instalación en un contenedor nuevo)
1. Descarga los tres ficheros
2. Modifica el fichero dobleMconfig.ini con tu configuración y guardalo
3. Copia los tres ficheros al directorio /config/custom-cont-init.d del propio contenedor
4. Reinicia el contenedor
5. Configura tus adaptadores en tvheadend y asigna la Red DVB-S (este paso solo hay que hacerlo la primera vez)
```
```
Tutorial contenedores docker en Synology:
- <a href="https://github.com/davidmuma/Docker_dobleM/blob/main/Varios/tvdocker.md">tvheadend</a>
- <a href="https://github.com/davidmuma/Docker_dobleM/blob/main/Varios/osdocker.md">oscam</a>
- <a href="https://github.com/davidmuma/Docker_dobleM/blob/main/Varios/ostv.md">vincular oscam + tvheadend</a>
