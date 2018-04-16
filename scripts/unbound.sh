#!/bin/sh
ROOT=`dirname $0`/..
PATH=$ROOT/bin:$ROOT/sbin:$PATH
(sleep 300; update-blocklists.sh) &
microdns 255.255.255.255 127.0.0.1 53002 &
export LD_LIBRARY_PATH=/usr/lib/freetz:$ROOT/lib
exec unbound "$@"
