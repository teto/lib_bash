#!/bin/bash 


# @param command name
gen_launch_command()
{
	# shoulddisplay command only if a certian variable is exported. Sthg like DEBUG
	local cmd="$1" 
	local result="Successful"

	echo -e "====== Launching command  ===\n\t$cmd"
	# $($cmd)
	eval "$cmd"
	if [ $? -ne 0 ]; then
		result="Failure happened"
	fi

	echo -e "==== Result: $result  ===="

}
