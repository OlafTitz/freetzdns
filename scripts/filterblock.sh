#!/bin/sh
# Do not run this manually. It should be called in the right working directory.

# This does the following to each blocklist file:
# - Canonicalize line endings
# - Remove the HTTP headers getblock.sh has left for debugging
# - Remove blank and comment lines
# The resulting raw lists are concatenated and processed further:
# - Strip IP addresses and aliases from /etc/hosts formatted files
# - Remove lines containing raw IP addresses
# - Sort and remove duplicates
# - Prepend a dot to each line if not already there
# The result is on standard output, a list of to-be-blocked domains.

(for i in *.blocklist ; do \
	cat "$i" | tr -d '\r' | sed -e '1,/^$/d' -e '/^#/d' -e '/^$/d' ;
	done
) | \
awk 'NF==1 {print} NF>1 {print $2}' | \
egrep -v '^[0-9.]+$' | fgrep '.' | \
sort -u | \
sed -e 's/^[^\.]/./'
