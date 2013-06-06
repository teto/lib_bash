#!/bin/bash 

source lib_generic.sh

mptcp_get_global_state()
{
	# -n  to prevent key name being displayed
	sysctl -n net.mptcp.mptcp_enabled
}

mptcp_switch_global_state()
{
	local newState=1 
	
	if [ $(mptcp_get_global_state) -ne 0 ]; then
		newState=0
	fi

	cmd="sysctl -w net.mptcp.mptcp_enabled=$newState"
	gen_launch_command "$cmd"
}


# @param if_name
# @return "on" or "off"
mptcp_get_if_capability()
{
	local if_name=$1

	
	local res=$(ip addr show $if_name | grep -o NOMULTIPATH)
	
	# if res empty 
	if [ -z "$res" ]; then
		echo "on"
	else
		echo "off"
	fi
	
}

# @param if_name
mptcp_switch_if_capability()
{
	local if_name=$1

	local new_cap="off";
	if [ $(mptcp_get_if_capability $if_name) == "off" ]; then
		new_cap="on"
	fi

	cmd="ip link set dev $if_name multipath $new_cap"
	gen_launch_command "$cmd"
}


mptcp_add_routing_table_entries ()
{
	echo "todo"


	
}


