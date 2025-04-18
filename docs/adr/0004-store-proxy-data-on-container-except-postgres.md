# 4. Store proxy data on container, except postgres

Date: 2025-04-17

## Status

accepted

## Context

Ideally, I want all persistent data to live on the NAS, but the Nginx Proxy Manager insists on running as root, and the NAS currently only supports [running NFS shares with non-root users](https://community.ui.com/questions/NFS-File-shares-in-UNAS/fa03aa65-afec-4106-90bd-77c7b6e044c4). I was able to run Nginx Proxy Manager using a second Postgres container that runs as `user: 977:988` so the postgres data volume is persisted on the NAS. However the Nginx Proxy Manager gives an error if you try to do the same on that container, and it's root user does not seem to be allowed to access the NFS share.

## Decision

Store the `/data/ and `/etc/letsencrypt` volumes of the Nginx Proxy Manager on the host container, rather than on the NAS.

## Consequences

I'm not sure what's in the `data` volume vs the postgres database. Postgres should survive a re-pave, but the `data` directory will not.
