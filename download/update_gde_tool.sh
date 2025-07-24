#!/bin/bash

base_dir="/home/images"
tool_name="gde_tool"
link_file="${tool_name}.txt"

function download_tools(){    
  links=$(cat ./${link_file} |grep ${2}|grep ${1}  |sort -u)
  if [ -d ${base_dir}/${tool_name}/${1}/${2}/pkg ]; then
    rm -rf ${base_dir}/${tool_name}/${1}/${2}/pkg
  fi
  mkdir -p ${base_dir}/${tool_name}/${1}/${2}/pkg
  pushd ${base_dir}/${tool_name}/${1}/${2}/pkg
    for link in ${links}
    do 
      wget ${link}
    done
  popd

  pushd ${base_dir}
    if [ -f ${tool_name}_${1}_${2}.tar.gz ]; then
      rm -f ${tool_name}_${1}_${2}.tar.gz
    fi
    tar czf ${tool_name}_${1}_${2}.tar.gz -C tools/${1}/${2}/pkg/ .
  popd
}


os_list=("el7" "ky10" "hce2" "oe2203sp1")
arch_list=("x86_64" "aarch64")
for os in ${os_list[@]}; do
  for arch in ${arch_list[@]}; do
    echo "OS:$os, arch: $arch"
    download_tools $os  $arch
  done
done
