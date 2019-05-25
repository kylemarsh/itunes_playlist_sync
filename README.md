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

### Sync over SSH
Use rsync over SSH to sync files directly to the remote host. This is more
convenient (and possibly faster?) as the user doesn't need to enter a password
in the "Connect to Server" dialog box, but potentially less secure since it
uses a passwordless SSH key. I describe some measures to lock that down so it
can't be used to run anything other than its specific rsync command below.

#### Set up SSH
For convenience we'll create a passwordless SSH key. For security we'll restrict
it to run a specific command.

1. Make a new keypair with `ssh-keygen` (give it a non-default name and
2. Send the identity to the remote server with the following (where
$IDENTITY_FILE is the ssh key that you just created, $REMOTE_USER is your
username on the remote server, and $REMOTE_HOST is the server you want to
connect to):
        `ssh-copy-id -i $IDENTITY_FILE $REMOTE_USER@REMOTE_HOST`
3. SSH into the remote server and prepend your new key's entry in authorized_keys
with the following command (being sure to change `/path/to/target` to your desired path):
        command="/usr/bin/rsync --server -vlogDtprc . /path/to/target",no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding 
NB: if this doesn't work add another `v` into the flags for the command used in
`rsync_playlists.sh` and copy the command that it has SSH run.

#### Install the Applescript Application
1. Edit `rsync_playlists.sh` and replace the placeholder variables with the
values you actually want to use.
2. Compile the applescript into an application, install it as an iTunes
script, and move the rsync script into the same folder:
```
osacompile -o "Sync Playlists.app" sync_playlists.applescript
mkdir -p ~/Library/iTunes/Scripts
mv "Sync Playlists.app" ~/Library/iTunes/Scripts/
mv rsync_playlists.sh ~/Library/iTunes/Scripts/
```

### Sync over AFP
This requires far less setup -- everything is contained in the applescript file
and you don't need to set up an SSH key, but it may be slower, and it requires
the user to enter their username/password every time (or at least click the
"Connect" button, if they've saved their credentials in the keychain). It's
also possible for the script to time out (default is 4s) before the server
connects. If you're having this problem, search for "delay" in the script and
increase the number.

#### Install the Applescript Application
Compile the applescript into an application and install it as an iTunes
script:
```
osacompile -o "Sync Playlists.app" sync_playlists_afp.applescript
mkdir -p ~/Library/iTunes/Scripts
mv "Sync Playlists.app" ~/Library/iTunes/Scripts/
```

Credit
------

I took most of my inspiration for the applescript used here from @dpet23's
[Export-iTunes-Playlists](https://github.com/dpet23/Export-iTunes-Playlists)
project, which further exports the actual music files along with the (user
selected) playlist files. I stripped mine down from that significantly, but
am still making use of his `clean_name` function.

