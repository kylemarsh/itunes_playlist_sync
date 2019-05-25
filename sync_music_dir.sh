#!/bin/sh
# This script is very specific for security; the specified identity file
# has passwordless authentication to the remote server, so I've set it up
# so it can only execute one command:
#    /usr/bin/rsync --server -vlogDtprc . /remote/path/to/music
# To discover this command, invoke rsync with at least 3 verbose flags: `-vvv`

# To set everything up so that this script works properly and (relatively)
# securely:
# 1. `ssh-keygen` and make a new keypair. Give it a non-default name and put that name in IDENTITY_FILE below
# 2. `ssh-copy-id -i $IDENTITY_FILE $REMOTE_USER@REMOTE_HOST` to send the identity to the remote server
# 3. SSH into the remote server and prepend your new key's entry in authorized_keys with:
#         command="/usr/bin/rsync --server -vlogDtprc . /remote/path/to/music",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding 

SOURCE_DIR="$HOME/Music/iTunes/iTunes Media/Music/"
TARGET_DIR="/remote/path/to/music"
IDENTITY_FILE="$HOME/.ssh/music-rsync.id_rsa"
REMOTE_USER="username"
REMOTE_HOST="hostname"
rsync -vac --rsync-path /usr/bin/rsync -e "ssh -i $IDENTITY_FILE" "$SOURCE_DIR" $REMOTE_USER@$REMOTE_HOST:$TARGET_DIR
