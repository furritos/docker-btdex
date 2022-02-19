# Pull base image
FROM jlesage/baseimage-gui:alpine-3.15

# Docker image version is provided via build arg
ARG DOCKER_IMAGE_VERSION=unknown

# BTDEX version
ARG BTDEX_VERSION=v0.5.14

# Define software download URLs
ARG BTDEX_URL=https://github.com/btdex/btdex/releases/download/${BTDEX_VERSION}/btdex-${BTDEX_VERSION}-all.jar

# BTDEX home directory
ARG BTDEX_HOME=/opt/btdex

# BTDEX application
ARG BTDEX_APP=${BTDEX_HOME}/btdex.jar

# Copy the start script.
COPY "startapp.sh" "/"
RUN chmod +x /startapp.sh

# Install Java 11
RUN \
    add-pkg openjdk11-jre \
    curl \
    gtk+ \
    gtk+-dev \
	&& \
    mkdir -p ${BTDEX_HOME} && \
    #Download
    curl -# -L -o ${BTDEX_APP} ${BTDEX_URL} && \
    #Cleanup
    rm -rf /tmp/* /tmp/.[!.]*

# Startup command
ENV APP_NAME="BTDEX"
