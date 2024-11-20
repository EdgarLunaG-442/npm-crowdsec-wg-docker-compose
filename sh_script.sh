#!/bin/bash
# ------------------------------------------------------------------
# [Author] Title
#          Description
# ------------------------------------------------------------------

VERSION=0.1.0
SUBJECT=some-unique-id
USAGE="Usage: command -ihv args"


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
  docker-compose up crowdsec -d
  sed -i "s/{{CROWDSEC_BOUNCER_APIKEY}}/$(docker-compose exec crowdsec cscli bouncer add npm-bouncer)/g" ./.env
  docker-compose down
fi

set -a
source ./.env
export CROWD_SEC_ENROLLMENT_KEY=$1
export WG_HOST=$2
docker-compose up -d
