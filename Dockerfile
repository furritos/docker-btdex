# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.12

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=unknown

# Define software download URLs.
ARG BTDEX_URL=https://github.com/btdex/btdex/releases/download/v0.5.0/btdex-all-v0.5.0.jar

# Define working directory
WORKDIR /tmp

# Install xterm.
RUN add-pkg xterm

# Install Java 8.
RUN \
    add-pkg openjdk8-jre \
        curl \
        sed \
        findutils \
        util-linux \
        lsscsi \
        gtk+3.0 \
	libappindicator \
        xdg-utils \
	&& \
    mkdir -p /defaults && \
    #Download
    curl -# -L -o /defaults/btdex.jar ${BTDEX_URL} && \
    #Cleanup
    rm -rf /tmp/* /tmp/.[!.]*

# Adjust the openbox config.
RUN \
    # Maximize only the main window.
    sed-patch 's/<application type="normal">/<application type="normal" title="BTDEX">/' \
        /etc/xdg/openbox/rc.xml && \
    # Make sure the main window is always in the background.
    sed-patch '/<application type="normal" title="BTDEX">/a \    <layer>below</layer>' \
        /etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/generic-app-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Copy the start script.
COPY rootfs/ /

# Set the name of the application.
ENV APP_NAME="BTDEX" \
    S6_KILL_GRACETIME=8000

# Mountable volume
VOLUME ["/config"]
