#!/bin/sh

ABSOLUTE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${ABSOLUTE_PATH}/config/openshift.env"

if [[ -z $(grep "### OpenShift" ~/.bashrc) ]]; then
echo -e "\n######################
### OpenShift v${OPENSHIFT_VERSION} ###
######################
export KUBECONFIG=${INSTALL_DIR}/auth/kubeconfig
alias ocp=\"cd ${BASTION_DIR}\"
" >> ~/.bashrc
fi

if [ -f "${HOME}/.ssh/id_rsa" ];
then
  echo -e "\033[32m[S]=============================================================================\033[0m"
      echo -e "\033[46m@@@[S]_[SSH KEY CREATE] ==> ${BASTION_IP}\033[0m"
      echo -e "File already exists!!!"
      echo -e "\033[36m@@@[E]_[SSH KEY CREATE] ==> ${BASTION_IP}\033[0m"
      echo -e "--------------------------------------------------"
  echo -e "\033[32m=============================================================================[E]\033[0m"
else
  echo -e "\033[32m[S]=============================================================================\033[0m"
      echo -e "\033[46m@@@[S]_[SSH KEY CREATE] ==> ${BASTION_IP}\033[0m"
      echo -e "[Generation public/private rsa key pair.]"
      echo -e " \$ ssh-keygen -t rsa -b 4096"
      echo -e "\033[36m@@@[E]_[SSH KEY CREATE] ==> ${BASTION_IP}\033[0m"
      echo -e "--------------------------------------------------"
  echo -e "\033[32m=============================================================================[E]\033[0m"
fi  

echo -e " \$ eval \"\$(ssh-agent -s)\""
echo -e "   Agent pid {PID}"
echo -e " \$ ssh-add ~/.ssh/id_rsa"
echo -e "   Identity added: /root/.ssh/id_rsa (/root/.ssh/id_rsa)"
