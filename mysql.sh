#!/bin/bash

# Run environment commands
sh preinstall.sh

# Prevent MySQL installation from prompting for a root password
export DEBIAN_FRONTEND="noninteractive"

# Set MySQL root password manually
debconf-set-selections <<< "mysql-server mysql-server/root_password password secret"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password secret"

# Install MySQL
apt install -y mysql-server mysql-client

# Generate random password for deployr
RANDOM_PASSWORD=`sh ./password.sh`

# Generate user and database creation query
cat << EOF > /tmp/mysql.sql
CREATE DATABASE \`homestead\`;
CREATE USER 'homestead'@'localhost' IDENTIFIED BY '$RANDOM_PASSWORD';
GRANT ALl PRIVILEGES ON \`homestead\`.* TO 'homestead'@'localhost';
FLUSH PRIVILEGES;
EOF

# Run query
mysql -u root -psecret < /tmp/mysql.sql

# Remove query
# rm /tmp/mysql.sql

echo MySQL password: "$RANDOM_PASSWORD"