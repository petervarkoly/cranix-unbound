#!/bin/bash

echo -n "["
for s in $( ls /usr/share/cranix/templates/unbound/safesearch/ )
do
	base=$(basename s)
	desc=$( head -n1 /usr/share/cranix/templates/unbound/safesearch/$s )
	active="false"
	[ -e /etc/unbound/local.d/$s ] && active="true"
	[ "${next}" ] && echo -n ","
	echo -n '{"name":"'${s/.conf/}'","description":"'${desc:2}'","active":'$active'}'
	next=1
done
echo -n "]"
