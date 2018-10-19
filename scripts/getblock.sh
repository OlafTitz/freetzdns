#!/bin/sh
# Do not run this manually. It should be called in the right working directory.

set -e
g() {
    curl -q -s -S -f -k -i -L -o "${1}.blocklist" "$2"
    wc -l "${1}.blocklist" >&2
}
rm -f *.blocklist
cp /var/tmp/flash/dnsmasq/*list .

# These are blacklist URLs obtained from
# https://github.com/pi-hole/pi-hole/blob/master/adlists.default
# Uncomment or add as needed.

#g stevenblack https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
#g malwaredomains https://mirror1.malwaredomains.com/files/justdomains
#g cameleon http://sysctl.org/cameleon/hosts
#g zeustracker 'https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist'
#g simple_tracking https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
#g simple_ad https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
#g adservers https://hosts-file.net/ad_servers.txt
