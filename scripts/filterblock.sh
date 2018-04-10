#!/bin/sh
(for i in *.blocklist ; do \
	cat "$i" | tr -d '\r' | sed -e '1,/^$/d' -e '/^#/d' -e '/^$/d' ;
	done
) | \
awk 'NF==1 {print} NF>1 {print $2}' | \
egrep -v '^[0-9.]+$' | fgrep '.' | \
sort -u | \
sed -e 's/^[^\.]/./'
