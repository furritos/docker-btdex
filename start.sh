#/bin/bash
/usr/bin/java -Djava.io.tmpdir=/tmp -Duser.home=/opt/btdex -jar /opt/btdex/btdex.jar &
sleep 15
wmctrl -r BTDEX -b toggle,fullscreen