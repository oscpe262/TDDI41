#!/bin/bash
### TO BE MADE DYNAMIC, IF THERE IS TIME
### Files ######################################################################
bind="/etc/bind/"
options="${bind}named.conf.options"
locals="${bind}named.conf.local"
resolv="/etc/resolv.conf"
################################################################################
nw="130.236.178"
br="\n\t"
ldb="/etc/bind/zones/db."
sila="sysinst.ida.liu.se"
b4="b4.${sila}"
arpa="178.236.130.in-addr.arpa"
cname="152-159.${arpa}"

### Zone Vars ##################################################################
TTL="3600"
SERIAL="`date +%s`"
REFRESH="3600"
RETRY="600"
EXPIRE="86400"
NTTL="600"
################################################################################

if [[ ! `uname -n` == "server" ]]; then
  sed -i '/nameserver/d' ${resolv}
  echo "nameserver ${nw}.154" >> ${resolv}
  exit 0
fi
#5-1 Install a DNS server on your server and configure it to meet the following requirements.
packages=("bind9" "bind9-doc" "bind9utils" "dnsutils" "host" )

for PKG in ${packages[@]}; do
  [[ `dpkg -l ${PKG}` ]] || apt-get install $PKG
done

# Backup or replace with default
[[ ! -d /etc/bind/.bak ]] && mkdir /etc/bind/.bak && cp /etc/bind/named.conf* /etc/bind/.bak/
cp /etc/bind/.bak/named.conf.local /etc/bind/
cp /etc/bind/.bak/named.conf.options /etc/bind/

#a) It must respond authoritatively to all non-recursive queries for names in the zones you are authoritative for.
echo -e "acl internals { ${br}127.0.0.0/8; ${br}${nw}.153; ${br}${nw}.154; ${br}${nw}.155; ${br}${nw}.156; \n};\n" >> ${locals}
sed -i '3i\\tlisten-on { 130.236.178.154; };' ${options}
sed -i '4i\\tallow-query { any; };' ${options}

#b) It must respond to all recursive queries from the hosts on your own network.
#c) It must not respond to any recursive queries from any outside host (i.e. host not on your own network).
sed -i '5i\\trecursion yes;' ${options}
sed -i '6i\\tallow-recursion { internals; };' ${options}

sed -i '7i\\tallow-transfer { none; };' ${options}
#d) Apart from the queries in (a), it should not respond to any queries from any outside host.
sed -i '8i\\tallow-query-cache { internals; };' ${options}
sed -i '9i\\tforwarders { 8.8.8.8; 8.8.4.4; };' ${options}

#e) It must contain valid zone data for your zone(s).
echo -e "zone \"${b4}\" {${br}type master;" >> ${locals}
echo -e "\tfile \"${ldb}${b4}\";\n};\n" >> ${locals}

echo -e "zone \"152-159.${arpa}\" {${br}type master;" >> ${locals}
echo -e "\tfile \"${ldb}${arpa}\";\n};\n" >> ${locals}

[[ -d /etc/bind/zones ]] && rm -r /etc/bind/zones
mkdir /etc/bind/zones

z1="${ldb}${b4}"
echo -e "\$TTL\t${TTL}" >> ${z1}
echo -e "@\tIN\tSOA\tserver.${b4}.\tHOSTMASTER.${b4}. (" >> ${z1}
echo -e "\t\t${SERIAL}\t; Serial" >> ${z1}
echo -e "\t\t${REFRESH}\t\t; Refresh" >> ${z1}
echo -e "\t\t${RETRY}\t\t; Retry" >> ${z1}
echo -e "\t\t${EXPIRE}\t\t; Expire" >> ${z1}
echo -e "\t\t${NTTL}\t\t; Negative Cache TLL\n);" >> ${z1}
echo -e "\n; name servers - NS records" >> ${z1}
echo -e "\tIN\tNS\tserver.${b4}." >> ${z1}
echo -e "\n; ${nw}.152/29 - A records" >> ${z1}
echo -e "server.${b4}.\tIN\tA\t${nw}.154" >> ${z1}
echo -e "gw.${b4}.\tIN\tA\t${nw}.153" >> ${z1}
echo -e "client-1.${b4}.\tIN\tA\t${nw}.155" >> ${z1}
echo -e "client-2.${b4}.\tIN\tA\t${nw}.156" >> ${z1}

zinv="${ldb}${arpa}"
echo -e "\$TTL\t${TTL}" >> ${zinv}
echo -e "@\tIN\tSOA\tserver.${b4}.\tHOSTMASTER.${b4}. (" >> ${zinv}
echo -e "\t\t${SERIAL}\t; Serial" >> ${zinv}
echo -e "\t\t${REFRESH}\t\t; Refresh" >> ${zinv}
echo -e "\t\t${RETRY}\t\t; Retry" >> ${zinv}
echo -e "\t\t${EXPIRE}\t\t; Expire" >> ${zinv}
echo -e "\t\t${NTTL}\t\t; Negative Cache TLL\n);" >> ${zinv}
echo -e "\n; name servers" >> ${zinv}
echo -e "\tIN\tNS\tserver.${b4}." >> ${zinv}
echo -e "\n; PTR records" >> ${zinv}
echo -e "153.${cname}.\tIN\tPTR\tgw.${b4}." >> ${zinv}
echo -e "154.${cname}.\tIN\tPTR\tserver.${b4}." >> ${zinv}
echo -e "155.${cname}.\tIN\tPTR\tclient-1.${b4}." >> ${zinv}
echo -e "156.${cname}.\tIN\tPTR\tclient-2.${b4}." >> ${zinv}

#f) The cache parameters must be chosen sensibly (i.e. you are expected to be able to motivate your choice).
#g) It must not be susceptible to the standard cache poisoning attacks. See http:www.kb.cert.org/vuls/id/800113 for details. Test your DNS server using porttest.dns-oarc.net (see http:www.dns-oarc.net/oarc/services/porttest).


#5-2 Install zone data for your normal zone.

# rate limit (tbd)
### Tweaks ###
sed -i '10i\\tmax-cache-size 64M;' ${options}
sed -i '11i\\tmax-cache-ttl 60;' ${options}
sed -i '12i\\tmax-ncache-ttl 0;' ${options}

### IPv4 mode ###
sed -i '/OPTIONS/d' /etc/default/bind9
echo -e "OPTIONS=\"-4 -u bind\"" >> /etc/default/bind9

### named.conf ###
sed -i '/default-zones/d' /etc/bind/named.conf

### adjust locals ###
echo -e "controls { ${br}inet 127.0.0.1 port 953 allow {127.0.0.1; }; \n};" >> ${locals}
[[ -f ${bind}ns_b4_rndc-key ]] || cp ${bind}rndc.key ${bind}ns_b4_rndc-key
echo -e "include \"${bind}ns_b4_rndc-key\";" >>  ${locals}

sed -i '/sysinst/d' ${resolv}
sed -i '/154/d' ${resolv}
sed -i '3i\search b4.sysinst.ida.liu.se' ${resolv}
sed -i '4i\nameserver 130.236.178.154' ${resolv}

/etc/init.d/bind9 restart
[[ ! ${?} -eq 0 ]] && echo "BIND9 Restart Failed, see /var/log/syslog for further details!" && cat /var/log/syslog | tail -n 15 && exit 1
exit 0
