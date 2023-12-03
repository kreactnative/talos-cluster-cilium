#!/bin/bash
n=0
retries=5

echo "update  nginx config"

sudo rm -rf /etc/nginx/nginx.conf
sudo cp /tmp/nginx.conf /etc/nginx/nginx.conf

echo "restart nginx proxy"
until [ "$n" -ge "$retries" ]; do
   if sudo systemctl restart nginx; then
      cat /etc/nginx/nginx.conf
      exit 0
   else
      n=$((n+1)) 
      sleep 5
   fi
done

echo "All retries failed. Exiting with code 1."
exit 1
