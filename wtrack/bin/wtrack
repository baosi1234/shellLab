#!/bin/sh

# wtrack 用法提示方法
function help()
{
  printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n"
  printf "NAME \n\twtrack -- Recursive search characters in files in the specified directory\n"
  printf "SYNOPSIS \n\t bash wtrack.sh [OPTIONS] search [file-suffix] [dir]\n"
  printf "OPTIONS \n\t -git check 'echo','print_r','var_dump','die','exit'\n"
  printf "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n"
}


function track()
{
    suffix='php'
    dir='./'
    case $# in
        0)
        echo 'ERROR! Please enter track string'
        exit 1
        ;;
        1)
        search=$1
        ;;
        2)
        search=$1
        suffix=$2
        ;;
        3)
        search=$1
        suffix=$2
        dir=$3
        ;;
        *)
        search=$1
        suffix=$2
        dir=$3
    esac
    find $dir -type f -name "*.$suffix" |xargs grep --color=auto -n "$search"
}


if [ $# -lt 1 ];then
    help
fi

case $1 in
    -h)
        help
        ;;
    --help)
        help
        ;;
    -g)
        for val in 'die' 'echo' 'exit' 'dump' 'print_r' 'var_dump'
        do
            track $val 
        done
        ;;
    --git)
        for val in 'die' 'echo' 'exit' 'dump' 'print_r' 'var_dump'
        do
            track $val 
        done
        ;;
    *)
        track $1 $2 $3
        ;;
esac

