#!/bin/bash
# (c) 2020 Dipl Ing Peter Varkoly <pvarkoly@cephalix.eu>

declare -a ROOMSIDS
echo '{"id":null,"accessType":"DEF","action":"","monday":true,"tuesday":true,"wednesday":true,"thursday":true,"friday":true,"saturday":false,"sunday":false,"holiday":false,"direct":true,"login":true,"portal":true,"printing":true,"proxy":false,"pointInTime":"06:00"}' > /tmp/defAcl
for i in $( crx_api.sh GET rooms/accessList | jq -c  '.[] | select( .accessType == "DEF" and .roomId != 2 )' );
do
        id=$( echo $i | jq .id )
        roomid=$( echo $i | jq .roomId )
        ROOMSIDS[$roomid]=1
        echo $id 
        echo $i | jq -c 'setpath(["direct"];true) | setpath(["proxy"];false)  | del(.roomName) | del(.allowSessionIp) | del (.roomId)'; > /tmp/newAcl
        crx_api.sh DELETE accessList/$id
       crx_api_post_file.sh rooms/$roomid/accessList /tmp/newAcl
done

#Collect the rooms
for i in $( crx_api.sh GET rooms/all | jq -c  '.[] | select( .id > 2 )' )
do
        roomid=$( echo $i | jq .id )
        echo $roomid
        if [ -z "$ROOMSIDS[$roomid]" ]; then
                crx_api_post_file.sh rooms/$roomid/accessList /tmp/defAcl
        fi
done
