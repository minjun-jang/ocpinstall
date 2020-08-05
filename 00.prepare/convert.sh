#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/config/openshift.env"

nodes=(`cat ${OPENSHIFT_NODES}`)



# ================
# Common functions
# ================
_usage() {
    echo -e "Usage : convert.sh [COMMAND] {OPTION}"
    echo -e "\tCOMMAND - getHostname | getIP | setDNS | check DNS | setHAProxy | setInstallConfig | SetIgnition"
    echo -e "\tOPTION - bastion | bootstrap | master | rotuer | infra | worker | all"

}

_getHostname(){
    if [ "e${1}" == "ebastion" ]; then
        echo `grep "^BASTION=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f2`
    elif [ "e${1}" == "ebootstrap" ]; then
        echo `grep "^BOOTSTRAP=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f2`
    elif [ "e${1}" == "emaster" ]; then
        echo `grep "^MASTER=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f2`
    elif [ "e${1}" == "erouter" ]; then
        echo `grep "^ROUTER=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f2`
    elif [ "e${1}" == "einfra" ]; then
        echo `grep "^INFRA=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f2`
    elif [ "e${1}" == "eworker" ]; then
        echo `grep "^WORKER=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f2`
    elif [ "e${1}" == "eall" ]; then
        for index in ${!nodes[*]}
        do
            if [ ${index} != 0 ] && [ `echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f1` != 0 ]; then
                domain_list=($(echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f2 | tr "|" " "))
                #ip_list=($(echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f3| tr "|" " "))
                for ((count=0; count<${#domain_list[@]}; count++)); do
                    echo ${domain_list[$count]}
                done
            fi
        done
    else
        _usage
    fi

}

_getIP(){
    if [ "e${1}" == "ebastion" ]; then
        echo `grep "^BASTION=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f3`
    elif [ "e${1}" == "ebootstrap" ]; then
        echo `grep "^BOOTSTRAP=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f3`
    elif [ "e${1}" == "emaster" ]; then
        echo `grep "^MASTER=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f3`
    elif [ "e${1}" == "erouter" ]; then
        echo `grep "^ROUTER=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f3`
    elif [ "e${1}" == "einfra" ]; then
        echo `grep "^INFRA=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f3`
    elif [ "e${1}" == "eworker" ]; then
        echo `grep "^WORKER=" ${OPENSHIFT_NODES} | cut -d '=' -f2 | cut -d "," -f3`
    elif [ "e${1}" == "eall" ]; then
        for index in ${!nodes[*]}
        do
            if [ ${index} != 0 ] && [ `echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f1` != 0 ]; then
                ip_list=($(echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f3| tr "|" " "))
                for ((count=0; count<${#ip_list[@]}; count++)); do
                    echo ${ip_list[$count]}
                done
            fi
        done
    else
        _usage
    fi
}

_checkDNS(){
for index in ${!nodes[*]}
do
    if [ "e${1}" != "e" ] && [ `echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f1` != 0 ]; then
        domain_list=($(echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f2 | tr "|" " "))
        ip_list=($(echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f3| tr "|" " "))
        for ((count=0; count<${#domain_list[@]}; count++)); do
            if [ "e${1}" == "eip" ]; then
                echo -e "\033[32m> dig -x ${ip_list[$count]} +short\033[0m"
                dig -x ${ip_list[$count]} +short
            elif [ "e${1}" == "ehost" ]; then
                echo -e "\033[33m> nslookup ${domain_list[$count]}.${DNS_DOMAIN}\033[0m"
                nslookup ${domain_list[$count]}.${DNS_DOMAIN}
            fi
        done
    fi
done

}

_setDNS(){
for index in ${!nodes[*]}
do
    if [ ${index} != 0 ] && [ `echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f1` != 0 ]; then
        #count=`echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f1`
        domain_list=($(echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f2 | tr "|" " "))
        ip_list=($(echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f3| tr "|" " "))
        for ((count=0; count<${#domain_list[@]}; count++)); do
            #echo -e "${domain_list[$count]}\tIN A\t${ip_list[$count]}"
            sed -i "s/;;;NODES;;;/${domain_list[$count]}.${CLUSTER_NAME}\t\tIN A\t\t${ip_list[$count]}\n;;;NODES;;;/g" ${BASTION_DIR}/00.prepare/config/dns/${BASE_DOMAIN}.zone 
            sed -i "s/;;;NODES;;;/$(echo ${ip_list[$count]} | cut -d '.' -f4)\t\tIN PTR\t${domain_list[$count]}.${DNS_DOMAIN}.\n;;;NODES;;;/g" ${BASTION_DIR}/00.prepare/config/dns/${BASE_DOMAIN}.rr.zone 
        done
    fi
done
sed -i "s/;;;NODES;;;//g" ${BASTION_DIR}/00.prepare/config/dns/${BASE_DOMAIN}.zone
sed -i "s/;;;NODES;;;//g" ${BASTION_DIR}/00.prepare/config/dns/${BASE_DOMAIN}.rr.zone

}

_setHAProxy(){
for index in ${!nodes[*]}
do
    domain_list=($(echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f2 | tr "|" " "))
    ip_list=($(echo ${nodes[$index]}|cut -d "=" -f2|cut -d "," -f3| tr "|" " "))
    if [ ${index} == 1 ]; then
        #echo "[${domain_list[0]} ${ip_list[0]}]"
        sed "s/###BOOTSTRAP6443###/\ \ \ \ server\ ${domain_list[0]}\ ${ip_list[0]}\:6443\ check/g" ${BASTION_DIR}/00.prepare/config/haproxy.cfg.sample |
        sed "s/###BOOTSTRAP22623###/\ \ \ \ server\ ${domain_list[0]}\ ${ip_list[0]}\:22623\ check/g" > ${BASTION_DIR}/00.prepare/config/haproxy.cfg
    elif [ ${index} == 2 ]; then
        for ((count=0; count<${#domain_list[@]}; count++)); do
            #echo "[${domain_list[$count]} ${ip_list[$count]}]"
            sed -i "s/###MASTER6443###/\ \ \ \ server\ ${domain_list[$count]}\ ${ip_list[$count]}\:6443\ check\n###MASTER6443###/g" ${BASTION_DIR}/00.prepare/config/haproxy.cfg
            sed -i "s/###MASTER22623###/\ \ \ \ server\ ${domain_list[$count]}\ ${ip_list[$count]}\:22623\ check\n###MASTER22623###/g" ${BASTION_DIR}/00.prepare/config/haproxy.cfg
        done
    elif [ ${index} == 3 ] && [ `echo ${nodes[3]}|cut -d "=" -f2|cut -d "," -f1` != 0 ]; then
        for ((count=0; count<${#domain_list[@]}; count++)); do
            #echo "[${domain_list[$count]} ${ip_list[$count]}]"
            sed -i "s/###ROUTER80###/\ \ \ \ server\ ${domain_list[$count]}\ ${ip_list[$count]}\:6443\ check\n###ROUTER80###/g" ${BASTION_DIR}/00.prepare/config/haproxy.cfg
            sed -i "s/###ROUTER443###/\ \ \ \ server\ ${domain_list[$count]}\ ${ip_list[$count]}\:22623\ check\n###ROUTER443###/g" ${BASTION_DIR}/00.prepare/config/haproxy.cfg
        done
    elif [ ${index} == 4 ] && [ `echo ${nodes[3]}|cut -d "=" -f2|cut -d "," -f1` == 0 ]; then
        for ((count=0; count<${#domain_list[@]}; count++)); do
            #echo "[${domain_list[$count]} ${ip_list[$count]}]"
            sed -i "s/###ROUTER80###/\ \ \ \ server\ ${domain_list[$count]}\ ${ip_list[$count]}\:6443\ check\n###ROUTER80###/g" ${BASTION_DIR}/00.prepare/config/haproxy.cfg
            sed -i "s/###ROUTER443###/\ \ \ \ server\ ${domain_list[$count]}\ ${ip_list[$count]}\:22623\ check\n###ROUTER443###/g" ${BASTION_DIR}/00.prepare/config/haproxy.cfg
        done
    fi
done
sed -i "/^###/d" ${BASTION_DIR}/00.prepare/config/haproxy.cfg

}

_setInstallConfig(){
SSH_PUB=$(cat /root/.ssh/id_rsa.pub | sed "s/\//\\\\\//g" | sed "s/\ /\\\ /g")
EXT_REGISTRY_CERT=($(cat /opt/registry/certs/domain.crt | sed "s/\//\\\\\//g" | sed "s/\ /\\\ /g" | sed "s/\ CERTIFICATE-----/@/g"))

yes|cp -rp ${BASTION_DIR}/00.prepare/config/install-config.org ${BASTION_DIR}/00.prepare/config/install-config.sample

for index in ${!EXT_REGISTRY_CERT[@]}
do
    LINE=$(echo ${EXT_REGISTRY_CERT[$index]} | awk '{ printf "  %s", $0}')
    if [ `expr ${index} + 1` == ${#EXT_REGISTRY_CERT[@]} ]; then
        sed -i "s/###EXT_REGISTRY_CERT###/${LINE}/g" ${BASTION_DIR}/00.prepare/config/install-config.sample
        sed -i "s/@/\ CERTIFICATE-----/g" ${BASTION_DIR}/00.prepare/config/install-config.sample
    else
        sed -i "s/###EXT_REGISTRY_CERT###/${LINE}\n###EXT_REGISTRY_CERT###/g" ${BASTION_DIR}/00.prepare/config/install-config.sample
    fi
done

sed "s/###BASE_DOMAIN###/${BASE_DOMAIN}/g" ${BASTION_DIR}/00.prepare/config/install-config.sample |
sed "s/###CLUSTER_NAME###/${CLUSTER_NAME}/g" |
sed "s/###PULL_SECRET###/$(cat ${BASTION_DIR}/01.ext-registry/config/pull-secret.json | jq -c)/g" |
sed "s/###SSH_PUB###/${SSH_PUB}/g" |
sed "s/###REGISTRY_URL###/${REGISTRY_URL}/g" |
sed "s/###REGISTRY_PORT###/${REGISTRY_PORT}/g" > ${BASTION_DIR}/00.prepare/config/install-config.yaml

}

_setIgnition(){
NODES_NAME=(`_getHostname all`)
NODES_IP=(`_getIP all`)
NET_BASE64=""
TEMP_IGN=""

for index in ${!NODES_NAME[@]}
do
    sed "s/###NODE_IP###/${NODES_IP[$index]}/g" ${BASTION_DIR}/00.prepare/config/net.sample |
    sed "s/###NODE_NETMASK###/${NODE_NW_NETMASK}/g" |
    sed "s/###NODE_GATEWAY###/${NODE_NW_GATEWAY}/g" |
    sed "s/###NODE_DEVICE_NAME###/${NODE_NW_NAME}/g" |
    sed "s/###DNS_DOMAIN###/${DNS_DOMAIN}/g" |
    sed "s/###DNS_IP###/${DNS_IP}/g" > /var/www/html/ign/net/${NODES_NAME[$index]}-net.txt
    NET_BASE64=$(cat /var/www/html/ign/net/${NODES_NAME[$index]}-net.txt | base64 -w0)
    echo -e "[${NODES_NAME[$index]}]\n${NET_BASE64}\n" >> /var/www/html/ign/net/nodes-net.txt

    TEMP_IGN=$(sed "s/###NODE_IP###/${NODES_IP[$index]}/g" ${BASTION_DIR}/00.prepare/config/nodes-ign.sample |
    sed "s/###NODE_DOMAIN###/${NODES_NAME[$index]}.${DNS_DOMAIN}/g" |
    sed "s/###NET_BASE64###/${NET_BASE64}/g" |
    sed "s/###NODE_NW_NAME###/${NODE_NW_NAME}/g" | jq -c)

    #echo ${TEMP_IGN} > /var/www/html/ign/net/${NODES_NAME[$index]}-tmp.ign

    if [ ${NODES_NAME[$index]} == "bootstrap" ]; then
        cat ${INSTALL_DIR}/bootstrap.ign | jq ".storage.files += $(echo ${TEMP_IGN} | jq .storage.files)" | jq -c . > /var/www/html/ign/${NODES_NAME[$index]}.ign
    elif [[ ${NODES_NAME[$index]} == *"master"* ]]; then
        cat ${INSTALL_DIR}/master.ign | jq ".storage.files += $(echo ${TEMP_IGN} | jq .storage.files)" | jq -c . > /var/www/html/ign/${NODES_NAME[$index]}.ign
    else
        cat ${INSTALL_DIR}/worker.ign | jq ".storage.files += $(echo ${TEMP_IGN} | jq .storage.files)" | jq -c . > /var/www/html/ign/${NODES_NAME[$index]}.ign
    fi
done

}

_setChrony(){
CHRONY="$(echo "server ${CHRONY_SERVER} iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony" | base64 -w0)"
echo ${CHRONY}
cat << EOF > ${INSTALL_DIR}/manifests/99-masters-chrony-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: masters-chrony-configuration
spec:
  config:
    ignition:
      config: {}
      security:
        tls: {}
      timeouts: {}
      version: 2.2.0
    networkd: {}
    passwd: {}
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,${CHRONY}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/chrony.conf
  osImageURL: ""
EOF

cat << EOF > ${INSTALL_DIR}/manifests/99-workers-chrony-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker 
  name: workers-chrony-configuration
spec:
  config:
    ignition:
      config: {}
      security:
        tls: {}
      timeouts: {}
      version: 2.2.0
    networkd: {}
    passwd: {}
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,${CHRONY}
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/chrony.conf
  osImageURL: ""
EOF
}




# ================
# Main functions
# ================
_main(){
if [ -z $1 ]; then
    _usage
    exit 1;
elif [ "e${1}" != "egetHostname" ] && [ "e${1}" != "egetIP" ] && [ "e${1}" != "echeckDNS" ] && [ "e${1}" != "esetDNS" ] && [ "e${1}" != "esetHAProxy" ] && [ "e${1}" != "esetInstallConfig" ] && [ "e${1}" != "esetIgnition" ] && [ "e${1}" != "esetChrony" ]; then
    _usage
    exit 1;
elif [ "e${1}" != "esetChrony" ] && [ "e${1}" != "esetIgnition" ] && [ "e${1}" != "esetInstallConfig" ] && [ "e${1}" != "esetHAProxy" ] && [ "e${1}" != "esetDNS" ] && [ "e${1}" != "echeckDNS" ] && [ "e${2}" != "ebastion" ] && [ "e${2}" != "emaster" ] && [ "e${2}" != "ebootstrap" ] && [ "e${2}" != "erouter" ] && [ "e${2}" != "einfra" ] && [ "e${2}" != "eworker" ] && [ "e${2}" != "eall" ]; then
    _usage
    exit 1;
fi

echo -e "`_${1} ${2}`"

}

# ================
# Main Logic
# ================
_main ${1} ${2}
