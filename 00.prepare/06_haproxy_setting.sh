#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/config/openshift.env"

CVTSHL=${ABSOLUTE_PATH}/convert.sh

echo -e "\033[32m[S]=============================================================================\033[0m"
echo -e "--------------------------------------------------"
echo -e "\033[46m@@@[S]_[HAPROXY INSTALL] ==> ${HAPROXY_IP}\033[0m"
yum -y install haproxy
if [ -f != /etc/haproxy/haproxy.cfg.org ]; then
    mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.org
fi
echo -e "\033[36m@@@[E]_[HAPROXY INSTALL] ==> ${HAPROXY_IP}\033[0m"

echo -e "--------------------------------------------------"
echo -e "\033[46m@@@[S]_[HAPROXY CONFIG COPY] ==> ${HAPROXY_IP}\033[0m"
. ${CVTSHL} setHAProxy
yes | cp -rf ${BASTION_DIR}/00.prepare/config/haproxy.cfg /etc/haproxy/
echo -e "\033[36m@@@[E]_[HAPROXY CONFING COPY] ==> ${HAPROXY_IP}\033[0m"

echo -e "--------------------------------------------------"
echo -e "\033[46m@@@[S]_[HAPROXY SERVICE START] ==> ${HAPROXY_IP}\033[0m"
semanage port -a -t http_port_t -p tcp 6443
semanage port -a -t http_port_t -p tcp 22623
#semanage port -m -t http_port_t -p tcp 8000
semanage port -l | grep http_port_t
systemctl enable haproxy
systemctl restart haproxy
systemctl status haproxy
echo -e "\033[36m@@@[E]_[HAPROXY SERVICE START] ==> ${HAPROXY_IP}\033[0m"
echo -e "\033[46m@@@[S]_[FIREWALL SETTING] ==> ${HAPROXY_IP}\033[0m"
firewall-cmd --permanent --add-port=22623/tcp
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-service=http

firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp

firewall-cmd --add-port 22623/tcp --zone=internal --perm
firewall-cmd --add-port 6443/tcp --zone=internal --perm  
firewall-cmd --add-service https --zone=internal --perm  
firewall-cmd --add-service http --zone=internal --perm  
 
firewall-cmd --add-port 6443/tcp --zone=external --perm  
firewall-cmd --add-service https --zone=external --perm  
firewall-cmd --add-service http --zone=external --perm  
firewall-cmd --complete-reload
firewall-cmd --list-all
echo -e "\033[36m@@@[E]_[FIREWALL SETTING] ==> ${HAPROXY_IP}\033[0m"
echo -e "\033[32m=============================================================================[E]\033[0m"
