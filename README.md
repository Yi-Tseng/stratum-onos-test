# Stratum + ONOS test config

## Prerequests

- Docker (tested with version 19.03)
- Docker compose (version 1.26)
- automake tool (for make command)

## Set up the server

### Hosts

- Set up virtual hosts (network namespaces)

```bash
make hosts
```

### ONOS

- To start ONOS container

```bash
make onos-start
```

- Push netcfg

```bash
make netcfg
```

- ONOS CLI

```bash
make onos-cli
```

### Clear test setup

```bash
make clear
```

## Set up the switch

Use `chassis-config.pb.txt` to start the Stratum

