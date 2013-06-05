#!/bin/bash


echo "Launching with kernel $(uname -a)"

CURRENT_IF="eth0"
declare -a IPERF_SERVERS=("multipath-tcp.org" "testdebit.info" $(ssh_get_client_ip))

source ./lib_ip.sh
source ./lib_mptcp.sh


display_main_list()
{

	echo -e "===================\nCurrent interface \"$CURRENT_IF\" \n=============="
	echo "a: switch on/off mptcp (currently $(mptcp_get_global_state) ) " 
	echo "z: select interface to configure "
	echo "e: switch multipath capability for interface $(mptcp_get_if_capability)"
	echo "r: enable multipath for interface (add routing table) "
	echo "s: set default table"
	echo "y: flush entries in table $CURRENT_IF"
	echo "t: display routing table $CURRENT_IF"
	echo "d: display global routing table"
	echo "f: launch iperf test with server \" $IPERF_SERVER\""

	echo "q: quit"
}










cmd="a"
while [ "$cmd" != "q" ]; do
		
	display_main_list

	read cmd

	case "$cmd" in
		[aA]) echo ""
			mptcp_switch_global_state
			;;


		[zZ]) ip_choose_interface_name CURRENT_IF
			;;

		[eE]) echo "changing interface mptcp capability"
			#if empty	
			#if [ -z $(get_if_mp_capability) ] 
			# ip link set dev $CURRENT_IF multipath off
			mptcp_switch_if_capability $CURRENT_IF
			;;


		[rR]) echo "update routing table for if $CURRENT_IF" 
		
			# mptcp ?
			ip=$(ip_get_if_ipv4 $CURRENT_IF)
			echo "enter gateway ip (nothing if you don't know) for if $CURRENT_IF (ip $ip)"
			read gateway_ip
			
			ip_add_routing_table "$CURRENT_IF" "$gateway_ip"
		
;;
		[sS])
			# this sets the default route to do only once ?
			#ip route add default via dev $gateway table  $CURRENT_IF
#ip route add default scope global nexthop via 10.1.1.1 dev eth0
			#echo "Please enter gateway ip (for default route)"
			#read gateway_ip
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
		[dD]) 
			echo "Show global routing table"
			ip route 
			#ip_show_routing_table "$CURRENT_IF"
			;;

		[fF]) 
			echo "Launching iperf test"
			gen_choose_value_from_array IPERF_SERVERS[@] iperf_server

			cmd="iperf -c $iperf_server"
			gen_launch_command "$cmd"
			#ip route 
			#ip_show_routing_table "$CURRENT_IF"
				

	esac
done;

