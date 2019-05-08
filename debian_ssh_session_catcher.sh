#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

#----------------------------------

# This script is a simple slack messenger for sending notices regarding successful ssh logins on debian based machines from unknown IP's
# Future-wise I am thinking about updating this from a report on the previous 24 hours to a listener on the log for instance notification

#::::::::::::::::::::::::::::::::::

HOST="$(hostname)" #replace with string if wanted
HOSTIP="$(hostname -I)"


### FUNCTIONS:

GRAB_LOG_FIELD () {

    TIMEFRAME='24 hours'

    YESTERDAY="$(date -d "-${TIMEFRAME}" +"%b %_d %T" | rev | cut -c 5- | rev)"
    NOW="$(date +"%b %_d %T" | rev | cut -c 5- | rev)"

    </var/log/auth.log sed -n "/^${YESTERDAY}/,/^${NOW}/ p" > one_day_auth.log

    LOG_POPULATION_CHECK="$(<one_day_auth.log wc -l)"

    if [[ $LOG_POPULATION_CHECK -eq 0 ]]; then
            rm one_day_auth.log
            HEAD_DATE="$(</var/log/auth.log head -1 | cut -d ' ' -f -4 | rev | cut -c 5- | rev)"
            </var/log/auth.log sed -n "/^${HEAD_DATE}/,/^${NOW}/ p" > one_day_auth.log
            TIME_STAMP="$(</var/log/auth.log head -1 | cut -d ' ' -f -4)"
            TIMEFRAME="since the start of the log [${TIME_STAMP}]"
    fi

}

PARSE_LOG_FIELD () {

    WHITELIST='10.10.10.10|10.0.2.2|134.201.250.155' #etc. add common occurance addresses. This is formated to drop the string directly into the last pipe below
    PARSEDOWN="$(<one_day_auth.log grep -a ssh | grep -a -B1 " session opened " | grep -a "Accepted" | egrep -v "$WHITELIST")"
    echo "$PARSEDOWN"

}

SLACK () {

    SLACK_ID='T3TA96RGD/BBN8F2PCJ/LjUilMrHteoE70C7A1S28LTS' #drop your bot's address here
    INGEST="$(PARSE_LOG_FIELD)"
    MESSAGE="$(echo -e "\`\`\`$INGEST\`\`\`")"

    SLACK="$(curl -X POST -H "Content-type: application/json" --data "{\"text\":\"Unkown IP found to have successfully opened SSH session on node _*$HOST, $HOSTIP*_. See auth.log lines below: $MESSAGE\"}" https://hooks.slack.com/services/$SLACK_ID)"

}


### RUNTIME LOGIC:

GRAB_LOG_FIELD
PARSE_LOG_FIELD

if (( "$(PARSE_LOG_FIELD | wc -w)" )); then
    echo "Non-standard IP's found to have successfully opened SSH sessions on host. Sending Slack message"
    SLACK
else
    echo "Nothing to do. Only known, standard IP's found to have successfully opened SSH sessions"
fi

exit
