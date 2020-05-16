#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

FILE='dwnl.url'

# Squid versions
V4=`cat $FILE | grep v4 | sed 's/<\/\?[^>]\+>//g'`
V5=`cat $FILE | grep v5 | sed 's/<\/\?[^>]\+>//g'`
V6=`cat $FILE | grep v6 | sed 's/<\/\?[^>]\+>//g'`

FILE_V4=`basename -s .tar.bz2 $V4`
FILE_V5=`basename -s .tar.bz2 $V5`
FILE_V6=`basename -s .tar.bz2 $V6`

basename -s .tar.bz2 $FILE

RED='\033[0;41;30m'
STD='\033[0;0;39m'

#FILE=/etc/resolv.conf
#if [ -f "$FILE" ]; then
#    echo "$FILE exist"
#fi

# [ -f /etc/resolv.conf ] && { echo "$FILE exist"; cp "$FILE" /tmp/; }
# [ -f /etc/hosts ] && echo "Found" || echo "Not found"


# ------------------ Functions & Other stuff needed ------------------#

pause(){
	read -p "Press [Enter] key to continue..." fackEnterKey
}

prepare_env(){
	apt install -y logrotate acl attr autoconf bison nettle-dev build-essential libacl1-dev \
 	 libaio-dev libattr1-dev libblkid-dev libbsd-dev libcap2-dev libcppunit-dev libldap2-dev \
 	 pkg-config libxml2-dev libdb-dev libgnutls28-dev openssl devscripts fakeroot libdbi-perl \
 	 libssl-dev libcppunit-dev libecap3-dev libkrb5-dev comerr-dev libnetfilter-conntrack-dev \
 	 libpam0g-dev libsasl2-dev krb5-user msktutil libsasl2-modules-gssapi-mit libtdb-dev
	pause
}

downl_squid(){
	while true
	do

	show_menus2
	read_options2
	done
}

down_v4(){
	echo "Downloading $FILE_V4"
	wget -c $FILE_V4.tar.bz2
	echo "Downloaded $FILE_V4. Now select 'Build/Install' option from previous menu"
	pause
	show_menus && read_options
}

down_v5(){
	echo "Downloading $FILE_V5"
	wget -c $FILE_V5.tar.bz2
	echo "Downloaded $FILE_V5. Now select 'Build/Install' option from previous menu"
	pause
	show_menus && read_options
}

down_v6(){
	echo "Downloading $FILE_V6"
	wget -c $FILE_V6.tar.bz2
	echo "Downloaded $FILE_V6. Now select 'Build/Install' option from previous menu"
	pause
	show_menus && read_options
}

build_install(){
	echo "Building..."
	preparing_area

	if [[ -f "$FILE_V4.tar.bz2" ]]
	then
		tar xvf $FILE_V4.tar.bz2
   		cd $FILE_V4
   		build_v4
   		cp squid4 /etc/init.d/
   		chmod +x /etc/init.d/squid4
   		update-rc.d squid4 defaults
   		systemctl enable squid4
	elif [[ -f "$FILE_V5.tar.bz2" ]]
	then
		tar xvf $FILE_V5.tar.bz2
   		cd $FILE_V5
   		build_v5
   		cp squid5 /etc/init.d/
   		chmod +x /etc/init.d/squid5
   		update-rc.d squid5 defaults
   		systemctl enable squid5
	else
		tar xvf $FILE_V6.tar.bz2
   		cd $FILE_V6
   		build_v6
   		cp squid6 /etc/init.d/
   		chmod +x /etc/init.d/squid6
   		update-rc.d squid6 defaults
   		systemctl enable squid6
	fi

	show_menus && read_options
}

preparing_area(){
	groupadd -g 13 proxy
	mkdir -p /var/spool/squid
	mkdir -p /var/log/squid
	mkdir -p /var/cache/squid
	useradd --system -g proxy -u 13 -d /var/spool/squid -M -s /usr/sbin/nologin proxy
 	chown proxy:proxy /var/spool/squid
 	chown proxy:proxy /var/log/squid
 	chown proxy:proxy /var/cache/squid
}

