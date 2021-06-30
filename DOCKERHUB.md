# Docker container for BTDEX

[![BTDEX logo](https://raw.githubusercontent.com/btdex/btdex/master/btdex-new.svg)](https://btdex.trade/)

This is a Docker container for [BTDEX](https://btdex.trade/).

The GUI of the application is accessed through a modern web browser (no installation or configuration needed on the client side) or via any VNC client.

---

## Quick Start

**NOTE**: The Docker command provided in this quick start is given as an example
and parameters should be adjusted to your need.

Launch the BTDEX docker container with the following command:
```
docker run -d \
    --name=btdex \
    -p 5800:5800 \
    -v /docker/appdata/btdex:/config:rw \
    furritos/docker-btdex
```

Where:
  - `/docker/appdata/btdex`: This is where the application stores its configuration, log and any files needing persistency.

Browse to `http://your-host-ip:5800` to access the BTDEX GUI.

## Documentation

Full documentation is available at https://github.com/furritos/docker-btdex.

## Support or Contact

Having troubles with the container or have questions?  Please
[create a new issue].

[create a new issue]: https://github.com/furritos/docker-btdex/issues