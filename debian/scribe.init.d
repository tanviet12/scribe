#!/bin/sh
#
# scribed - this script starts and stops the scribed daemon
#
# chkconfig:   - 84 16
# description:  Scribe is a server for aggregating log data \
#               streamed in real time from a large number of \
#               servers.
# processname: scribed
# config:      /etc/scribed/scribed.conf
# config:      /etc/sysconfig/scribed
# pidfile:     /var/run/scribed.pid

# Source function library
. /etc/rc.d/init.d/functions
SCRIBED_CONFIG="/etc/scribe/scribe.conf"
run="/usr/local/bin/scribed"
run_ctrl="/usr/local/bin/scribe_ctrl"
user="scribe"
prog=$(basename $run)

[ -e /etc/sysconfig/$prog ] && . /etc/sysconfig/$prog

port=$(egrep "^port=" $SCRIBED_CONFIG | awk -F"=" '{ print $2 }')

lockfile=/var/lock/subsys/scribed

start() {
        echo -n $"Starting $prog: "
        $run -c $SCRIBED_CONFIG > /dev/null 2>&1 &
        RETVAL=$?
        if [ $RETVAL -eq 0 ]; then
                success
                touch $lockfile
        fi
        echo
        return $RETVAL
}

stop() {
    echo -n $"Stopping $prog: "
    $run_ctrl stop $port
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

status() {
    $run_ctrl status $port
}

restart() {
    stop
    start
}

reload() {
    echo "Probably not implemented."
    $run_ctrl reload $port
}

case "$1" in
    start|stop|restart|status|reload)
        $1
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|reload}"
        exit 2
esac
