#!/bin/bash
# ------------------------------------------------------------------

if [ ! -e ./.env ]
then
  cp ./.env.template ./.env
fi


if [[ -n $(grep -E -ir --include=.env "{{MYSQL_PASSWORD}}" .) ]]
then
  EASY_WG_PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32)
  EASY_WG_PASSWORD_HASH=$(docker run -it ghcr.io/wg-easy/wg-easy wgpw "$EASY_WG_PASSWORD" | sed "s/PASSWORD_HASH=//g")
  sed -i "s/{{MYSQL_ROOT_PASSWORD}}/$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32)/g" ./.env
  sed -i "s/{{MYSQL_PASSWORD}}/$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32)/g" ./.env
fi

set -a
source ./.env
export WG_HOST=$1
MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
MYSQL_PASSWORD="$MYSQL_PASSWORD" \
CROWDSEC_BOUNCER_APIKEY="$CROWDSEC_BOUNCER_APIKEY" \
WG_HOST="$WG_HOST" \
docker compose up -d
set +a