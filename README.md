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
integrates with DHCP to give dynamically registered hosts local names
and manages locally defined names.
Everything else is forwarded to one of two other locally running server
processes, specified by dnsmasq configuration:

* Usually, the __unbound__ process is queried (on localhost port 53001).
  This does all the recursive resolving, caching and DNSSEC validation
  for regular domains on the internet. No specialized configuration here.
* Blacklisted domains are directed to the __microdns__ process, on localhost
  port 53002, which answers "authoritative NXDOMAIN, no additional data"
  to any query sent to it, making the domain look non-existent.
  This also applies to those domains which have no (globally valid) data
  by definition, like 10.IN-ADDR.ARPA.

## Installation

This is designed for bigger Fritzboxes (dnsmasq and unbound need a
nontrivial amount of memory) which also have some free space in the
`/var/media/ftp` partition. The binaries are installed there. (The
Freetz addon build could also be used, but is more complicated, has
more pitfalls and requires a firmware update if anything gets changed,
so this is just more convenient.)

### Prerequisites

Freetz must be already completely built.
Freetz configuration needs the following packages selected:
* __dnsmasq__ (in the menu: Packages - Packages, enable DNSSEC)
* __curl__ (Packages - Packages)
* __openssl__ (Shared libraries - Crypto & SSL)
* __libexpat__ (Shared libraries - XML & XSLT)
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
run the `install.sh` script in the unbound subdirectory, which copies
the configuration and creates the necessary device nodes (unbound runs
under chroot).

Manually copy the files in the dnsmasq subdirectory.
Pay special attention to `dnsmasq.extra`, which you perhaps already
have edited with the Freetz web interface. After installing the 
configuration files or any change therein, run `modsave all`.

## Running

Make sure that the provided `bin/start-unbound.sh` script gets called from
`rc.custom` to start the unbound and microdns processes. Run the
`bin/update-blocklists.sh` script once a week (or whatever you
consider useful) from crontab.

Configure dnsmasq from the Freetz web interface to **not** use
the ISP's upstream nameserver, and use `127.0.0.1#53001` as
"additional" (really only) upstream nameserver.

### Domain blocklisting

This resolver can use the domain blocklists found in the
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
You can change this if you desire and know how to operate unbound.

Local, blocked and invalid domains are redirected by dnsmasq and those
queries never arrive at unbound, so unbound configuration can be kept
at a minimum and never needs to be changed (except for purely operational
issues).

The start script sets up microdns to return NXDOMAIN for the affected
queries. You can change this to return a special IP address (usually
in the 127.* range), this address is given in the microdns command
line in the start-unbound.sh script.

## Authors and licenses

### For unbound

Copyright (c) 2007, NLnet Labs. All rights reserved.

This software is open source.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

Neither the name of the NLNET LABS nor the names of its contributors may
be used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

### For microdns

Copyright (c) 2009-2010 Sam Trenholme

TERMS

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

This software is provided 'as is' with no guarantees of correctness or
fitness for purpose.

### For everything else in this package

Copyright (c) 2018 Olaf Titz

TERMS

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

This software is provided 'as is' with no guarantees of correctness or
fitness for purpose.
