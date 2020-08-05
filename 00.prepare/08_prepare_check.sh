#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/config/openshift.env"

CVTSHL=${ABSOLUTE_PATH}/convert.sh

echo -e "\033[32m[S]=============================================================================\033[0m"
echo -e "--------------------------------------------------"
echo -e "\033[46m@@@[S]_[CHECK BASTION] ==> ${BASTION_IP}\033[0m"
echo -e "\033[44m[RHEL Version Check : ${BASTION_IP}]\033[0m"; cat /etc/redhat-release
echo -e "\n\033[44m[hostname : ${BASTION_IP}]\033[0m"; hostname
echo -e "\n\033[44m[Selinux Check : ${BASTION_IP}]\033[0m"; sestatus
echo -e "\n\033[44m[Services Check : ${BASTION_IP}]\033[0m" 
echo "  NetworkManager - `systemctl is-active NetworkManager`"
echo "  haproxy - `systemctl is-active haproxy`"
echo "  httpd - `systemctl is-active httpd`"
echo "  named - `systemctl is-active named`"
echo "  chronyd - `systemctl is-active chronyd`"
echo -e "\n\033[44m[yum repo Check : ${BASTION_IP}]\033[0m"; yum repolist
echo -e "\n\033[44m[Time Date : ${BASTION_IP}]\033[0m"; timedatectl status
echo -e "\n\033[44m[chronyc Check : ${BASTION_IP}]\033[0m"; chronyc sources -v
echo -e "\n\033[44m[Tools Chekc : ${BASTION_IP}]\033[0m"
echo "oc `oc version`"
echo "-----"
echo "`openshift-install version`"
echo -e "\n\033[44m[DNS CHECK : ${BASTION_IP}]\033[0m"; . ${CVTSHL} checkDNS ip; . ${CVTSHL} checkDNS host
echo -e "\033[36m@@@[E]_[CHECK BASTION] ==> ${BASTION_IP}\033[0m"
echo -e "\033[32m=============================================================================[E]\033[0m"
