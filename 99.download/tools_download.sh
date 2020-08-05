#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/../00.prepare/config/openshift.env"

OPENSHIFT_RELEASE=4.5.1
#OPENSHIFT_RELEASE=$(curl -s https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${OPENSHIFT_VERSION}/latest/sha256sum.txt | cut -d "-" -f2 | uniq)
#BUILD_VERSION=$(curl -s https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/release.txt | grep 'Name:' | awk '{print $NF}')
BUILD_VERSION=${OPENSHIFT_RELEASE}

echo OPENSHIFT_RELEASE=${OPENSHIFT_RELEASE}
echo BUILD_VERSION=${BUILD_VERSION}

echo -e "\033[32m[S]=============================================================================\033[0m"
echo -e "\033[46m@@@[S]_[TOOLS DOWNLOAD]\033[0m"
echo -e "----- [installer download]"
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${BUILD_VERSION}/openshift-install-linux-${BUILD_VERSION}.tar.gz -P ${ABSOLUTE_PATH}/install
echo -e "----- [client download]"
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${BUILD_VERSION}/openshift-client-linux-${BUILD_VERSION}.tar.gz -P ${ABSOLUTE_PATH}/client/
echo -e "----- [rhcos download]"
#wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${OPENSHIFT_VERSION}/${BUILD_VERSION}/rhcos-${OPENSHIFT_RELEASE}-x86_64-installer.x86_64.iso -P ${ABSOLUTE_PATH}/rhcos/
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${OPENSHIFT_VERSION}/${BUILD_VERSION}/rhcos-${OPENSHIFT_RELEASE}-x86_64-metal.x86_64.raw.gz -P ${ABSOLUTE_PATH}/rhcos/
#echo -e "----- [unzip tools --> /usr/local/bin]"
#tar -xzf ${ABSOLUTE_PATH}/client/openshift-client-linux-${BUILD_VERSION}.tar.gz -C /usr/local/bin/
#tar -xzf ${ABSOLUTE_PATH}/install/openshift-install-linux-${BUILD_VERSION}.tar.gz -C /usr/local/bin/
#rm -rf ${ABSOLUTE_PATH}/install/openshift-install-linux-*
#rm -rf ${ABSOLUTE_PATH}/client/openshift-client-linux-*
#rm -rf /usr/local/bin/README.md
echo -e "\033[36m@@@[E]_[TOOLS DOWNLOAD]\033[0m"
echo -e "\033[32m=============================================================================[E]\033[0m"
