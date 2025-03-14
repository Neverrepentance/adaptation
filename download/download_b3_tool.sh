#!/bin/bash

wget http://172.16.44.106:9000/self-packet/h3c/oe2203sp1/x86_64/h3c-tool-latest.oe2203sp1.x86_64.rpm
wget http://172.16.44.106:9000/self-packet/h3c/oe2203sp1/aarch64/h3c-tool-latest.oe2203sp1.aarch64.rpm
wget http://172.16.44.106:9000/self-packet/h3c/ky10/x86_64/h3c-tool-latest.ky10.x86_64.rpm
wget http://172.16.44.106:9000/self-packet/h3c/ky10/aarch64/h3c-tool-latest.ky10.aarch64.rpm
wget http://172.16.44.106:9000/self-packet/h3c/el7/x86_64/h3c-tool-latest.el7.x86_64.rpm

tar czf h3c-tools.tar.gz h3c-tool*.rpm
rm -f h3c-tool*.rpm
