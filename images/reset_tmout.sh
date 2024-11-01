#!/bin/bash

sed -i '/export TMOUT=/d' /etc/bashrc
source /etc/profile
source /etc/bashrc