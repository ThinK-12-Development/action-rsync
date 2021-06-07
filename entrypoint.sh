#!/bin/sh

set -eu

#
# Prepare SSH config
#

mkdir .ssh

echo "$INPUT_KEY" > remote.key
echo "$INPUT_PROXY_KEY" > proxy.key

echo "Host destination" > .ssh/config
echo " User $INPUT_USER" >> .ssh/config
echo " HostName $INPUT_HOST" >> .ssh/config
echo " StrictHostKeyChecking=no" >> .ssh/config
echo " IdentityFile ~/.ssh/remote.key" >> .ssh/config
echo " ProxyJump proxy" >> .ssh/config

echo "Host proxy" > .ssh/config
echo " User $INPUT_PROXY_USER" >> .ssh/config
echo " HostName $INPUT_PROXY_HOST" >> .ssh/config
echo " StrictHostKeyChecking=no" >> .ssh/config
echo " IdentityFile ~/.ssh/proxy.key" >> .ssh/config

chmod 600 .ssh
chmod 400 .ssh/config
chmod 400 remote.key
chmod 400 proxy.key

mv remote.key .ssh
mv proxy.key .ssh

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
      "$INPUT_SOURCE" destination:"$INPUT_DESTINATION"
