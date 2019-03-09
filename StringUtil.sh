#!/bin/bash

randstr() {
  index=0
  str=""
  for i in {a..z}; do arr[index]=$i; index=`expr ${index} + 1`; done
  for i in {A..Z}; do arr[index]=$i; index=`expr ${index} + 1`; done
  # for i in {0..9}; do arr[index]=$i; index=`expr ${index} + 1`; done
  for i in {1..6}; do str="$str${arr[$RANDOM%$index]}"; done
  echo $str
}
# 返回以：分割的右部分  234:234 =》 234
splitMy() {
  local str=$1;
  local arr=(${str/:/ });
  echo "${arr[1]}";
}

getArr(){
  local _path=$1;
  for i in `grep -o 'options' -r ${_path}`;do
    echo "get one:"$i
    local _temp2=`splitMy $i`
    echo "handle"$_temp2
  done
}
