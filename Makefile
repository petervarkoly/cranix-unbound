#
# Copyright (c) Peter Varkoly Nürnberg, Germany.  All rights reserved.
#
DESTDIR         = /
SHARE           = $(DESTDIR)/usr/share/cranix/
HERE            = $(shell pwd)
REPO            = /data1/OSC/home:pvarkoly:CRANIX
TOPACKAGE       = Makefile tools templates
PACKAGE		= cranix-unbound

install:
	mkdir -p $(SHARE)/{tools,templates}/unbound
	mkdir -p $(DESTDIR)/usr/lib/systemd/system
	mkdir -p $(DESTDIR)/etc/logrotate.d
	install -m 755 tools/*      $(SHARE)/tools/unbound/
	install -m 644 templates/*  $(SHARE)/templates/unbound/
	mv $(SHARE)/templates/unbound/crx_fw_log_watcher.service $(DESTDIR)/usr/lib/systemd/system/
	mv $(SHARE)/templates/unbound/logrotate $(DESTDIR)/etc/logrotate.d/crx-fw-watcher

dist:
	xterm -e git log --raw  &
	if [ -e $(PACKAGE) ] ;  then rm -rf $(PACKAGE) ; fi
	mkdir $(PACKAGE)
	for i in $(TOPACKAGE); do \
	    cp -rp $$i $(PACKAGE); \
	done
	find $(PACKAGE) -type f > files;
	tar jcpf $(PACKAGE).tar.bz2 -T files;
	rm files
	rm -rf $(PACKAGE)
	if [ -d $(REPO)/$(PACKAGE) ] ; then \
	   cd $(REPO)/$(PACKAGE); osc up; cd $(HERE);\
	   mv $(PACKAGE).tar.bz2 $(REPO)/$(PACKAGE); \
	   cd $(REPO)/$(PACKAGE); \
	   osc vc; \
	   osc ci -m "New Build Version"; \
	fi
