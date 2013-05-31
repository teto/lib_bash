#! /bin/bash

# accept  1 arguement , interface name
ip_get_if_ipv4()
{
        
    ip -o -4 addr show $1 scope global| tr -s ' '|cut -d' ' -f4
}

# not done
# ip_get_if_ipv6()
# {
        
#         #ip -o -6 addr show $1 scope global| tr -s ' '|cut -d' ' -f4
# }


# @param a list of interface names "eth0 eth1 etc..."
ip_show_routing_table()
{
    # local if_name=$1;

    for if_name in $@; do
        
        echo "Show routing table for interface \"$if_name\""

        cmd="ip route show table $if_name"
        echo -e "launching command \t $cmd "
        eval $cmd

    done


}

# expect name of the variable to save if name into
# choose_interface_name test will save if name into test so 
ip_choose_interface_name()                                                                           
{

        if [ $# -ne 1 ]; then
                echo "Usage: name of the exported variable, for instance export MY_IF; $0 MY_IF"
                exit 1                                                                                  
        fi  
        echo "Please choose an interface or type q to quit"
        
        # -o allows to keep output on one line                                                  
        #read ip mask <<< $( echo "$1"|cut -d'/' -f1-2 --output-delimiter=' ')
        results=$( ip -o addr list scope global | cut -d' ' -f2 )
#echo "names: $if_names"
        # create an array, add null in order to start valid indexes from "1"
        declare -a if_names=('null' $results );                                    
        #echo "test ${if_names[0]}"                                                
#       echo "if_no at then end $letter"                                           

        chosen_if=-1                                                               

        while [ $chosen_if -ge ${#if_names[@]} ] || [ $chosen_if -le 0 ]; do       
                                                                                   
		if_no=1
		for if_name in $results; do
			echo "$if_no) $if_name"                                                
			#if_names[$if_no] = $if_name
			if_no=$((if_no+1))                                                     
		done;

                read chosen_if

		# if wanna quit
                if [ $chosen_if == "q" ]; then
                        echo quit
                        return
                fi
        done
        CURRENT_IF="${if_names[$chosen_if]}"
        #echo "$CURRENT_IF"
	#set \${!1}="${if_names[$chosen_if]}"
	read $1 <<< "${if_names[$chosen_if]}"

}

# @param ip in format A.B.C.D
# @param mask mask should be an integer between 1 and 32 (for now)
ip_get_network_address()
{
    local ip=$1 mask=$2 network_address;

    #read ip mask <<< $( echo "$1"|cut -d'/' -f1-2 --output-delimiter=' ')

    # if [ $# -ne 2 ]; then
    #         echo "usage: <ip/mask> <nameOfVarToSaveInto>"
    #         exit 1
    # fi

    mask=$(ip_convert_number_to_dotted_mask $mask)
    #echo "mask $mask"

    ip=$(ip_dotted_to_integer $ip)
   # echo "ip $ip"

    network_address=$(( ip & mask  ))

    network_address=$(ip_convert_integer_to_dotted $network_address)
    echo $network_address
    #echo ip: $ip 
    #echo mask $mask
    #exit 0

}


# converts /24 to 255.255.255.0
ip_convert_number_to_dotted_mask()
{
    local num=$1 mask=0;

    if [ $num -lt 0 ] || [ $num -gt 32 ]; then

        return 1;
    fi

    #echo "num $num"
    num=$((32-num))
    #echo "num $num"

    for i in $(seq $num 32) ; do
    #     res=$(( res + 2**e))
        #echo "i $i num $num"
        mask=$(( mask | 1 << i))
        #echo "mask $mask"
    done;
    echo "$mask"
}


# ip_dotted_to_integer() { 
#     local IFS=. num quad ip e
#     num=$1
  
#     for e in 3 2 1
#     do
#         (( quad = 256 ** e))
#         (( ip[3-e] = num / quad ))
#         (( num = num % quad ))
#     done
#     ip[3]=$num
#     echo "${ip[*]}"
# }



# converts A.B.C.D to a 32 bits integer
# ip_dotted_to_integer() { 
#     local IFS=. num quad ip e
#     num=$1
#     for e in 3 2 1
#     do
#         (( quad = 256 ** e))
#         (( ip[3-e] = num / quad ))
#         (( num = num % quad ))
#     done
#     ip[3]=$num
#     echo "${ip[*]}"
# }


# converts a 32 bits integer to A.B.C.D 
ip_convert_integer_to_dotted() { 

    local ip="" num
    num=$1

    #local declare -a ip=(0 0 0 0)
    for i in 0 8 16 24; do

        tmp=$(( num >> i  & 255))
        ip="$tmp $ip"
    done
    echo $ip | tr ' ' '.'

}





# converts A.B.C.D to a 32 bits integer

ip_dotted_to_integer ()
{
    # changing IFS locally permits correct declaration of ip as an array
    local IFS=. ip num=0 e
    declare -a ip=($1)
    for e in 3 2 1
    do
        (( num += ip[3-e] * 256 ** e ))
    done
    (( num += ip[3] ))
    

    echo $num
}

