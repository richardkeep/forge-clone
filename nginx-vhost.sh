#!/bin/bash

NAME=$1
if [ -z "$NAME" ]; then
	NAME="default"
fi

PORT=$2
if [ -z "$PORT" ]; then
	PORT=80
fi

cat << EOF > /etc/nginx/sites-available/"$NAME"
server {
	server_name $NAME;
	listen $PORT;
	root /home/deployer/$NAME/current/public;
	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;
	index index.php;

	location / {
		try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
	}

	location ~ /\.ht {
	        deny all;
	}

	location ~* \.(jpg|jpeg|gif|css|png|js|ico|html)\$ {
		access_log off;
		expires max;
	}

	location ~ /\.ht {
		deny  all;
	}

	include phpfpm.conf;
}
EOF

ln -sfn /etc/nginx/sites-available/"$NAME" /etc/nginx/sites-enabled/"$NAME"

nginx -t
systemctl reload nginx

