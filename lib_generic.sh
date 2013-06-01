#!/bin/bash 


# @param command name
gen_launch_command()
{
	# shoulddisplay command only if a certian variable is exported. Sthg like DEBUG
	local cmd="$1"
	echo -e "====== Launching command : $cmd ==="
	# $($cmd)
	eval "$cmd"
	if [ $? -ne 0 ]; then
		echo -e "\tFailure happened"
	fi

	echo -e "==== End ===="

}