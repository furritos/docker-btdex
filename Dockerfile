# Pull base image
FROM alpine:3.15

# BTDEX version
ARG BTDEX_VERSION=v0.5.14

# Define software download URLs
ARG BTDEX_URL=https://github.com/btdex/btdex/releases/download/${BTDEX_VERSION}/btdex-${BTDEX_VERSION}-all.jar

# BTDEX home directory
ARG BTDEX_HOME=/opt/btdex

# BTDEX application
ARG BTDEX_APP=${BTDEX_HOME}/btdex.jar

# root Home
ARG ROOT_HOME=/root

# noVNC Home
ARG NOVNC_HOME=${ROOT_HOME}/noVNC

# Install Fluxbox, noVNC, OpenJDK-11 and download BTDEX.jar
RUN \
    echo "http://dl-3.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --update --upgrade add bash curl firefox fluxbox font-noto font-noto-extra \
    git gtk+3.0 gtk+3.0-dev openjdk11-jre supervisor terminus-font ttf-dejavu \
    ttf-font-awesome ttf-inconsolata x11vnc xdg-utils xterm xvfb && \
    git clone --depth 1 https://github.com/novnc/noVNC.git ${NOVNC_HOME} && \
    git clone --depth 1 https://github.com/novnc/websockify ${NOVNC_HOME}/utils/websockify && \
    sed -i -- "s/ps -p/ps -o pid | grep/g" ${NOVNC_HOME}/utils/novnc_proxy && \
    mkdir -p ${BTDEX_HOME}/plots && \
    mkdir -p ${BTDEX_HOME}/cache && \
    mkdir -p ${ROOT_HOME}/.fluxbox && \
    curl -# -L -o ${BTDEX_APP} ${BTDEX_URL} && \
    # A bit of cleaning up to slim down the image
    apk del git && \
    rm -rf ${NOVNC_HOME}/.git && \
    rm -rf ${NOVNC_HOME}/utils/websockify/.git && \
    rm -rf /var/cache/apk/*

# Copy Supervisor Daemon configuration 
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy Fluxbox configurations
ADD ./fluxbox ${ROOT_HOME}/.fluxbox

EXPOSE 8080

# Setup environment variables
ENV HOME=${ROOT_HOME} \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1440 \
    DISPLAY_HEIGHT=900

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
