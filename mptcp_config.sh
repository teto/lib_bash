#!/bin/bash


echo "Launching with kernel $(uname -a)"

CURRENT_IF="eth0"


source ./lib_ip.sh
source ./lib_mptcp.sh


display_main_list()
{

	echo -e "===================\nCurrent interface $CURRENT_IF\n=============="
	echo "a: switch on/off mptcp (currently $(mptcp_get_state) ) " 
	echo "z: select interface to configure "
	echo "e: switch multipath capability for interface $(mptcp_get_if_capability)"
	echo "r: enable multipath for interface (add routing table) "
	echo "s: set default table"
	echo "y: flush entries in table"
	echo "t: display routing tables"
	echo "q: quit"
}










cmd="a"
while [ "$cmd" != "q" ]; do
		
	display_main_list

	read cmd

	case "$cmd" in
		[aA]) echo "choice A"
			;;


		[zZ]) ip_choose_interface_name CURRENT_IF
			;;

		[eE]) echo "changing capability"
			#if empty	
			#if [ -z $(get_if_mp_capability) ] 
			# ip link set dev $CURRENT_IF multipath off
			mptcp_switch_if_capability $CURRENT_IF
			;;


		[rR]) echo "update routing table for if $CURRENT_IF" 
		
			# mptcp ?
			ip_add_routing_table "$CURRENT_IF"
			# FIRST, make a table-alias
			# if [ `grep $CURRENT_IF /etc/iproute2/rt_tables | wc -l` -eq 0 ]; then
			# 	NUM=`cat /etc/iproute2/rt_tables | wc -l`
			# 	echo "$NUM $CURRENT_IF" >> /etc/iproute2/rt_tables
			# fi
			
			# # local if_ip if_ip_and_mask mask
			# # retrieve IP
			# if_ip_and_mask=$(ip_get_if_ipv4 $CURRENT_IF);
			# echo "ip & mask $if_ip_and_mask"
			
			
			# if_ip=$(echo $if_ip_and_mask | cut -d'/' -f1)
			# mask=$(echo $if_ip_and_mask | cut -d'/' -f2)

			# network_address=$(ip_get_network_address $if_ip $mask)
			# echo "Network address $network_address"
			# echo "adding routing rule: from $if_ip with mask $mask"

			# ip rule add from $if_ip table $CURRENT_IF
		
			# # compute network address from address	
			# ip route add $network_address dev $CURRENT_IF scope link table $CURRENT_IF
			#ip route add default via  dev $CURRENT_IF table  $CURRENT_IF
;;
		[sS])
			# this sets the default route to do only once ?
			#ip route add default via dev $gateway table  $CURRENT_IF

			echo "Please enter gateway ip (for default route)"
			read gateway_ip
			ip_add_default_route $gateway_ip $CURRENT_IF
			;;

		[yY]) # flush entries
			# ip_rt_flush
			ip_delete_and_flush_table "$CURRENT_IF"

			;;
		[tT]) 
			#echo "Show routing tables"
			ip_show_routing_table "$CURRENT_IF"
			;;
	esac
done;

