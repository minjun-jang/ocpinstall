#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/../00.prepare/config/openshift.env"

echo -e "\033[32m[S]=============================================================================\033[0m"
echo -e "\033[46m@@@[S]_[PODMAN INSTALL]\033[0m"
yum -y install podman httpd-tools skopeo jq
echo -e "\033[36m@@@[E]_[PODMAN INSTALL]\033[0m"

echo -e "--------------------------------------------------"
echo -e "\033[46m@@@[S]_[CREATE CERTIFICATE & PODMAN RUN REGISTRY]\033[0m"
echo -e "----- [make directory /opt/registry/{auth,certs,data}]"
mkdir -p /opt/registry/{auth,certs,data}
echo -e "----- [create certificate]"
cd /opt/registry/certs
htpasswd -bBc /opt/registry/auth/htpasswd ${REGISTRY_USER} ${REGISTRY_PASSWD}
openssl req -newkey rsa:4096 -nodes -sha256 -keyout domain.key -x509 -days 3650 -out domain.crt
yes | cp -rf /opt/registry/certs/domain.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust

echo -e "----- [ext-registry start]"
sed "s/###REGISTRY_NAME###/${REGISTRY_NAME}/g" ${BASTION_DIR}/01.ext-registry/config/ext-registry.sample | 
sed "s/###REGISTRY_PORT###/${REGISTRY_PORT}/g" > ${BASTION_DIR}/01.ext-registry/service/ext-registry.service
yes | cp -rf ${ABSOLUTE_PATH}/../01.ext-registry/service/ext-registry.service /etc/systemd/system/ext-registry.service
systemctl daemon-reload
systemctl enable ext-registry
systemctl start ext-registry
systemctl status ext-registry

firewall-cmd --add-port=5000/tcp --zone=internal --permanent 
firewall-cmd --add-port=5000/tcp --zone=public   --permanent 
firewall-cmd --reload
echo -e "\033[36m@@@[E]_[CREATE CERTIFICATE & PODMAN RUN REGISTRY]\033[0m"

echo -e "--------------------------------------------------"
echo -e "\033[46m@@@[S]_[CHECK EXT-REGISTRY]\033[0m"
curl -u ${REGISTRY_USER}:${REGISTRY_PASSWD} -k https://${REGISTRY_URL}:${REGISTRY_PORT}/v2/_catalog
echo -e "\033[36m@@@[E]_[CHECK EXT-REGISTRY]\033[0m"
echo -e "\033[32m=============================================================================[E]\033[0m"
