#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/config/openshift.env"

echo -e "\033[32m[S]=============================================================================\033[0m"
echo -e "\033[46m@@@[S]_[REPO CONFIG CHANGE]\033[0m"
sed "s/###LOCAL_REPO_PATH###/${LOCAL_REPO_PATH}/g" ${ABSOLUTE_PATH}/config/local.sample > ${ABSOLUTE_PATH}/config/local.repo
sed "s/###REPO_IP###/${REPO_IP}\:${REPO_PORT}/g" ${ABSOLUTE_PATH}/config/ocp45.sample > ${ABSOLUTE_PATH}/config/ocp45.repo
echo -e "\033[36m@@@[E]_[REPO CONFIG CHANGE]\033[0m"

echo -e "--------------------------------------------------"
echo -e "\033[46m@@@[S]_[REPO FILE COPY] ==> ${REPO_IP}\033[0m"
yes|cp -rp ${ABSOLUTE_PATH}/config/local.repo /etc/yum.repos.d/
yes|cp -rp ${ABSOLUTE_PATH}/config/ocp45.repo /etc/yum.repos.d/ocp45
yes|mv  /etc/yum.repos.d/redhat.repo /etc/yum.repos.d/redhat
echo -e "\033[36m@@@[E]_[REPO FILE COPY] ==> ${REPO_IP}\033[0m"

echo -e "--------------------------------------------------"
echo -e "\033[46m@@@[S]_[HTTPD INSTALL & BASTION YUM REPOLIST] ==> ${REPO_IP}\033[0m"
yum clean all
yum repolist
yum -y install httpd
if [ ! -d "/var/www/html/repos" ]; then
  cp -R ${BASTION_DIR}/99.download/repos /var/www/html/repos
fi
chmod -R +r /var/www/html/repos
restorecon -vR /var/www/html
sed -i "s/Listen\ 80/Listen\ ${REPO_PORT}/g" /etc/httpd/conf/httpd.conf
firewall-cmd --permanent --add-port=${REPO_PORT}/tcp
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
systemctl enable httpd; 
systemctl restart httpd; 
yes|mv /etc/yum.repos.d/redhat.repo /etc/yum.repos.d/redhat
yes|mv /etc/yum.repos.d/local.repo /etc/yum.repos.d/local
yes|mv /etc/yum.repos.d/ocp45 /etc/yum.repos.d/ocp45.repo
yum clean all
yum repolist
echo -e "\033[36m@@@[E]_[HTTPD INSTALL & REPOLIST] ==> ${REPO_IP}\033[0m"
echo -e "\033[32m=============================================================================[E]\033[0m"
