#!/bin/bash
# ------------------------------------------------------------------

if [ ! -e ./.env ]
then
  cp ./.env.template ./.env
fi


if [[ -n $(grep -E -ir --include=.env "{{MYSQL_PASSWORD}}" .) ]]
then
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
docker compose -f ./docker-compose-k3s.yml up -d
set +a