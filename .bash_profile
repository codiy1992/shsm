#!/bin/bash
# https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html

find ~/.gnupg -type f -exec chmod 600 {} \; # Set 600 for files
find ~/.gnupg -type d -exec chmod 700 {} \; # Set 700 for directories

gpg --quiet --import ~/.gnupg/secret.key

if [ ! -f ~/.ssh/id_rsa ]; then
    gpg --quiet --yes -r mail@codiy.net -o ~/.ssh/id_rsa -d ~/.gnupg/id_rsa.gpg
    chmod 0400 ~/.ssh/id_rsa
fi

if [ ! -f ~/.ssh/config ]; then
    echo '-----BEGIN PGP MESSAGE-----

hF4D+yQAOXOmX7ISAQdA+VfAHnuTodjIJPxfJ6TJAnfmKzzeimprwkB8Y2MSp3Aw
bUxq680VJ0gcAGIHLCD2geePRiGYyf2HXjG10sIsazvBn2VmSVNl6tQdOJLfdHVm
0p0B4Z1xiBv7TY1I+gf/3YJloVHCELpqk7Jwa+Hf0NQ/vePPc8YVnlpLlM3R84+i
5Gn6Wh4ro//9FKkemnOTdwCTRJiYfnU+A5G8z7W1kL7eUDPKsPrrX/IxQch7G3vp
9iFBUZafFXI1hBAcIYvgSv+wh2uGEHE1bzj9JyL3G8t/wVJ4n7/QlZyZ/oKZm1ad
HzJWlkXE5VAg6tSjnJRi
=iqOo
-----END PGP MESSAGE-----' > /tmp/ssh_config
    gpg --quiet --yes -r mail@codiy.net -o ~/.ssh/config -d /tmp/ssh_config
fi

(ssh-keygen -F github.com 1> /dev/null || ssh-keyscan github.com) 2> /dev/null >> ~/.ssh/known_hosts
(ssh-keygen -F git-codecommit.us-east-1.amazonaws.com 1> /dev/null || ssh-keyscan git-codecommit.us-east-1.amazonaws.com) 2> /dev/null >> ~/.ssh/known_hosts

if [ ! -d ~/data ]; then
    git clone ssh://git-codecommit.us-east-1.amazonaws.com/v1/repos/shsm ~/data
fi

export PATH="/root/bin:${PATH}"
export PS1='shsm:\w\$ '

git pull
cd ~/data
git pull
cd
