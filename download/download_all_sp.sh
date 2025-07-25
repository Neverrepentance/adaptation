#!/bin/bash

# exec > >(tee -a /home/image/dev/download/logs/$0.log) 2>&1

set -x

rm -f *.core
rm -f core.*


OS=$1
cache_path="$2"
ARCH=$(arch)

base_dir="/home/images"

echo "OS:$OS, arch: $ARCH, cache path:${cache_path}"

function clear_cache(){
  if [ -d ${base_dir}/${1}/${OS}/${ARCH} ]; then
     rm -rf ${base_dir}/${1}/${OS}/${ARCH}
  fi 
  
  mkdir -p ${base_dir}/${1}/${OS}/${ARCH}/pkg
  find $cache_path -name "*.rpm" -exec rm -f {} \;
}


function download_rpm(){
  yum -y reinstall ${2} || yum -y install ${2}
  find $cache_path -name "*.rpm" -exec mv {} ${base_dir}/${1}/${OS}/${ARCH}/pkg \;
}

function tar_rpm(){
  if [ ! -d ${base_dir}/${1}/${OS}/${ARCH} ]; then
    return
  fi
  pushd ${base_dir}
    if [ -f ${1}_${OS}_${ARCH}.tar.gz ]; then
      rm -f ${1}_${OS}_${ARCH}.tar.gz
    fi
    tar czf ${1}_${OS}_${ARCH}.tar.gz -C ${1}/${OS}/${ARCH}/pkg/ .
  popd
}

## 下载网络相关组件
function s_net(){
  # 网络配置 ifconfig命令
  download_rpm common net-tools
  # 抓包调试
  download_rpm common tcpdump
  # 创建虚拟接口，配置vlan
  download_rpm common vconfig
  # tcpkill旁路阻断需要
  download_rpm common libnet
}


## JDK ，Java程序如管理端、Zookeeper需要
function s_jdk(){
  download_rpm common java-1.8.0-openjdk
}

