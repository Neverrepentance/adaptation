#!/bin/bash

set -x

rm -f *.core
rm -f core.*

yum -y install tar
OS=$(rpm -qa|grep ^tar-[0-9]|awk -F '.' '{print $(NF-1)}')
if [ -z "$OS" ]; then
  OS=$(rpm -qa|head -n 1|awk -F '.' '{print $(NF-1)}')
fi
ARCH=$(arch)

if [[ "$OS" == "el7" ]]; then
  ### 修改yum配置，安装时缓存包
  sed -i '/keepcache=/d' /etc/yum.conf
  echo "keepcache=1" >> /etc/yum.conf
  cache_path=/var/cache/yum
elif [[ "$OS" == "ky10" ]] || [[ "$OS" == "oe2203sp1" ]] || [[ "$OS" == "tl3" ]]; then
  sed -i '/keepcache=/d' /etc/dnf/dnf.conf
  echo "keepcache=1" >> /etc/dnf/dnf.conf
  sed -i '/cachedir=/d' /etc/dnf/dnf.conf
  echo "cachedir=/var/cache/dnf/rpm" >> /etc/dnf/dnf.conf
  sed -i '/sslverify=/d' /etc/dnf/dnf.conf
  echo "sslverify=false" >> /etc/dnf/dnf.conf
  cache_path=/var/cache/dnf
  sed -i 's/gpgcheck = 1/gpgcheck = 0/g'  /etc/yum.repos.d/kylin_${ARCH}.repo
  sed -i 's/gpgcheck = 1/gpgcheck = 0/g'  /etc/yum.repos.d/openEuler.repo
  sed -i 's/gpgcheck = 1/gpgcheck = 0/g'  /etc/yum.repos.d/TencentOS.repo

  if [[ "$OS" == "ky10" ]]; then
    spv=$(cat /etc/.productinfo |grep -Eo "SP[0-9]")
    OS=$(echo ${OS}${spv}|awk '{print tolower($0)}')
  fi
fi 

echo "$OS, $ARCH"

yum clean all
yum makecache

yum -y install tar
yum -y install findutils

function clear_cache(){
  if [ -d ${OS}/${ARCH}/${1} ]; then
     rm -rf ${OS}/${ARCH}/${1}
  fi 
  
  mkdir -p ${OS}/${ARCH}/${1}/pkg
  find $cache_path -name "*.rpm" -exec rm -f {} \;
}

function download_rpm(){
  yum -y install ${2}

  find $cache_path -name "*.rpm" -exec mv {} ${OS}/${ARCH}/${1}/pkg \;
}

