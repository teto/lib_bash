#!/bin/bash

# traffic control lib

TC="tc"

# @param if_name
tc_show_stats () {
	
	local if_name=$1

	echo "---- qdisc statistics ----------"
	$TC -s qdisc show dev $if_name
	echo "---- class statistics ----------"
	$TC -s class show dev $if_name
}


# @param if_name
tc_show_config () {

	local if_name=$1

	echo "---- qdisc parameters ----------"
	$TC qdisc show dev $if_name
	echo "---- class parameters ----------"
	$TC class show dev $if_name
	echo "---- filter parameters Egress ----------"
	$TC filter show dev $if_name
	echo "---- filter parameters Ingress ----------"
	$TC filter show dev $if_name parent ffff:
}



# @param if_name
stop_egress_filtering () {

	local if_name=$1
  	sudo $TC qdisc del dev $if_name root
}
