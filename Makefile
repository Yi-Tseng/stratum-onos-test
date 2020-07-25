# Copyright 2019-present Open Networking Foundation
# SPDX-License-Identifier: Apache-2.0
ONOS_HOST ?= localhost

onos_url := http://${ONOS_HOST}:8181/onos
onos_curl := curl --fail -sSL --user onos:rocks --noproxy localhost

pull:
	docker-compose pull

start:
	make onos-start
	sleep 35
	./onos-cmd cfg set org.onosproject.grpc.ctl.GrpcChannelControllerImpl enableMessageLog true
	make pipeconf-install
	sleep 10

onos-start:
	docker-compose up -d

onos-stop:
	docker-compose down -t0

onos-reset:
	./onos-cmd wipe-out please

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

netcfg-routing: netcfg-simple
	${onos_curl} -X POST -H 'Content-Type:application/json' \
		${onos_url}/v1/network/configuration/ -d@./netcfg-routing.json

netcfg-routing-vlan: netcfg-simple
	${onos_curl} -X POST -H 'Content-Type:application/json' \
		${onos_url}/v1/network/configuration/ -d@./netcfg-routing-vlan.json

netcfg-bridging: netcfg-simple
	${onos_curl} -X POST -H 'Content-Type:application/json' \
		${onos_url}/v1/network/configuration/ -d@./netcfg-bridging.json

hosts-routing:
	sudo ./vhost.py prov vhost-routing.json

hosts-routing-vlan:
	sudo ./vhost.py prov vhost-routing-vlan.json

hosts-bridging:
	sudo ./vhost.py prov vhost-bridging.json

check-routing:
	sudo ip netns exec h1 ping -c1 10.0.1.254
	sudo ip netns exec h2 ping -c1 10.0.2.254
	sudo ip netns exec h1 ping -c1 10.0.2.1

check-bridging:
	sudo ip netns exec h1 ping -c5 10.0.1.2

clear-hosts:
	sudo ./vhost.py clear

clear: onos-stop clear-hosts
	sudo rm -rf ./tmp

grpc-log:
	@ls tmp/onos/grpc_*.log
