#!/bin/bash
[[ ! `uname -n` == "server" ]] && echo "wrong node" exit 1
#5-1 Install a DNS server on your server and configure it to meet the following requirements.
packages=("bind9" "bind9-doc" "bind9utils" "dnsutils" "host" "emacs23-nox")
for PKG in ${packages[@]}; do
  [[ `dpkg -l ${PKG}` ]] && echo "${PKG} installed" || apt-get install $PKG
done

bind="/etc/bind/"
options="${bind}named.conf.options"
locals="${bind}named.conf.local"
serial="`date +%Y%m%d`01"
nw="130.236.178"
resolv="/etc/resolv.conf"
br="\n\t"
ldb="/etc/bind/zones/db."
sila="sysinst.ida.liu.se"
b4="b4.${sila}"
arpa="178.236.130.in-addr.arpa"

# Backup, just in case :p
[[ ! -d /etc/bind/.bak ]] && mkdir /etc/bind/.bak && cp /etc/bind/named.conf* /etc/bind/.bak/

#a) It must respond authoritatively to all non-recursive queries for names in the zones you are authoritative for.
#b) It must respond to all recursive queries from the hosts on your own network.
cp /etc/bind/.bak/named.conf.local /etc/bind/
echo -e "acl internals { ${br}127.0.0.0/8; ${br}${nw}.153; ${br}${nw}.154; ${br}${nw}.155; ${br}${nw}.156; \n};\n" >> ${locals}
sed -i '/listen-on {/d ; 2i\\tlisten-on { 130.236.178.154; };' ${options}
sed -i '/\trecursion/d ; 4i\\trecursion yes;' ${options}
#c) It must not respond to any recursive queries from any outside host (i.e. host not on your own network).
sed -i '/allow-recursion/d ; 5i\\tallow-recursion { internals; };' ${options}
#d) Apart from the queries in (a), it should not respond to any queries from any outside host.
sed -i '/allow-query/d ; 6i\\tallow-query { internals; };' ${options}
sed -i '/allow-transfer/d ; 7i\\tallow-transfer { none; };' ${options}
sed -i '/forwarders {/d ; 8i\\tforwarders { 8.8.8.8; 8.8.4.4; };' ${options}
#e) It must contain valid zone data for your zone(s).
echo -e "zone \"${b4}\" {${br}type master;" >> ${locals}
echo -e "\tfile \"${ldb}${b4}\";\n};\n" >> ${locals}

echo -e "zone \"${arpa}\" {${br}type master;" >> ${locals}
echo -e "\tfile \"${ldb}${arpa}\";\n};\n" >> ${locals}

[[ -d /etc/bind/zones ]] && rm -r /etc/bind/zones
mkdir /etc/bind/zones

z1="${ldb}${b4}"
echo -e "\$TTL\t3600" >> ${z1}
echo -e "@\tIN\tSOA\tserver.${b4}.\t${b4}. (" >> ${z1}
echo -e "\t\t${serial}\t; Serial" >> ${z1}
echo -e "\t\t3600\t\t; Refresh" >> ${z1}
echo -e "\t\t600\t\t; Retry" >> ${z1}
echo -e "\t\t86400\t\t; Expire" >> ${z1}
echo -e "\t\t600\t\t; Negative Cache TLL\n);" >> ${z1}
echo -e "\n; name servers - NS records" >> ${z1}
echo -e "\tIN\tNS\tserver.${b4}." >> ${z1}
echo -e "\n; name servers - A records" >> ${z1}
echo -e "server.${b4}.\tIN\tA\t${nw}.154" >> ${z1}
echo -e "\n; ${nw}.152/29 - A records" >> ${z1}
echo -e "gw.${b4}.\tIN\tA\t${nw}.153" >> ${z1}
echo -e "client-1.${b4}.\tIN\tA\t${nw}.155" >> ${z1}
echo -e "client-2.${b4}.\tIN\tA\t${nw}.156" >> ${z1}

zinv="${ldb}${arpa}"
echo -e "\$TTL\t3600" >> ${z1}
echo -e "@\tIN\tSOA\tserver.${b4}.\t${b4}. (" >> ${z1}
echo -e "\t\t${serial}\t; Serial" >> ${z1}
echo -e "\t\t3600\t\t; Refresh" >> ${z1}
echo -e "\t\t600\t\t; Retry" >> ${z1}
echo -e "\t\t86400\t\t; Expire" >> ${z1}
echo -e "\t\t600\t\t; Negative Cache TLL\n);" >> ${z1}
echo -e "\n; name servers" >> ${z1}
echo -e "\tIN\tNS\tserver.${b4}." >> ${z1}
echo -e "\n; PTR records" >> ${z1}
echo -e "153\tIN\tPTR\tgw.${b4}." >> ${z1}
echo -e "154\tIN\tPTR\tserver.${b4}." >> ${z1}
echo -e "155\tIN\tPTR\tclient-1.${b4}." >> ${z1}
echo -e "155\tIN\tPTR\tclient-2.${b4}." >> ${z1}
#f) The cache parameters must be chosen sensibly (i.e. you are expected to be able to motivate your choice).
#g) It must not be susceptible to the standard cache poisoning attacks. See http:www.kb.cert.org/vuls/id/800113 for details. Test your DNS server using porttest.dns-oarc.net (see http:www.dns-oarc.net/oarc/services/porttest).
#5-2 Install zone data for your normal zone.

### IPv4 mode ###
sed -i '/OPTIONS/d' /etc/default/bind9
echo -e "OPTIONS=\"-4 -u bind\"" >> /etc/default/bind9

### named.conf ###
sed -i '/default-zones/d' /etc/bind/named.conf

### adjust locals ###
echo -e "controls { ${br}inet 127.0.0.1 port 953 allow {127.0.0.1; }; \n};" >> ${locals}
[[ -f ${bind}ns_b4_rndc-key ]] || cp ${bind}rndc.key ${bind}ns_b4_rndc-key
echo -e "include \"${bind}ns_b4_rndc-key\";" >>  ${locals}

sed -i '/sysinst/d ; 3i\search b4.sysinst.ida.liu.se' ${resolv}

/etc/init.d/bind9 restart
[[ ! ${?} -eq 0 ]] && echo "BIND9 Restart Failed, see /var/log/syslog for further details!" && cat /var/log/syslog | tail -n 15 && exit 1
exit 0
