#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

run() {
    j=1
    while eval "\${pipestatus_$j+:} false"; do
        unset pipestatus_$j
        j=$(($j+1))
    done
    j=1 com= k=1 l=
    for a; do
        if [ "x$a" = 'x|' ]; then
            com="$com { $l "'3>&-
                        echo "pipestatus_'$j'=$?" >&3
                      } 4>&- |'
            j=$(($j+1)) l=
        else
            l="$l \"\$$k\""
        fi
        k=$(($k+1))
    done
    com="$com $l"' 3>&- >&4 4>&-
               echo "pipestatus_'$j'=$?"'
    exec 4>&1
    eval "$(exec 3>&1; eval "$com")"
    exec 4>&-
    j=1
    while eval "\${pipestatus_$j+:} false"; do
        eval "[ \$pipestatus_$j -eq 0 ]" || return 1
        j=$(($j+1))
    done
    return 0
}

log() {
    if [ -n "${1-}" ]; then
        echo "[cont-init.d] $(basename $0): $*"
    else
        while read OUTPUT; do
            echo "[cont-init.d] $(basename $0): $OUTPUT"
        done
    fi
}

# Install requested packages.
if [ "${INSTALL_EXTRA_PKGS:-UNSET}" != "UNSET" ]; then
    log "installing requested package(s)..."
    for PKG in $INSTALL_EXTRA_PKGS; do
        if cat /etc/apk/world | grep -wq "$PKG"; then
            log "package '$PKG' already installed"
        else
            log "installing '$PKG'..."
            run add-pkg "$PKG" 2>&1 \| log
        fi
    done
fi

# Make sure mandatory directories exist.
mkdir -p /config/logs

if [ ! -f /config/btdex.jar ]; then
    cp /defaults/btdex.jar /config
fi

# Add the API Port
echo "apiPort=9000" > /config/config.properties

# Take ownership of the config directory content.
find /config -mindepth 1 -exec chown $USER_ID:$GROUP_ID {} \;

# Make sure logs directory exist.
mkdir -p /run/s6/services/app/logs

# Take ownership of the config directory content.
find /run/s6/services/app -mindepth 1 -exec chown $USER_ID:$GROUP_ID {} \;
