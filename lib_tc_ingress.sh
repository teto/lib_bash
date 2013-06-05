#!/bin/bash


source ./lib_tc.sh

# @param interface_name
start_ingress_filtering() {

	local if_name=$1

	sudo $TC qdisc add dev $if_name handle ffff: ingress
	for SOURCE in $SOURCES ; do
		echo "Adding filter for $SOURCE"

	    sudo $TC filter add dev $if_name parent ffff: protocol ip   \
	    u32 match ip src $SOURCE flowid :1              \
	    police rate $RATE mtu $MTU burst $BURST drop
	done;
}



# @param interface_name
stop_ingress_filtering () {
	
	local if_name=$1

	sudo $TC qdisc del dev $if_name ingress
}
