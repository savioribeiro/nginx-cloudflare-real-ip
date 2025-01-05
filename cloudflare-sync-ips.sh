#!/bin/bash

CLOUDFLARE_FILE_PATH=${1:-/etc/nginx/cloudflare}

IPS_V4=$(curl -s -L https://www.cloudflare.com/ips-v4)
IPS_V6=$(curl -s -L https://www.cloudflare.com/ips-v6)

if [ -n "$IPS_V4" ] && [ -n "$IPS_V6" ]; then
    echo "#Cloudflare" > $CLOUDFLARE_FILE_PATH
    echo "" >> $CLOUDFLARE_FILE_PATH

    echo "# - IPv4" >> $CLOUDFLARE_FILE_PATH
    for i in $IPS_V4; do
        echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH
    done

    echo "" >> $CLOUDFLARE_FILE_PATH
    echo "# - IPv6" >> $CLOUDFLARE_FILE_PATH
    for i in $IPS_V6; do
        echo "set_real_ip_from $i;" >> $CLOUDFLARE_FILE_PATH
    done

    echo "" >> $CLOUDFLARE_FILE_PATH
    echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_FILE_PATH

    # Test configuration and reload nginx
    nginx -t && systemctl reload nginx
    echo "File updated and Nginx reloaded successfully."
else
    echo "Error: Unable to get Cloudflare IPs (IPv4 or IPv6). The file was not updated." >&2
    exit 1
fi
