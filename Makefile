#
# Copyright (c) Peter Varkoly Nürnberg, Germany.  All rights reserved.
#
DESTDIR         = /
SHARE           = $(DESTDIR)/usr/share/cranix/
HERE            = $(shell pwd)
REPO            = /data1/OSC/home:varkoly:CRANIX-4-2:leap15.2
TOPACKAGE       = Makefile tools templates
PACKAGE		= cranix-unbound

install:
	mkdir -p $(SHARE)/{tools,templates}/unbound
	install -m 755 tools/*      $(SHARE)/tools/unbound/
	install -m 755 templates/*  $(SHARE)/templates/unbound/
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
