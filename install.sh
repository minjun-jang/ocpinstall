#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/00.prepare/config/openshift.env"

CVTSHL=${ABSOLUTE_PATH}/00.prepare/convert.sh

_usage() {
    echo -e "Usage: $0 [ clean | rm | manifests | ignition | custom | coreos | mon ] "
    echo -e "\t\t(extras) [ get_images | prep_installer | prep_images ]"
}

_clean() {
    echo -e "\033[36m[Clean(move) Install Directory!!!]\033[0m"
    echo -e "\033[44mmoving installation folder - ${INSTALL_DIR} -> ${INSTALL_DIR}_${DATETIME}\033[0m"
    mv ${INSTALL_DIR} ${INSTALL_DIR}_${DATETIME}
    mv /var/www/html/ign /var/www/html/ign_${DATETIME}
    ##rm -fr ${INSTALL_DIR}
}

_rm() {
    echo -e "\033[36m[Remove Install Directory!!!]\033[0m"
    echo -e "\033[44mremove installation folder - ( ${INSTALL_DIR}_* ), ( /var/www/html/ign_* )\033[0m"
    rm -rf ${INSTALL_DIR}_*
    rm -rf /var/www/html/ign_*
}

_manifests() {
    echo -e "\033[36m[Creating and populating installation folder]\033[0m"
    if [ -d ${INSTALL_DIR} ]; then
        echo -e "\033[44mDirectory(${INSTALL_DIR}) already exists\033[0m"
        exit 1;
    fi
    mkdir -p ${INSTALL_DIR}
    . ${CVTSHL} setInstallConfig
    yes | cp -rf ${BASTION_DIR}/00.prepare/config/install-config.yaml ${INSTALL_DIR}/install-config.yaml
    yes | cp -rf ${BASTION_DIR}/00.prepare/config/install-config.yaml ${INSTALL_DIR}/install-config.yaml.back
    echo -e "\033[44mGenerating manifests files\033[0m"
    openshift-install create manifests --dir=${INSTALL_DIR}
    echo -e "\033[44mChange Option - mastersSchedulable: flase\033[0m"
    sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' ${INSTALL_DIR}/manifests/cluster-scheduler-02-config.yml
    cat ${INSTALL_DIR}/manifests/cluster-scheduler-02-config.yml
    . ${CVTSHL} setChrony
}

_ignition() {
    echo -e "\033[36m[Creating and populating installation folder]\033[0m"
    if [ ! -d ${INSTALL_DIR}/manifests ]; then
        echo -e "\033[44mRun it first! ( manifests ) \033[0m"
        exit 1;
    fi
    echo -e "\033[44mGenerating ignition files\033[0m"
    openshift-install create ignition-configs --dir=${INSTALL_DIR}
    touch ${INSTALL_DIR}/${DATETIME}
}

_custom() {
echo -e "\033[36m[Create Ignition Files]\033[0m"
if [ -d /var/www/html/ign ]; then
    echo -e "\033[44mDirectory(/var/www/html/ign}) already exists\033[0m"
    echo -e "\033[44mMove Directory(/var/www/html/ign_${DATETIME})\033[0m"
    mv /var/www/html/ign /var/www/html/ign_${DATETIME}
    ls -d /var/www/html/ign /var/www/html/ign_${DATETIME}
fi

echo -e "\033[44mCreate Directory(mkdir -p /var/www/html/ign/net)\033[0m"
mkdir -p /var/www/html/ign/net
ls -d /var/www/html/ign/net

echo -e "\033[44mSetting Ignition Files\033[0m"
. ${CVTSHL} setIgnition
ls /var/www/html/ign/*.ign

}

_coreos() {
NODES_NAME=($(. ${CVTSHL} getHostname all))
NODES_IP=($(. ${CVTSHL} getIP all))

echo -e "\033[36m[COREOS INSTALL CONFIGURE]\033[0m"
for index in ${!NODES_NAME[@]}
do
    echo -e "\033[44m[${NODES_NAME[$index]}]\033[0m"
    echo -e "coreos.inst.install_dev=sda coreos.inst.image_url=http://${REPO_IP}:${REPO_PORT}/bios.raw.gz" 
    echo -e "coreos.inst.ignition_url=http://${REPO_IP}:${REPO_PORT}/ign/${NODES_NAME[$index]}.ign"
    echo -e "ip=${NODES_IP[$index]}::${NODE_NW_GATEWAY}:${NODE_NW_NETMASK}:${NODES_NAME[$index]}.${DNS_DOMAIN}:${NODE_NW_NAME}:none nameserver=${NW_DNS1}"
done

}

_monitoring() {
CMD=""
if [ "e${1}" == "ebootstrap" ]; then
    CMD="openshift-install wait-for bootstrap-complete --dir=${INSTALL_DIR} --log-level debug"
    ${CMD}
elif [ "e${1}" == "enodes" ]; then
    CDM="openshift-install wait-for install-complete --dir=${INSTALL_DIR} --log-level debug"
    ${CMD}
else
    echo -e "\033[36m[Input Opttion]\033[0m"
    echo -e "\033[44m./install mon {bootstrap|nodes}\033[0m"
fi
}







# Capture First param
key="$1"

case $key in
    clean)
        _clean
        ;;
    rm)
        _rm
        ;;
    manifests)
        _manifests
        ;;
    ignition)
        _ignition
        ;;
    custom)
        _custom
        ;;
    coreos)
        _coreos 
        ;;
    mon)
        _monitoring ${2}
        ;;
    *)
        _usage
        ;;
esac

