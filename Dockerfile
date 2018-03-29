FROM alpine:latest
Label maintainer="Wolfereign"

# Update Packages and Install Needed Packages
RUN apk add --update --no-cache \ 
    samba \
    samba-common-tools \
    supervisor \
    && rm -rf /var/cache/apk/*
 
# exposes samba's default ports (137, 138 for nmbd and 139, 445 for smbd) 
EXPOSE 137/udp 138/udp 139 445

ENTRYPOINT ["supervisord", "-c", "/config/supervisord.conf"]
