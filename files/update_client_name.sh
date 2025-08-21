#!/bin/bash

MAC="$1"
NAME="$2"

if [ -z "$MAC" ] || [ -z "$NAME" ]; then
    echo "Usage: $0 <MAC> <NAME>"
    exit 1
fi

# MongoDB Update ausführen
mongo --port 27117 ace --eval "db.user.update({\"mac\": \"${MAC}\"}, {\"\$set\": {\"name\": \"${NAME}\"}}, {multi: true})"

# UniFi Service neu starten
service unifi restart

echo "Updated ${MAC} with name ${NAME} and restarted UniFi service"
