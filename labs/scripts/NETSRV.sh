#!/bin/bash
echo "server" > /etc/hostname
#
echo "130.236.178.155  server.b4.sysinst.ida.liu.se server" >> /etc/hosts
#
echo "auto lo" > /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces
echo "auto eth0" >> /etc/network/interfaces
echo "   iface eth0 inet static" >> /etc/network/interfaces
echo "   address 130.236.178.156" >> /etc/network/interfaces
echo "   netmask 255.255.255.248" >> /etc/network/interfaces
echo "   network 130.236.178.152" >> /etc/network/interfaces
echo "   gateway 130.236.178.153" >> /etc/network/interfaces
echo "nameserver 130.236.1.9" >> /etc/resolv.conf
sed -i "s/^hosts.*$/hosts: files dns/g" /etc/nsswitch.conf
