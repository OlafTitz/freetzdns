#!/bin/sh
ROOT=`dirname $0`/..
export LD_LIBRARY_PATH="$ROOT/lib"
exec "$ROOT/sbin/unbound" "$@"
