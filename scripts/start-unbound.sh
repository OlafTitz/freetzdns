#!/bin/sh
ROOT=`dirname $0`/..
PATH=$ROOT/bin:$ROOT/sbin:$PATH

# Refresh the blocklists; a bit delayed to make sure everything is running
(sleep 600; update-blocklists.sh) &

# Run microdns. The first argument is the address to return for blocked
# domains, or 255.255.255.255 to return NXDOMAIN.
microdns 255.255.255.255 127.0.0.1 53002 &

# Run unbound (will daemonize itself)
export LD_LIBRARY_PATH=/usr/lib/freetz:$ROOT/lib
exec unbound "$@"
