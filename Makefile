# Copyright 2019-present Open Networking Foundation
# SPDX-License-Identifier: Apache-2.0

onos_post := curl -sSL --user onos:rocks --noproxy localhost -X POST -H 'Content-Type:application/json'

pull:
	docker-compose pull

onos-start:
	docker-compose up -d

onos-stop:
	docker-compose down -t0

onos-restart: stop start

onos-cli:
	ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -p 8101 onos@localhost

onos-log:
	docker-compose logs -f onos

netcfg:
	${onos_post} ${onos_url}/v1/network/configuration/ -d@./netcfg.json

hosts:
	sudo ./vhost.py prov vhost.json

clear-hosts:
	sudo ./vhost.py clear

clear: onos-stop clear-hosts
