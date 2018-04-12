DNS:=$(shell pwd)/dns
PACKAGE:=freetz-dns-bin.tar.gz

package: all
	install -o root -g root -m 755 -d $(DNS)/sbin
	install -o root -g root -m 755 build/microdns $(DNS)/sbin
	$(MAKE) install -C build/$(UNBOUND)
	rm -rf $(DNS)/include $(DNS)/share $(DNS)/lib/pkgconfig
	rm -f $(DNS)/lib/libunbound.a $(DNS)/lib/libunbound.la
	find $(DNS) -name '*~' | xargs rm
	chown root:root $(DNS)
	chmod 700 $(DNS)
	tar czf $(PACKAGE) dns

all: prereq build/microdns build/unbound cp-scripts cp-conf

prereq:
	test -n "$(TARGET_CC)" # Run this via build.sh only

cp-scripts: builddirs
	install -o root -g root -m 755 -d $(DNS)/bin
	install -o root -g root -m 755 scripts/* $(DNS)/bin

cp-conf: builddirs
	install -o root -g root -m 755 -d $(DNS)/etc/dnsmasq $(DNS)/etc/unbound
	install -o root -g root -m 644 conf/dnsmasq/* $(DNS)/etc/dnsmasq
	install -o root -g root -m 644 conf/unbound/* $(DNS)/etc/unbound

build/microdns: builddirs src/microdns.c
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -DUID=100 -DGID=1000 \
	  -o build/microdns src/microdns.c

build/unbound: builddirs
	(cd build && tar xzf ../$(UNBOUND).tar.gz)
	(cd build/$(UNBOUND) && \
	CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
	./configure --host="$(TARGET)" \
	  --prefix="$(DNS)" \
	  --with-conf-file=/var/tmp/flash/unbound/unbound.conf \
	  --with-pidfile=/tmp/unbound.pid \
	  --with-run-dir=/tmp \
	  --with-rootkey-file=/var/tmp/flash/unbound/root.key \
	  --with-ssl="$(OPENSSL)" \
	  --with-libevent=no --without-pthreads \
	  --disable-rpath --enable-allsymbols \
	  --with-username=nobody \
	&& make)
	touch build/unbound

builddirs: prereq
	test -d build || mkdir build
	test -d dns || mkdir dns

allclean: prereq
	rm -rf bin dns $(PACKAGE)

.PHONY: prereq builddirs package allclean
