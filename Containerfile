FROM debian:sid-slim
LABEL maintainer="Vanilla OS Contributors"

ARG DEBIAN_FRONTEND=noninteractive
RUN echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/01norecommends

# Copy bucket in /tmp
COPY bucket /tmp/bucket

# Install dependencies
RUN apt-get update && \
    apt-get install -y apt-utils man-db apt-transport-https ca-certificates gnupg2 && \
    apt-get clean

# Docker images of Debian have rules that remove manpages and other files which may not be useful
# for containers, but remove these rules because we're building a desktop system.
RUN rm /etc/dpkg/dpkg.cfg.d/*
# Reinstall all currently installed packages in order to get the man pages back
RUN apt-get update && \
    dpkg -l | grep ^ii | cut -d' ' -f3 | xargs apt-get install -y --reinstall && \
    rm -r /var/lib/apt/lists/*
# Re-generate mandb just to be sure
RUN mandb -c

# Remove Debian sources
RUN rm -f /etc/apt/sources.list.d/debian.sources

# Add base system files
ADD includes.container /

# Add Vanilla OS Extra Packages key
RUN apt-key add /tmp/bucket/vanilla.key

# Install packages
# Note: we need to perform a full update before installing packages
#       to ensure that the vanilla version replaces the debian one
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y $(cat /tmp/bucket/install.packages) && \
    apt-get clean
