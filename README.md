# Image to run a basic/simple Samba File Server

## Included Packages
    samba
    samba-common-tools
    supervisor
    
## Samba
Image is designed to run a default configured samba server.  This means to make configuration changes you need to mount config files into the container.

  * --mount type=bind,source=/somelocation/smb.conf,target=/etc/samba/smb.conf,readonly
    * Create a config file, store it somewhere, and then just load it into the container at run time.
  * --mount type=bind,source="/var/lib/samba",target=/var/lib/samba
    * This is where samba stores its password database file in ubuntu.  If you want to persist this then you will want it stored outside the container with a bind mount or volume.  
    * Alternatively if you want to sync your host users & password with the samba container then create the directory path on your host and mount it to your container.  You can then have pam on the host update the passdp.tdp file when passwords for users change.
  * --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly
    * Mount this if you want to sync the hosts users to the container.  Ensure read only is specified!
  * --mount type=bind,source=/etc/group,target=/etc/group,readonly
    * Mount this if you want to sync the hosts users to the container.  Ensure read only is specified!
    
If users are going to authenticate from something like Active Directory, OpenLDAP, or FreeIPA then you can ignore most of the mounts above and just specify it in the smb.conf file you mount in.

## Example Run
```
docker run -d \
  --name=samba \
  --network=bridge \
  -p 137:137/udp \
  -p 138:138/udp \
  -p 139:139 \
  -p 445:445 \
  --restart="unless-stopped" \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
  --mount type=bind,source="$fPath",target=/etc/samba/smb.conf,readonly \
  --mount type=bind,source="/var/lib/samba",target=/var/lib/samba \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  --mount type=bind,source=/home,target=/home \
  --mount type=bind,source=/vpool/library,target=/data/library \
  --mount type=bind,source=/vpool/backups,target=/data/backups \
  wolfereign/samba-simple
  ```
  
## Example Bash Script
```
#!/bin/bash
# https://hub.docker.com/r/wolfereign/samba-simple/

# Create smb.conf if it doesn't exist
fName="smb.conf"
sDir="/vpool/container-data/secrets"
fPath="${sDir}/${fName}"

if [ ! -f "$fPath" ]; then
# Create smb.conf file
cat << EOF > "$fpath"
  [global]
  workgroup = WORKGROUP
  server string = Samba Server %v
  netbios name = portland
  security = user
  map to guest = bad user
  dns proxy = no

  [backups]
  path = /data/backups
  create mode = 770
  directory mode = 770
  #force user = wolfereign
  #force group = wolfereign
  browsable = yes
  writable = yes
  guest ok = no
  read only = no
  valid users = wolfereign

  [library]
  path = /data/library
  create mode = 770
  directory mode = 770
  force user = curator
  force group = curator
  browsable = yes
  writable = yes
  guest ok = no
  read only = no
  valid users = wolfereign
EOF
fi

# Stand-up new container
docker run -d \
  --name=samba \
  --network=bridge \
  -p 137:137/udp \
  -p 138:138/udp \
  -p 139:139 \
  -p 445:445 \
  --restart="unless-stopped" \
  --mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
  --mount type=bind,source="$fPath",target=/etc/samba/smb.conf,readonly \
  --mount type=bind,source="/var/lib/samba",target=/var/lib/samba \
  --mount type=bind,source=/etc/passwd,target=/etc/passwd,readonly \
  --mount type=bind,source=/etc/group,target=/etc/group,readonly \
  --mount type=bind,source=/home,target=/home \
  --mount type=bind,source=/vpool/library,target=/data/library \
  --mount type=bind,source=/vpool/backups,target=/data/backups \
  wolfereign/samba-simple
  ```
