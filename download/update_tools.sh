#!/bin/bash

base_dir="/home/images"

link_file="local_tool_3.2.5.txt"

function download_tools(){    
  links=$(cat ./${link_file} |grep ${2}|grep ${1}  |sort -u)
  if [ -d ${base_dir}/tools/${1}/${2}/pkg ]; then
    rm -rf ${base_dir}/tools/${1}/${2}/pkg
  fi
  mkdir -p ${base_dir}/tools/${1}/${2}/pkg
  pushd ${base_dir}/tools/${1}/${2}/pkg
    for link in ${links}
    do 
      wget ${link}
    done
  popd

  pushd ${base_dir}
    if [ -f tools_${1}_${2}.tar.gz ]; then
      rm -f tools_${1}_${2}.tar.gz
    fi
    tar czf tools_${1}_${2}.tar.gz -C tools/${1}/${2}/pkg/ .
  popd
}


os_list=("el7" "ky10" "oe2203sp1")
arch_list=("x86_64" "aarch64")
for os in ${os_list[@]}; do
  for arch in ${arch_list[@]}; do
    echo "OS:$os, arch: $arch"
    download_tools $os  $arch
  done
done