## 中文字体
function s_xfont(){
  if [[ "$ARCH" == "x86_64" ]] && [[ "${OS}" == "el8" ]]; then
        cp ${base_dir}/xfont/${OS}/${ARCH}_local/* ${base_dir}/common/${OS}/${ARCH}/pkg/
        yum -y localinstall ${base_dir}/common/${OS}/${ARCH}/pkg/libXfont*.rpm
        yum -y localinstall ${base_dir}/common/${OS}/${ARCH}/pkg//xorg*.rpm
        download_rpm common libXfont
  else
    download_rpm common libXfont
    download_rpm common libXfont2
    download_rpm common xorg-x11-fonts
  fi
}

## 压缩解压功能
function s_unzip(){
  download_rpm common unzip
}

## 
function s_misc(){
  # bridge的创建配置命令，如brctl等
  download_rpm common bridge-utils
  # xml解析库
  download_rpm common libxslt
}

## 时间同步相关库
function s_ntp(){
  download_rpm common ntp
  download_rpm common ntpdate
  if ! rpm -q ntp > /dev/null
  then
    ## centos8,以及基于centos8的系统，chrony取代了ntp。
    download_rpm common chrony
  fi
}

## 公共模块使用，用于通过管道显示数据处理进度
function s_pv(){
  download_rpm common pv
}

## 通用组件
function s_common(){
  download_rpm common createrepo

  # nslookup 诊断命令
  download_rpm common bind-utils
  # 远程ssh响应式交互
  download_rpm common expect
  # ftp备份
  download_rpm common ftp
  # IP地址库
  download_rpm common GeoIP
  # 抓包的库
  download_rpm common libpcap
  # 运维工具htop
  download_rpm common htop
  # 查看硬盘相关信息
  download_rpm common hdparm
  # 上传下载包
  download_rpm common lrzsz
  # lspci，PCI查询命令
  download_rpm common pciutils
  # 提供killall、fuser、pstree等运维命令
  download_rpm common psmisc
  # tcl，图形用户界面开发及测试脚本语言工具
  download_rpm common tcl
  # 网络运费工具
  download_rpm common traceroute
  # ftp服务器
  download_rpm common vsftpd

  # 公共模块安全修复红线需要
  download_rpm common rng-tools

  # wget命令
  download_rpm common nettle
  download_rpm common wget
  
  download_rpm common xdg-utils

  # 增加运维工具
  download_rpm common gdb-headless
  download_rpm common gdb
  download_rpm common iotop
  download_rpm common lsof  
  download_rpm common strace

  # 增加jemalloc 工具
  download_rpm common graphviz

 
  # 增加浮点运算命令
  download_rpm common bc

  
  download_rpm common ipset
}

## python的安装
function s_python(){
  python3="python3"
  download_rpm common python3

  python_dir="${base_dir}/python/${OS}/${ARCH}/whl/"

  if [ -d ${python_dir} ]; then
    rm -rf ${python_dir}
  fi

  mkdir -p ${python_dir}
  curl http://mirrors.aliyun.com/pypi/get-pip.py -o get-pip.py
  python3 get-pip.py --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  ${python3} -m pip download pip -d  ${python_dir} --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  ${python3} -m pip download setuptools -d  ${python_dir} --index-url=https://pypi.tuna.tsinghua.edu.cn/simple

  ${python3} -m pip install --upgrade pip --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  ${python3} -m pip install --upgrade setuptools --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  if [ ! -f /lib64/libffi.so.6 ]; then
    if [ -f /lib64/libffi.so.7 ]; then
      ln -f /lib64/libffi.so.7 /lib64/libffi.so.6
    elif [ -f /lib64/libffi.so.8 ]; then
      ln -f /lib64/libffi.so.8 /lib64/libffi.so.6
    fi
  fi
  
  ${python3} -m pip download supervisor -d  ${python_dir} --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  ${python3} -m pip download ipaddress -d  ${python_dir} --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  ${python3} -m pip download enum34 -d  ${python_dir} --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  ${python3} -m pip download idna -d  ${python_dir} --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  ${python3} -m pip download paramiko -d  ${python_dir} --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  ${python3} -m pip download ply -d  ${python_dir} --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  ## six安装会在原生python3不同的lib目录下安装，导致系统原生python3的six组件丢失，产生异常
  # ${python3} -m pip download six -d  ${python_dir} --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  ${python3} -m pip download scapy -d  ${python_dir} --index-url=https://pypi.tuna.tsinghua.edu.cn/simple
  ${python3} -m pip download watchdog -d  ${python_dir} --index-url=https://pypi.tuna.tsinghua.edu.cn/simple

  pushd ${base_dir}
    tar czf python_${OS}_${ARCH}.tar.gz python/${OS}/${ARCH}/whl/*
  popd
}

function s_mysql(){
  clear_cache mysql
  #rpm -ivh /home/images/mysql57-community-release-el7-7.noarch.rpm
  if [[ "$OS" == "el7" ]]; then
    rpm -ivh /home/images/mysql80-community-release-el7-7.noarch.rpm
  else
    rpm -ivh /home/images/mysql80-community-release-el8-9.noarch.rpm
  fi

  ## 社区版
  download_rpm common mysql-community-client
  download_rpm common mysql-community-server
  download_rpm common mysql-community-common
  download_rpm common mysql-community-libs
  
  if ! rpm -q mysql-community-server > /dev/null
  then
    ## 部分系统如bclinux，不支持社区版。
    download_rpm common mysql
    download_rpm common mysql-server
    download_rpm common mysql-common
    download_rpm common mysql-libs
  fi

   mv ${base_dir}/common/${OS}/${ARCH}/pkg/mysql*.rpm ${base_dir}/mysql/${OS}/${ARCH}/pkg

  tar_rpm mysql
}

function s_snmp(){
  # ky10 sp1, 需要这三四个依赖
  download_rpm common perl
  download_rpm common perl-devel
  download_rpm common perl-libs
  download_rpm common net-snmp-libs

  download_rpm common net-snmp
}


function s_stat(){
  download_rpm common sysstat 
}

function s_networkmanager(){
  if [[ "${OS}" == "el7" ]]; then
    download_rpm common libsepol-devel
    download_rpm common libsepol
    download_rpm common readline
    download_rpm common NetworkManager
    download_rpm common lz4
  fi
}

function s_network(){
  download_rpm common network-scripts
}

function s_chrome(){
 clear_cache chrome
 if [[ "$ARCH" == "x86_64" ]]; then 
    if [[ "${OS}" == "el8" ]]; then
      cp ${base_dir}/chrome/${OS}/${ARCH}_local/* ./chrome/${OS}/${ARCH}/pkg/
      yum -y localinstall ${base_dir}/chrome/${OS}/${ARCH}/pkg/libvulkan1*.rpm
      yum -y localinstall ${base_dir}/chrome/${OS}/${ARCH}/pkg/xdg*.rpm
      yum -y localinstall ${base_dir}/chrome/${OS}/${ARCH}/pkg/liberation*.rpm
      yum -y localinstall ${base_dir}/chrome/${OS}/${ARCH}/pkg/google-chrome-stable*.rpm
    else
      yum -y localinstall ${base_dir}/chrome/google-chrome-stable-136*.x86_64.rpm
      cp ${base_dir}/chrome/google-chrome-stable-*.x86_64.rpm ${base_dir}/chrome/${OS}/${ARCH}/pkg/
    fi
 else
    yum -y localinstall ${base_dir}/chrome/browser360-cn-stable-*.aarch64.rpm
    cp ${base_dir}/chrome/browser360-cn-stable-*.aarch64.rpm ${base_dir}/chrome/${OS}/${ARCH}/pkg/
 fi
 find $cache_path -name "*.rpm" -exec mv {} ${base_dir}/common/${OS}/${ARCH}/pkg \;
 tar_rpm chrome
}

function s_dialog(){
  download_rpm common dialog
}


function s_mariadb(){
 download_rpm common mariadb
 download_rpm common mariadb-server
}

function s_tool(){
  if [ "${OS}" == "bc82" ]; then
    target_os="el7"
  else
    target_os=${OS}
  fi
  links=$(cat ./local_tool_3.2.5.txt |grep ${ARCH}|grep ${target_os} |sort -u)
  if [ -d ${base_dir}/tools/${OS}/${ARCH}/pkg ]; then
    rm -rf ${base_dir}/tools/${OS}/${ARCH}/pkg
  fi
  mkdir -p ${base_dir}/tools/${OS}/${ARCH}/pkg
  pushd ${base_dir}/tools/${OS}/${ARCH}/pkg
    for link in ${links}
    do 
      wget ${link}
    done
  popd
  tar_rpm tools
}

clear_cache "common"

# find 命令
download_rpm common findutils
# 解压安装包
download_rpm common tar


if [[ $# -ge 3 ]]; then
  for param in "${@:3}"
  do
    s_${param}
  done
  exit 0
fi

s_common
s_net
s_jdk
s_xfont
s_unzip
s_misc
s_ntp
s_pv
s_snmp
s_stat
# s_networkmanager
# s_network
s_chrome
s_mysql
s_python
s_tool
tar_rpm "common"


