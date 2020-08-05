#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/config/openshift.env"

echo -e "\033[32m[S]=============================================================================\033[0m"
echo -e "\033[46m@@@[S]_[TOOLS SETTING]\033[0m"
echo -e "----- [copy rhcos [rhcos-${BUILD_VERSION}-x86_64-metal.x86_64.raw.gz] --> /var/www/html]"
yes|cp -rp ${BASTION_DIR}/99.download/rhcos/rhcos-${BUILD_VERSION}-x86_64-metal.x86_64.raw.gz /var/www/html/bios.raw.gz
echo -e "----- [unzip tools [openshift-client-linux-${BUILD_VERSION}.tar.gz] --> /usr/local/bin]"
tar -xzf ${BASTION_DIR}/99.download/client/openshift-client-linux-${BUILD_VERSION}.tar.gz -C /usr/local/bin/
echo -e "----- [unzip tools [openshift-install-linux-${BUILD_VERSION}.tar.gz] --> /usr/local/bin]"
tar -xzf ${BASTION_DIR}/99.download/install/openshift-install-linux-${BUILD_VERSION}.tar.gz -C /usr/local/bin/
#rm -rf ${BASTION_DIR}/99.download/install/openshift-install-linux-*
#rm -rf ${BASTION_DIR}/99.download/client/openshift-client-linux-*
rm -rf /usr/local/bin/README.md
oc completion bash >/etc/bash_completion.d/openshift
echo -e "\033[36m@@@[E]_[TOOLS SETTING]\033[0m"
echo -e "\033[32m=============================================================================[E]\033[0m"
