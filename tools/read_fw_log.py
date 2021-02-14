#!/usr/bin/python3
# (C) 2021 Peter Varkoly <pvarkoly@cephalix.eu> All rights reserved

import re
import os
import time

users = {}

def get_logged_in_user(SRC):
    if SRC in users:
        if users[SRC]['time'] > ( time.time() - 60 ):
            return users[SRC]['user']
    else:
        users[SRC] = {}
    user=os.popen('/usr/sbin/crx_api_text.sh GET devices/loggedIn/{0}'.format(SRC)).read()
    users[SRC]['user'] = user
    users[SRC]['time'] = time.time()

LOG_FILE="/var/log/cranix-internet-access.log"
with open(LOG_FILE,'a',1) as log:
    journal = os.popen('/usr/bin/journalctl -o short-iso -f')
    while True:
        line = journal.readline()
        match=re.search("^(\S+) .*NEW-CON.* SRC=([0-9\.]+) DST=([0-9\.]+) .*PROTO=([A-Z]+) (.*DPT=([0-9]+))*",line)
        if match:
            TIME=match.group(1)
            SRC=match.group(2)
            DST=match.group(3)
            PROTO=match.group(4)
            DPT=match.group(6)
            user=get_logged_in_user(SRC)
            log.write("{0};{1};{2};{3};{4};{5}\n".format(TIME,user,SRC,DST,PROTO,DPT))
