#!/bin/bash 


mptcp_get_state()
{
	sysctl -n net.mptcp.mptcp_enabled
}


# @param if_name
# @return "on" or "off"
mptcp_get_if_capability()
{
	local if_name=$1

	
	local res=$(ip addr show $if_name | grep -o NOMULTIPATH)
	
	# if res empty 
	if [ -z $res ]; then
		echo "off"
	else
		echo "on"
	fi
	
}

# @param if_name
mptcp_switch_if_capability()
{
	local if_name=$1

	local new_cap="off";
	if [ $(mptcp_get_if_capability $if_name) == "off"]; then
		cap="on"
	fi

				#if [ -z $(get_if_mp_capability) ] 
	ip link set dev $if_name multipath $new_cap
}


mptcp_add_routing_table_entries ()
{



	
}


