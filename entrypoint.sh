#!/bin/sh

set -eu

EXCLUSIONS_FILE=exclusions

REMOTE_SSH_KEY_FILE=remote.key
REMOTE_DESTINATION=$INPUT_USER@$INPUT_HOST:$INPUT_DESTINATION
REMOTE_SHELL="ssh -o StrictHostKeyChecking=no -i $REMOTE_SSH_KEY_FILE"

PROXY_SSH_KEY_FILE=proxy.key
PROXY_COMMAND="ssh -o StrictHostKeyChecking=no -i $PROXY_SSH_KEY_FILE $INPUT_PROXY_USER@$INPUT_PROXY_HOST -W %h:%p"
PROXY_SHELL="ssh -o 'ProxyCommand $PROXY_COMMAND'"

echo ".cache" > "$EXCLUSIONS_FILE"
echo ".docker" > "$EXCLUSIONS_FILE"
echo ".env" > "$EXCLUSIONS_FILE"
echo ".*.env" > "$EXCLUSIONS_FILE"
echo ".git" > "$EXCLUSIONS_FILE"
echo ".github" > "$EXCLUSIONS_FILE"
echo ".storybook" > "$EXCLUSIONS_FILE"
echo ".vscode" > "$EXCLUSIONS_FILE"
echo "docker-compose.yml" > "$EXCLUSIONS_FILE"
echo "Dockerfile" > "$EXCLUSIONS_FILE"

echo "$INPUT_KEY" > $REMOTE_SSH_KEY_FILE
echo "$INPUT_PROXY_KEY" > $PROXY_SSH_KEY_FILE

chmod 400 $EXCLUSIONS_FILE
chmod 400 $REMOTE_SSH_KEY_FILE
chmod 400 $PROXY_SSH_KEY_FILE

rsync --archive \
      --compress \
      --quiet \
      --recursive \
      --exclude_from "$EXCLUSIONS_FILE" \
      --rsh "$PROXY_SHELL" \
      --rsh "$REMOTE_SHELL" \
      "$INPUT_SOURCE" "$REMOTE_DESTINATION"
