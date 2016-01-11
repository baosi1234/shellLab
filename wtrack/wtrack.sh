#!/bin/sh

# wtrack 用法提示方法
function alert()
{
  printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n"
  printf "NAME \n\twtrack -- Recursive search characters in files in the specified directory\n"
  printf "SYNOPSIS \n\t bash wtrack.sh [OPTIONS] search [file-suffix] [dir]\n"
  printf "OPTIONS \n\t -git check 'echo','print_r','var_dump','die','exit'\n"
  printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n"
}


function track()
{
  echo 'track'
}



if [ $# -lt 1 ];then
  alert
fi

case $1 in
  -g)
    echo '1'
    ;;
  -s)
    echo '2'
    ;;
  *)
    track
    ;;
esac
