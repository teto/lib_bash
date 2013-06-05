#!/bin/bash

# HTB = Hierartichal Token Filter

source ./lib_tc.sh


# intereseting, lot of explanations
# http://luxik.cdi.cz/~devik/qos/htb/manual/userg.htm
start_htb_filtering() {
	echo "start htb filtering TODO"

	local if_name="$1"
	local destination_ips="$2"
	
	$TC class add dev "$if_name" parent 1:0 classid 1:10 htb rate 32kbps ceil 32kbps prio 0
	
}

