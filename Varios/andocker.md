# <b>Instalación de antennas en Docker Synology </B>

Buscamos la imagen de antennas de thejf
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/a2.jpg)

Damos doble clic sobre la imagen y descargamos la última versión
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/a3.jpg)

Esperamos a que se descargue y aparezca en nuestras imágenes descargadas
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/a4.jpg)

Damos doble clic, cambiamos el nombre del contendor y le damos a Configuración Avanzada
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/a5.jpg)

Lo dejamos como en la captura (modifica la ip por la tuya)
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/a6.jpg)

Utilizamos la misma red que el host
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/a7.jpg)

Pinchamos en el + , añadimos la variable TVHEADEND_URL con nuestro usuario, contraseña e ip de tvheadend, también añadimos la variable TUNER_COUNT con el número de sintonizadores, le damos a aplicar
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/a8.jpg)

Siguiente
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/a9.jpg)

Y Aplicar. Ya tenemos nuestro contendedor de antennas corriendo
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/a10.jpg)

Ahora iremos a tvheadend y crearemos el usuario "*" (modifica la ip por la tuya)
![alt text](https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/Images/a11.jpg)
