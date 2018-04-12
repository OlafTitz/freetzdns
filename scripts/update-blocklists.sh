#!/bin/sh

PATH=`dirname $0`:$PATH
set -e
test -d /tmp/dns || mkdir /tmp/dns
cd /tmp/dns
getblock.sh
filterblock.sh *.blocklist > /tmp/servers.conf
kill -HUP `cat /tmp/dnsmasq.pid`
