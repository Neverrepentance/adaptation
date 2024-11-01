#!/bin/bash
set -x

rm -f *.core
rm -f core.*

OS="el7"
ARCH=$(arch)

rm -f /etc/yum.repos.d/*
if [ "${ARCH}" == "aarch64" ]; then
    cp ./repo/Centos-altarch-7.repo /etc/yum.repos.d/
else
    cp ./repo/Centos-7.repo /etc/yum.repos.d/
fi


sed -i '/keepcache=/d' /etc/yum.conf
echo "keepcache=1" >> /etc/yum.conf
cache_path=/var/cache/yum

yum clean all
yum makecache

sh ./download_all.sh "${OS}" "${cache_path}"