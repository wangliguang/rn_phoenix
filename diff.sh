#! /bin/bash

localNewFile='./index.bundle'
# 已时间戳为文件名
newName=`date +"%s".bundle`;
scp $localNewFile root@47.94.81.19:/app/s_phoenix/public/bundle/$newName
count=`ssh root@47.94.81.19 "cd /app/s_phoenix/public/bundle && ls -l | grep "^-" | wc -l"`
if [  $count -gt 8 ]; then
    oldFile=`ssh root@47.94.81.19 "cd /app/s_phoenix/public/bundle && ls -t * | tail -1"`
    echo $oldFile
    ssh root@47.94.81.19 "rm /app/s_phoenix/public/bundle/${oldFile}" 
fi