#!/bin/bash
set -x

rm -f *.core
rm -f core.*


OS="oe2203sp1"
ARCH=$(arch)

sed -i '/keepcache=/d' /etc/dnf/dnf.conf
echo "keepcache=1" >> /etc/dnf/dnf.conf
sed -i '/cachedir=/d' /etc/dnf/dnf.conf
echo "cachedir=/var/cache/dnf/rpm" >> /etc/dnf/dnf.conf
sed -i '/sslverify=/d' /etc/dnf/dnf.conf
echo "sslverify=false" >> /etc/dnf/dnf.conf
cache_path=/var/cache/dnf
sed -i 's/gpgcheck = 1/gpgcheck = 0/g'  /etc/yum.repos.d/openEuler.repo

yum clean all
yum makecache

(
    exec ./download_all.sh "${OS}" "${cache_path}"
) &
wait $!