# Pull base image
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye

# BTDEX version
ARG BTDEX_VERSION=v0.6.8

# Define software download URLs
ARG BTDEX_URL=https://github.com/btdex/btdex/releases/download/${BTDEX_VERSION}/btdex-${BTDEX_VERSION}-all.jar

# BTDEX home directory
ARG BTDEX_HOME=/opt/btdex

# BTDEX application
ARG BTDEX_APP=${BTDEX_HOME}/btdex.jar

# Copy icon to share directory
COPY icon/icon48.png /usr/share/btdex/icons/

# Copy startup script
COPY start.sh /usr/local/bin/

# Set web page title
ENV TITLE "BTDEX ${BTDEX_VERSION}"

# Install supporting packages and download BTDEX.jar
RUN mkdir -p /usr/share/man/man1 && \
    apt update && \
    env DEBIAN_FRONTEND=noninteractive apt reinstall -y ca-certificates && \
    update-ca-certificates && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    firefox-esr \
    git \
    wmctrl \
    supervisor \
    openjdk-11-jre && \
    mkdir -p ${BTDEX_HOME}/plots && \
    mkdir -p ${BTDEX_HOME}/cache && \
    curl -# -L -o ${BTDEX_APP} ${BTDEX_URL} && \
    chmod 755 /usr/local/bin/start.sh && \
    rm -rf /var/lib/apt/lists/*

RUN chown -R abc:abc ${BTDEX_HOME}

COPY /root /
