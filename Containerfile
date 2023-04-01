FROM debian:sid-slim
LABEL maintainer="Vanilla OS Contributors"

ARG DEBIAN_FRONTEND=noninteractive
RUN echo 'APT::Install-Recommends "0";' > /etc/apt/apt.conf.d/01norecommends

# Copy bucket in /tmp
COPY bucket /tmp/bucket

# Install dependencies
RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https ca-certificates gnupg2 && \
    apt-get clean
    
# Remove Debian sources
RUN rm -f /etc/apt/sources.list.d/debian.sources

# Add base system files
ADD includes.container /

# Add Vanilla OS keys
RUN apt-key add /tmp/bucket/vanilla-main.key
RUN apt-key add /tmp/bucket/vanilla.key

# Install packages
# Note: we need to perform a full update before installing packages
#       to ensure that the vanilla version replaces the debian one
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y $(cat /tmp/bucket/install.packages) && \
    apt-get clean
