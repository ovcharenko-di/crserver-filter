#!/bin/bash

# start apache2
source /etc/apache2/envvars
exec /usr/sbin/apache2 -DFOREGROUND
