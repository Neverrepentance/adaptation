#!/bin/bash

set -x

ARCH=$(arch)

## 配置软件仓库
if [ "$ARCH" == "aarch64" ]; then
    \cp -f ../repo/Centos-altarch-7.repo /etc/yum.repos.d/CentOS-Base.repo
elif [ "$ARCH" == "x86_64" ]; then
    \cp -f ../repo/Centos-7.repo /etc/yum.repos.d/CentOS-Base.repo
fi

base_path="/home/compile"

## 这里不需要保存安装的软件包
#sed -i '/keepcache=/d' /etc/yum.conf
#echo "keepcache=1" >> /etc/yum.conf

## 安装编译需要的软件
yum clean all
yum makecache

yum install -y tar 
yum install -y wget
yum install -y gcc
yum install -y make
yum install -y bzip2
yum install -y autoconf

jemalloc_version=5.3.0
jemalloc_url="https://github.com/jemalloc/jemalloc/archive/refs/tags/${jemalloc_version}.tar.gz"
mkdir -p ${base_path}/jemalloc/
wget --no-check-certificate ${jemalloc_url}
mv ./${jemalloc_version}.tar.gz ${base_path}/jemalloc/
tar zxf  ${base_path}/jemalloc/${jemalloc_version}.tar.gz -C  ${base_path}/jemalloc/
pushd  ${base_path}/jemalloc/jemalloc-${jemalloc_version}/
    ./autogen.sh
    make 
    make install
popd

redis_version="6.2.16"
redis_source_url="https://github.com/redis/redis/archive/refs/tags/${redis_version}.tar.gz"

mkdir -p  ${base_path}/redis/
rm -rf  ./redis/${ARCH}
mkdir -p  ./redis/${ARCH}

wget --no-check-certificate ${redis_source_url}
mv ${redis_version}.tar.gz ${base_path}/redis/
tar zxf  ${base_path}/redis/${redis_version}.tar.gz -C  ${base_path}/redis/
pushd  ${base_path}/redis/redis-${redis_version}
    make MALLOC=jemalloc
popd
cp ${base_path}/redis/redis-${redis_version}/src/redis-server ./redis/${ARCH}/
cp ${base_path}/redis/redis-${redis_version}/src/redis-cli ./redis/${ARCH}/

tar czf redis.tar.gz redis