build_v4(){
	./configure --srcdir=. --prefix=/usr --localstatedir=/var/lib/squid --libexecdir=/usr/lib/squid \
 	 --datadir=/usr/share/squid --sysconfdir=/etc/squid4 --with-default-user=proxy --with-logdir=/var/log/squid \
	 --with-open-ssl=/etc/ssl/openssl.cnf --with-openssl --enable-ssl --enable-ssl-crtd --build=x86_64-linux-gnu \
	 --with-pidfile=/var/run/squid.pid --enable-removal-policies=lru,heap \
	 --enable-delay-pools --enable-cache-digests --enable-icap-client --enable-ecap --enable-follow-x-forwarded-for \
	 --with-large-files --with-filedescriptors=65536 --with-default-user=proxy \
	 --enable-auth-basic=DB,fake,getpwnam,LDAP,NCSA,NIS,PAM,POP3,RADIUS,SASL,SMB \
	 --enable-auth-digest=file,LDAP --enable-auth-negotiate=kerberos,wrapper --enable-auth-ntlm=fake,SMB_LM \
	 --enable-linux-netfilter --with-swapdir=/var/cache/squid --enable-useragent-log --enable-htpc \
	 --infodir=/usr/share/info --mandir=/usr/share/man --includedir=/usr/include --disable-maintainer-mode \
	 --disable-dependency-tracking --disable-silent-rules --enable-inline --enable-async-io \
	 --enable-storeio=ufs,aufs,diskd,rock --enable-eui --enable-esi --enable-icmp --enable-zph-qos \
	 --enable-external-acl-helpers=file_userip,kerberos_ldap_group,time_quota,LDAP_group,session,SQL_session,unix_group,wbinfo_group \
	 --enable-url-rewrite-helpers=fake --enable-translation --enable-epoll --enable-snmp --enable-wccpv2 \
	 --with-aio --with-pthreads --enable-arp --enable-arp-acl \
	 --with-build-environment=default --disable-dependency-tracking && make -j`nproc` && make install

	echo "Result: Squid4 built successfully"
}

build_v5(){
	./configure --srcdir=. --prefix=/usr --localstatedir=/var/lib/squid --libexecdir=/usr/lib/squid \
 	 --datadir=/usr/share/squid --sysconfdir=/etc/squid5 --with-default-user=proxy --with-logdir=/var/log/squid \
	 --with-open-ssl=/etc/ssl/openssl.cnf --with-openssl --enable-ssl --enable-ssl-crtd --build=x86_64-linux-gnu \
	 --with-pidfile=/var/run/squid.pid --enable-removal-policies=lru,heap \
	 --enable-delay-pools --enable-cache-digests --enable-icap-client --enable-ecap --enable-follow-x-forwarded-for \
	 --with-large-files --with-filedescriptors=65536 --with-default-user=proxy \
	 --enable-auth-basic=DB,fake,getpwnam,LDAP,NCSA,NIS,PAM,POP3,RADIUS,SASL,SMB \
	 --enable-auth-digest=file,LDAP --enable-auth-negotiate=kerberos,wrapper --enable-auth-ntlm=fake,SMB_LM \
	 --enable-linux-netfilter --with-swapdir=/var/cache/squid --enable-useragent-log --enable-htpc \
	 --infodir=/usr/share/info --mandir=/usr/share/man --includedir=/usr/include --disable-maintainer-mode \
	 --disable-dependency-tracking --disable-silent-rules --enable-inline --enable-async-io \
	 --enable-storeio=ufs,aufs,diskd,rock --enable-eui --enable-esi --enable-icmp --enable-zph-qos \
	 --enable-external-acl-helpers=file_userip,kerberos_ldap_group,time_quota,LDAP_group,session,SQL_session,unix_group,wbinfo_group \
	 --enable-url-rewrite-helpers=fake --enable-translation --enable-epoll --enable-snmp --enable-wccpv2 \
	 --with-aio --with-pthreads --enable-arp --enable-arp-acl \
	 --with-build-environment=default --disable-dependency-tracking && make -j`nproc` && make install

	echo "Result: Squid5 built successfully"
}

