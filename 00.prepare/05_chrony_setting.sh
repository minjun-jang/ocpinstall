#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/config/openshift.env"

echo -e "\033[32m[S]=============================================================================\033[0m"
echo -e "\033[46m@@@[S]_[YUM INSTALL CHRONY] ==> ${CHRONY_SERVER}\033[0m"
Asystemctl stop ntpd
systemctl disable ntpd
timedatectl set-timezone Asia/Seoul
timedatectl status
yum -y remove ntp
yum -y install chrony
sed -i "s/^server/#server/g" /etc/chrony.conf
sed -i "s/^allow/#allow/g" /etc/chrony.conf
sed -i "s/^local/#local/g" /etc/chrony.conf
sed -i'' -r -e "/#server\ 3.rhel.pool.ntp.org\ iburst/a\server\ bastion.${DNS_DOMAIN}\ iburst" /etc/chrony.conf
sed -i'' -r -e "/^#allow\ 192.168.0.0\/16/a\allow\ ${CHRONY_ALLOW}" /etc/chrony.conf
sed -i'' -r -e "/^#local\ stratum\ 10/a\local\ stratum\ ${CHRONY_STRATUM}" /etc/chrony.conf
firewall-cmd --permanent --add-port=123/udp
firewall-cmd --reload
systemctl enable chronyd
systemctl restart chronyd
chronyc sources -v
chronyc tracking
echo -e "\033[36m@@@[E]_[YUM INSTALL CHRONY] ==> ${CHRONY_SERVER}\033[0m"
echo -e "================================================================================[E]"
