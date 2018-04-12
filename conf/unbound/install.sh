#!/bin/sh
# Run this once to create and populate the Freetz config directory
set -e
umask 022
mkdir /var/tmp/flash/unbound
cp named.cache unbound.conf /var/tmp/flash/unbound
mkdir /var/tmp/flash/unbound/dev
cd /var/tmp/flash/unbound/dev
mknod -m 644 random c 1 8
mknod -m 644 urandom c 1 9
