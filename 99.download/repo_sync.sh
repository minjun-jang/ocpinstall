#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/../00.prepare/config/openshift.env"

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

for repo in \
rhel-7-server-rpms \
rhel-7-server-extras-rpms \
rhel-7-server-ose-${OPENSHIFT_VERSION}-rpms
do
  reposync -n --gpgcheck -l --repoid=${repo} --download_path=${ABSOLUTE_PATH}/repos
#  reposync --gpgcheck -lm --repoid=${repo} --download_path=${ABSOLUTE_PATH}/repos
  createrepo -v ${ABSOLUTE_PATH}/repos/${repo} -o ${ABSOLUTE_PATH}/repos/${repo}
done
