#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/../00.prepare/config/openshift.env"

FILE_NAME=openshift4.4_repos_$(date +%Y%m%d).tar.gz

#tar zcvf - ${ABSOLUTE_PATH}/repos | split -b 3700M - ${ABSOLUTE_PATH}/${FILE_NAME}
tar zcvf - ./repos | split -b 3700M - ./${FILE_NAME}

#Ex> cat /root/.openshift/v4.4/00.prepare/openshift4.4_repos_20200717.tar.gz* | tar zxvf -
