#! /bin/bash
#

# parameter is priorratry
if [ $# -eq 1 ]; then
	DESTINATION=$1

# check variable exists
# env variable created by ssh
elif [ ! -z "$SSH_CLIENT" ]; then

	DESTINATION=$( echo "$SSH_CLIENT" | cut -d' ' -f1)
else
      echo "Use $0 <IPdest>"
      exit 1

fi

echo "Using netperf server \"$DESTINATION\""

RATE=3000kbit
DEV="eth0"
#BURST=16kbit
#src nuages
SOURCES="79.141.8.227/32 94.228.180.198/32"
MTU=1440
INTERFACES="eth0 eth1"
TC="tc"

#set -e
source lib_tc.sh
source lib_mptcp.sh
source lib_ip.sh


stop_egress_filtering () {
#   
	for IF in $INTERFACES; do
		echo "Clear root for if $IF"
		$TC qdisc del dev $IF root		
	done;
}


# use: device 
start_htb_filtering()
{
	DEVICE=$1
	rate="400kbps"
	echo "installing htb filter for device $DEVICE"

	$TC qdisc add dev $DEVICE root handle 1:0 htb default 10
	$TC class add dev $DEVICE parent 1:0 classid 1:10 htb rate $rate ceil $rate prio 0
}


cmd=a
while [ $cmd != "q" ]; do


echo -e "\n=====================\nActions for device $DEV ?\n=====================i\n"
echo "a: show config"
echo "z: show statistics"
echo "e: stop shaping (=> outbound traffic)"
echo "s: change interface"
echo "1: start egress filtering (on both interfaces)"
echo "r: start netperf test"
echo "d: set extra latency for device (not implemented yet)"
echo "q: quit"

read cmd
case "$cmd" in
        [aA]) echo -e "Showing qdiscs for dev\n"
                tc_show_config
                ;;
        [zZ]) echo -e "Showing stats\n"
                tc_show_stats
                ;;

        [eE]) echo -e "Stop egress filtering\n"
                stop_egress_filtering ;
                ;;

	[rR]) echo -e "Starting test towards server $DESTINATION"
		# tests de 10 sec au lieu de 30
		 netperf -t omni -H $DESTINATION -l 10 -T 1/1  -c -C -- -m 512k -V 
		;;

	1) echo -e "Start egress filtering"
		
		for IF in $INTERFACES; do 
			start_htb_filtering $IF
		done
		;;
        [sS]) echo -e "enter interface name"
       ip_choose_interface_name DEV
#		res=4
                #while [ $res -ne 0 ]; do
                 #       read tempDEV
                        #$(ip addr list $tempDEV)
                 #       ip addr list $tempDEV
		#	res=$?
                #done;
                #DEV=$tempDEV
                #echo -e "New device set to $DEV"
		;;









	
esac;


done;
