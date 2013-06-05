#! /bin/bash
#
# -- simulate a much smaller amount of bandwidth than the 100MBit interface
#
# Interesting comments here
# http://mailman.ds9a.nl/pipermail/lar$TC/2003q3/009572.html

RATE=256kbit
DEV=ppp0
BURST=16kbit
#SOURCES="10.168.53.2/32 10.168.73.10/32 10.168.28.20/32"
#src nuages
SOURCES="79.141.8.227/32 94.228.180.198/32"
MTU=1440 

TC="tc"



source ./lib_tc.sh
source ./lib_ip.sh
source ./lib_tc_ingress.sh
source ./lib_tc_htb.sh
source ./lib_tc_cbq.sh
source ./lib_tc_tbf.sh


# === HANDLES ===
#handles are written x:y where x is an integer identifying a qdisc and y is an integer identifying a class belonging to that qdisc. T
#The handle for a qdisc must have zero for its y value and the handle for a class must have a non-zero value for its y value. The "1:" above is treated as "1:0".


# a root class has qdisc as its parent , that is handle qdiscNo:1

# HTB= Hierarchical Token Bucket
#	$TC qdisc add dev $DEV root handle 1:0 htb default 10







cmd="a"
while [ $cmd != "q" ]; do


echo -e "\n=====================\nActions for device $DEV ?\n=====================i\n"
echo "a: show config"
echo "z: show statistics"
echo "1: start ingress shaping" 
echo "2: start cbf shaping" 
echo "3: start tbf shaping" 
echo "t: stop policing (= ingress shaping)"
echo "e: stop shaping (=> outbound traffic)"
echo "w: switching MPTCP state"

#echo "r:  "

#echo "y: adding filters"
#echo "s: adding ingress qdisc"
echo "s: change interface"
#echo "r: adding ingress qdisc"

echo "q: quit"

read cmd 
case "$cmd" in 

	[aA]) echo -e "Showing qdiscs for dev\n"
		tc_show_config $DEV #$TC qdisc show dev $DEV
		;;
	[zZ]) echo -e "Showing stats\n"
		tc_show_stats $DEV  # $TC filter show dev $DEV parent ffff:
		;;


	1) echo -e "Start ingress filtering \n"
		#sudo $TC qdisc del dev $DEV ingress
		start_ingress_filtering $DEV
		;;
	#[rR]) echo -e "not working Reloading script\n"
				
	#	;;

	[eE]) echo -e "Stop egress filtering\n"
		stop_egress_filtering $DEV;
		;;
	
	[tT]) echo -e "Stop ingress shaping \n"
		stop_ingress_filtering $DEV;
		;;

	2) echo -e "Start CBQ filtering (unreliable a priori) \n"
		start_cbq_filtering $DEV
		;;
	3) echo -e "Start TBF filtering \n"
		start_tbf_filtering $DEV
		;;

	[sS]) ip_choose_interface_name DEV
		;;	



esac;

done

