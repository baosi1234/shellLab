#! /bin/bash
# filename: create_xml.sh
# create_wangxb_20150123
#

outfile=$1
tabs=0

put(){
    echo '<'${*}'>' >> $outfile
}


put_tag() {
    echo '<'$1'>'${@:2}'</'$1'>' >> $outfile
}
put_tag_cdata() {
    echo '<'$1'><![CDATA['${@:2}']]></'$1'>' >> $outfile
}

put_head(){
    put '?'${1}'?'
}

out_tabs(){
    tmp=0
    tabsstr=""
    while [ $tmp -lt $((tabs)) ]
    do
        tabsstr=${tabsstr}'\t'
        tmp=$((tmp+1))
    done
    echo -e -n $tabsstr >> $outfile
}

tag_start(){
    out_tabs
    put $1
    tabs=$((tabs+1))
}

tag() {
    out_tabs
    if [ "$1" == 0 ]
    then
        put_tag $2 $(echo ${@:3})
    elif [ "$1" == 1 ]
    then
        put_tag_cdata $2 $(echo ${@:3})
    fi
}

tag_end(){
    tabs=$((tabs-1))
    out_tabs
    put '/'${1}
}





