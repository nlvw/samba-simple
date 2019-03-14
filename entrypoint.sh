#!/bin/sh

# Ensure Direcory Structure
mkdir -p /samba/config
mkdir -p /samba/shares
mkdir -p /samba/shares/public

# Ensure Deluge UID/GID are correctly set.
groupmod --gid "$GROUP_ID" deluge || true
usermod --uid "$USER_ID" deluge || true

# Ensure smb.conf exists
if [ ! -f /samba/config/smb.conf ];then 
	cp /root/smb.conf /samba/config/smb.conf
fi

# Ensure Permissions on Directory Structure
chown -R samba:samba /samba
chmod -R 770 /samba
chmod -R u+s g+s /samba

# Run Supervisor to start smbd/nmbd
supervisord -c /root/supervisord.conf
