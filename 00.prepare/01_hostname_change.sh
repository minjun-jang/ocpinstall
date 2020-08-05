#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/config/openshift.env"

echo -e "\033[32m[S]=============================================================================\033[0m"
echo -e "--------------------------------------------------"
echo -e "\033[46m@@@[S]_[HOST NAME CHANGE] ==> ${BASTION_IP}\033[0m"
hostnamectl set-hostname bastion.${DNS_DOMAIN}
hostname
echo -e "\033[36m@@@[E]_[HOST NAME CHANGE] ==> ${BASTION_IP}\033[0m"
echo -e "\033[32m=============================================================================[E]\033[0m"
