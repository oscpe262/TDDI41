#!/bin/bash
source common.sh

#Exercise 3: Install and configure the NIS server
#3-1 Install the NIS server software on your server.
if [[ `uname -n` == "server" ]]; then
  PKGS=( "nis" )
  for PKG in ${PKGS[@]}; do
    [[ `dpkg -l $PKG` ]] && apt-get -q -y install $PKG --no-install-recommends
  done

#3-2 Configure your server as a NIS master for your NIS domain.
  ypserv


#3-3 Populate the NIS tables with data from your local files.
  /usr/lib/yp/ypinit -m
echo "ypserver server.b4.sysinst.ida.liu.se" >> /etc/yp.conf
sed -i '/0.0.0.0/d' /etc/ypserv.securenets
echo "255.255.255.248\t\t${nw}.$STARTADDRESS" >> /etc/ypserv.securenets
sed -i 's/NISSERVER.*/NISSERVER=master' /etc/default/nis
fi
#Report: Automated tests that show that the NIS server is running and contains the appropriate data.

#When testing NIS at this point, when you have no clients, you may need to use the ypbind command manually to bind to the server. The ypcat command is useful to read the contents of a NIS map. The ypwhich command shows which server the client is bound to.

#The next step is to configure NIS clients. You may configure your server as a NIS client to itself, if you want to. The advantage of this is homogeneity. The disadvantage is that the server will be more difficult to work with if NIS service breaks.
