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
	echo "t: display routing tables"
	echo "q: quit"
}




# choose_interface()
# {

# 	echo "Please choose an interface or type q to quit"
# 	#results=$( ip -o addr list scope global | grep "^[0-9]*:" | tr -d ':' | cut -d' ' -f2 )
# 	# -o allows to keep output on one line
# 	results=$( ip -o addr list scope global | cut -d' ' -f2 )
# #echo "names: $if_names"
# 	# create an array, add null in order to start valid indexes from "1"
# 	declare -a if_names=('null' $results );
# 	echo "test ${if_names[0]}"
	
# 	if_no=1
# 	for if_name in $results; do
# 		echo "$if_no) $if_name"
# 		#if_names[$if_no] = $if_name
# 		if_no=$((if_no+1))
# 	done;
# #	echo "if_no at then end $letter"

# 	chosen_if=-1

# 	while [ $chosen_if -ge ${#if_names[@]} ] || [ $chosen_if -le 0 ]; do 
# 		read chosen_if
# 		if [ $chosen_if == "q" ]; then
# 			echo quit
# 			return 
# 		fi
# 	done			
# 	CURRENT_IF="${if_names[$chosen_if]}"
# 	echo "changed interface  to $CURRENT_IF"

# }


#choose_interface_


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


			# FIRST, make a table-alias
			if [ `grep $CURRENT_IF /etc/iproute2/rt_tables | wc -l` -eq 0 ]; then
				NUM=`cat /etc/iproute2/rt_tables | wc -l`
				echo "$NUM $CURRENT_IF" >> /etc/iproute2/rt_tables
			fi
			

			# retrieve IP
			if_ip_and_mask=$(get_if_ipv4 $CURRENT_IF);
			echo "ip & mask $if_ip_and_mask"

			if_ip=$(echo $if_ip_and_mask | cut -d'/' -f2)
			mask=$(echo if_ip_and_mask | cut -d'/' -f2)

			echo "adding routing rule: from $if_ip with mask $mask"
			ip rule add from 10.1.1.2 table $CURRENT_IF
		
			# compute network address from address	
			ip route add 10.1.1.0/24 dev $CURRENT_IF scope link table $CURRENT_IF
			ip route add default via 10.1.1.1 dev $CURRENT_IF table  $CURRENT_IF
			;;
		[tT]) echo "Show routing tables"
			ip route show table $CURRENT_IF 
	esac
done;

