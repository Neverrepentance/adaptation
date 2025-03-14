#!/bin/bash
set -x

rm -f *.core
rm -f core.*

# 部分rpm如wget无法在cmcc的仓库上找到，还是得保留官方的仓库源
# rm -f /etc/yum.repo.d/*.repo
cp ./repo/BCLinux-Base.repo /etc/yum.repos.d/

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