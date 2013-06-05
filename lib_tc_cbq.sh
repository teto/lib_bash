#!/bin/bash

# CBQ = Class Based Queuing


source ./lib_tc.sh

#1 http://www.tldp.org/HOWTO/Adv-Routing-HOWTO/lartc.ratelimit.single.html
start_cbq_filtering() {

	echo "start CBQ filtering"
	
 	# cbq = Class Based Queuing  
	$TC qdisc add dev $DEV root handle 1: cbq avpkt 1000 bandwidth 100mbit 

	# A class that is configured with 'isolated' will not lend out bandwidth to sibling classes
# A class can also be 'bounded', which means that it will not try to borrow bandwidth from sibling classes
	$TC class add dev $DEV parent 1: classid 1:1 cbq rate 400kbit \
	  allot 1500 prio 5 bounded isolated 

	for SOURCE in $SOURCES; do
		$TC filter add dev $DEV parent 1: protocol ip prio 16 u32 \
		match ip dst $SOURCE flowid 1:1
	done

}