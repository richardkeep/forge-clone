#!/bin/bash

DEPLOYER=deployer

service nginx stop
service php7.1-fpm stop
deluser --remove-home "$DEPLOYER"
