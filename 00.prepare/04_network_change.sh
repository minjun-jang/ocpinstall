#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/config/openshift.env"

echo -e "\033[32m[S]=============================================================================\033[0m"
echo -e "--------------------------------------------------"
echo -e "\033[46m@@@[S]_[HOST NETWORK CONFIGRUE] ==> ${BASTION_IP}\033[0m"
nmcli con mod ${NW_NAME} connection.id ${NW_NAME}
nmcli con mod ${NW_NAME} ipv4.addr ${BASTION_IP}/${NW_PREFIX}
nmcli con mod ${NW_NAME} ipv4.gateway ${NW_GATEWAY}
nmcli con mod ${NW_NAME} ipv4.dns ${NW_DNS1}
nmcli con mod ${NW_NAME} ipv4.dns-search ${NW_DNS_SEARCH}
nmcli con mod ${NW_NAME} ipv4.method manual
nmcli con mod ${NW_NAME} ipv6.method ignore
nmcli con reload
systemctl restart network
nmcli con show ${NW_NAME} | grep -i ipv4
echo -e "\033[36m@@@[E]_[HOST NETWORK CONFIGRUE] ==> ${BASTION_IP}\033[0m"
echo -e "\033[32m=============================================================================[E]\033[0m"
