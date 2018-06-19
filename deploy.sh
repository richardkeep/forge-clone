#!/bin/bash

PROJECT_NAME=$1
if [ -z "$PROJECT_NAME" ]; then
	PROJECT_NAME="default"
fi

REPOSITORY=$2
if [ -z "$REPOSITORY" ]; then
	REPOSITORY="git@github.com:laravel/laravel.git"
fi

# Load environment
source .env

RELEASES_PATH="$DEPLOYER_BASE_PATH"/"$PROJECT_NAME"/releases
LATEST_RELEASE=`date '+%Y%m%d%H%M%S'`
CURRENT_RELEASE_PATH="$DEPLOYER_BASE_PATH"/"$PROJECT_NAME"/current
LATEST_RELEASE_PATH="$DEPLOYER_BASE_PATH"/"$PROJECT_NAME"/releases/"$LATEST_RELEASE"
CURRENT_PROJECT_PATH="$DEPLOYER_BASE_PATH"/"$PROJECT_NAME"

if [ ! -d "$RELEASES_PATH" ]; then
	mkdir -p "$RELEASES_PATH"
fi

# Check if this is the first release
if [ -z "$(ls -A $RELEASES_PATH)" ]; then
	FIRST_RELEASE=TRUE
else
	FIRST_RELEASE=FALSE
fi

# Pull latest version
runuser -l deployer -c "git clone git@github.com:laravel/laravel.git $LATEST_RELEASE_PATH -q"

# Update storage
if [ $FIRST_RELEASE == "TRUE" ]; then
	# Create storage directory
	mv "$LATEST_RELEASE_PATH"/storage "$CURRENT_PROJECT_PATH"/storage

	# Create .env file
	mv "$LATEST_RELEASE_PATH"/.env.example "$CURRENT_PROJECT_PATH"/.env

	# Update permissions
	chown -R "$DEPLOYER":"$DEPLOYER" "$CURRENT_PROJECT_PATH"/storage
else
	rm -fr "$LATEST_RELEASE_PATH"/storage
fi

# Update permissions
chown -R "$DEPLOYER":"$DEPLOYER" "$LATEST_RELEASE_PATH"

ln -sfn "$CURRENT_PROJECT_PATH"/storage "$LATEST_RELEASE_PATH"/storage

# Publish .env
ln -sfn "$CURRENT_PROJECT_PATH"/.env "$LATEST_RELEASE_PATH"/.env

# Install vendor packages
cd "$LATEST_RELEASE_PATH"
composer install -q

# Publish current release
ln -sfn "$LATEST_RELEASE_PATH" "$CURRENT_RELEASE_PATH"

# Update permissions
chown -R "$DEPLOYER":"$DEPLOYER" "$DEPLOYER_BASE_PATH"
chmod -R g+rw "$LATEST_RELEASE_PATH"
chmod -R g+rw "$CURRENT_PROJECT_PATH"/storage

if [ $FIRST_RELEASE == "TRUE" ]; then
	# Generate key
	cd "$LATEST_RELEASE_PATH" && php artisan key:generate
fi

exit 0