#!/bin/bash

set -x
set -e

rm -f /etc/yum.repos.d/*
if [ "${ARCH}" == "aarch64" ]; then
    cp ../download/repo/Centos-altarch-7.repo /etc/yum.repos.d/
else
    cp ../download/repo/Centos-7.repo /etc/yum.repos.d/
fi
yum clean all
yum makecache

## 安装编译依赖
yum install -y gcc pam-level zlib-level openssl-devel net-tools perl make

yum install -y wget



ssl_version=1_1_1w
ssh_version=9.9p1
upgrade_name=upgrade_openssh-${ssh_version}-$(arch)

## 下载源码，编译
rm -f OpenSSL_*.tar.gz || echo "rm old ssl source pkg"
rm -rf openssl-OpenSSL_* || echo "rm  old ssl sourc folder"
wget https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_${ssl_version}.tar.gz
tar zxf OpenSSL_${ssl_version}.tar.gz
pushd openssl-OpenSSL_${ssl_version}
    ./config --shared
    make
    make install
    cp -fd libssl.so* /usr/lib64/
    cp -fd libcrypto.so* /usr/lib64/
popd

ldconfig

rm -rf openssh-* || echo "rm  old ssh sourc folder"
rm -rf openssh-${ssh_version} || echo "rm  old ssh sourc folder"
wget https://mirrors.aliyun.com/pub/OpenBSD/OpenSSH/portable/openssh-${ssh_version}.tar.gz
tar zxf openssh-${ssh_version}.tar.gz
pushd openssh-${ssh_version}
    ./configure --sysconfdir=/etc/ssh
    make
    make install
popd

## 制作升级包
if [ -d ${upgrade_name} ]; then
    rm -rf ${upgrade_name}
fi
mkdir ${upgrade_name}
mkdir -p ${upgrade_name}/lib64
cp -r -p /usr/local/bin ${upgrade_name}/
cp -r -p /usr/local/sbin ${upgrade_name}/
cp -r -p /usr/local/libexec ${upgrade_name}/
cp -r -p /usr/local/share ${upgrade_name}/
cp -fd openssl-OpenSSL_${ssl_version}/libssl.so* ${upgrade_name}/lib64
cp -fd openssl-OpenSSL_${ssl_version}/libcrypto.so* ${upgrade_name}/lib64

mkdir -p ${upgrade_name}/etc_ssh/
cp -r -p /etc/ssh ${upgrade_name}/etc_ssh/
cp -r -p /etc/ssl ${upgrade_name}/etc_ssl/

cp upgrade_ssh.sh ${upgrade_name}/

tar czf ${upgrade_name}.tar.gz ${upgrade_name}

## clear
rm -f OpenSSL_${ssl_version}.tar.gz
rm -f openssh-${ssh_version}.tar.gz
rm -rf openssl-OpenSSL_${ssl_version}
rm -rf openssh-${ssh_version}