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

hQGMA4UngdkzpqQSAQv+LYK/0aw+9MSzS7Z+Mzf8raF3VCbh7vBVJ+Mtvzm5F4/3
yDLSZeRP4i+o41Ux30JqxnMO5FOMZ5EFWWpP8hYYU3N2tmEHdEFQyltxHXUWBsnI
4ApGg7hYgqgaUn/MMyJeTqotoa8wnBrVP3nf0uzpjwhJsC/3uhvrIfVNZQwHmOQM
LnGaWjHWxwz6z1Biitj91MMsD9Le0N2/TkruSIaNbmDh2Uq2rCE5hskF3EU+yYrl
Zr9Tx3CYc5h3uHHUl0UOQSreNNZrkoMS5rdBm6FY1yHeLt5EscZxqS9BeaT00NbA
PpWtcaXaQ/Mzx3dJqjI7dWVtXF098CpoUhKr8bdca8CDYUOr1MivW2o56eJC7b7b
R0+Z2M0eHhYIt+12DIznwRa7YdBZNDP7MqYUONK96Uf2g8P6IYM2STN88jvqCZn5
MvWyVSN6Vo/b0CFuFxIWHYxF/2yLFLaBcUVAWFW5LKHa9xFN+fIxQ3tKrcB0zoCM
tMRLxF9W9MuebyhspOOf0p0BVHGU+fy30ePWcTHovDUD0pttT+tylk0cAZD/QGMA
l0DhDVXK9vUbOcfH2VDekUtbKq/cZ+IxvmwzEhtmeVCjGb+RlwXEHhAit6raVGF+
aNgUbMs0qizp/rHVG9VuIOLmfits6I4xSx2W+TZTZO4jz0RirblQZlykEeMdjYqJ
7UDexwc1vrcIlOyFuLKec4kb75CCfUWd3+uwSpzX
=mkha
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
