#!/bin/bash

user=""
status=""
file=""
speed=""
clientHost=""
clientIP=""
serverIP=""
serverPort=""
protocol=""
location=""
res=$(/usr/local/proftpd/bin/ftpwho -v|sed 's/^$/#####/g')
#echo "$res"
if [ $? -eq 0 ];then
    lastline=$(echo "$res" | tail -n1)
    if [ "$lastline" == "no users connected" ];then
        echo "no user"
        exit
    fi
    #lineTotal=$(echo "$res"|wc -l)
    userNum=$(echo "$lastline"|awk '{print $4}')
    #echo $userNum
    #修改系统默认的分隔符
    oldifs="$IFS"
    IFS=$'\n'
    for line in $res
    do
        #echo "$line"
        if [[ "$line" =~ "standalone" ]];then
            continue
        fi
        if [[ "$line" =~ ^[1-9] ]];then
            user=$(echo "$line"|awk '{print $2}')
            if [[ "$line" =~ "idle" ]];then
                status="idle"
                file="Null"
            elif [[ "$line" =~ "authenticating" ]];then
                user=$(echo "$line"|awk -F'[()]' '{print $2}')
                status="authenticating"
                file="Null"   
            else
                status=$(echo "$line"|awk -F'[()]' '{print $NF}'|awk '{print $1}')
                file=$(echo "$line"|awk '{print $NF}')
            fi
        fi
        if [[ "$line" =~ "KB/s" ]];then
             speed=$(echo "$line"|awk '{print $2}')
        fi
        if [[ "$line" =~ "client" ]];then
            clientHost=$(echo "$line"|awk '{print $2}')
            #指定[]做为分隔符
            clientIP=$(echo "$line"|awk -F'[][]' '{print $2}')
        fi
        if [[ "$line" =~ "server" ]];then
            serverIP=$(echo "$line"|awk '{print $2}'|cut -d: -f1)
            serverPort=$(echo "$line"|awk '{print $2}'|cut -d: -f2)
        fi
        if [[ "$line" =~ "protocol" ]];then
            protocol=$(echo "$line"|awk '{print $2}')
        fi
        if [[ "$line" =~ "location" ]];then
            location=$(echo $line|awk '{print $2}')
        fi
        if [[ "$line" =~ "#####" ]];then
            echo $user,$status,$file,$speed,$clientHost,$clientIP,$serverIP,$serverPort,$protocol,$location
            user=""
            status=""
            file=""
            speed=""
            clientHost=""
            clientIP=""
            serverIP=""
            serverPort=""
            protocol=""
            location=""
        fi
    done 
    IFS="$oldifs"
else
    echo "Error:$res"
fi
