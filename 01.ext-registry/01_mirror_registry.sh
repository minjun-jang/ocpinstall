#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/../00.prepare/config/openshift.env"

echo -e "\033[32m[S]=============================================================================\033[0m"
echo -e "\033[46m@@@[S]_[MIRRORING REGISTRY]\033[0m"
echo -e "----- [create pull-secret.json]"
sed "s/###REGISTRY_URL###/${REGISTRY_URL}/g" ${ABSOLUTE_PATH}/config/ext-secret.sample |
sed "s/###REGISTRY_PORT###/${REGISTRY_PORT}/g" | 
sed "s/###REGISTRY_PASSWD###/${REGISTRY_PASSWD_ECD}/g" > ${ABSOLUTE_PATH}/config/ext-secret.json
#cat ${ABSOLUTE_PATH}/config/ext-secret.json | jq

cat ${ABSOLUTE_PATH}/config/pull-secret.org | jq ".auths += `cat ${ABSOLUTE_PATH}/config/ext-secret.json | jq .auths`" | jq -c . > ${ABSOLUTE_PATH}/config/pull-secret.json
#cat ${ABSOLUTE_PATH}/config/pull-secret.json | jq

echo -e "----- [login ext-registry]"
podman login -u ${REGISTRY_USER} -p ${REGISTRY_PASSWD} --authfile ${ABSOLUTE_PATH}/config/pull-secret.json ${REGISTRY_URL}:${REGISTRY_PORT}

echo -e "----- [mirroring]"
export OPENSHIFT_RELEASE=${OPENSHIFT_RELEASE}-x86_64
export LOCAL_REGISTRY=${REGISTRY_URL}:${REGISTRY_PORT}
export LOCAL_REPOSITORY='ocp4/openshift4' 
export PRODUCT_REPO='openshift-release-dev' 
export LOCAL_SECRET_JSON=${ABSOLUTE_PATH}/config/pull-secret.json
export RELEASE_NAME="ocp-release" 
oc adm -a ${LOCAL_SECRET_JSON} release mirror \
--from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OPENSHIFT_RELEASE} \
--to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
--to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OPENSHIFT_RELEASE}
echo -e "\033[36m@@@[E]_[MIRRORING REGISTRY]\033[0m"
echo -e "\033[32m=============================================================================[E]\033[0m"
