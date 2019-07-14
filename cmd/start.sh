#!/bin/sh

set -e

CHOWN=$(/usr/bin/which chown)
SQUID=$(/usr/bin/which squid)

initialize_cache() {
	echo "Creating cache folder..."
	"$SQUID" -z

	sleep 5
}

create_cert() {
	if [ ! -f /etc/squid/cert/private.pem ]; then
		echo "Creating certificate..."
		openssl req -new -newkey rsa:2048 -sha256 -days 3650 -nodes -x509 \
			-extensions v3_ca -keyout /etc/squid/cert/private.pem \
			-out /etc/squid/cert/private.pem \
			-subj "/CN=$CN/O=$O/OU=$OU/C=$C" -utf8 -nameopt multiline,utf8

		openssl x509 -in /etc/squid/cert/private.pem \
			-outform DER -out /etc/squid/cert/CA.der

		openssl x509 -inform DER -in /etc/squid/cert/CA.der \
			-out /etc/squid/cert/CA.pem
	else
		echo "Certificate found..."
	fi
}

clear_certs_db() {
	echo "Clearing generated certificate db..."
	rm -rfv /var/lib/ssl_db/
	/usr/lib/squid/ssl_crtd -c -s /var/lib/ssl_db
	"$CHOWN" -R squid.squid /var/lib/ssl_db
}

run() {
	echo "Starting squid..."
#	create_cert
#	clear_certs_db
#	initialize_cache
	exec "$SQUID" -NYCd 1 # -f /etc/squid/squid.conf
}

run
