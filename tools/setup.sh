#!/bin/bash
# (c) 2020 Peter Varkoly <pvarkoly@cephalix.eu>

if [ ! -e /etc/sysconfig/cranix ]; then
	echo "It is not a CRANIX server"
	exit 0
fi
. /etc/sysconfig/cranix
if [ -z "${CRANIX_FORWARDER}" ]; then
	CRANIX_FORWARDER=$( gawk '/dns forwarder/ { print $4 }' /etc/samba/smb.conf )
fi
if [ -z "${CRANIX_FORWARDER}" ]; then
	echo "Can not evaluate an valid forwarder"
	exit 0
fi
#Create unbound configuration
sed    s/CRANIX_NETWORK/${CRANIX_NETWORK}/ /usr/share/cranix/templates/unbound/cranix.conf > /etc/unbound/conf.d/cranix.conf
sed -i s/CRANIX_NETMASK/${CRANIX_NETMASK}/ /etc/unbound/conf.d/cranix.conf
sed -i s/CRANIX_PROXY/${CRANIX_PROXY}/     /etc/unbound/conf.d/cranix.conf
sed -i s/CRANIX_FORWARDER/${CRANIX_FORWARDER}/ /etc/unbound/conf.d/cranix.conf

#Enhance cranix configuration
/usr/bin/fillup /etc/sysconfig/cranix /usr/share/cranix/templates/unbound/UNBOUND-SETTINGS /etc/sysconfig/cranix

#Create unbound initial blacklist
/usr/share/cranix/tools/unbound/create_unbound_redirects.sh

#Open all rooms for direct internet access
/usr/share/cranix/tools/unbound/open_rooms.sh

#Adapt wpad.dat and proxy pack file to use direkt internet for all rooms
echo 'function FindProxyForURL(url, host)
{
	return "DIRECT";
}
' > /srv/www/admin/wpad.dat
echo 'function FindProxyForURL(url, host)
{
	return "DIRECT";
}
' > /srv/www/admin/proxy.pac

#Remove wpad-curl from dhcp config
sed -i /wpad-curl/d /etc/dhcpd.conf
sed -i /wpad-curl/d /usr/share/cranix/templates//dhcpd.conf
/usr/bin/systemctl try-restart dhcpd

#Set the proxy ip as forwarder in samba
sed -i "s/dns forwarder.*/dns forwarder = ${CRANIX_PROXY}/" /etc/samba/smb.conf

#Enable and start unbound
/usr/bin/systemctl enable unbound
/usr/bin/systemctl start  unbound

#Add new apiAcl
/usr/sbin/crx_api.sh PUT  system/enumerates/apiAcl/system.unbound
/usr/sbin/crx_api.sh POST system/acls/groups/1 '{"acl":"system.unbound","allowed":true,"userId":null,"groupId":1}'

#Restart samba
/usr/bin/systemctl restart samba-ad
