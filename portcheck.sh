#!/bin/bash -x


### This script hits each of the IP's in the LAN/VPC/network with netcat and checks a predefined list of ports. If any ports are down it will send notice via slack.

# If you implement email instead, for cron to have the sendmail path, run: PATH=$(env | grep -i path); sed -i "/bash/a $PATH" portcheck.sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

#----------------------------------

#       Below, the 'ip' array corresponds to the port values listed in subsequent arrays.
#       Bash did not like full IP addresses or a straight integer set (referencing more integers),
#       so the 'ip' array is an added alphabetized list combined with the last two octets of the necessary IP's,
#       which gets cut and added to 'OCT_FRONT'. later in the script

#::::::::::::::::::::::::::::::::::

SLACK () {
	SLACK_AD='' #drop your bot's address here 
	MESSAGE='Heads up! Port *$port* on the $name instance (${OCT_FRONT}.$octet) is not reporting available.\n\nPlease check that the instance is up and the corresponding service is running. For a list of ports and servrices on the instance run: \`netstat -plunt\`.'

	curl -X POST -H "Content-type: application/json" --data "{\"text\":\"$MESSAGE\"}" https://hooks.slack.com/services/$SLACK_AD
}

OCT_FRONT='172.31'

ip=( A9_11 B0_22 C35_162 D9_199 ) 

A9_11=( 22 25 80 443 )
B0_22=( 22 80 443 ) 
C35_162=( 22 3306 )
D9_199=( 22 11211 ) 

# This next list is an associative array to allows us to pair the last two IP octets (after tranforming them in the nested for loop) to the server name.

declare -A instance_monikers=( [9.11]="Web Server 1" [0.22]="Web Server 2" [35.162]="Database" [9.199]="Memcache" )

# The logic is a set of for loops, where the first loop calls and expands the array values. Then the second, nested for loop calls the expanded values as their own arrays, which are then manipulated via variables to run a netcat check and send notification via slack API if the port is not open.

for i in "${ip[@]}"; do
        array="${i}[@]"
        for port in "${!array}"; do
                octet=$(echo $i | cut -c 2- | sed s/_/\./g)
                portchk=$(nc -z ${OCT_FRONT}.$octet $port; echo $?)
                name=$(echo ${instance_monikers[$octet]})
                        if [ ! $portchk -eq 0 ]; then
                                        SLACK
                        fi
        done
done

exit

