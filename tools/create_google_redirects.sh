#!/bin/bash
#
FILE="../templates/safesearch/google.conf"
echo "# Google Safe Search" >  $FILE
for d in $( curl -s https://www.google.com/supported_domains )
do
	echo "local-zone: '${d/\./}' redirect"       >> $FILE
	echo "local-data: '${d/\./} A 216.239.32.20'" >> $FILE
done
