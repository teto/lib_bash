#!/bin/bash

# TBF = Token Bucket Filter

source ./lib_tc.sh



# http://www.cyberciti.biz/faq/linux-traffic-shaping-using-$TC-to-control-http-traffic/
# TBF is very precise, network- and processor friendly. It should be your first choice if you simply want to slow an interface down!

start_tbf_filtering() {
	echo "start tbf filtering"
	
	# => default trafic go to 1:10
	# turn on queing discipline 
	$TC qdisc add dev $DEV root handle 1:0 htb default 1
	## This *instantly* creates classes 1:1, 1:2, 1:3
	# by default thoses classes are fifo but we can replace them	
	#$TC qdisc add dev $DEV root handle 1: prio 




	# tbf = Token Bucket Filter
	# rate - You can set the allowed bandwidth.
	#ceil - You can set burst bandwidth allowed when buckets are present.
	#prio - You can set priority for additional bandwidth. So classes with lower prios are offered the bandwidth first. For example, you can give lower prio for DNS traffic and higher for HTTP downloads.
	#iptables and $TC: You need to use iptables and tc as follows to control outbound HTTP traffic.
	# $TC qdisc add dev $DEV root tbf rate 8mbit burst 10kb latency 70ms minburst 1540

	
	$TC class add dev $DEV parent 1:0 classid 1:10 htb rate 32kbps ceil 32kbps prio 0
	
	#  filters are called from within a qdisc, and not the other way around!
	# The filters attached to that qdisc then return with a decision 
	#  and the qdisc uses this to enqueue the packet into one of the classes.

	$TC filter add dev $DEV parent 1:0 prio 0 protocol ip u32 \
		match ip dst 79.141.8.227/32 flowid 1:10
}
