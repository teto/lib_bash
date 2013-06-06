#!/bin/bash

# TBF = Token Bucket Filter

source ./lib_tc.sh



# http://www.cyberciti.biz/faq/linux-traffic-shaping-using-$TC-to-control-http-traffic/
# TBF is very precise, network- and processor friendly. It should be your first choice if you simply want to slow an interface down!

# @param if_name
# @param destination ip to which filter should apply
start_tbf_filtering() {

	local if_name="$1"
	local destination_ips="$2"

	echo "start tbf filtering for if '$if_name' "
	
	# => default trafic go to 1:10
	# turn on queing discipline 
#	$TC qdisc add dev $if_name root handle 1:0 htb default 1
	## This *instantly* creates classes 1:1, 1:2, 1:3
	# by default thoses classes are fifo but we can replace them	
	#$TC qdisc add dev $DEV root handle 1: prio 




	# tbf = Token Bucket Filter
	# rate - You can set the allowed bandwidth.
	#ceil - You can set burst bandwidth allowed when buckets are present.
	#prio - You can set priority for additional bandwidth. So classes with lower prios are offered the bandwidth first. For example, you can give lower prio for DNS traffic and higher for HTTP downloads.
	#iptables and $TC: You need to use iptables and tc as follows to control outbound HTTP traffic.


	#To attach a TBF with a sustained maximum rate of 1mbit/s, a peakrate of 2.0mbit/s, 
	#a 10kilobyte buffer, 
	#with a pre-bucket queue size limit calculated so the TBF causes at most 70ms of latency,
	# with perfect peakrate behavior, enter:
# tc qdisc add dev eth0 root tbf rate 1mbit burst 10kb latency 70ms peakrate 2mbit minburst 1540

#	cmd="$TC qdisc add dev "$if_name" root tbf rate 2mbit burst 10kb latency 30ms peakrate 1mbit minburst 1540"
#	gen_launch_command "$cmd"

	# Cette ligne marche
	#$TC qdisc add dev "$if_name" root tbf rate 0.5mbit burst 10kb latency 70ms peakrate 1mbit minburst 1540
	# peakrate not mandatory it seems, should remain under 1mbit
	$TC qdisc add dev "$if_name" root tbf rate 60mbit burst 100kb latency 30ms  #minburst 1540
	
	#  filters are called from within a qdisc, and not the other way around!
	# The filters attached to that qdisc then return with a decision 
	#  and the qdisc uses this to enqueue the packet into one of the classes.
	# 79.141.8.227/32
#	for destination in "$destination_ips"; do
#		echo "Adding filter for destination \"$destination\""
#		$TC filter add dev "$if_name" parent 1:0 prio 0 protocol ip u32 \
#			match ip dst "$destination" flowid 1:10
#	done;
}
