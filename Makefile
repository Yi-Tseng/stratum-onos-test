# Copyright 2019-present Open Networking Foundation
# SPDX-License-Identifier: Apache-2.0
ONOS_HOST ?= localhost
ONOS_WEB_PORT ?= 18181
ONOS_SSH_PORT ?= 18101

onos_url := http://${ONOS_HOST}:${ONOS_WEB_PORT}/onos
onos_curl := curl --fail -sSL --user onos:rocks --noproxy localhost

pull:
	docker-compose pull

start:
	make onos-start
	sleep 35
	./onos-cmd app deactivate kafka
	./onos-cmd app activate drivers.barefoot
	./onos-cmd cfg set org.onosproject.grpc.ctl.GrpcChannelControllerImpl enableMessageLog true
	./onos-cmd cfg set org.onosproject.provider.general.device.impl.GeneralDeviceProvider checkupInterval 5
	sleep 10
	# FIXME: remove when fabric-tna will have explicit app requirement on
	#  segmentrouting. Untile then, triggering a new activation should solve
	#  the wiring problem as at this point segmentrouting should be active.
	./onos-cmd app deactivate fabric-tna
	./onos-cmd app activate fabric-tna

onos-start:
	docker-compose up -d

onos-stop:
	docker-compose down -t0

onos-reset:
	./onos-cmd wipe-out please

onos-cli:
	ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -p "${ONOS_SSH_PORT}" onos@localhost

onos-log:
	docker-compose logs -f onos

pipeconf-reinstall:
	$(info *** Replacing pipeconf app in ONOS at ${ONOS_HOST}...)
	./onos-cmd app deactivate fabric-tna
	${onos_curl} -X DELETE '${onos_url}/v1/applications/org.stratumproject.fabric-tna'
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

netcfg-int: netcfg-simple
	${onos_curl} -X POST -H 'Content-Type:application/json' \
		${onos_url}/v1/network/configuration/ -d@./netcfg-int.json

hosts-routing:
	sudo ./vhost.py prov vhost-routing.json

hosts-routing-vlan:
	sudo ./vhost.py prov vhost-routing-vlan.json

hosts-bridging:
	sudo ./vhost.py prov vhost-bridging.json

hosts-int:
	sudo ./vhost.py prov vhost-int.json

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

up4-unload:
	${onos_curl} -X DELETE ${onos_url}/v1/applications/org.omecproject.up4

up4-load:
	${onos_curl} -X POST -HContent-Type:application/octet-stream \
		'${onos_url}/v1/applications?activate=true' \
		--data-binary @./up4-app-1.0.0-SNAPSHOT.oar
	@echo

