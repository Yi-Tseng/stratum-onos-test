# Stratum + ONOS test config

## Prerequisites

- Docker (tested with version 19.03)
- Docker compose (version 1.26)
- make

## Set up switch

Start stratum_bfrt container:

    export CHASSIS_CONFIG=/root/stratum-configs/chassis_config.pb.txt
    export DOCKER_IMAGE=registry.aetherproject.org/tost/stratum-bfrt
    export DOCKER_IMAGE_TAG=9.2.0-4.14.49
    ./start-stratum-container.sh

### Start ONOS and connect to switch

Start ONOS:

    make start

This command will:
- Start the TOST container which includes ONOS, Trellis control, and Fabric-TNA pipeconf
- Enable gRPC message logging (located in `./tmp/onos/grpc_*.log`)

That will take some time to complete. While you wait, on a separate terminal
window, open the ONOS log and keep an eye on it:

    make onos-log

To access the ONOS CLI:

    make onos-cli

If you need to use a different version of Fabric-TNA pipeconf, you can copy the oar file
to this directory and run:

    make pipeconf-reinstalll

Once `make start` completes, push netcfg to trigger connection to the switch
from ONOS:

    make netcfg-simple

Observe Stratum logs and ONOS logs for possible errors.

A log of all gRPC messages sent from ONOS to the switch is available under
`./tmp/onos/grpc_*.log`. The filename changes at each execution, to find out:

    make grpc-log

Pick a test from the ones available below and run the corresponding commands.

When done, stop ONOS and clear any host configuration:

    make clear

NOTE: running different kinds of tests (e.g., routing and bridging) requires
restarting ONOS.

#### Test 1 - Routing

    make netcfg-routing
    make hosts-routing
    # Wait for the netcfg to be applied (check ONOS log)
    make check-routing

Add default route using the ONOS CLI (`make onos-cli`) to trigger an update of
the default action in the routing_v4 table:

    onos> route-add 0.0.0.0/0 10.0.2.1

#### Test 2 - Routing with VLAN-tagged host

    make netcfg-routing-vlan
    make hosts-routing-vlan
    # Wait for the netcfg to be applied (check ONOS log)
    make check-routing

#### Test 3 - Bridging

    make netcfg-bridging
    make hosts-bridging
    # Wait for the netcfg to be applied (check ONOS log)
    make check-bridging
