Requires in `/etc/fstab`:

`https://its.data.uu.nl /home/<myuid>/yoda davfs rw,user,uid=<myuid>,noauto,conf=/etc/uu/user_webdav_mount.conf`

## Desktop items

Copy `mount_yoda.desktop` to `.local/share/applications` to add it to the menu. Run: `ln -s .local/share/applications/mount_yoda.desktop .config/autostart` to add to autostart.
