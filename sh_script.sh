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
  sed -i "s/{{EASY_WG_PASSWORD}}/$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32)/g" ./.env

fi

if [[ -n $(grep -E -ir --include=.env "{{CROWDSEC_BOUNCER_APIKEY}}" .) ]]
then
  set -a
  source ./.env
  export CROWD_SEC_ENROLLMENT_KEY=$1
  docker compose up crowdsec -d
  sed -i "s/{{CROWDSEC_BOUNCER_APIKEY}}/$(docker compose exec crowdsec cscli bouncer add npm-bouncer)/g" ./.env
  docker compose down
fi

set -a
source ./.env
export CROWD_SEC_ENROLLMENT_KEY=$1
export WG_HOST=$2
MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
MYSQL_PASSWORD="$MYSQL_PASSWORD" \
CROWDSEC_BOUNCER_APIKEY="$CROWDSEC_BOUNCER_APIKEY" \
CROWD_SEC_ENROLLMENT_KEY="$CROWD_SEC_ENROLLMENT_KEY" \
WG_HOST="$WG_HOST" \
docker compose up -d