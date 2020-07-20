# Copyright 2019-present Open Networking Foundation
# SPDX-License-Identifier: Apache-2.0
ONOS_HOST ?= localhost

onos_url := http://${ONOS_HOST}:8181/onos
onos_curl := curl --fail -sSL --user onos:rocks --noproxy localhost

pull:
	docker-compose pull

onos-start:
	docker-compose up -d

onos-stop:
	docker-compose down -t0

onos-restart: onos-stop onos-start

onos-cli:
	ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -p 8101 onos@localhost

onos-log:
	docker-compose logs -f onos

pipeconf-install:
	$(info *** Installing and activating pipeconf app in ONOS at ${ONOS_HOST}...)
	${onos_curl} -X POST -HContent-Type:application/octet-stream \
		'${onos_url}/v1/applications?activate=true' \
		--data-binary @./fabric-tna-1.0.0-SNAPSHOT.oar
	@echo

netcfg-simple:
	${onos_curl} -X POST -H 'Content-Type:application/json' \
		${onos_url}/v1/network/configuration/ -d@./netcfg-simple.json

netcfg-routing:
	${onos_curl} -X POST -H 'Content-Type:application/json' \
		${onos_url}/v1/network/configuration/ -d@./netcfg-routing.json

hosts:
	sudo ./vhost.py prov vhost.json

clear-hosts:
	sudo ./vhost.py clear

clear: onos-stop clear-hosts
	rm -rf ./tmp

start:
	make onos-start
	sleep 35
	./onos-cmd cfg set org.onosproject.grpc.ctl.GrpcChannelControllerImpl enableMessageLog true
	make pipeconf-install
	sleep 10

grpc-log:
	@ls tmp/onos/grpc_*.log
