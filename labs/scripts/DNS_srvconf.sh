#!/bin/bash
[[ ! `uname -n` == "server" ]] && echo "wrong node" exit 1
#5-1 Install a DNS server on your server and configure it to meet the following requirements.
packages=("bind9" "bind9-doc" "dnsutils" "host" "emacs23-nox")
for PKG in ${packages[@]}; do
  [[ `dpkg -l ${PKG}` ]] && echo "${PKG} installed" || apt-get install $PKG
done

bind="/etc/bind/"
options="${bind}named.conf.options"
locals="${bind}named.conf.local"
db="/var/cache/bind/db.sysinst.ida.liu.se"
dbi="${db}.inv"
serial="`date +%Y%m%d`01"
nw="130.236.178"
resolv="/etc/resolv.conf"


#a) It must respond authoritatively to all non-recursive queries for names in the zones you are authoritative for.
#b) It must respond to all recursive queries from the hosts on your own network.
#c) It must not respond to any recursive queries from any outside host (i.e. host not on your own network).
#d) Apart from the queries in (a), it should not respond to any queries from any outside host.
#e) It must contain valid zone data for your zone(s).
#f) The cache parameters must be chosen sensibly (i.e. you are expected to be able to motivate your choice).
#g) It must not be susceptible to the standard cache poisoning attacks. See http:www.kb.cert.org/vuls/id/800113 for details. Test your DNS server using porttest.dns-oarc.net (see http:www.dns-oarc.net/oarc/services/porttest).
#5-2 Install zone data for your normal zone.

### adjust options ###
[[ `cat ${options} | grep "154"` ]] || sed -i '2i\\tlisten-on { 130.236.178.154; };' ${options}
sed -i '/allow-query/d' ${options}
sed -i '3i\\tallow-query { internals; };' ${options}
sed -i '/allow-recursion/d' ${options}
sed -i '4i\\tallow-recursion { internals; };' ${options}
sed -i '/allow-transfer/d' ${options}
sed -i '5i\\tallow-transfer { none; };' ${options}

### adjust locals ###
sed -i '/acl internals/d' ${locals}
sed -i '/controls {/d' ${locals}
sed -i '/include/d' ${locals}
echo -e "acl internals { 127.0.0.0/8; 130.236.178.152/29; };" >> ${locals}
echo -e "controls { inet 127.0.0.1 port 953 allow {127.0.0.1; }; };" >> ${locals}
[[ -f ${bind}ns_b4_rndc-key ]] || cp ${bind}rndc.key ${bind}ns_b4_rndc-key
echo -e "include \"${bind}ns_b4_rndc-key\";" >>  ${locals}

### cache files ###

[[ -f ${db} ]] && rm ${db}
echo -e "\$TTL\t3600" >> ${db}
echo -e "@\tIN\tSOA\tserver.b4.sysinst.ida.liu.se.\b4.tsysinst.ida.liu.se. (" >> ${db}
echo -e "\t\t${serial}\t; Serial" >> ${db}
echo -e "\t\t3600\t\t; Refresh" >> ${db}
echo -e "\t\t600\t\t; Retry" >> ${db}
echo -e "\t\t86400\t\t; Expire" >> ${db}
echo -e "\t\t600\t\t; Negative Cache TLL\n);" >> ${db}
echo -e "@\t\tIN\tNS\tserver.b4.sysinst.ida.liu.se." >> ${db}
echo -e ""  >> ${db}
echo -e "server\tIN\tA\t${nw}.154" >> ${db}
echo -e "gw\t\tIN\tA\t${nw}.153" >> ${db}
echo -e "client-1\tIN\tA\t${nw}.155" >> ${db}
echo -e "client-2\tIN\tA\t${nw}.156" >> ${db}
echo "" >> ${db}

[[ -f ${dbi} ]] && rm ${dbi}
echo -e "@\tIN\tSOA\tserver.b4.sysinst.ida.liu.se.\tsysinst.ida.liu.se. (" >> ${dbi}
echo -e "\t\t${serial}\t; Serial" >> ${dbi}
echo -e "\t\t3600\t\t; Refresh" >> ${dbi}
echo -e "\t\t600\t\t; Retry" >> ${dbi}
echo -e "\t\t86400\t\t; Expire" >> ${dbi}
echo -e "\t\t600 \t\t; Negative Cache TLL\n);" >> ${dbi}
echo -e "@\tIN\tNS\tserver.b4.sysinst.ida.liu.se." >> ${dbi}
echo -e "154\tIN\tPTR\tserver.b4.sysinst.ida.liu.se." >> ${dbi}
echo -e "153\tIN\tPTR\tgw.b4.sysinst.ida.liu.se." >> ${dbi}
echo -e "155\tIN\tPTR\tclient-1.b4.sysinst.ida.liu.se." >> ${dbi}
echo -e "156\tIN\tPTR\tclient-2.b4.sysinst.ida.liu.se." >> ${dbi}

sed -i '/sysinst/d ; 3i\search b4.sysinst.ida.liu.se' ${resolv}

/etc/init.d/bind9 restart
[[ ! ${?} -eq 0 ]] && echo "BIND9 Restart Failed, see /var/log/syslog for further details!" && cat /var/log/syslog | tail -n 15 && exit 1
exit 0
