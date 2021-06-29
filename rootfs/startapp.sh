#!/usr/bin/with-contenv sh

set -u # Treat unset variables as an error.

trap "exit" TERM QUIT INT
trap "kill_bitrex" EXIT

log() {
    echo "[jdsupervisor] $*"
}

getpid_bitrex() {
    PID=UNSET
    if [ -f /config/btdex.pid ]; then
        PID="$(cat /config/btdex.pid)"
        # Make sure the saved PID is still running and is associated to
        # btdex.
        if [ ! -f /proc/$PID/cmdline ] || ! cat /proc/$PID/cmdline | grep -qw "btdex.jar"; then
            PID=UNSET
        fi
    fi
    if [ "$PID" = "UNSET" ]; then
        PID="$(ps -o pid,args | grep -w "btdex.jar" | grep -vw grep | tr -s ' ' | cut -d' ' -f2)"
    fi
    echo "${PID:-UNSET}"
}

is_btdex_running() {
    [ "$(getpid_bitrex)" != "UNSET" ]
}

start_bitrex() {
    cd /config && /usr/bin/java \
        -Dawt.useSystemAAFontSettings=gasp \
        -Djava.awt.headless=false \
        -jar /config/btdex.jar >/config/logs/output.log 2>&1 &
}

kill_bitrex() {
    PID="$(getpid_bitrex)"
    if [ "$PID" != "UNSET" ]; then
        log "Terminating btdex..."
        kill $PID
        wait $PID
    fi
}

if ! is_btdex_running; then
    log "btdex not started yet.  Proceeding..."
    start_bitrex
fi

BTDEX_NOT_RUNNING=0
while [ "$BTDEX_NOT_RUNNING" -lt 5 ]
do
    if is_btdex_running; then
        BTDEX_NOT_RUNNING=0
    else
        BTDEX_NOT_RUNNING="$(expr $BTDEX_NOT_RUNNING + 1)"
    fi
    sleep 1
done

log "btdex no longer running.  Exiting..."
