---
title: Docker via Homebrew
published: 2016-01-17 16:49:53 +0000
tags: docker, osx, homebrew
---

On the site, [Docker][] recommend using the [Docker Toolbox][] to get up and
running with it. I'm personally not much of a fan of these "platform"
installers; in attempting to provide a common solution for most, people like me
end up fighting with it. Fortunately, this can all be done standlone through
[Homebrew]. Here's how to do it:

```sh
brew install docker docker-machine
```

This pulls in the `docker` executable and the new(er) way to managing machines
(as you can't use Docker directly on OS X): `docker-machine`.

## Creating a Local Docker Machine

This will pull in a recent [boot2docker][] image (platform dependent). You'll
then need to set the environment variables so that Docker knows to use it.

```sh
docker-machine create main
eval $(docker-machine env main)
```

The `eval` will set the following bits of configuration (although it'd vary for
you):

```sh
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.237.131:2376"
export DOCKER_CERT_PATH="/Users/nickcharlton/.docker/machine/machines/main"
export DOCKER_MACHINE_NAME="main"
```

### …with VMware Fusion

But, I prefer to use [VMware Fusion][] for running VMs, so I do it this way
instead:

```sh
docker-machine create --driver vmwarefusion main
eval $(docker-machine env main)
```

There we go. Docker that can be done nicely as with any other tool through
Homebrew.

[Docker]: https://docker.com
[Docker Toolbox]: https://docker.com/toolbox
[Homebrew]: http://brew.sh
[boot2docker]: https://github.com/boot2docker/boot2docker
[VMware Fusion]: https://www.vmware.com/uk/products/fusion/
