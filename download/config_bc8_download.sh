#!/bin/bash
set -x

rm -f *.core
rm -f core.*

rm -f /etc/yum.repo.d/*.repo
cp ./repo /etc/yum.repo.d/

OS="bc82"
ARCH=$(arch)

sed -i '/keepcache=/d' /etc/dnf/dnf.conf
echo "keepcache=1" >> /etc/dnf/dnf.conf
sed -i '/cachedir=/d' /etc/dnf/dnf.conf
echo "cachedir=/var/cache/dnf/rpm" >> /etc/dnf/dnf.conf
sed -i '/sslverify=/d' /etc/dnf/dnf.conf
echo "sslverify=false" >> /etc/dnf/dnf.conf
cache_path=/var/cache/dnf

yum clean all
yum makecache

sh ./download_all.sh "${OS}" "${cache_path}"