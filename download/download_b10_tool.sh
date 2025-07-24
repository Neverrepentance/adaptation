#!/bin/bash

pushd /home/images/B10 
  wget http://172.16.44.106:9000/self-packet/B10/oe2203sp1/aarch64/sec-tool-latest.oe2203sp1.B10.aarch64.rpm
  wget http://172.16.44.106:9000/self-packet/B10/oe2203sp1/x86_64/sec-tool-latest.oe2203sp1.B10.x86_64.rpm

  tar czf b10-tools.tar.gz *.rpm
  rm -f *.rpm
popd
