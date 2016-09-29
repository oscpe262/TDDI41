#!/bin/bash
echo "gw" > /etc/hostname
#
echo "130.236.178.153  gw.b4.sysinst.ida.liu.se" >> /etc/hosts
echo "130.236.178.17   gw.b4.sysinst.ida.liu.se" >> /etc/hosts
#
echo "auto lo" > /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces
echo "auto eth0" >> /etc/network/interfaces
echo "   iface eth0 inet static" >> /etc/network/interfaces
echo "   address 130.236.178.153" >> /etc/network/interfaces
echo "   netmask 255.255.255.248" >> /etc/network/interfaces
echo "   gateway 130.236.178.17" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces
echo " auto eth1" >> /etc/network/interfaces
echo "   iface eth1 inet static" >> /etc/network/interfaces
echo "   address 130.236.178.17" >> /etc/network/interfaces
echo "   netmask 255.255.0.0" >> /etc/network/interfaces
echo "   gateway 130.236.178.0"  >> /etc/network/interfaces
