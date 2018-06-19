#!/bin/bash

# Run environment commands
sh preinstall.sh

# Install needed 
apt -y install apt-transport-https lsb-release ca-certificates wget git

# Load environment
source .env

# Generate random password for deployr
RANDOM_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Create user
useradd "$DEPLOYER" -m -s /bin/bash -U -G www-data
echo "$DEPLOYER:$RANDOM_PASSWORD" | chpasswd

# Make user sudo
usermod -a -G sudo "$DEPLOYER"

chown -R "$DEPLOYER":"$DEPLOYER" "$DEPLOYER_BASE_PATH"

echo Deployer password: "$RANDOM_PASSWORD"

runuser -l deployer -c 'ssh-keyscan github.com >> githubKey'
runuser -l deployer -c 'ssh-keygen -lf githubKey'
runuser -l deployer -c 'mkdir ~/.ssh'
runuser -l deployer -c 'touch ~/.ssh/known_hosts'
runuser -l deployer -c 'cat githubKey >> ~/.ssh/known_hosts'
runuser -l deployer -c 'rm githubKey'

runuser -l deployer -c 'ssh-keygen -b 2048 -t rsa -f /home/deployer/.ssh/id_rsa -q -N ""'
echo "SSH Key: "
cat /home/deployer/.ssh/id_rsa.pub
