# 2. Make plex user root

Date: 2025-03-22

## Status

accepted

## Context

What is the issue that we're seeing that is motivating this decision or change?

It's been really hard to set up a mount on the plex machine that the plex user can access, without getting permission denied errors.

Eventually, I found this:
https://unix.stackexchange.com/questions/471946/grant-full-root-permissions-to-an-user

## Decision

What is the change that we're proposing and/or doing?

Change the setup script to make the plex user root.

## Consequences

What becomes easier or more difficult to do because of this change?

It's easier to make the mount work. Since there's nothing else in the container I can't see what harm it does.