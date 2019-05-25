Export and Sync iTunes Playlists
================================

Applescript to export playlists from iTunes and shell script to rsync them
to a remote server.

I have a Sonos system and I've set it up to look at my NAS for its music library
and it can read m3u playlist files from a `playlists` directory in the music
library. Unfortunately, iTunes only allows you to export playlists one at a
time. This Applescript (and helper shell script) are my solution to allow my
family to easily sync their iTunes playlists with the Sonos system.

Installation
------------

### Set up SSH
For convenience we'll create a passwordless SSH key. For security we'll restrict
it to run a specific command.

1. Make a new keypair with `ssh-keygen` (give it a non-default name and
2. Send the identity to the remote server with `ssh-copy-id -i $IDENTITY_FILE $REMOTE_USER@REMOTE_HOST`
3. SSH into the remote server and prepend your new key's entry in authorized_keys with:
        command="/usr/bin/rsync --server -vlogDtprc . /path/to/target",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding 

### Install the Applescript Application
Compile the applescript into an application and install it as an iTunes
script, and move the rsync script into the same folder:
```
osacompile -o "Sync Playlists.app" sync_playlists.applescript
mkdir -p ~/Library/iTunes/Scripts
mv "Sync Playlists.app" ~/Library/iTunes/Scripts/
mv rsync_playlists.sh
```

Credit
------

I took most of my inspiration for the applescript used here from @dpet23's
[Export-iTunes-Playlists](https://github.com/dpet23/Export-iTunes-Playlists)
project, which further exports the actual music files along with the (user
selected) playlist files. I stripped mine down from that significantly, but
am still making use of his `clean_name` function.

