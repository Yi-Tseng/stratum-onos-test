# Stratum + ONOS test config

## Prerequisites

- Docker (tested with version 19.03)
- Docker compose (version 1.26)
- make

## Set up switch

SSH into switch:

    ssh root@10.128.13.223

Copy latest stratum_bfrt docker image:

    scp onlbuilder@10.254.1.15:~/stratum-images/stratum-bfrt-9.2.0.tgz /tmp
    docker load < /tmp/stratum-bfrt-9.2.0.tgz

Start stratum_bfrt container:

    CHASSIS_CONFIG=/root/chassis_config.pb.txt DOCKER_IMAGE=stratumproject/stratum-bfrt DOCKER_IMAGE_TAG=9.2.0 ./start-stratum-container.sh --bf-sim

## Set up server

SSH into server:

    ssh cord@10.128.13.88
    cd ~/stratum-onos-test

### Start ONOS and connect to switch

Copy the fabric-tna pipeconf oar in `./fabric-tna-1.0.0-SNAPSHOT.oar` (it should
already be available on the server).

Start ONOS:

    make start

This command will:
- Start ONOS container
- Enable gRPC message logging (located in `./tmp/onos/grpc_*.log`)
- Install fabric-tna pipeconf

That will take some time to complete. While you wait, on a separate terminal
window, open the ONOS log and keep an eye on it:

    make onos-log

Once `make start` completes, push netcfg to trigger connection to the switch
from ONOS:

    make netcfg-simple

Observe stratum logs and ONOS logs for possible errors.

A log of all gRPC messages sent from ONOS to the switch is available under 
`./tmp/onos/grpc_*.log`. The filename changes at each execution, to find out:

    make grpc-log

### Test connectivity (WIP)

Instructions are still work in progress.

### Other commands

To access the ONOS CLI:

    make onos-cli

To set up virtual hosts (network namespaces):

    make hosts

To stop ONOS and clear the setup:

    make clear

