!/bin/bash
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
  export CROWDSEC_ENROLLMENT_KEY=$1
  docker compose up crowdsec -d
  sleep 5
  sed -i "s/{{CROWDSEC_BOUNCER_APIKEY}}/$(docker exec crowdsec cscli bouncer add npm-bouncer | grep -A 2 "API key for 'npm-bouncer':" | tail -n 1 | xargs)/g" ./.env
  docker compose down
fi

set -a
source ./.env
export CROWDSEC_ENROLLMENT_KEY=$1
export WG_HOST=$2
MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
MYSQL_PASSWORD="$MYSQL_PASSWORD" \
EASY_WG_PASSWORD="$EASY_WG_PASSWORD" \
CROWDSEC_BOUNCER_APIKEY="$CROWDSEC_BOUNCER_APIKEY" \
CROWDSEC_ENROLLMENT_KEY="$CROWDSEC_ENROLLMENT_KEY" \
WG_HOST="$WG_HOST" \
docker compose up -d
