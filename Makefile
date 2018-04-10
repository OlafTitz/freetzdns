ROOT:="$(shell pwd)/root"

install: all
	install -o root -g root -m 755 -d root/bin
	install -o root -g root -m 755 build/microdns root/bin
	(cd root && tar czf ../install.tar.gz .)

all: build-microdns build-unbound build-scripts build-conf

build-scripts: builddirs
	install -o root -g root -m 755 -d root/bin
	install -o root -g root -m 755 scripts/* root/bin

build-conf: builddirs
	install -o root -g root -m 755 -d root/etc/dnsmasq root/etc/unbound
	install -o root -g root -m 755 conf/dnsmasq/* root/etc/dnsmasq
	install -o root -g root -m 755 conf/unbound/* root/etc/unbound

build-microdns: builddirs
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -o build/microdns src/microdns.c

build-unbound: builddirs
	(cd build && tar xzf ../$(UNBOUND).tar.gz)
	(cd "build/$(UNBOUND)" && \
	CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" \
	./configure --host="$(TARGET)" \
	  --prefix="$(ROOT)" \
	  --with-conf-file=/var/tmp/flash/unbound/unbound.conf \
	  --with-pidfile=/tmp/unbound.pid \
	  --with-run-dir=/tmp \
	  --with-rootkey-file=/var/tmp/flash/unbound/root.key \
	  --with-ssl="$(OPENSSL)" \
	  --with-libevent --without-pthreads \
	  --disable-rpath --enable-allsymbols \
	  --with-username=nobody \
	&& make && make install)
	rm -rf "$(ROOT)/include" "$(ROOT)/share" "$(ROOT)/lib/pkgconfig"
	rm -f "$(ROOT)/lib/libunbound.a" "$(ROOT)/lib/libunbound.la"

builddirs:
	test -d build || mkdir build
	test -d root || mkdir root

allclean:
	rm -rf build root install.tar.gz

.PHONY: allclean
