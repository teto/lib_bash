#!/bin/bash


# 
function ssh_get_client_ip()
{
if [ ! -z "$SSH_CLIENT" ]; then

	local ip=$( echo "$SSH_CLIENT" | cut -d' ' -f1)
	echo $ip
fi
}