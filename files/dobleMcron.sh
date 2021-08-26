#!/bin/bash

SCRIPT=$(readlink -f $0)
CARPETA_SCRIPT=`dirname $SCRIPT`
. $CARPETA_SCRIPT/dobleMconfig.ini
cd "$CARPETA_SCRIPT"

sed -i '/dobleMdocker/d' /etc/crontabs/root
sed -i "1i 00	4	*/${DIAS}	*	*	$CARPETA_SCRIPT/dobleMdocker.sh" /etc/crontabs/root
crond reload
