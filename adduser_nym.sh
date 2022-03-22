#!/bin/sh
USER="nym"

if id $USER > /dev/null 2>&1; then
   echo "user exist ... Will not overwrite /etc/config/users!"
   exit 0
else
  echo "user deosn't exist ... Creating user Nym"
  echo "nym:*:1789:1789:nym:/home/nym:/bin/false" >> /etc/passwd
fi
