#!/bin/bash
source common.sh

sednssw() {
  sed -i "/$1/s/$1.*/$1:\t\t$2/" /etc/nsswitch.conf
}
# Add backups

### Exercise 3: Install and configure the NIS server ###########################
### 3-1 Install the NIS server software on your server.
PKGS=( "nis" )
for PKG in ${PKGS[@]}; do
  pkginstall $PKG
done


### 3-2 Configure your server as a NIS master for your NIS domain.
if [[ `uname -n` == "server" ]]; then
  /etc/init.d/nis stop
  sed -i '/ypserver/d' /etc/yp.conf
  echo "ypserver server.${GROUP}.sysinst.ida.liu.se" >> /etc/yp.conf
  sed -i '/0.0.0.0/d' /etc/ypserv.securenets
  sed -i '/255.255.255.248/d' /etc/ypserv.securenets
  echo -e "255.255.255.248\t\t${nw}.$STARTADDRESS" >> /etc/ypserv.securenets
  sed -i 's/NISSERVER.*/NISSERVER=master/' /etc/default/nis


### 3-3 Populate the NIS tables with data from your local files.
  ypserv
  nisrestart
fi

### Report: Automated tests that show that the NIS server is running and contains the appropriate data.
# See NIS_test.sh
#
### When testing NIS at this point, when you have no clients, you may need to use the ypbind command manually to bind to the server. The ypcat command is useful to read the contents of a NIS map. The ypwhich command shows which server the client is bound to.
#
### The next step is to configure NIS clients. You may configure your server as a NIS client to itself, if you want to. The advantage of this is homogeneity. The disadvantage is that the server will be more difficult to work with if NIS service breaks.

### Exercise 4: Configure NIS clients ##########################################
### 4-1 Configure your clients as NIS clients, so they bind to the NIS server at start.
if [[ ! `uname -n` == "server" ]]; then
  /etc/init.d/nis stop
  sed -i '/ypserver/d' /etc/yp.conf
  echo "ypserver server.${GROUP}.sysinst.ida.liu.se" >> /etc/yp.conf
  sed -i 's/NISSERVER.*/NISSERVER=false/' /etc/default/nis
  [[ ! -d /var/yp ]] && mkdir /var/yp
  ypbind
  sed -i '/order/d' /etc/host.conf
  sed -i '/hosts/d' /etc/nsswitch.conf
  sed -i '/^+/d' /etc/passwd
  echo "order nis" >> /etc/host.conf
  echo -e "hosts:\t\tfiles nis dns" >> /etc/nsswitch.conf
  echo "+::::::" >> /etc/passwd
  nisrestart
fi

### Report: Automated tests that show that the clients bind to the NIS server at startup. At this point your clients are NIS clients but do not use NIS for anything.
# See NIS_test.sh

### Exercise 5: Configure the clients' name service switch #####################
#
### 5-2 Configure the name service switch on your clients so they use NIS for as much as possible. Note that you should still use local files as the first information source. Please do not use compat unless you intend to use the special features it provides.


if [[ ! `uname -n` == "server" ]]; then
  sednssw "passwd"    "files nis"
  sednssw "group"     "compat"
  sednssw "shadow"    "files nis"
  sednssw "hosts"     "files nis dns"
  sednssw "networks"  "files nis"
  sednssw "protocols" "db files nis"
  sednssw "services"  "db files nis"
  sednssw "ethers"    "db files nis"
  sednssw "rpc"       "db files nis"
  sednssw "netgroup"  "nis"
fi

### Report: Automated tests that show that the clients are now using NIS as expected. Answer to the question above.
# See NIS.pdf and NIS_test.sh
#
### Note that your clients should get as much information as possible from NIS. The only information that should remain local is information that truly is local as well as information that never changes.
