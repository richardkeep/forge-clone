#!/bin/bash

# Generates random password
RANDOM_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo $RANDOM_PASSWORD
