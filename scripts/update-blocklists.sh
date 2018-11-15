#!/bin/sh

PATH=`dirname $0`:$PATH
set -e
(
	test -d /tmp/dns || mkdir /tmp/dns
	cd /tmp/dns
	echo "Downloading blocklists" >&2
	getblock.sh
	filterblock.sh *.blocklist > /tmp/servers.conf
	wc -l /tmp/servers.conf >&2
	echo "Reloading dnsmasq" >&2
	kill -HUP `cat /tmp/dnsmasq.pid`
) 2>&1 | logger -t update-blocklists -p user.info
