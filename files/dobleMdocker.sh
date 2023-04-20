#!/bin/bash
# - script creado por dobleM
sleep 5

LOCAL_SCRIPT_VERSION=36
REMOTE_SCRIPT_VERSION=`curl https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/files/version.txt 2>/dev/null`

SCRIPT=$(readlink -f $0)
CARPETA_SCRIPT=`dirname $SCRIPT`
CARPETA_DOBLEM="$CARPETA_SCRIPT/dobleM"

TVHEADEND_CONFIG_DIR="/config"
TVHEADEND_GRABBER_DIR="/usr/bin"
FFMPEG_DIR="/usr/bin/ffmpeg"

. $CARPETA_SCRIPT/dobleMconfig.ini

cd "$CARPETA_SCRIPT"

if [ -z "$COLUMNS" ]; then
	COLUMNS=80
fi

(
printf " Versión script instalado: $LOCAL_SCRIPT_VERSION \n\n"
printf " Versión script  servidor: $REMOTE_SCRIPT_VERSION \n\n"

rm $CARPETA_SCRIPT/dobleMscript.log

ELIMINAR_LISTA()
{
	# Iniciamos borrado
		echo
		printf "%-$(($COLUMNS-10))s"  " Eliminando lista de canales $FICHERO_LISTA"
		# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/channel/config/* $TVHEADEND_CONFIG_DIR/channel/tag/*
					do
						if [[ -f $fichero ]]; then
							ultima=$(tail -n 1 $fichero)
							if [[ $ultima = $FICHERO_LISTA ]]; then
							rm -f $fichero
							fi
						fi
					done
		# Borramos epggrab channels marcados, conservando canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/*
					do
						if [[ -f $fichero ]]; then
							ultima=$(tail -n 1 $fichero)
							if [[ $ultima = $FICHERO_LISTA ]]; then
							rm -f $fichero
							fi
						fi
					done
		# Borramos el input correspondiente a la lista y el fichero dobleM???.ver
			ERROR=false
			rm -rf $TVHEADEND_CONFIG_DIR/$NOMBRE_INPUT
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			rm -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "/tv_grab_EPG_$FICHERO_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$FICHERO_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": false,\n\t\t\t\"priority\": 5\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Fin borrado de canales
}

INSTALAR_GRABBER_SAT()
{
	# Comprobamos que los valores del ini son correctos
	case $FORMATO_IMG in
		1) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=false/g'';;
		2) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=true/g'';;
		*) printf "\n $FORMATO_IMG no es una opción válida para FORMATO_IMG\n"; exit;;
	esac
	# Preparamos CARPETA_DOBLEM y descargamos el grabber para satelite
		printf "%-$(($COLUMNS-10))s"  " 1. Descargando grabber"
			ERROR=false
			rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$FICHERO_LISTA
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Configuramos tvheadend y grabber para satelite
		printf "%-$(($COLUMNS-10))s"  " 2. Configurando grabber"
			ERROR=false
			#cron y grabber config epggrab
			sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# A diario a las 5:00 | 9:00 | 13:00 |17:00 | 21:00\\n0 5 * * *\\n0 9 * * *\\n0 13 * * *\\n0 17 * * *\\n0 21 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "/tv_grab_EPG_$FICHERO_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$FICHERO_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": true,\n\t\t\t\"priority\": 5\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s%s%s\n" "[" "  OK  " "]"
			else
			printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Copiamos archivos para grabber
		printf "%-$(($COLUMNS-10))s"  " 3. Instalando grabber"
			ERROR=false
			cp -r $CARPETA_DOBLEM/tv_grab_EPG_$FICHERO_LISTA $TVHEADEND_GRABBER_DIR/
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			$FORMATO_IMAGEN_GRABBER $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Borramos carpeta termporal dobleM
		printf "%-$(($COLUMNS-10))s"  " 4. Eliminando archivos temporales"
			rm -rf $CARPETA_DOBLEM
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Fin instalación
}

