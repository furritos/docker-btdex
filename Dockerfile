# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.12

# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=unknown

# Install xterm.
RUN add-pkg xterm

# Install Java 8.
RUN \
    add-pkg openjdk8-jre-base && \
    # Removed uneeded stuff.
    rm -r \
        /usr/lib/jvm/java-1.8-openjdk/bin \
        /usr/lib/jvm/java-1.8-openjdk/lib \
        /usr/lib/jvm/java-1.8-openjdk/jre/lib/ext \
        && \
    # Cleanup.
    rm -rf /tmp/* /tmp/.[!.]*

# Install dependencies.
RUN \
    add-pkg \
        wget \
        sed \
        findutils \
        util-linux \
        lsscsi

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
COPY startapp.sh /startapp.sh

# Set the name of the application.
ENV APP_NAME="BTDEX"

