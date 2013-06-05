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


# Care, Array indices are shifted not to start at 0
# @param array of values to choose between
# @param name_of_global variable in which to write the result from choice
gen_choose_value_from_array()
{
	#local entries=${1[@]}

	declare -a entries=("${!1}")
	#echo tableau2 ${entries[@]}, taille ${#entries[@]}

	local name_of_variable_to_save_to=$2
	# local name_of_variable_to_save_to=${!2}

    local chosen_entry=-1                                                               

    # while chosen number outside of entries boundaries
    while [ $chosen_entry -gt ${#entries[@]} ] || [ $chosen_entry -lt 1 ]; do       
                    
		entry_no=1
		for entry in "${entries[@]}"; do
			echo "$entry_no) $entry"                                                
			#if_names[$if_no] = $if_name
			entry_no=$((entry_no+1))                                                     
		done;

        read chosen_entry

		# if wanna quit
        if [ $chosen_entry == "q" ]; then
                echo quit
                return
        fi


    done


    #CURRENT_IF="${if_names[$chosen_entry]}"
        #echo "$CURRENT_IF"
	#set \${!1}="${if_names[$chosen_entry]}"
	local choice="${entries[$((chosen_entry-1))]}"
	echo "Saving choice $chosen_entry=$choice  into $name_of_variable_to_save_to"
	read $name_of_variable_to_save_to <<< "${choice}"

}