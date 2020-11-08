#!/bin/bash
# (c) 2020 Peter Varkoly <pvarkoly@cephalix.eu>

if [ ! -e /etc/sysconfig/cranix ]; then
	echo "It is not a CRANIX server"
	exit 1
fi
. /etc/sysconfig/cranix
if [ -z "${CRANIX_FORWARDER}" ]; then
	CRANIX_FORWARDER=$( gawk '/dns forwarder/ { print $4 }' /etc/samba/smb.conf )
fi
if [ -z "${CRANIX_FORWARDER}" ]; then
	echo "Can not evaluate an valid forwarder"
	exit 2
fi
#Create unbound configuration
sed    s/CRANIX_NETWORK/${CRANIX_NETWORK}/ /usr/share/cranix/templates/unbound/cranix.conf > /etc/unbound/conf.d/cranix.conf
sed -i s/CRANIX_NETMASK/${CRANIX_NETMASK}/ /etc/unbound/conf.d/cranix.conf
sed -i s/CRANIX_FORWARDER/${CRANIX_FORWARDER}/ /etc/unbound/conf.d/cranix.conf

#Enhance cranix configuration
/usr/bin/fillup /etc/sysconfig/cranix /usr/share/cranix/templates/unbound/UNBOUND-SETTINGS /etc/sysconfig/cranix

#Create unbound initial blacklist
/usr/share/cranix/tools/unbound/create_unbound_redirects.sh

#Enable and start unbound
/usr/bin/systemctl enable unbound
/usr/bin/systemctl start  unbound
