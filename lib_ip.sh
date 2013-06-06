#! /bin/bash

source lib_generic.sh

# accept  1 arguement , interface name
ip_get_if_ipv4()
{
       local if_name="$1" 
    ip -o -4 addr show "$if_name" scope global| tr -s ' '|cut -d' ' -f4|cut -d'/' -f1
}

# @param interface name
ip_get_if_gateway()
{
        local if_name="$1"
	ip -4 route list 0/0 |grep "$if_name"| cut -d' ' -f3
}

# @param interface name
ip_get_if_mask()
{
    local if_name="$1" 
    ip -o -4 addr show "$if_name" scope global| tr -s ' '|cut -d' ' -f4|cut -d'/' -f2
}


# @param if_name

#  @param gateway_ip optional parameter, if set adds a route
ip_add_routing_table()
{
    local if_name gateway_ip if_ip if_mask network_address NUM
    if_name=$1
    if [ ! -z $2 ]; then
     	gateway_ip=$2
	echo "gateway ip set to $gateway_ip"
	fi


    # FIRST, make a table-alias
    if [ `grep $if_name /etc/iproute2/rt_tables | wc -l` -eq 0 ]; then
        NUM=`cat /etc/iproute2/rt_tables | wc -l`
        echo "$NUM $if_name" >> /etc/iproute2/rt_tables
    fi
    
    # local if_ip if_ip_and_mask mask
    # retrieve IP
    # if_ip_and_mask=$(ip_get_if_ipv4 $if_name);
    
    
    if_ip=$(ip_get_if_ipv4 $if_name)
    mask=$(ip_get_if_mask $if_name)
    
 echo "ip & mask $if_ip & $mask"
    network_address=$(ip_get_network_address $if_ip $mask)
    echo "Network address $network_address"
    echo "adding routing rule: from $if_ip with mask $mask"



    cmd="ip rule add from $if_ip table $if_name"
    gen_launch_command "$cmd"
    # compute network address from address  
    cmd="ip route add $network_address dev $if_name scope link table $if_name"
    gen_launch_command "$cmd"

	if [ ! -z $gateway_ip ]; then
		cmd="ip route add default via $gateway_ip dev $if_name table $if_name"
		gen_launch_command "$cmd"
	fi
}


# Expects
# @param if_name

# @param gateway_ip
# @param table_name Routing table name
ip_add_default_route()
{
#    local rt_table_name gateway_ip
	local if_ip if_name
	if_name=$1
	if_ip=$(ip_get_if_ipv4 $if_name)

    #gateway_ip=$1
    #rt_table_name=$2
cmd="ip route add default scope global nexthop via $if_ip dev $if_name"
    #cmd="ip route add default via dev $gateway_ip table  $rt_table_name"
                                              
    gen_launch_command "$cmd"
}


ip_delete_and_flush_table()
{
    local if_name=$1;

    ip rule del table $if_name
    ip route flush table $if_name
}

# returns an array with as entries
# - mask
# - ip
ip_get_if_infos()
{
	echo "TODO"
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

    for if_name in "$@"; do
        
        echo "Show routing table for interface \"$if_name\""

        cmd="ip route show table $if_name"

        # echo -e "launching command \t $cmd "
        # eval $cmd
        gen_launch_command "$cmd"

    done


}

# @param name of the variable to save if_name to
ip_choose_interface_name()                                                                           
{

    local if_name=$1

    if [ $# -ne 1 ]; then
            echo "Usage: name of the exported variable, for instance export MY_IF; $0 MY_IF"
            exit 1                                                                                  
    fi  
    echo "Please choose an interface or type q to quit"
    

    #echo "Saving result into variable named $if_name"
    # -o allows to keep output on one line                                                  
    results=$( ip -o addr list scope global | cut -d' ' -f2 )
    
    # create an array
    declare -a if_names=( $results );                                    

    #echo tableau ${if_names[@]}
    gen_choose_value_from_array if_names[@] $if_name

    echo $CURRENT_IF

}


# @param ip in format A.B.C.D
# @param mask mask should be an integer between 1 and 32 (for now)
ip_get_network_address()
{
    local ip mask network_address;
    ip=$1
    mask=$2
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