build_v6(){
	./configure --srcdir=. --prefix=/usr --localstatedir=/var/lib/squid --libexecdir=/usr/lib/squid \
 	 --datadir=/usr/share/squid --sysconfdir=/etc/squid6 --with-default-user=proxy --with-logdir=/var/log/squid \
	 --with-open-ssl=/etc/ssl/openssl.cnf --with-openssl --enable-ssl --enable-ssl-crtd --build=x86_64-linux-gnu \
	 --with-pidfile=/var/run/squid.pid --enable-removal-policies=lru,heap \
	 --enable-delay-pools --enable-cache-digests --enable-icap-client --enable-ecap --enable-follow-x-forwarded-for \
	 --with-large-files --with-filedescriptors=65536 --with-default-user=proxy \
	 --enable-auth-basic=DB,fake,getpwnam,LDAP,NCSA,NIS,PAM,POP3,RADIUS,SASL,SMB \
	 --enable-auth-digest=file,LDAP --enable-auth-negotiate=kerberos,wrapper --enable-auth-ntlm=fake,SMB_LM \
	 --enable-linux-netfilter --with-swapdir=/var/cache/squid --enable-useragent-log --enable-htpc \
	 --infodir=/usr/share/info --mandir=/usr/share/man --includedir=/usr/include --disable-maintainer-mode \
	 --disable-dependency-tracking --disable-silent-rules --enable-inline --enable-async-io \
	 --enable-storeio=ufs,aufs,diskd,rock --enable-eui --enable-esi --enable-icmp --enable-zph-qos \
	 --enable-external-acl-helpers=file_userip,kerberos_ldap_group,time_quota,LDAP_group,session,SQL_session,unix_group,wbinfo_group \
	 --enable-url-rewrite-helpers=fake --enable-translation --enable-epoll --enable-snmp --enable-wccpv2 \
	 --with-aio --with-pthreads --enable-arp --enable-arp-acl \
	 --with-build-environment=default --disable-dependency-tracking && make -j`nproc` && make install

	echo "Result: Squid6 built successfully"
}

# ------------------ Menus & Options ------------------#

show_menus() {
    clear
    echo "#--------------------------------#" 
    echo "     Squid downloader/builder"
    echo "#--------------------------------#"
    echo "1. Prepare environment"
    echo "2. Download Squid if needed"
    echo "3. Build/Install Squid"
    echo "4. Exit"
}

show_menus2() {
    clear
    echo "#--------------------------------#" 
    echo "     Squid downloader/builder"
    echo "#--------------------------------#"
    echo "1. Squid v4"
    echo "2. Squid v5"
    echo "3. Squid v6"
    echo "4. Exit"
}

read_options(){
    local choice
    read -p "Enter choice [ 1 - 4 ] " choice
    case $choice in
	1) prepare_env ;;
	2) downl_squid ;;
	3) build_install ;;
	4) exit 0;;
	*) echo -e "${RED}Error...${STD}" && sleep 1
    esac
}

read_options2(){
    local choice
    read -p "Enter choice [ 1 - 4 ] " choice
    case $choice in
	1) down_v4 ;;
	2) down_v5 ;;
	3) down_v6 ;;
	4) show_menus && read_options ;;
	*) echo -e "${RED}Error...${STD}" && sleep 1
    esac
}

# ----------------------------------------------
# Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Main logic - infinite loop
# ------------------------------------
while true
do

    show_menus
    read_options
done
