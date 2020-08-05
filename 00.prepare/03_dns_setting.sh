#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/config/openshift.env"

CVTSHL=${ABSOLUTE_PATH}/convert.sh

echo -e "\033[32m[S]=============================================================================\033[0m"
echo -e "\033[46m@@@[S]_[YUM INSTALL BIND] ==> ${DNS_IP}\033[0m"
yum -y install bind bind-utils
rm -vf /var/named/*${BASE_DOMAIN}*
pushd /var/named
dnssec-keygen -a HMAC-SHA256 -b 256 -n USER -r /dev/urandom ${BASE_DOMAIN}
grep Key: ${BASE_DOMAIN}*.private | cut -d ' ' -f 2 \
| sed 's/^/secret\ \"/' \
| sed 's/$/\";};/' \
| sed -e '1 ikey\ ${BASE_DOMAIN}\ {' \
| sed -e '2 ialgorithm HMAC-SHA256;' \
> /var/named/${BASE_DOMAIN}.key
popd
rndc-confgen -a -r /dev/urandom
restorecon -rv /etc/rndc.* /etc/named.*
chown -v root:named /etc/rndc.key
chcon -Rv -u system_u /etc/rndc.key
chmod -v 640 /etc/rndc.key
restorecon -rv /var/named/forwarders.conf
chmod -v 755 /var/named/forwarders.conf
rm -rvf /var/named/dynamic
mkdir -vp /var/named/dynamic
echo -e "\033[36m@@@[E]_[YUM INSTALL BIND] ==> ${DNS_IP}\033[0m"
echo -e "--------------------------------------------------"

echo -e "\033[46m@@@[S]_[SETTING NAMED] ==> ${DNS_IP}\033[0m"
sed "s/###BASE_DOMAIN###/${BASE_DOMAIN}/g" ${BASTION_DIR}/00.prepare/config/dns/named.sample |
sed "s/###DNS_REVERSE###/${DNS_REVERSE}/g" > ${BASTION_DIR}/00.prepare/config/dns/named.conf
sed "s/###DNS_DOMAIN###/${DNS_DOMAIN}/g" ${BASTION_DIR}/00.prepare/config/dns/zone.sample |
sed "s/###BASTION_IP###/${BASTION_IP}/g" |
sed "s/###BASE_DOMAIN###/${BASE_DOMAIN}/g" |
sed "s/###CLUSTER_NAME###/${CLUSTER_NAME}/g" > ${BASTION_DIR}/00.prepare/config/dns/${BASE_DOMAIN}.zone
sed "s/###DNS_DOMAIN###/${DNS_DOMAIN}/g" ${BASTION_DIR}/00.prepare/config/dns/rr-zone.sample |
sed "s/###BASE_DOMAIN###/${BASE_DOMAIN}/g" |
sed "s/###BASTION_IP###/$(echo ${BASTION_IP} | cut -d '.' -f4)/g" |
sed "s/###DNS_REVERSE_API###/${DNS_REVERSE_API}/g" |
sed "s/###BASE_DOMAIN###/${BASE_DOMAIN}/g" > ${BASTION_DIR}/00.prepare/config/dns/${BASE_DOMAIN}.rr.zone
. ${CVTSHL} setDNS
echo -e "\033[36m@@@[E]_[SETTING NAMED] ==> ${DNS_IP}\033[0m"
echo -e "--------------------------------------------------"

echo -e "\033[46m@@@[S]_[NAMED FILE COPY] ==> ${DNS_IP}\033[0m"
yes|cp -rp ${BASTION_DIR}/00.prepare/config/dns/${BASE_DOMAIN}.zone /var/named/dynamic/${BASE_DOMAIN}.zone
yes|cp -rp ${BASTION_DIR}/00.prepare/config/dns/${BASE_DOMAIN}.rr.zone /var/named/dynamic/${BASE_DOMAIN}.rr.zone
if [ ! -f "/etc/named.conf.org" ]; then
    mv /etc/named.conf /etc/named.conf.org
fi
yes|cp -rp ${BASTION_DIR}/00.prepare/config/dns/named.conf /etc/named.conf
echo -e "\033[36m@@@[E]_[NAMED FILE COPY] ==> ${DNS_IP}\033[0m"
echo -e "--------------------------------------------------"

echo -e "\033[46m@@@[S]_[DNS SETTING & NAMED SERVICE START] ==> ${DNS_IP}\033[0m"
firewall-cmd --perm --add-port=53/tcp
firewall-cmd --perm --add-port=53/udp
firewall-cmd --add-service dns --zone=internal --perm 
firewall-cmd --reload
restorecon -rv /etc/named.conf
restorecon -rv /var/named
chgrp named -R /var/named
chown -v root:named /etc/named.conf
chcon -Rv -u system_u /etc/named.conf
chcon -Rv -u system_u /var/named/dynamic/*
systemctl enable named
systemctl restart named
systemctl status named
echo -e "\n\033[36m@@@[E]_[DNS SETTING & NAMED SERVICE START] ==> ${DNS_IP}\033[0m"
echo -e "\033[32m=============================================================================[E]\033[0m"
