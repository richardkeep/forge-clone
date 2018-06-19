#!/bin/bash

./reset.sh || true && ./init.sh && ./php7.1.sh && ./nginx.sh && ./nginx-vhost.sh forge.app && ./mysql.sh && ./deploy.sh forge.app