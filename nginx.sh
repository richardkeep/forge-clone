#!/bin/bash

sh preinstall.sh
source .env

apt -y install nginx

sed -i "s/user www-data;/user $DEPLOYER;/" /etc/nginx/nginx.conf

cat << EOF > /etc/nginx/phpfpm.conf
location ~ \.php\$ {
	expires off; ## Do not cache dynamic content

	fastcgi_buffers 16 16k;
	fastcgi_buffer_size 32k;
	fastcgi_connect_timeout 600;
	fastcgi_send_timeout 1800;
	fastcgi_read_timeout 1800;

#	fastcgi_pass 127.0.0.1:9000;
	fastcgi_pass unix:/run/php/php7.1-fpm.sock;
	fastcgi_index index.php;
	fastcgi_param REMOTE_ADDR \$http_x_real_ip;
	fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;

	include fastcgi_params;

	fastcgi_keep_conn on;
}
EOF

nginx -t
systemctl restart nginx
