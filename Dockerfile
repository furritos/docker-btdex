# Pull base image
FROM debian:bullseye-slim

# BTDEX version
ARG BTDEX_VERSION=v0.6.7

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
RUN apt-get update && \
    env DEBIAN_FRONTEND=noninteractive apt reinstall -y ca-certificates && \
        update-ca-certificates && \
        apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        eterm \
        firefox-esr \
        fluxbox \
        git \
        openjdk-11-jre \
        openssl \
        supervisor \
        x11vnc \
        xdg-utils \
        xvfb && \
    git clone --depth 1 https://github.com/novnc/noVNC ${NOVNC_HOME} && \
    git clone --depth 1 https://github.com/novnc/websockify ${NOVNC_HOME}/utils/websockify && \
    mkdir -p ${BTDEX_HOME}/plots && \
    mkdir -p ${BTDEX_HOME}/cache && \
    mkdir -p ${ROOT_HOME}/.fluxbox && \
    curl -# -L -o ${BTDEX_APP} ${BTDEX_URL} && \
    rm -rf ${NOVNC_HOME}/.git && \
    rm -rf ${NOVNC_HOME}/utils/websockify/.git && \
    rm -rf /var/lib/apt/lists/*

# Copy Supervisor Daemon configuration 
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy Signum wallpaper
COPY signum-wallpaper.jpg /usr/share/images/fluxbox/signum-wallpaper.jpg

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
