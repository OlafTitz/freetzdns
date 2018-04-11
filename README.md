# A complete DNS resolver for Freetz

This is a complete resolver package based on standard components
with the following features:

* Full recursive, caching DNS resolver
* Integration with DHCP
* DNSSEC validation
* Domain blocklists

The building blocks are

1. __dnsmasq__, contained in the Freetz distribution
2. __unbound__, provided here
3. __microdns__, a little helper provided here
4. some config files to wire them together
5. some scripts to obtain external blocklists

## Overview

The resolver which is seen by users on port 53 is __dnsmasq__. This
integrates with DHCP to give dynamically registered hosts local names.
Everything else is forwarded to some other server, specified by
dnsmasq configuration:

* Usually, the __unbound__ process is queried (on localhost port 53001).
  This does all the recursive resolving, caching and DNSSEC validation
  for regular domains on the internet. No specialized configuration here.
* Blacklisted domains are directed to the __microdns__ process, on localhost
  port 53002, which answers "authoritative NXDOMAIN, no additional data"
  to any query sent to it. This also applies to those domains which
  have no (globally valid) data by definition, like 10.IN-ADDR.ARPA.

## Installation

This is designed for bigger Fritzboxes (unbound needs a nontrivial
amount of memory) which also have some free space in the `/var/media/ftp`
partition. The binaries are installed there. (The Freetz addon build
could also be used, but is more complicated, has more pitfalls
and requires a firmware update if anything gets changed, so this is
just more convenient.)

### Prerequisites

Freetz must be already completely built. Freetz configuration needs
the following packages selected: __dnsmasq__, __openssl__, __expat__.
It is recommended to run this firmware version and configure dnsmasq
to work with the ISP's resolver before proceeding.

### Building

Edit the `build.sh` script to match your Freetz build. Run this script.
It builds the binaries and generates a tarball as `freetz-dns-bin.tar.gz`.

### Installing

Copy the generated tarball to the Fritzbox. On the Fritzbox, unpack it
in `/var/media/ftp`. This creates a directory `dns`, only accessible by
root, with the following subdirectories:

* `/bin`, the binaries (actually shellscripts) to run
* `/sbin`, the binaries indirectly run by the scripts
* `/lib`, the shared libraries of unbound
* `/etc`, configuration files

The configuration files in `.../etc` actually are Freetz configuration
files and therefore must be copied over to (the respective
subdirectory of) `/var/tmp/flash`. After editing them to your needs,
manually copy both subdirectories to `/var/tmp/flash`.

Pay special attention to `dnsmasq.extra`, which you perhaps already
have edited with the Freetz web interface. After copying the files, run
`modsave all`.

## Running

Make sure that the provided `bin/unbound.sh` script gets called from
`rc.custom` to start the unbound and microdns processes. Run the
`bin/update-blocklists.sh` script once a week (or whatever you
consider useful) from crontab.

### Domain blocklisting

This resolver can use the domain blocklists from the
[pi-hole](https://pi-hole.net) project or other sources. As delivered,
no domain blocklisting is used. Edit the `bin/getblock.sh` script to
suit your needs.

The `bin/update-blocklists.sh` script, which should run every few
days, obtains the desired lists, reformats them to suit dnsmasq, and
creates a dnsmasq servers file.

## Notes on implementation

Both unbound and dnsmasq can do DNSSEC validation. In my experience
the setup given here, where unbound validates and dnsmasq just trusts
upstream, works best. This is not a problem as, in this setup, dnsmasq
never directly forwards to sources outside of the Fritzbox. (The ISP's
DNS is never used at all.)

I deliberately chose to maintain the DNSSEC trust anchors manually.
These are therefore found in the `unbound.conf` file as "trust-anchor"
parameters with a DS key. No trust anchor file of any type is used.

