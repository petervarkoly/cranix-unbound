#
# spec file for package cranix-unbound
#
# Copyright (c) 2020 SUSE LINUX GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           cranix-unbound
Version:        
Release:        0
Summary:
# FIXME: Select a correct license from https://github.com/openSUSE/spec-cleaner#spdx-licenses
License:        
# FIXME: use correct group, see "https://en.opensuse.org/openSUSE:Package_group_guidelines"
Group:          Productivity/Networking/Web/Proxy
Url:            https://www.cephalix.eu
Source:         %{name}.tar.bz2
Prereq:		unbound
Prereq:		cranix-base
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
Package to integrate the unbound validating, recursive, and caching DNS(SEC) resolver into the CRANIX server

%prep
%setup -n %{name}

%build

%install
%make_install

%post
if [ ! -e /etc/unbound/conf.d/cranix.conf ]; then
	/usr/share/cranix/tools/unbound/setup.sh
fi

%postun

%files
%defattr(-,root,root)
%doc ChangeLog README COPYING

%changelog

