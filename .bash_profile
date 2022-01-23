#!/bin/bash
# https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html

chmod 0700 ~/.gnupg

gpg --quiet --import ~/.gnupg/secret.key

if [ ! -f ~/.ssh/id_rsa ]; then
    gpg --quiet --yes -r mail@codiy.net -o ~/.ssh/id_rsa -d data/.ssh/id_rsa
fi

chmod 0400 ~/.ssh/id_rsa

export PATH="/root/bin:${PATH}"
export PS1='shsm:\w\$ '
