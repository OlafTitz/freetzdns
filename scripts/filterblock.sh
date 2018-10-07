#!/bin/sh

# This does the following to each blocklist file given as arguments:
# - Canonicalize line endings
# - Remove the HTTP headers getblock.sh has left for debugging
# - Remove blank and comment lines
# The resulting raw lists are concatenated and processed further:
# - Strip IP addresses and aliases from /etc/hosts formatted files
# - Remove lines containing raw IP addresses
# - Sort and remove duplicates
# - Remove whitelisted domains
# - Convert the domain names into appropriate "server=" lines
# The result is on standard output.

set -e
w=`cat noblock.whitelist | sed -e '/^#/d' -e '/^$/d'`
(for i in "$@" ; do \
	cat "$i" | tr -d '\r' | sed -e '1,/^$/d' -e '/^#/d' -e '/^$/d' ;
	done
) | \
awk 'NF==1 {print} NF>1 {print $2}' | \
grep -E -v '^[0-9.]+$' | \
sort -u | \
grep -F -v -e "$w" | \
sed -e 's:^:server=/:' -e 's:$:/127.0.0.1#53002:'
