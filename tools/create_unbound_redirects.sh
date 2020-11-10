#!/bin/bash

. /etc/sysconfig/cranix

rm /etc/unbound/local.d/bad.conf
if [ -z "$CRANIX_UNBOUND_LISTS" ]
then
        CRANIX_UNBOUND_LISTS="porn warez violence"
fi
for LIST in $CRANIX_UNBOUND_LISTS
do
    for i in $( grep [[:alpha:]]  /var/lib/squidGuard/db/BL/${LIST}/domains )
    do
         if [ -z "${i//[a-zA-Z0-0\.\-]/}" ]
         then
             echo "local-zone: \"$i\" redirect" >> /etc/unbound/local.d/bad.conf;
             echo "local-data: \"$i A $CRANIX_PROXY\"" >> /etc/unbound/local.d/bad.conf;
         fi
    done
done
for i in $( grep [[:alpha:]] /var/lib/squidGuard/db/custom/bad/domains )
do
         if [ -z "${i//[a-zA-Z0-0\.\-]/}" ]
         then
             echo "local-zone: \"$i\" redirect" >> /etc/unbound/local.d/bad.conf;
             echo "local-data: \"$i A $CRANIX_PROXY\"" >> /etc/unbound/local.d/bad.conf;
         fi
done
for i in $( cat /usr/share/cranix/templates/unbound/google-domains.txt  )
do
         echo "local-zone: \"$i\" redirect" >> /etc/unbound/local.d/bad.conf;
         echo "local-data: \"$i A 216.239.32.20\"" >> /etc/unbound/local.d/bad.conf;
done
/usr/bin/systemctl restart unbound
