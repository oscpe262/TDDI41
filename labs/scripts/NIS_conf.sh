#!/bin/bash
source common.sh

### Exercise 3: Install and configure the NIS server ###########################
### 3-1 Install the NIS server software on your server.
PKGS=( "nis" )
for PKG in ${PKGS[@]}; do
  [[ `dpkg -l $PKG` ]] && apt-get -q -y install $PKG --no-install-recommends
done


### 3-2 Configure your server as a NIS master for your NIS domain.
if [[ `uname -n` == "server" ]]; then
  echo "ypserver server.${GROUP}.sysinst.ida.liu.se" >> /etc/yp.conf
  sed -i '/0.0.0.0/d' /etc/ypserv.securenets
  echo "255.255.255.248\t\t${nw}.$STARTADDRESS" >> /etc/ypserv.securenets
  sed -i 's/NISSERVER.*/NISSERVER=master' /etc/default/nis


### 3-3 Populate the NIS tables with data from your local files.
  ypserv
  /usr/lib/yp/ypinit -m
  /etc/init.d/nis restart
fi

### Report: Automated tests that show that the NIS server is running and contains the appropriate data.
# See NIS_test.sh

### When testing NIS at this point, when you have no clients, you may need to use the ypbind command manually to bind to the server. The ypcat command is useful to read the contents of a NIS map. The ypwhich command shows which server the client is bound to.

### The next step is to configure NIS clients. You may configure your server as a NIS client to itself, if you want to. The advantage of this is homogeneity. The disadvantage is that the server will be more difficult to work with if NIS service breaks.

### Exercise 4: Configure NIS clients ##########################################
### 4-1 Configure your clients as NIS clients, so they bind to the NIS server at start.
if [[ ! `uname -n` == "server" ]]; then
  echo "ypserver server.${GROUP}.sysinst.ida.liu.se" >> /etc/yp.conf
  sed -i 's/NISSERVER.*/NISSERVER=false' /etc/default/nis
  [[ ! -d /var/yp ]] && mkdir /var/yp
  ypbind
  sed -i '/order/d' >> /etc/host.conf
  sed -i '/hosts/d' >>
  echo "order nis" >> /etc/host.conf
  echo "+::::::" >> /etc/passwd
  echo -e "hosts\t\tfiles nis dns" >> /etc/nsswitch.conf


  /etc/init.d/nis restart
fi

### Report: Automated tests that show that the clients bind to the NIS server at startup. At this point your clients are NIS clients but do not use NIS for anything.
# See NIS_test.sh

### Exercise 5: Configure the clients' name service switch #####################
### 5-1 What is the difference between using "compat" and using "files nis" as the list of sources for e.g. passwords in the name service switch.

### 5-2 Configure the name service switch on your clients so they use NIS for as much as possible. Note that you should still use local files as the first information source. Please do not use compat unless you intend to use the special features it provides.

### 5-3 Why should you use local files as the first information source instead of NIS.

### Report: Automated tests that show that the clients are now using NIS as expected. Answer to the question above.

### Note that your clients should get as much information as possible from NIS. The only information that should remain local is information that truly is local as well as information that never changes.
