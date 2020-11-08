#!/bin/bash
# (c) 2020 Dipl Ing Peter Varkoly <pvarkoly@cephalix.eu>

rm -rf   /run/roomids
mkdir -p /run/roomids
echo '{"id":null,"accessType":"DEF","action":"","monday":true,"tuesday":true,"wednesday":true,"thursday":true,"friday":true,"saturday":false,"sunday":false,"holiday":false,"direct":true,"login":true,"portal":true,"printing":true,"proxy":false,"pointInTime":"06:00"}' > /tmp/defAcl
for i in $( crx_api.sh GET rooms/accessList | jq -c  '.[] | select( .accessType == "DEF" and .roomId != 2 )' );
do
        id=$( echo $i | jq .id )
        roomid=$( echo $i | jq .roomId )
	touch /run/roomids/${roomid}
        echo $id 
        echo $i | jq -c 'setpath(["direct"];true) | setpath(["proxy"];false)  | del(.roomName) | del(.allowSessionIp) | del (.roomId)' > /tmp/newAcl
        crx_api.sh DELETE rooms/accessList/$id
        crx_api_post_file.sh rooms/$roomid/accessList /tmp/newAcl
done

#Collect the rooms
IFS=$'\n'
for i in $( crx_api.sh GET rooms/all | jq -c  '.[] | select( .id > 2 and .roomControl != "no" )' )
do
        roomid=$( echo $i | jq .id )
        if [ ! -e /run/roomids/${roomid} ]; then
                crx_api_post_file.sh rooms/$roomid/accessList /tmp/defAcl
        fi
done

rm -r /run/roomids/
