#! /bin/bash
#

# parameter is priorratry
if [ $# -eq 1 ]; then
	DESTINATION=$1

# check variable exists
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

config () {
	echo "---- qdisc parameters ----------"
	$TC qdisc show dev $DEV
	echo "---- class parameters ----------"
	$TC class show dev $DEV
	echo "---- filter parameters Egress ----------"
	$TC filter show dev $DEV
	echo "---- filter parameters Ingress ----------"
	$TC filter show dev $DEV parent ffff:
}


stats () {
  echo "---- qdisc statistics ----------"
  $TC -s qdisc show dev $DEV
  echo "---- class statistics ----------"
  $TC -s class show dev $DEV
}


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
echo "w: switch mptcp state"
echo "1: start egress filtering (on both interfaces)"
echo "r: start netperf test"
echo "d: set extra latency for device (not implemented yet)"
echo "q: quit"

read cmd
case "$cmd" in
        [aA]) echo -e "Showing qdiscs for dev\n"
                config
                ;;
        [zZ]) echo -e "Showing stats\n"
                stats
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
                res=4
                while [ $res -ne 0 ]; do
                        read tempDEV
                        #$(ip addr list $tempDEV)
                        ip addr list $tempDEV
			res=$?
                done;
                DEV=$tempDEV
                echo -e "New device set to $DEV"
		;;
        [wW]) echo -e "Switching mptcp state"
                res=$(sysctl net.mptcp.mptcp_enabled | cut -d' ' -f3)
                echo -e "MPTCP current state $res. Switching..."
                if [ $res -eq 1 ]; then
                        res=0;
                else
                        res=1
                fi

                        sysctl -w net.mptcp.mptcp_enabled=$res

                ;;








	
esac;


done;
