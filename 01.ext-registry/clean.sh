#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

systemctl stop ext-registry
systemctl disable ext-registry

podman rm $(podman ps -qa)
podman rmi $(podman images -qa)

rm -rf /opt/registry/certs
rm -rf /opt/registry/auth
rm -rf /etc/systemd/system/ext-registry.service
