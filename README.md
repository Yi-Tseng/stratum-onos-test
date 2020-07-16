# Stratum + ONOS test config

## Prerequests

- Docker (tested with version 19.03)
- Docker compose (version 1.26)
- automake tool (for make command)

## Set up the server

### 1. Hosts

- Set up virtual hosts (network namespaces)

```bash
make hosts
```

### 2. ONOS

- Start ONOS container

```bash
make onos-start
```

- Push netcfg, ONOS won't try to connect to the switch until we push the pipeline.

```bash
make netcfg
```

- ONOS CLI

```bash
make onos-cli
```

### 3. Build and push Fabric-TNA pipeconf

- Clone fabric-tna pipeconf

```bash
git clone https://github.com/stratum/fabric-tna.git
```

- Build fabric-tna pipeline and pipeconf

```bash
cd fabric-tna
make fabric
make pipeconf
```

- Push pipeconf to ONOS

```bash
make pipeconf-install
```

## Set up the switch

Deploy `chassis-config.pb.txt` to the switch and start the Stratum.

### Clear test setup

```bash
make clear
```
