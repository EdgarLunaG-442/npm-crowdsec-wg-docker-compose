## Description

NPM stack with crowdsec and wireguard. (npm with bd records)

This example contains multiple containers :
* crowdsec : Read NPM logs from the mounted volumes
* npm : The Nginx Proxy Manager container
* wg-easy : wireguard server with wg-easy
* db: mariadb to store npm data/records

replace positional arguments and run

Run sh_script.sh to run the containers

```bash
/bin/bash ./.sh_script.sh CROWD_SEC_ENROLLMENT_KEY WG_HOST
```

**Prerequisites:** [Docker](https://docs.docker.com/engine/install/) / [Docker Compose](https://docs.docker.com/compose/install/)