INSTALAR_SAT()
{
	# Comprobamos que los valores del ini son correctos
	case $LISTA_SAT in
		1) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1';; #No borramos nada
		2) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|fa0254ffc9bdcc235a7ce86ec62b04b1';; #borramos todo menos Astra individual y Astra SD
		3) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1';; #borramos todo menos Astra comunitaria y Astra SD
		4) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c';; #borramos todo menos Astra individual
		5) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2';; #borramos todo menos Astra comunitaria
		*) printf "\n $LISTA_SAT no es una opción válida para LISTA_SAT\n"; exit;;
	esac
	case $FORMATO_EPG in
		1) FORMATO_IDIOMA_EPG='\n\t\t"spa",\n\t\t"eng"\n\t';;
		2) FORMATO_IDIOMA_EPG='\n\t\t"eng",\n\t\t"spa"\n\t';;
		*) printf "\n $FORMATO_EPG no es una opción válida para FORMATO_EPG\n"; exit;;
	esac
	case $FORMATO_IMG in
		1) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=false/g'';;
		2) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=true/g'';;
		*) printf "\n $FORMATO_IMG no es una opción válida para FORMATO_IMG\n"; exit;;
	esac
	case $TIPO_PICON in
		1) RUTA_PICON="file://$TVHEADEND_CONFIG_DIR/picons";;
		2) RUTA_PICON="file://$TVHEADEND_CONFIG_DIR/picons";;
		3) RUTA_PICON="file://$TVHEADEND_CONFIG_DIR/picons";;
		4) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/picons_dobleM/master/color/";;
		5) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/picons_dobleM/master/blanco/";;
		6) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/picons_dobleM/master/reflejo/";;
		*) printf "\n $TIPO_PICON no es una opción válida para TIPO_PICON\n"; exit;;
	esac
	# Iniciamos instalación
		printf "\n Instalando lista $FICHERO_LISTA $ver_web \n"
	# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM?????.tar.xz
		printf "%-$(($COLUMNS-10+1))s"  " 1. Descargando lista y grabber para canales satélite"
			ERROR=false
			rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM/picons && cd $CARPETA_DOBLEM
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			if [[ $TIPO_PICON -le 3 ]]; then
				case $TIPO_PICON in
					1) FICHERO_PICON="color";;
					2) FICHERO_PICON="blanco";;
					3) FICHERO_PICON="reflejo";;
				esac
				curl -skO https://raw.githubusercontent.com/davidmuma/picons_dobleM/master/$FICHERO_PICON.tar.xz
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
			fi		
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$FICHERO_LISTA.ver
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$FICHERO_LISTA
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$FICHERO_LISTA.tar.xz
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Descomprimimos el tar, borramos canales no elegidos y marcamos con dobleM????? al final todos los archivos de la carpeta /channel/config/ , /channel/tag/
		printf "%-$(($COLUMNS-10+1))s"  " 2. Preparando lista de canales satélite"
			ERROR=false
			if [[ $TIPO_PICON -le 3 ]]; then
				tar -xf "$FICHERO_PICON.tar.xz" -C $CARPETA_DOBLEM/picons
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
			fi
			tar -xf "$FICHERO_LISTA.tar.xz"
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			grep -L $LIMPIAR_CANALES_SAT $CARPETA_DOBLEM/channel/config/* | xargs -I{} rm {}
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/config/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/tag/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "\$a}\n$FICHERO_LISTA" $CARPETA_DOBLEM/channel/config/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "\$a}\n$FICHERO_LISTA" $CARPETA_DOBLEM/channel/tag/*
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Marcamos con dobleM????? al final todos los archivos de la carpeta /epggrab/xmltv/channels/
		printf "%-$(($COLUMNS-10+1))s"  " 3. Preparando grabber para satélite"
			ERROR=false
			sed -i '/^\}$/,$d' $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "\$a}\n$FICHERO_LISTA" $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modid\": .*#\"modid\": \"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA\",#g" $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Comprobamos si existe el fichero /epggrab/config
		printf "%-$(($COLUMNS-10))s"  " 4. Comprobando si existe el fichero /epggrab/config"
			if [[ ! -f $TVHEADEND_CONFIG_DIR/epggrab/config ]]; then
				ERROR=false
				mkdir $TVHEADEND_CONFIG_DIR/epggrab
				cp -f $CARPETA_DOBLEM/epggrab/config $TVHEADEND_CONFIG_DIR/epggrab/
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				chown -R abc:abc $TVHEADEND_CONFIG_DIR/epggrab
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				rm -f $CARPETA_DOBLEM/epggrab/config
				if [ $? -eq 0 -a $ERROR = "false" ]; then
					printf "%s%s%s\n" "[" "  OK  " "]"
				else
					printf "%s%s%s\n" "[" "FAILED" "]"
				fi
			else
				rm -f $CARPETA_DOBLEM/epggrab/config
				if [ $? -eq 0 ]; then
					printf "%s%s%s\n" "[" "  OK  " "]"
				else
					printf "%s%s%s\n" "[" "FAILED" "]"
				fi
			fi
	# Configuramos tvheadend y grabber para satelite
		printf "%-$(($COLUMNS-10))s"  " 5. Configurando tvheadend"
			ERROR=false
			#Modo experto
			sed -i 's#"uilevel":.*#"uilevel": 2,#' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			#Idiomas EPG config tvheadend
			sed -i 's#"language":.*#"language": [\n\t idiomas_inicio#' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i 's#"epg_compress":.*#idiomas_final \n\t"epg_compress": true,#' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i '/idiomas_inicio/,/idiomas_final/d' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"language\":.*#\"language\": \[$FORMATO_IDIOMA_EPG\],#g" $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			#picons config tvheadend
			sed -i 's#"prefer_picon":.*#"prefer_picon": true,\n\t picons_inicio#' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i 's#"http_server_name":.*#picons_final \n\t&#' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i '/picons_inicio/,/picons_final/d' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"prefer_picon\".*#\"prefer_picon\": true,\n\t\"chiconpath\": \"https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/icon/%U.png\",\n\t\"chiconscheme\": 0,\n\t\"piconpath\": \"$RUTA_PICON\",\n\t\"piconscheme\": 0,#" $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			#cron y grabber config epggrab
			sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# A diario a las 5:00 | 9:00 | 13:00 |17:00 | 21:00\\n0 5 * * *\\n0 9 * * *\\n0 13 * * *\\n0 17 * * *\\n0 21 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "/tv_grab_EPG_$FICHERO_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$FICHERO_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": true,\n\t\t\t\"priority\": 5\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s%s%s\n" "[" "  OK  " "]"
			else
			printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Borramos configuración actual
		printf "%-$(($COLUMNS-10+1))s"  " 6. Eliminando instalación anterior si la hubiera"
			# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
					# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
						for fichero in $TVHEADEND_CONFIG_DIR/channel/config/* $TVHEADEND_CONFIG_DIR/channel/tag/*
						do
							if [[ -f $fichero ]]; then
								ultima=$(tail -n 1 $fichero)
								if [[ $ultima = $FICHERO_LISTA ]]; then
								rm -f $fichero
								fi
							fi
						done
			# Borramos epggrab channels marcados, conservando canales mapeados por los usuarios
					# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
						for fichero in $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/*
						do
							if [[ -f $fichero ]]; then
								ultima=$(tail -n 1 $fichero)
								if [[ $ultima = $FICHERO_LISTA ]]; then
								rm -f $fichero
								fi
							fi
						done
			# Borramos resto de la instalación anterior
			ERROR=false
			rm -rf $TVHEADEND_CONFIG_DIR/$NOMBRE_INPUT
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Copiamos archivos para canales
		printf "%-$(($COLUMNS-10+1))s"  " 7. Instalando lista de canales satélite"
			ERROR=false
			cp -r $CARPETA_DOBLEM/bouquet/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/channel/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/input/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/picons/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chown -R abc:abc $TVHEADEND_CONFIG_DIR/bouquet
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chown -R abc:abc $TVHEADEND_CONFIG_DIR/channel
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chown -R abc:abc $TVHEADEND_CONFIG_DIR/input
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chown -R abc:abc $TVHEADEND_CONFIG_DIR/picons
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/$FICHERO_LISTA.ver $TVHEADEND_CONFIG_DIR
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Copiamos archivos para grabber
		printf "%-$(($COLUMNS-10+1))s"  " 8. Instalando grabber para satélite"
			ERROR=false
			cp -r $CARPETA_DOBLEM/epggrab/ $TVHEADEND_CONFIG_DIR/
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/tv_grab_EPG_$FICHERO_LISTA $TVHEADEND_GRABBER_DIR/
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			$FORMATO_IMAGEN_GRABBER $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Borramos carpeta termporal dobleM
		printf "%-$(($COLUMNS-10))s"  " 9. Eliminando archivos temporales"
			rm -rf $CARPETA_DOBLEM
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Fin instalación
}

ACTUALIZAR_SAT()
{
	# Comprobamos que los valores del ini son correctos
	case $LISTA_SAT in
		1) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1';; #No borramos nada
		2) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|fa0254ffc9bdcc235a7ce86ec62b04b1';; #borramos todo menos Astra individual y Astra SD
		3) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1';; #borramos todo menos Astra comunitaria y Astra SD
		4) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c';; #borramos todo menos Astra individual
		5) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2';; #borramos todo menos Astra comunitaria
		*) printf "\n $LISTA_SAT no es una opción válida para LISTA_SAT\n"; exit;;
	esac
	case $FORMATO_EPG in
		1) FORMATO_IDIOMA_EPG='\n\t\t"spa",\n\t\t"eng",\n\t\t"ger",\n\t\t"fre"\n\t';;
		2) FORMATO_IDIOMA_EPG='\n\t\t"fre",\n\t\t"eng",\n\t\t"ger",\n\t\t"spa"\n\t';;
		3) FORMATO_IDIOMA_EPG='\n\t\t"ger",\n\t\t"eng",\n\t\t"spa",\n\t\t"fre"\n\t';;
		4) FORMATO_IDIOMA_EPG='\n\t\t"eng",\n\t\t"spa",\n\t\t"ger",\n\t\t"fre"\n\t';;
		*) printf "\n $FORMATO_EPG no es una opción válida para FORMATO_EPG\n"; exit;;
	esac
	case $FORMATO_IMG in
		1) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=false/g'';;
		2) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=true/g'';;
		*) printf "\n $FORMATO_IMG no es una opción válida para FORMATO_IMG\n"; exit;;
	esac
	case $TIPO_PICON in
		1) RUTA_PICON="file://$TVHEADEND_CONFIG_DIR/picons";;
		2) RUTA_PICON="file://$TVHEADEND_CONFIG_DIR/picons";;
		3) RUTA_PICON="file://$TVHEADEND_CONFIG_DIR/picons";;
		4) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/picons_dobleM/master/color/";;
		5) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/picons_dobleM/master/blanco/";;
		6) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/picons_dobleM/master/reflejo/";;
		*) printf "\n $TIPO_PICON no es una opción válida para TIPO_PICON\n"; exit;;
	esac
	# Iniciamos instalación
		printf "\n Actualizando lista $FICHERO_LISTA $ver_web \n"
	# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM?????.tar.xz
		printf "%-$(($COLUMNS-10+1))s"  " 1. Descargando lista y grabber para canales satélite"
			ERROR=false
			rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM/picons && cd $CARPETA_DOBLEM
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			if [[ $TIPO_PICON -le 3 ]]; then
				case $TIPO_PICON in
					1) FICHERO_PICON="color";;
					2) FICHERO_PICON="blanco";;
					3) FICHERO_PICON="reflejo";;
				esac
				curl -skO https://raw.githubusercontent.com/davidmuma/picons_dobleM/master/$FICHERO_PICON.tar.xz
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$FICHERO_LISTA.ver
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$FICHERO_LISTA
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$FICHERO_LISTA.tar.xz
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Descomprimimos el tar, borramos canales no elegidos y marcamos con dobleM????? al final todos los archivos de la carpeta /channel/config/ , /channel/tag/
		printf "%-$(($COLUMNS-10+1))s"  " 2. Preparando lista de canales satélite"
			ERROR=false
			if [[ $TIPO_PICON -le 3 ]]; then
				tar -xf "$FICHERO_PICON.tar.xz" -C $CARPETA_DOBLEM/picons
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
			fi
			tar -xf "$FICHERO_LISTA.tar.xz"
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			grep -L $LIMPIAR_CANALES_SAT $CARPETA_DOBLEM/channel/config/* | xargs -I{} rm {}
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/config/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i '/^\}$/,$d' $CARPETA_DOBLEM/channel/tag/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "\$a}\n$FICHERO_LISTA" $CARPETA_DOBLEM/channel/config/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "\$a}\n$FICHERO_LISTA" $CARPETA_DOBLEM/channel/tag/*
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Marcamos con dobleM????? al final todos los archivos de la carpeta /epggrab/xmltv/channels/
		printf "%-$(($COLUMNS-10+1))s"  " 3. Preparando grabber para satélite"
			ERROR=false
			sed -i '/^\}$/,$d' $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "\$a}\n$FICHERO_LISTA" $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modid\": .*#\"modid\": \"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA\",#g" $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Comprobamos si existe el fichero /epggrab/config
		printf "%-$(($COLUMNS-10))s"  " 4. Comprobando si existe el fichero /epggrab/config"
			if [[ ! -f $TVHEADEND_CONFIG_DIR/epggrab/config ]]; then
				ERROR=false
				mkdir $TVHEADEND_CONFIG_DIR/epggrab
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				cp -f $CARPETA_DOBLEM/epggrab/config $TVHEADEND_CONFIG_DIR/epggrab/
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				chown -R abc:abc $TVHEADEND_CONFIG_DIR/epggrab
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				rm -f $CARPETA_DOBLEM/epggrab/config
				if [ $? -eq 0 -a $ERROR = "false" ]; then
					printf "%s%s%s\n" "[" "  OK  " "]"
				else
					printf "%s%s%s\n" "[" "FAILED" "]"
				fi
			else
				rm -f $CARPETA_DOBLEM/epggrab/config
				if [ $? -eq 0 ]; then
					printf "%s%s%s\n" "[" "  OK  " "]"
				else
					printf "%s%s%s\n" "[" "FAILED" "]"
				fi
			fi
	# Configuramos tvheadend y grabber para satelite
		printf "%-$(($COLUMNS-10))s"  " 5. Configurando tvheadend"
			ERROR=false
			#Modo experto
			sed -i 's#"uilevel":.*#"uilevel": 2,#' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			#Idiomas EPG config tvheadend
			sed -i 's#"language":.*#"language": [\n\t idiomas_inicio#' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i 's#"epg_compress":.*#idiomas_final \n\t"epg_compress": true,#' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i '/idiomas_inicio/,/idiomas_final/d' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"language\":.*#\"language\": \[$FORMATO_IDIOMA_EPG\],#g" $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			#picons config tvheadend
			sed -i 's#"prefer_picon":.*#"prefer_picon": true,\n\t picons_inicio#' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i 's#"http_server_name":.*#picons_final \n\t&#' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i '/picons_inicio/,/picons_final/d' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"prefer_picon\".*#\"prefer_picon\": true,\n\t\"chiconpath\": \"https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/icon/%U.png\",\n\t\"chiconscheme\": 0,\n\t\"piconpath\": \"$RUTA_PICON\",\n\t\"piconscheme\": 0,#" $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			#cron y grabber config epggrab
			sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# A diario a las 5:00 | 9:00 | 13:00 |17:00 | 21:00\\n0 5 * * *\\n0 9 * * *\\n0 13 * * *\\n0 17 * * *\\n0 21 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "/tv_grab_EPG_$FICHERO_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$FICHERO_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": true,\n\t\t\t\"priority\": 5\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s%s%s\n" "[" "  OK  " "]"
			else
			printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Borramos configuración actual
		printf "%-$(($COLUMNS-10+1))s"  " 6. Preparando canales que serán actualizados"
		# Mantenemos canales deshabilitados por el usuario
			for channelenabled in $(ls $TVHEADEND_CONFIG_DIR/channel/config);
			do
				channelchange=$(sed -n '2p' $TVHEADEND_CONFIG_DIR/channel/config/$channelenabled)
				sed -i "s/.*\"enabled\":.*/$channelchange/" $CARPETA_DOBLEM/channel/config/$channelenabled 2>/dev/null
			done
			# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
					# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
						for fichero in $TVHEADEND_CONFIG_DIR/channel/config/* $TVHEADEND_CONFIG_DIR/channel/tag/*
						do
							if [[ -f $fichero ]]; then
								ultima=$(tail -n 1 $fichero)
								if [[ $ultima = $FICHERO_LISTA ]]; then
								rm -f $fichero
								fi
							fi
						done
			# Borramos epggrab channels marcados, conservando canales mapeados por los usuarios
					# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
						for fichero in $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/*
						do
							if [[ -f $fichero ]]; then
								ultima=$(tail -n 1 $fichero)
								if [[ $ultima = $FICHERO_LISTA ]]; then
								rm -f $fichero
								fi
							fi
						done
			# Borramos resto de la instalación anterior
			ERROR=false
			rm -rf $TVHEADEND_CONFIG_DIR/$NOMBRE_INPUT
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Copiamos archivos para canales
		printf "%-$(($COLUMNS-10+1))s"  " 7. Instalando canales satélite actualizados"
			ERROR=false
			cp -r $CARPETA_DOBLEM/bouquet/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/channel/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/input/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/picons/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chown -R abc:abc $TVHEADEND_CONFIG_DIR/bouquet
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chown -R abc:abc $TVHEADEND_CONFIG_DIR/channel
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chown -R abc:abc $TVHEADEND_CONFIG_DIR/input
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chown -R abc:abc $TVHEADEND_CONFIG_DIR/picons
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/$FICHERO_LISTA.ver $TVHEADEND_CONFIG_DIR
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Copiamos archivos para grabber
		printf "%-$(($COLUMNS-10+1))s"  " 8. Instalando grabber para satélite"
			ERROR=false
			cp -r $CARPETA_DOBLEM/epggrab/ $TVHEADEND_CONFIG_DIR/
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/tv_grab_EPG_$FICHERO_LISTA $TVHEADEND_GRABBER_DIR/
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			$FORMATO_IMAGEN_GRABBER $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Borramos carpeta termporal dobleM
		printf "%-$(($COLUMNS-10))s"  " 9. Eliminando archivos temporales"
			rm -rf $CARPETA_DOBLEM
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Fin instalación
}

ELIMINAR_LISTA_IPTV()
{
		if [[ $FICHERO_LISTA ]]; then
			if [[ $NOMBRE_LISTA != $NOMBRE_LISTA_OLD ]]; then
				IPTV_BOUQUET=`grep -l "$NOMBRE_LISTA_OLD\"\," /config/bouquet/* | cut -d "/" -f4`
				echo
				printf "%-$(($COLUMNS-10))s"  " Eliminando lista IPTV $NOMBRE_LISTA_OLD"
			else
				IPTV_BOUQUET=`grep -l "$NOMBRE_LISTA\"\," /config/bouquet/* | cut -d "/" -f4`
				echo
				printf "%-$(($COLUMNS-10))s"  " Eliminando lista IPTV $NOMBRE_LISTA"
			fi
				ID_NETWORK=`grep iptv-network /config/bouquet/$IPTV_BOUQUET | cut -c 28-59`
				ID_TAG=`grep chtag_ref /config/bouquet/$IPTV_BOUQUET | cut -c 16-47`
				ERROR=false
				grep -l $IPTV_BOUQUET /config/channel/config/* | xargs -I{} rm {}
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				rm -rf /config/channel/tag/$ID_TAG
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				rm -rf /config/bouquet/$IPTV_BOUQUET
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				rm -rf /config/input/iptv/networks/$ID_NETWORK
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				rm -rf $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA_OLD
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				grep -l tv_grab_EPG_$NOMBRE_LISTA_OLD /config/epggrab/xmltv/channels/* | xargs -I{} rm {}
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				rm -rf /config/$FICHERO_LISTA.ver
				if [ $? -eq 0 -a $ERROR = "false" ]; then
					printf "%s%s%s\n" "[" "  OK  " "]"
				else
					printf "%s%s%s\n" "[" "FAILED" "]"
				fi
		fi
}

INSTALAR_GRABBER_IPTV()
{
		if [[ -n ${EPG_LISTA} ]]; then
		# Borramos grabber anterior si lo hubiera
			if [[ -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA_OLD ]]; then
				printf "%-$(($COLUMNS-10))s"  " . Borrando grabber anterior"
				ERROR=false
				rm -rf $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA_OLD
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				grep -l tv_grab_EPG_$NOMBRE_LISTA_OLD /config/epggrab/xmltv/channels/* | xargs -I{} rm {}
				if [ $? -eq 0 -a $ERROR = "false" ]; then
					printf "%s%s%s\n" "[" "  OK  " "]"
				else
					printf "%s%s%s\n" "[" "FAILED" "]"
				fi
			fi
		# Descargamos el grabber para IPTV
			printf "%-$(($COLUMNS-10))s"  " . Preparando grabber"
				ERROR=false
				curl -so $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/IPTV/dobleM_tv_grab
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				sed -i "s#XMLTV_LOCATION_WEB=.*#XMLTV_LOCATION_WEB=\"$EPG_LISTA\"#g" $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
				if [ $? -eq 0 -a $ERROR = "false" ]; then
					printf "%s%s%s\n" "[" "  OK  " "]"
				else
					printf "%s%s%s\n" "[" "FAILED" "]"
				fi
		# Comprobamos si existe el fichero /epggrab/config
				if [[ ! -f $TVHEADEND_CONFIG_DIR/epggrab/config ]]; then
					printf "%-$(($COLUMNS-10))s"  " . Descargando fichero /epggrab/config"
					ERROR=false
					mkdir $TVHEADEND_CONFIG_DIR/epggrab
					if [ $? -ne 0 ]; then
						ERROR=true
					fi
					curl -so $TVHEADEND_CONFIG_DIR/epggrab/config https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/IPTV/dobleM_config
					if [ $? -ne 0 ]; then
						ERROR=true
					fi
					chown -R abc:abc $TVHEADEND_CONFIG_DIR/epggrab
					if [ $? -eq 0 -a $ERROR = "false" ]; then
						printf "%s%s%s\n" "[" "  OK  " "]"
					else
						printf "%s%s%s\n" "[" "FAILED" "]"
					fi
				fi
		# Configuramos tvheadend y grabber para IPTV
			printf "%-$(($COLUMNS-10))s"  " . Configurando grabber"
				ERROR=false
				#cron y grabber config epggrab
				sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# A diario a las 5:00 | 9:00 | 13:00 |17:00 | 21:00\\n0 5 * * *\\n0 9 * * *\\n0 13 * * *\\n0 17 * * *\\n0 21 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				sed -i "/tv_grab_EPG_$NOMBRE_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$NOMBRE_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": true,\n\t\t\t\"priority\": 4\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config
				if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
				else
				printf "%s%s%s\n" "[" "FAILED" "]"
				fi
		else
			echo " -> Lista sin EPG"
		fi
	# Fin instalación
}

INSTALAR_LISTA_IPTV()
{
		if [[ -n ${NOMBRE_LISTA} ]]; then
			if [[ $NOMBRE_LISTA != $NOMBRE_LISTA_OLD ]]; then
				printf "%-$(($COLUMNS-10))s"  " . Introduciendo datos lista IPTV"
				IPTV_BOUQUET=`grep -l "$NOMBRE_LISTA_OLD\"\," /config/bouquet/* | cut -d "/" -f4`
			else
				printf "%-$(($COLUMNS-10))s"  " . Actualizando datos lista IPTV"
				IPTV_BOUQUET=`grep -l "$NOMBRE_LISTA\"\," /config/bouquet/* | cut -d "/" -f4`
			fi
				ID_NETWORK=`grep iptv-network /config/bouquet/$IPTV_BOUQUET | cut -c 28-59`
				ERROR=false
				sed -i "s#$NOMBRE_LISTA_OLD#$NOMBRE_LISTA#" /config/$FICHERO_LISTA.ver
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				sed -i 's#"enabled":.*#"enabled": true,#' /config/bouquet/$IPTV_BOUQUET
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				sed -i '1,2d' /config/input/iptv/networks/$ID_NETWORK/config
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				printf "{\n\t\"url\": \"$URL_LISTA\",\n $( cat /config/input/iptv/networks/$ID_NETWORK/config )" > /config/input/iptv/networks/$ID_NETWORK/config
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				sed -i "s#\"channel_number\": .*#\"channel_number\": $CANAL_LISTA,#" /config/input/iptv/networks/$ID_NETWORK/config
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				sed -i "s#\"networkname\": .*#\"networkname\": \"$NOMBRE_LISTA\",#" /config/input/iptv/networks/$ID_NETWORK/config
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				ID_TAG=`grep chtag_ref /config/bouquet/$IPTV_BOUQUET | cut -c 16-47`
				sed -i "s#\"index\": .*#\"index\": $CANAL_LISTA,#" /config/channel/tag/$ID_TAG
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				sed -i "s#\"name\": .*#\"name\": \"·$NOMBRE_LISTA\",#" /config/channel/tag/$ID_TAG
				if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
				else
				printf "%s%s%s\n" "[" "FAILED" "]"
				fi
		else
			echo " -> Lista sin NOMBRE"
		fi
}

DESCARGAR_LISTA_IPTV()
{
	# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM?????.tar.xz
		printf "%-$(($COLUMNS-10))s"  " . Descargando lista de canales IPTV"
			ERROR=false
			rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/IPTV/$FICHERO_LISTA.tar.xz
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			tar -xf "$FICHERO_LISTA.tar.xz"
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Comprobamos que exite fichero listas, y lo creamos
		printf "%-$(($COLUMNS-10))s"  " . Preparando lista de canales IPTV"
			echo "NOMBRE_LISTA_OLD=$FICHERO_LISTA" > $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Copiamos archivos para canales
		printf "%-$(($COLUMNS-10))s"  " . Instalando lista de canales IPTV"
			ERROR=false
			cp -r $CARPETA_DOBLEM/bouquet/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/channel/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/input/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chown -R abc:abc $TVHEADEND_CONFIG_DIR/bouquet
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chown -R abc:abc $TVHEADEND_CONFIG_DIR/channel
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chown -R abc:abc $TVHEADEND_CONFIG_DIR/input
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Borramos carpeta termporal dobleM
		printf "%-$(($COLUMNS-10))s"  " . Eliminando archivos temporales"
			rm -rf $CARPETA_DOBLEM
			if [ $? -eq 0 ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Fin instalación
}

if [[ $LISTA_SAT -eq 0 ]]; then
	FICHERO_LISTA=dobleM-SAT
	NOMBRE_INPUT="input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8"
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Omitiendo instalación de lista $FICHERO_LISTA \n"
	else
		REINICIO=1
		ELIMINAR_LISTA
	fi
else
	FICHERO_LISTA=dobleM-SAT
	NOMBRE_INPUT="input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8"
	fecha_fichero_ini=`stat -c %Y $CARPETA_SCRIPT/dobleMconfig.ini 2>/dev/null`
	fecha_fichero_ver=`stat -c %Y $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver 2>/dev/null`
	ver_local=`cat $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver 2>/dev/null`
	ver_web=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$FICHERO_LISTA.ver 2>/dev/null`
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		REINICIO=1
		INSTALAR_SAT
	else
		if [[ $fecha_fichero_ini -gt $fecha_fichero_ver ]]; then
			REINICIO=1
			ACTUALIZAR_SAT
		else
			if [[ $ver_local = $ver_web ]]; then
				if [[ ! -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$FICHERO_LISTA ]]; then
					printf "\n El grabber para $FICHERO_LISTA se ha borrado o no existe"
					printf "\n Procedo a descargarlo e instalarlo de nuevo \n"
					REINICIO=1
					INSTALAR_GRABBER_SAT
				else
					printf "\n Versión  $FICHERO_LISTA  instalada: $ver_local"
					printf "\n Versión $FICHERO_LISTA en servidor: $ver_web"
					printf "\n No es necesario actualizar la lista \n"
				fi
			else
				REINICIO=1
				ACTUALIZAR_SAT
			fi
		fi
	fi
fi

if [[ $CANAL_LISTA1 -eq 0 ]]; then
	FICHERO_LISTA=dobleM_LISTA1
	NOMBRE_LISTA="$NOMBRE_LISTA1"
	CANAL_LISTA="$CANAL_LISTA1"
	URL_LISTA="$URL_LISTA1"
	EPG_LISTA="$EPG_LISTA1"
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Omitiendo instalación de lista IPTV $FICHERO_LISTA\n"
	else
		REINICIO=1
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		ELIMINAR_LISTA_IPTV
	fi
else
	FICHERO_LISTA=dobleM_LISTA1
	NOMBRE_LISTA="$NOMBRE_LISTA1"
	CANAL_LISTA="$CANAL_LISTA1"
	URL_LISTA="$URL_LISTA1"
	EPG_LISTA="$EPG_LISTA1"
	fecha_fichero_ini=`stat -c %Y $CARPETA_SCRIPT/dobleMconfig.ini 2>/dev/null`
	fecha_fichero_ver=`stat -c %Y $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver 2>/dev/null`
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Instalando lista IPTV $NOMBRE_LISTA\n"
		REINICIO=1
		DESCARGAR_LISTA_IPTV
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		INSTALAR_LISTA_IPTV
		INSTALAR_GRABBER_IPTV
	else
		if [[ $fecha_fichero_ini -gt $fecha_fichero_ver ]]; then
			printf "\n Modificando lista IPTV $NOMBRE_LISTA\n"
			REINICIO=1
			. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
			INSTALAR_LISTA_IPTV
			INSTALAR_GRABBER_IPTV
		else
			if [[ ! -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA ]]; then
				printf "\n El grabber para $NOMBRE_LISTA se ha borrado o no existe"
				printf "\n Procedo a descargarlo e instalarlo de nuevo \n"
				REINICIO=1
				. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
				INSTALAR_GRABBER_IPTV
			fi
		fi
	fi
fi

if [[ $CANAL_LISTA2 -eq 0 ]]; then
	FICHERO_LISTA=dobleM_LISTA2
	NOMBRE_LISTA="$NOMBRE_LISTA2"
	CANAL_LISTA="$CANAL_LISTA2"
	URL_LISTA="$URL_LISTA2"
	EPG_LISTA="$EPG_LISTA2"
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Omitiendo instalación de lista IPTV $FICHERO_LISTA\n"
	else
		REINICIO=1
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		ELIMINAR_LISTA_IPTV
	fi
else
	FICHERO_LISTA=dobleM_LISTA2
	NOMBRE_LISTA="$NOMBRE_LISTA2"
	CANAL_LISTA="$CANAL_LISTA2"
	URL_LISTA="$URL_LISTA2"
	EPG_LISTA="$EPG_LISTA2"
	fecha_fichero_ini=`stat -c %Y $CARPETA_SCRIPT/dobleMconfig.ini 2>/dev/null`
	fecha_fichero_ver=`stat -c %Y $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver 2>/dev/null`
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Instalando lista IPTV $NOMBRE_LISTA\n"
		REINICIO=1
		DESCARGAR_LISTA_IPTV
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		INSTALAR_LISTA_IPTV
		INSTALAR_GRABBER_IPTV
	else
		if [[ $fecha_fichero_ini -gt $fecha_fichero_ver ]]; then
			printf "\n Modificando lista IPTV $NOMBRE_LISTA\n"
			REINICIO=1
			. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
			INSTALAR_LISTA_IPTV
			INSTALAR_GRABBER_IPTV
		else
			if [[ ! -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA ]]; then
				printf "\n El grabber para $NOMBRE_LISTA se ha borrado o no existe"
				printf "\n Procedo a descargarlo e instalarlo de nuevo \n"
				REINICIO=1
				. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
				INSTALAR_GRABBER_IPTV
			fi
		fi
	fi
fi

if [[ $CANAL_LISTA3 -eq 0 ]]; then
	FICHERO_LISTA=dobleM_LISTA3
	NOMBRE_LISTA="$NOMBRE_LISTA3"
	CANAL_LISTA="$CANAL_LISTA3"
	URL_LISTA="$URL_LISTA3"
	EPG_LISTA="$EPG_LISTA3"
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Omitiendo instalación de lista IPTV $FICHERO_LISTA\n"
	else
		REINICIO=1
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		ELIMINAR_LISTA_IPTV
	fi
else
	FICHERO_LISTA=dobleM_LISTA3
	NOMBRE_LISTA="$NOMBRE_LISTA3"
	CANAL_LISTA="$CANAL_LISTA3"
	URL_LISTA="$URL_LISTA3"
	EPG_LISTA="$EPG_LISTA3"
	fecha_fichero_ini=`stat -c %Y $CARPETA_SCRIPT/dobleMconfig.ini 2>/dev/null`
	fecha_fichero_ver=`stat -c %Y $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver 2>/dev/null`
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Instalando lista IPTV $NOMBRE_LISTA\n"
		REINICIO=1
		DESCARGAR_LISTA_IPTV
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		INSTALAR_LISTA_IPTV
		INSTALAR_GRABBER_IPTV
	else
		if [[ $fecha_fichero_ini -gt $fecha_fichero_ver ]]; then
			printf "\n Modificando lista IPTV $NOMBRE_LISTA\n"
			REINICIO=1
			. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
			INSTALAR_LISTA_IPTV
			INSTALAR_GRABBER_IPTV
		else
			if [[ ! -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA ]]; then
				printf "\n El grabber para $NOMBRE_LISTA se ha borrado o no existe"
				printf "\n Procedo a descargarlo e instalarlo de nuevo \n"
				REINICIO=1
				. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
				INSTALAR_GRABBER_IPTV
			fi
		fi
	fi
fi

if [[ $CANAL_LISTA4 -eq 0 ]]; then
	FICHERO_LISTA=dobleM_LISTA4
	NOMBRE_LISTA="$NOMBRE_LISTA4"
	CANAL_LISTA="$CANAL_LISTA4"
	URL_LISTA="$URL_LISTA4"
	EPG_LISTA="$EPG_LISTA4"
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Omitiendo instalación de lista IPTV $FICHERO_LISTA\n"
	else
		REINICIO=1
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		ELIMINAR_LISTA_IPTV
	fi
else
	FICHERO_LISTA=dobleM_LISTA4
	NOMBRE_LISTA="$NOMBRE_LISTA4"
	CANAL_LISTA="$CANAL_LISTA4"
	URL_LISTA="$URL_LISTA4"
	EPG_LISTA="$EPG_LISTA4"
	fecha_fichero_ini=`stat -c %Y $CARPETA_SCRIPT/dobleMconfig.ini 2>/dev/null`
	fecha_fichero_ver=`stat -c %Y $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver 2>/dev/null`
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Instalando lista IPTV $NOMBRE_LISTA\n"
		REINICIO=1
		DESCARGAR_LISTA_IPTV
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		INSTALAR_LISTA_IPTV
		INSTALAR_GRABBER_IPTV
	else
		if [[ $fecha_fichero_ini -gt $fecha_fichero_ver ]]; then
			printf "\n Modificando lista IPTV $NOMBRE_LISTA\n"
			REINICIO=1
			. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
			INSTALAR_LISTA_IPTV
			INSTALAR_GRABBER_IPTV
		else
			if [[ ! -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA ]]; then
				printf "\n El grabber para $NOMBRE_LISTA se ha borrado o no existe"
				printf "\n Procedo a descargarlo e instalarlo de nuevo \n"
				REINICIO=1
				. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
				INSTALAR_GRABBER_IPTV
			fi
		fi
	fi
fi

if [[ $CANAL_LISTA5 -eq 0 ]]; then
	FICHERO_LISTA=dobleM_LISTA5
	NOMBRE_LISTA="$NOMBRE_LISTA5"
	CANAL_LISTA="$CANAL_LISTA5"
	URL_LISTA="$URL_LISTA5"
	EPG_LISTA="$EPG_LISTA5"
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Omitiendo instalación de lista IPTV $FICHERO_LISTA\n"
	else
		REINICIO=1
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		ELIMINAR_LISTA_IPTV
	fi
else
	FICHERO_LISTA=dobleM_LISTA5
	NOMBRE_LISTA="$NOMBRE_LISTA5"
	CANAL_LISTA="$CANAL_LISTA5"
	URL_LISTA="$URL_LISTA5"
	EPG_LISTA="$EPG_LISTA5"
	fecha_fichero_ini=`stat -c %Y $CARPETA_SCRIPT/dobleMconfig.ini 2>/dev/null`
	fecha_fichero_ver=`stat -c %Y $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver 2>/dev/null`
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Instalando lista IPTV $NOMBRE_LISTA\n"
		REINICIO=1
		DESCARGAR_LISTA_IPTV
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		INSTALAR_LISTA_IPTV
		INSTALAR_GRABBER_IPTV
	else
		if [[ $fecha_fichero_ini -gt $fecha_fichero_ver ]]; then
			printf "\n Modificando lista IPTV $NOMBRE_LISTA\n"
			REINICIO=1
			. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
			INSTALAR_LISTA_IPTV
			INSTALAR_GRABBER_IPTV
		else
			if [[ ! -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA ]]; then
				printf "\n El grabber para $NOMBRE_LISTA se ha borrado o no existe"
				printf "\n Procedo a descargarlo e instalarlo de nuevo \n"
				REINICIO=1
				. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
				INSTALAR_GRABBER_IPTV
			fi
		fi
	fi
fi

if [[ $CANAL_LISTA6 -eq 0 ]]; then
	FICHERO_LISTA=dobleM_LISTA6
	NOMBRE_LISTA="$NOMBRE_LISTA6"
	CANAL_LISTA="$CANAL_LISTA6"
	URL_LISTA="$URL_LISTA6"
	EPG_LISTA="$EPG_LISTA6"
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Omitiendo instalación de lista IPTV $FICHERO_LISTA\n"
	else
		REINICIO=1
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		ELIMINAR_LISTA_IPTV
	fi
else
	FICHERO_LISTA=dobleM_LISTA6
	NOMBRE_LISTA="$NOMBRE_LISTA6"
	CANAL_LISTA="$CANAL_LISTA6"
	URL_LISTA="$URL_LISTA6"
	EPG_LISTA="$EPG_LISTA6"
	fecha_fichero_ini=`stat -c %Y $CARPETA_SCRIPT/dobleMconfig.ini 2>/dev/null`
	fecha_fichero_ver=`stat -c %Y $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver 2>/dev/null`
	if [[ ! -f $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver ]]; then
		printf "\n Instalando lista IPTV $NOMBRE_LISTA\n"
		REINICIO=1
		DESCARGAR_LISTA_IPTV
		. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
		INSTALAR_LISTA_IPTV
		INSTALAR_GRABBER_IPTV
	else
		if [[ $fecha_fichero_ini -gt $fecha_fichero_ver ]]; then
			printf "\n Modificando lista IPTV $NOMBRE_LISTA\n"
			REINICIO=1
			. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
			INSTALAR_LISTA_IPTV
			INSTALAR_GRABBER_IPTV
		else
			if [[ ! -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA ]]; then
				printf "\n El grabber para $NOMBRE_LISTA se ha borrado o no existe"
				printf "\n Procedo a descargarlo e instalarlo de nuevo \n"
				REINICIO=1
				. $TVHEADEND_CONFIG_DIR/$FICHERO_LISTA.ver
				INSTALAR_GRABBER_IPTV
			fi
		fi
	fi
fi

if [[ $REINICIO -eq 1 ]]; then
	printf "\n Reiniciando tvheadend para aplicar los cambios \n\n"
		pkill -SIGKILL tvheadend
else
	printf "\n No hay cambios \n\n"
fi

) | tee "$TVHEADEND_CONFIG_DIR/dobleMscript.log"
