# 3. Support two kinds of provisioning

Date: 2025-04-01

## Status

accepted

## Context

I'm learning about ansible. In the meantime I trust bash, and I have already got some bash init scripts for provisioning things.

## Decision

Support two ways of provisioning a machine.

Each container folder has either an `init.sh` script or a `playbook.yml`.

If it's the former, we copy the init.sh onto the machine and run it, otherwise we use ansible.

## Consequences

We keep our options open for both types of provisioning for now, while we figure out what's best.