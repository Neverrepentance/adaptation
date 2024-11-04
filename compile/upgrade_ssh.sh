#!/bin/bash

date_str=$(date +%Y%m%d)

## 备份
function backup(){
    mkdir -p /data/dsa/backup/ssh_${date_str}
    pushd /data/dsa/backup/ssh_${date_str}
        mkdir etc_ssh
        cp -f /etc/ssh/* ./etc_ssh/
        tar czf etc_ssh.tar.gz ./etc_ssh/
        cp /etc/pam.d/sshd ./
        cp /etc/pam.d/system-auth ./

        cp /usr/bin/ssh ./ssh
        cp /usr/sbin/sshd ./sshd_exe
    popd 
}

## 升级
function upgrade(){
    \cp -rfp ./lib64/* /usr/lib64/
    \cp -rfp ./bin /usr/
    \cp -rfp ./sbin /usr/
    \cp -rfp ./libexec /usr/
    \cp -rfp ./share /usr/


    if [ ! -f /usr/lib64/libcrypto.so.10 ]; then
        ln -s /usr/lib64/libcrypto.so.1.0.0 /usr/lib64/libcrypto.so.10
    fi

    if [ ! -f /usr/lib64/libssl.so.10 ]; then
        ln -s /usr/lib64/libssl.1.0.0 /usr/lib64/libssl.so.10
    fi

    restartssh
}

function roolback(){
    if [ ! -d /data/dsa/backup/ssh_${date_str} ]; then
        echo "back dir /data/dsa/backup/ssh_${date_str} not exist"
        exit 1
    fi
    pushd /data/dsa/backup/ssh_${date_str}
        \cp -f ssh /usr/bin/
        \cp -f sshd_exe /usr/sbin/sshd
        \cp -f sshd /etc/pam.d/
        \cp -f system-auth /etc/pam.d

        tar zxf etc_ssh.tar.gz
        \cp -f ./etc_ssh/* /etc/ssh/
        rm -rf ./etc_ssh
    popd 

    restartssh
}

## 重启
function restartssh(){
    systemctl daemon-reload
    systemctl restart sshd
}

if [ $? == 0 ]; then
  command=upgrade
else
    command=$1
fi


case "$command" in
  backup)
    backup
    exit 0
  ;;
  upgrade)
    backup
    upgrade
    exit 0
  ;;
  roolback)
    roolback
    exit 0
  ;;
  *)
    echo "Usage: ./$0 backup|upgrade|roolback"
  ;;
esac