function tar_rpm(){
  if [ ! -d ${OS}/${ARCH}/${1} ]; then
    return
  fi

  if [ ! -d ${OS}_${ARCH} ]; then
    mkdir ${OS}_${ARCH}
  fi
  rm -rf ${OS}_${ARCH}/${1}
  cp -r ${OS}/${ARCH}/${1} ${OS}_${ARCH}/

  tar czf ${OS}.${ARCH}.${1}.tar.gz ${OS}/${ARCH}/${1}/pkg/*
}

function tar_all_rpm(){
  if [ -n "$1" ]; then
    return
  fi
  if [ ! -d ${OS}_${ARCH} ]; then
    return
  fi

  tar czf ${OS}_${ARCH}.tar.gz ${OS}_${ARCH}
}

find $cache_path -name "*.rpm" -exec rm -f {} \;

function s_net(){
clear_cache net
download_rpm net net-tools
download_rpm net tcpdump
download_rpm net vconfig
tar_rpm net
}

function s_jdk(){
clear_cache jdk
download_rpm jdk java-1.8.0-openjdk
tar_rpm jdk jdk
}

function s_xfont(){
clear_cache xfont
download_rpm xfont libXfont
download_rpm xfont libXfont2
download_rpm xfont xorg-x11-fonts
tar_rpm xfont
}

function s_unzip(){
clear_cache unzip
download_rpm unzip unzip
tar_rpm unzip
}

function s_misc(){
clear_cache misc
download_rpm misc bridge-utils
download_rpm misc libxslt
tar_rpm misc
}

function s_ntp(){
clear_cache ntp
download_rpm ntp ntp
download_rpm ntp ntpdate
download_rpm ntp chrony
tar_rpm ntp
}

function s_pv(){
clear_cache pv
download_rpm pv pv
tar_rpm pv
}

function s_common(){
clear_cache common
download_rpm common bind-libs
download_rpm common expect
download_rpm common ftp
download_rpm common GeoIP
download_rpm common libpcap
download_rpm common htop
download_rpm common hdparm
download_rpm common lrzsz
download_rpm common pciutils
download_rpm common psmisc
download_rpm common tcl
download_rpm common traceroute
download_rpm common vsftpd
tar_rpm common
}

function s_python(){
clear_cache python
python3=./python/python_${ARCH}/bin/python3
#download_rpm python python3
#curl http://mirrors.aliyun.com/pypi/get-pip.py -o get-pip.py
#python3 get-pip.py --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
#${python3} -m pip install --upgrade pip --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
#${python3} -m pip install --upgrade setuptools --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
mkdir -p ${OS}/${ARCH}/python/pkg/whl
#${python3} -m pip download pip --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
#${python3} -m pip download setuptools --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
if [ -f /lib64/libffi.so.7 ]; then
  ln -f /lib64/libffi.so.7 /lib64/libffi.so.6
fi
if [ -f /lib64/libffi.so.8 ]; then
  ln -f /lib64/libffi.so.8 /lib64/libffi.so.6
fi
${python3} -m pip download ipaddress -d  ${OS}/${ARCH}/python/pkg/whl/ --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
${python3} -m pip download enum34 -d  ${OS}/${ARCH}/python/pkg/whl/ --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
${python3} -m pip download idna -d  ${OS}/${ARCH}/python/pkg/whl/ --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
${python3} -m pip download paramiko -d  ${OS}/${ARCH}/python/pkg/whl/ --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
${python3} -m pip download ply -d  ${OS}/${ARCH}/python/pkg/whl/ --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
${python3} -m pip download six -d  ${OS}/${ARCH}/python/pkg/whl/ --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
${python3} -m pip download scapy -d  ${OS}/${ARCH}/python/pkg/whl/ --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
${python3} -m pip download watchdog -d  ${OS}/${ARCH}/python/pkg/whl/ --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
${python3} -m pip download pandas -d ${OS}/${ARCH}/python/pkg/whl/ --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
${python3} -m pip download pymysql -d ${OS}/${ARCH}/python/pkg/whl/ --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
${python3} -m pip download openpyxl -d ${OS}/${ARCH}/python/pkg/whl/ --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
tar_rpm python
}

function s_mysql(){
clear_cache mysql
#rpm -ivh /home/images/mysql57-community-release-el7-7.noarch.rpm
if [[ "$OS" == "el7" ]]; then
  rpm -ivh /home/images/mysql80-community-release-el7-7.noarch.rpm
else
  rpm -ivh /home/images/mysql80-community-release-el8-9.noarch.rpm
fi
yum module disable mysql -y
download_rpm mysql mysql-community-client
download_rpm mysql mysql-community-server
download_rpm mysql mysql-community-common
download_rpm mysql mysql-community-libs
tar_rpm mysql
}

function s_snmp(){
clear_cache snmp
download_rpm snmp net-snmp
tar_rpm snmp
}


function s_stat(){
clear_cache stat
download_rpm stat sysstat
tar_rpm stat
}

function s_networkmanager(){
clear_cache networkmanager
download_rpm networkmanager NetworkManager
download_rpm networkmanager lz4
tar_rpm networkmanager
}

function s_network(){
clear_cache network
download_rpm network network-scripts
tar_rpm network
}

function s_chrome(){
 clear_cache chrome
 if [[ "$ARCH" == "x86_64" ]]; then 
    yum -y localinstall ./chrome/google-chrome-stable-*.x86_64.rpm
    cp ./chrome/google-chrome-stable-*.x86_64.rpm ./${OS}/${ARCH}/chrome/pkg/
 else
    yum -y localinstall ./chrome/browser360-cn-stable-*.aarch64.rpm
    cp ./chrome/browser360-cn-stable-*.aarch64.rpm ./${OS}/${ARCH}/chrome/pkg/
 fi
 download_rpm chrome xdg-utils
 tar_rpm chrome
}

function s_dialog(){
  clear_cache dialog
  download_rpm dialog dialog
  tar_rpm dialog
}


function s_mariadb(){
 clear_cache mariadb
 #download_rpm mariadb perl
 download_rpm mariadb mariadb
 download_rpm mariadb mariadb-server
 tar_rpm mariadb
}


if [[ $# -ge 1 ]]; then
  for param in $@
  do
    s_${param}
  done
  exit 0
fi


s_net
s_jdk
s_xfont
s_unzip
s_misc
s_ntp
s_pv
s_common
s_python
s_mysql
s_snmp
s_stat
s_networkmanager
s_network
s_chrome
s_dialog

tar_all_rpm
