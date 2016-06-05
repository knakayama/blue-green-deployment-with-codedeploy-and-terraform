#!/usr/bin/env bash

sed -i "s@server_name  localhost@server_name $(curl -s http://169.254.169.254/latest/meta-data/public-hostname)@" \
  "/etc/nginx/nginx.conf"
