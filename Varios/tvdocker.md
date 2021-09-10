# <b>Instalación de TVheadend en Docker Synology </B>
El primer paso es crear las carpetas que serán mapeadas
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/d0.jpg)

Buscamos la imagen de tvheadend de linuxserver
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/d1.jpg)

Damos doble clic sobre la imagen y descargamos la última versión
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/d2.jpg)

Esperamos a que se descargue y aparezca en nuestras imágenes descargadas
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/d3.jpg)

Damos doble clic, cambiamos el nombre del contendor y le damos a Configuración Avanzada
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/d4.jpg)

Lo dejamos como en la captura
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/d5.jpg)

Agregamos carpetas y lo dejamos como en la captura
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/d6.jpg)

Utilizamos la misma red que el host
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/d7.jpg)

Pinchamos en el + , añadimos la variable TZ Europe/Madrid y le damos a aplicar
(Opcional: para que no nos marque errores de permisos el log de tvheadend, también hay que añadir el PGID 101 y el PUID, éste último se obtiene entrando por terminal a nuestro synology y poniendo el comando id)
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/d8.jpg)

Siguiente
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/d9.jpg)

Y Aplicar. Ya tenemos nuestro contendedor de tvheadend corriendo
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/d10.jpg)
