#!/bin/sh
ROOT=`dirname $0`/..
PATH=$ROOT/bin:$ROOT/sbin:$PATH
(sleep 60; update-blocklists.sh) &
microdns 255.255.255.255 127.0.0.1 53002 &
export LD_LIBRARY_PATH="$ROOT/lib"
exec unbound "$@"
