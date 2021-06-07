#!/bin/sh

set -eu

#
# Prepare SSH config
#

echo "$INPUT_KEY" > /etc/ssh/remote.key
echo "$INPUT_PROXY_KEY" > /etc/ssh/proxy.key

chmod 400 /etc/ssh/remote.key
chmod 400 /etc/ssh/proxy.key

echo "Host destination" >> /etc/ssh/ssh_config
echo " User $INPUT_USER" >> /etc/ssh/ssh_config
echo " HostName $INPUT_HOST" >> /etc/ssh/ssh_config
echo " StrictHostKeyChecking=no" >> /etc/ssh/ssh_config
echo " IdentityFile ~/.ssh/remote.key" >> /etc/ssh/ssh_config
echo " ProxyJump proxy" >> /etc/ssh/ssh_config

echo "Host proxy" >> /etc/ssh/ssh_config
echo " User $INPUT_PROXY_USER" >> /etc/ssh/ssh_config
echo " HostName $INPUT_PROXY_HOST" >> /etc/ssh/ssh_config
echo " StrictHostKeyChecking=no" >> /etc/ssh/ssh_config
echo " IdentityFile ~/.ssh/proxy.key" >> /etc/ssh/ssh_config

#
# Add default file exclusions
#

echo ".cache" > exclusions
echo ".docker" >> exclusions
echo ".env" >> exclusions
echo ".*.env" >> exclusions
echo ".git" >> exclusions
echo ".github" >> exclusions
echo ".storybook" >> exclusions
echo ".vscode" >> exclusions
echo "docker-compose.yml" >> exclusions
echo "Dockerfile" >> exclusions

chmod 400 exclusions

#
# Main
#

rsync --archive \
      --compress \
      --quiet \
      --recursive \
      --exclude-from exclusions \
      "$INPUT_SOURCE" "destination:$INPUT_DESTINATION"
