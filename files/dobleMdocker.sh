#!/bin/bash
# - script creado por dobleM
LOCAL_SCRIPT_VERSION=23
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

if [[ $LOCAL_SCRIPT_VERSION < $REMOTE_SCRIPT_VERSION ]]; then
	cd $CARPETA_SCRIPT
	curl -skO https://raw.githubusercontent.com/davidmuma/Docker_dobleM/master/files/dobleMdocker.sh
	sh dobleMdocker.sh && exit
fi

(
printf " Versión del script: $LOCAL_SCRIPT_VERSION \n\n"

ELIMINAR_LISTA()
{
	# Iniciamos borrado
		echo
		printf "%-$(($COLUMNS-10))s"  " Eliminando lista de canales $NOMBRE_LISTA"
		# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/channel/config/* $TVHEADEND_CONFIG_DIR/channel/tag/*
					do
						if [ -f "$fichero" ]; then
							ultima=$(tail -n 1 $fichero)
							if [ "$ultima" = $NOMBRE_LISTA ]; then
							rm -f $fichero
							fi
						fi
					done
		# Borramos epggrab channels marcados, conservando canales mapeados por los usuarios
				# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
					for fichero in $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/*
					do
						if [ -f "$fichero" ]; then
							ultima=$(tail -n 1 $fichero)
							if [ "$ultima" = $NOMBRE_LISTA ]; then
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
			rm -f $TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver
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
		1) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=false/g''; break;;
		2) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=true/g''; break;;
		*) printf "\n $FORMATO_IMG no es una opción válida para FORMATO_IMG\n"; exit;;
	esac
	# Preparamos CARPETA_DOBLEM y descargamos el grabber para satelite
		printf "%-$(($COLUMNS-10))s"  " 1. Descargando grabber"
			ERROR=false
			rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$NOMBRE_LISTA
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Configuramos tvheadend y grabber para satelite
		printf "%-$(($COLUMNS-10))s"  " 2. Configurando grabber"
			ERROR=false
			#cron y grabber config epggrab
			sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# Todos los días a las 8:04, 14:04 y 20:04\\n4 8 * * *\\n4 14 * * *\\n4 20 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "/tv_grab_EPG_$NOMBRE_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$NOMBRE_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": true,\n\t\t\t\"priority\": 5\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -eq 0 -a $ERROR = "false" ]; then
			printf "%s%s%s\n" "[" "  OK  " "]"
			else
			printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Copiamos archivos para grabber
		printf "%-$(($COLUMNS-10))s"  " 3. Instalando grabber"
			ERROR=false
			cp -r $CARPETA_DOBLEM/tv_grab_EPG_$NOMBRE_LISTA $TVHEADEND_GRABBER_DIR/
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			$FORMATO_IMAGEN_GRABBER $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
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

INSTALAR_GRABBER_IPTV()
{
	# Preparamos CARPETA_DOBLEM y descargamos el grabber para IPTV
		printf "%-$(($COLUMNS-10))s"  " 1. Descargando grabber"
			ERROR=false
			rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$NOMBRE_LISTA
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Configuramos tvheadend y grabber para IPTV
		printf "%-$(($COLUMNS-10))s"  " 2. Configurando grabber"
			ERROR=false
			#cron y grabber config epggrab
			sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# Todos los días a las 8:04, 14:04 y 20:04\\n4 8 * * *\\n4 14 * * *\\n4 20 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config
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
	# Copiamos archivos para grabber
		printf "%-$(($COLUMNS-10))s"  " 3. Instalando grabber"
			ERROR=false
			cp -r $CARPETA_DOBLEM/tv_grab_EPG_$NOMBRE_LISTA $TVHEADEND_GRABBER_DIR/
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
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
		1) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #No borramos nada
		2) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #borramos todo menos Astra individual y Astra SD
		3) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #borramos todo menos Astra comunitaria y Astra SD
		4) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c'; break;; #borramos todo menos Astra individual
		5) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2'; break;; #borramos todo menos Astra comunitaria
		*) printf "\n $LISTA_SAT no es una opción válida para LISTA_SAT\n"; exit;;
	esac
	case $FORMATO_EPG in
		1) FORMATO_IDIOMA_EPG='\n\t\t"spa",\n\t\t"eng",\n\t\t"ger",\n\t\t"fre"\n\t'; break;;
		2) FORMATO_IDIOMA_EPG='\n\t\t"fre",\n\t\t"eng",\n\t\t"ger",\n\t\t"spa"\n\t'; break;;
		3) FORMATO_IDIOMA_EPG='\n\t\t"ger",\n\t\t"eng",\n\t\t"spa",\n\t\t"fre"\n\t'; break;;
		4) FORMATO_IDIOMA_EPG='\n\t\t"eng",\n\t\t"spa",\n\t\t"ger",\n\t\t"fre"\n\t'; break;;
		*) printf "\n $FORMATO_EPG no es una opción válida para FORMATO_EPG\n"; exit;;
	esac
	case $FORMATO_IMG in
		1) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=false/g''; break;;
		2) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=true/g''; break;;
		*) printf "\n $FORMATO_IMG no es una opción válida para FORMATO_IMG\n"; exit;;
	esac
	case $TIPO_PICON in
		1) RUTA_PICON="file://$TVHEADEND_CONFIG_DIR/picons"; break;;
		2) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/dobleM"; break;;
		3) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/reflejo"; break;;
		4) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/transparent"; break;;
		5) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/color"; break;;
		*) printf "\n $TIPO_PICON no es una opción válida para TIPO_PICON\n"; exit;;
	esac
	# Iniciamos instalación
		printf "\n Instalando lista $NOMBRE_LISTA $ver_web \n"
	# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM?????.tar.xz
		printf "%-$(($COLUMNS-10+1))s"  " 1. Descargando lista y grabber para canales satélite"
			ERROR=false
			rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.ver
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$NOMBRE_LISTA
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.tar.xz
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Descomprimimos el tar, borramos canales no elegidos y marcamos con dobleM????? al final todos los archivos de la carpeta /channel/config/ , /channel/tag/
		printf "%-$(($COLUMNS-10+1))s"  " 2. Preparando lista de canales satélite"
			ERROR=false
			tar -xf "$NOMBRE_LISTA.tar.xz"
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
			sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/config/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/tag/*
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
			sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modid\": .*#\"modid\": \"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\",#g" $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Comprobamos si existe el fichero /epggrab/config
		printf "%-$(($COLUMNS-10))s"  " 4. Comprobando si existe el fichero /epggrab/config"
			if [ ! -f "$TVHEADEND_CONFIG_DIR/epggrab/config" ]; then
				ERROR=false
				mkdir $TVHEADEND_CONFIG_DIR/epggrab
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				cp -f $CARPETA_DOBLEM/epggrab/config $TVHEADEND_CONFIG_DIR/epggrab/
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
			sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# Todos los días a las 8:04, 14:04 y 20:04\\n4 8 * * *\\n4 14 * * *\\n4 20 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "/tv_grab_EPG_$NOMBRE_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$NOMBRE_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": true,\n\t\t\t\"priority\": 5\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config
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
							if [ -f "$fichero" ]; then
								ultima=$(tail -n 1 $fichero)
								if [ "$ultima" = $NOMBRE_LISTA ]; then
								rm -f $fichero
								fi
							fi
						done
			# Borramos epggrab channels marcados, conservando canales mapeados por los usuarios
					# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
						for fichero in $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/*
						do
							if [ -f "$fichero" ]; then
								ultima=$(tail -n 1 $fichero)
								if [ "$ultima" = $NOMBRE_LISTA ]; then
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
			rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
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
			cp -r $CARPETA_DOBLEM/$NOMBRE_LISTA.ver $TVHEADEND_CONFIG_DIR
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
			cp -r $CARPETA_DOBLEM/tv_grab_EPG_$NOMBRE_LISTA $TVHEADEND_GRABBER_DIR/
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			$FORMATO_IMAGEN_GRABBER $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
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
		1) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #No borramos nada
		2) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #borramos todo menos Astra individual y Astra SD
		3) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2\|fa0254ffc9bdcc235a7ce86ec62b04b1'; break;; #borramos todo menos Astra comunitaria y Astra SD
		4) LIMPIAR_CANALES_SAT='ac6da31b4882740649cd13bc94f96b1c'; break;; #borramos todo menos Astra individual
		5) LIMPIAR_CANALES_SAT='8e06542863d3606f8a583e43c73580c2'; break;; #borramos todo menos Astra comunitaria
		*) printf "\n $LISTA_SAT no es una opción válida para LISTA_SAT\n"; exit;;
	esac
	case $FORMATO_EPG in
		1) FORMATO_IDIOMA_EPG='\n\t\t"spa",\n\t\t"eng",\n\t\t"ger",\n\t\t"fre"\n\t'; break;;
		2) FORMATO_IDIOMA_EPG='\n\t\t"fre",\n\t\t"eng",\n\t\t"ger",\n\t\t"spa"\n\t'; break;;
		3) FORMATO_IDIOMA_EPG='\n\t\t"ger",\n\t\t"eng",\n\t\t"spa",\n\t\t"fre"\n\t'; break;;
		4) FORMATO_IDIOMA_EPG='\n\t\t"eng",\n\t\t"spa",\n\t\t"ger",\n\t\t"fre"\n\t'; break;;
		*) printf "\n $FORMATO_EPG no es una opción válida para FORMATO_EPG\n"; exit;;
	esac
	case $FORMATO_IMG in
		1) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=false/g''; break;;
		2) FORMATO_IMAGEN_GRABBER='sed -i 's/enable_fanart=.*/enable_fanart=true/g''; break;;
		*) printf "\n $FORMATO_IMG no es una opción válida para FORMATO_IMG\n"; exit;;
	esac
	case $TIPO_PICON in
		1) RUTA_PICON="file://$TVHEADEND_CONFIG_DIR/picons"; break;;
		2) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/dobleM"; break;;
		3) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/reflejo"; break;;
		4) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/transparent"; break;;
		5) RUTA_PICON="https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/picon/color"; break;;
		*) printf "\n $TIPO_PICON no es una opción válida para TIPO_PICON\n"; exit;;
	esac
	# Iniciamos instalación
		printf "\n Actualizando lista $NOMBRE_LISTA $ver_web \n"
	# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM?????.tar.xz
		printf "%-$(($COLUMNS-10+1))s"  " 1. Descargando lista y grabber para canales satélite"
			ERROR=false
			rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.ver
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$NOMBRE_LISTA
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.tar.xz
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Descomprimimos el tar, borramos canales no elegidos y marcamos con dobleM????? al final todos los archivos de la carpeta /channel/config/ , /channel/tag/
		printf "%-$(($COLUMNS-10+1))s"  " 2. Preparando lista de canales satélite"
			ERROR=false
			tar -xf "$NOMBRE_LISTA.tar.xz"
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
			sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/config/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/tag/*
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
			sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modid\": .*#\"modid\": \"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\",#g" $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Comprobamos si existe el fichero /epggrab/config
		printf "%-$(($COLUMNS-10))s"  " 4. Comprobando si existe el fichero /epggrab/config"
			if [ ! -f "$TVHEADEND_CONFIG_DIR/epggrab/config" ]; then
				ERROR=false
				mkdir $TVHEADEND_CONFIG_DIR/epggrab
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				cp -f $CARPETA_DOBLEM/epggrab/config $TVHEADEND_CONFIG_DIR/epggrab/
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
			sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# Todos los días a las 8:04, 14:04 y 20:04\\n4 8 * * *\\n4 14 * * *\\n4 20 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "/tv_grab_EPG_$NOMBRE_LISTA\"/,/},/d" $TVHEADEND_CONFIG_DIR/epggrab/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modules\": {#\"modules\": {\n\t\t\"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\": {\n\t\t\t\"class\": \"epggrab_mod_int_xmltv\",\n\t\t\t\"dn_chnum\": 0,\n\t\t\t\"name\": \"XMLTV: EPG_$NOMBRE_LISTA\",\n\t\t\t\"type\": \"Internal\",\n\t\t\t\"enabled\": true,\n\t\t\t\"priority\": 5\n\t\t},#g" $TVHEADEND_CONFIG_DIR/epggrab/config
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
							if [ -f "$fichero" ]; then
								ultima=$(tail -n 1 $fichero)
								if [ "$ultima" = $NOMBRE_LISTA ]; then
								rm -f $fichero
								fi
							fi
						done
			# Borramos epggrab channels marcados, conservando canales mapeados por los usuarios
					# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
						for fichero in $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/*
						do
							if [ -f "$fichero" ]; then
								ultima=$(tail -n 1 $fichero)
								if [ "$ultima" = $NOMBRE_LISTA ]; then
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
			rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
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
			cp -r $CARPETA_DOBLEM/$NOMBRE_LISTA.ver $TVHEADEND_CONFIG_DIR
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
			cp -r $CARPETA_DOBLEM/tv_grab_EPG_$NOMBRE_LISTA $TVHEADEND_GRABBER_DIR/
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			$FORMATO_IMAGEN_GRABBER $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
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

INSTALAR_IPTV()
{
	# Comprobamos que los valores del ini son correctos
	case $LISTA_IPTV in
		1) LIMPIAR_FFMPEG=''epglimit.*0''; break;; #borramos todo menos los no ffmpeg
		2) LIMPIAR_FFMPEG=''epglimit.*7''; break;; #borramos todo menos los si ffmpeg
		*) printf "\n $LISTA_IPTV no es una opción válida para LISTA_IPTV\n"; exit;;
	esac
	# Iniciamos instalación
		printf "\n Instalando lista $NOMBRE_LISTA $ver_web \n"
	# Preparamos CARPETA_DOBLEM y descargamos el fichero dobleM?????.tar.xz
		printf "%-$(($COLUMNS-10))s"  " 1. Descargando lista y grabber para canales IPTV"
			ERROR=false
			rm -rf $CARPETA_DOBLEM && mkdir $CARPETA_DOBLEM && cd $CARPETA_DOBLEM
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.ver
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/tv_grab_EPG_$NOMBRE_LISTA
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			curl -skO https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.tar.xz
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Descomprimimos el tar y marcamos con dobleM????? al final todos los archivos de la carpeta /channel/config/ , /channel/tag/
		printf "%-$(($COLUMNS-10))s"  " 2. Preparando lista de canales IPTV"
			ERROR=false
			tar -xf "$NOMBRE_LISTA.tar.xz"
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			grep -L $LIMPIAR_FFMPEG $CARPETA_DOBLEM/channel/config/* | xargs -I{} rm {}
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
			sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/config/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/channel/tag/*
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Marcamos con dobleM????? al final todos los archivos de la carpeta /epggrab/xmltv/channels/
		printf "%-$(($COLUMNS-10))s"  " 3. Preparando grabber para IPTV"
			ERROR=false
			sed -i '/^\}$/,$d' $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "\$a}\n$NOMBRE_LISTA" $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#\"modid\": .*#\"modid\": \"$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA\",#g" $CARPETA_DOBLEM/epggrab/xmltv/channels/*
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Comprobamos si existe el fichero /epggrab/config
		printf "%-$(($COLUMNS-10))s"  " 4. Comprobando si existe el fichero /epggrab/config"
			if [ ! -f "$TVHEADEND_CONFIG_DIR/epggrab/config" ]; then
				ERROR=false
				mkdir $TVHEADEND_CONFIG_DIR/epggrab
				if [ $? -ne 0 ]; then
					ERROR=true
				fi
				cp -f $CARPETA_DOBLEM/epggrab/config $TVHEADEND_CONFIG_DIR/epggrab/
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
	# Configuramos tvheadend y grabber para IPTV
		printf "%-$(($COLUMNS-10))s"  " 5. Configurando grabber en tvheadend"
			ERROR=false
			#Modo experto
			sed -i 's#"uilevel":.*#"uilevel": 2,#' $TVHEADEND_CONFIG_DIR/config
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			#cron y grabber config epggrab
			sed -i -e 's/"channel_rename": .*,/"channel_rename": false,/g' -e 's/"channel_renumber": .*,/"channel_renumber": false,/g' -e 's/"channel_reicon": .*,/"channel_reicon": false,/g' -e 's/"epgdb_periodicsave": .*,/"epgdb_periodicsave": 0,/g' -e 's/"epgdb_saveafterimport": .*,/"epgdb_saveafterimport": true,/g' -e 's/"cron": .*,/"cron": "\# Todos los días a las 8:04, 14:04 y 20:04\\n4 8 * * *\\n4 14 * * *\\n4 20 * * *",/g' -e 's/"int_initial": .*,/"int_initial": true,/g' -e 's/"ota_initial": .*,/"ota_initial": false,/g' -e 's/"ota_cron": .*,/"ota_cron": "\# Configuración modificada por dobleM\\n\# Telegram: t.me\/EPG_dobleM",/g' -e 's/"ota_timeout": .*,/"ota_timeout": 600,/g' $TVHEADEND_CONFIG_DIR/epggrab/config
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
	# Borramos configuración actual
		printf "%-$(($COLUMNS-10+1))s"  " 6. Eliminando instalación anterior si la hubiera"
			# Borramos channels y tags marcados, conservando redes y canales mapeados por los usuarios
					# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
						for fichero in $TVHEADEND_CONFIG_DIR/channel/config/* $TVHEADEND_CONFIG_DIR/channel/tag/*
						do
							if [ -f "$fichero" ]; then
								ultima=$(tail -n 1 $fichero)
								if [ "$ultima" = $NOMBRE_LISTA ]; then
								rm -f $fichero
								fi
							fi
						done
			# Borramos epggrab channels marcados, conservando canales mapeados por los usuarios
					# Recorremos los ficheros de estas carpetas para borrar solo los que tengan la marca dobleM?????
						for fichero in $TVHEADEND_CONFIG_DIR/epggrab/xmltv/channels/*
						do
							if [ -f "$fichero" ]; then
								ultima=$(tail -n 1 $fichero)
								if [ "$ultima" = $NOMBRE_LISTA ]; then
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
			rm -f $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Copiamos archivos para canales
		printf "%-$(($COLUMNS-10))s"  " 7. Instalando lista de canales IPTV"
			ERROR=false
			cp -r $CARPETA_DOBLEM/channel/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/input/ $TVHEADEND_CONFIG_DIR
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			sed -i "s#FFMPEG_TEMP#$FFMPEG_DIR $FFMPEG_COMMAND#g" $CARPETA_DOBLEM/dobleM-FFMPEG.sh && chmod +rx $CARPETA_DOBLEM/dobleM-FFMPEG.sh && cp -r $CARPETA_DOBLEM/dobleM-FFMPEG.sh /var
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/$NOMBRE_LISTA.ver $TVHEADEND_CONFIG_DIR
			if [ $? -eq 0 -a $ERROR = "false" ]; then
				printf "%s%s%s\n" "[" "  OK  " "]"
			else
				printf "%s%s%s\n" "[" "FAILED" "]"
			fi
	# Copiamos archivos para grabber
		printf "%-$(($COLUMNS-10))s"  " 8. Instalando grabber para para IPTV"
			ERROR=false
			cp -r $CARPETA_DOBLEM/epggrab/ $TVHEADEND_CONFIG_DIR/
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			cp -r $CARPETA_DOBLEM/tv_grab_EPG_$NOMBRE_LISTA $TVHEADEND_GRABBER_DIR/
			if [ $? -ne 0 ]; then
				ERROR=true
			fi
			chmod +rx $TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA
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


if [ $LISTA_SAT -eq 0 ]; then
	NOMBRE_LISTA=dobleM-SAT
	NOMBRE_INPUT="input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8"
	if [ ! -f "$TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver" ]; then
		printf "\n Omitiendo instalación de lista $NOMBRE_LISTA \n"
	else
		REINICIO=1
		ELIMINAR_LISTA
	fi
else
	NOMBRE_LISTA=dobleM-SAT
	NOMBRE_INPUT="input/dvb/networks/b59c72f4642de11bd4cda3c62fe080a8"
	fecha_fichero_ini=`stat -c %Y $CARPETA_SCRIPT/dobleMconfig.ini`
	fecha_fichero_ver=`stat -c %Y $TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver`
	ver_local=`cat $TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver 2>/dev/null`
	ver_web=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.ver 2>/dev/null`
	if [ ! -f "$TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver" ]; then
		REINICIO=1
		INSTALAR_SAT
	else
		if [ $fecha_fichero_ini -gt $fecha_fichero_ver ]; then
			REINICIO=1
			ACTUALIZAR_SAT
		else
			if [ $ver_local = $ver_web ]; then
				if [ ! -f "$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA" ]; then
					printf "\n El grabber para $NOMBRE_LISTA se ha borrado o no existe"
					printf "\n Procedo a descargarlo e instalarlo de nuevo \n"
					REINICIO=1
					INSTALAR_GRABBER_SAT
				else
					printf "\n Versión  $NOMBRE_LISTA  instalada: $ver_local"
					printf "\n Versión $NOMBRE_LISTA en servidor: $ver_web"
					printf "\n No es necesario actualizar la lista \n"
				fi
			else
				REINICIO=1
				ACTUALIZAR_SAT
			fi
		fi
	fi

fi

if [ $LISTA_TDT -eq 0 ]; then
	NOMBRE_LISTA=dobleM-TDT
	NOMBRE_INPUT="input/iptv/networks/c80013f7cb7dc75ed04b0312fa362ae1"
	if [ ! -f "$TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver" ]; then
		printf "\n Omitiendo instalación de lista $NOMBRE_LISTA \n"
	else
		REINICIO=1
		ELIMINAR_LISTA
	fi
else
	LISTA_IPTV=$LISTA_TDT
	NOMBRE_LISTA=dobleM-TDT
	NOMBRE_INPUT="input/iptv/networks/c80013f7cb7dc75ed04b0312fa362ae1"
	fecha_fichero_ini=`stat -c %Y $CARPETA_SCRIPT/dobleMconfig.ini`
	fecha_fichero_ver=`stat -c %Y $TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver`
	ver_local=`cat $TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver 2>/dev/null`
	ver_web=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.ver 2>/dev/null`
	if [ $fecha_fichero_ini -gt $fecha_fichero_ver ]; then
		REINICIO=1
		INSTALAR_IPTV
	else
		if [ $ver_local = $ver_web ]; then
			if [ ! -f "$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA" ]; then
				printf "\n El grabber para $NOMBRE_LISTA se ha borrado o no existe"
				printf "\n Procedo a descargarlo e instalarlo de nuevo \n"
				REINICIO=1
				INSTALAR_GRABBER_IPTV
			else
				printf "\n Versión  $NOMBRE_LISTA  instalada: $ver_local"
				printf "\n Versión $NOMBRE_LISTA en servidor: $ver_web"
				printf "\n No es necesario actualizar la lista \n"
			fi
		else
			REINICIO=1
			INSTALAR_IPTV
		fi
	fi
fi

if [ $LISTA_PLUTO -eq 0 ]; then
	NOMBRE_LISTA=dobleM-PlutoTV_ALL
	NOMBRE_INPUT="input/iptv/networks/d80013f7cb7dc75ed04b0312fa362ae1"
	if [ ! -f "$TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver" ]; then
		printf "\n Omitiendo instalación de lista $NOMBRE_LISTA \n"
	else
		REINICIO=1
		ELIMINAR_LISTA
	fi
else
	LISTA_IPTV=$LISTA_PLUTO
	NOMBRE_LISTA=dobleM-PlutoTV_ALL
	NOMBRE_INPUT="input/iptv/networks/d80013f7cb7dc75ed04b0312fa362ae1"
	fecha_fichero_ini=`stat -c %Y $CARPETA_SCRIPT/dobleMconfig.ini`
	fecha_fichero_ver=`stat -c %Y $TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver`
	ver_local=`cat $TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver 2>/dev/null`
	ver_web=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.ver 2>/dev/null`
	if [ $fecha_fichero_ini -gt $fecha_fichero_ver ]; then
		REINICIO=1
		INSTALAR_IPTV
	else
		if [ $ver_local = $ver_web ]; then
			if [ ! -f "$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA" ]; then
				printf "\n El grabber para $NOMBRE_LISTA se ha borrado o no existe"
				printf "\n Procedo a descargarlo e instalarlo de nuevo \n"
				REINICIO=1
				INSTALAR_GRABBER_IPTV
			else
				printf "\n Versión  $NOMBRE_LISTA  instalada: $ver_local"
				printf "\n Versión $NOMBRE_LISTA en servidor: $ver_web"
				printf "\n No es necesario actualizar la lista \n"
			fi
		else
			REINICIO=1
			INSTALAR_IPTV
		fi
	fi
fi

if [ $LISTA_PLUTOVOD -eq 0 ]; then
	NOMBRE_LISTA=dobleM-PlutoVOD_ES
	NOMBRE_INPUT="input/iptv/networks/f801b3c9e6be4260665d32be03908e00"
	if [ ! -f "$TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver" ]; then
		printf "\n Omitiendo instalación de lista $NOMBRE_LISTA \n"
	else
		REINICIO=1
		ELIMINAR_LISTA
	fi
else
	LISTA_IPTV=$LISTA_PLUTOVOD
	NOMBRE_LISTA=dobleM-PlutoVOD_ES
	NOMBRE_INPUT="input/iptv/networks/f801b3c9e6be4260665d32be03908e00"
	fecha_fichero_ini=`stat -c %Y $CARPETA_SCRIPT/dobleMconfig.ini`
	fecha_fichero_ver=`stat -c %Y $TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver`
	ver_local=`cat $TVHEADEND_CONFIG_DIR/$NOMBRE_LISTA.ver 2>/dev/null`
	ver_web=`curl https://raw.githubusercontent.com/davidmuma/Canales_dobleM/master/files/$NOMBRE_LISTA.ver 2>/dev/null`
	if [ $fecha_fichero_ini -gt $fecha_fichero_ver ]; then
		REINICIO=1
		INSTALAR_IPTV
	else
		if [ $ver_local = $ver_web ]; then
			if [ ! -f "$TVHEADEND_GRABBER_DIR/tv_grab_EPG_$NOMBRE_LISTA" ]; then
				printf "\n El grabber para $NOMBRE_LISTA se ha borrado o no existe"
				printf "\n Procedo a descargarlo e instalarlo de nuevo \n"
				REINICIO=1
				INSTALAR_GRABBER_IPTV
			else
				printf "\n Versión  $NOMBRE_LISTA  instalada: $ver_local"
				printf "\n Versión $NOMBRE_LISTA en servidor: $ver_web"
				printf "\n No es necesario actualizar la lista \n"
			fi
		else
			REINICIO=1
			INSTALAR_IPTV
		fi
	fi
fi

if [ $REINICIO -eq 1 ]; then
	printf "\n Reiniciando tvheadend para aplicar los cambios \n"
		pkill -SIGKILL tvheadend
else
	printf "\n No hay cambios \n"
fi

) | tee "$CARPETA_SCRIPT/dobleMscript.log"
