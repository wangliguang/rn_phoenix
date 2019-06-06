#! /bin/bash


remoteNewFile='root@47.94.81.19:/app/s_phoenix/public/bundle/new.bundle'
remoteOldFile='root@47.94.81.19:/app/s_phoenix/public/bundle/old.bundle'
remoteDiffFile='root@47.94.81.19:/app/s_phoenix/public/bundle/diff.patch'

localNewFile='./new.bundle'
localOldFile='./old.bundle'
localDiffFile='./diff.patch'

HTTP_CODE=`curl -o /dev/null -s --head -w "%{http_code}" "http://47.94.81.19:3000/bundle/new.bundle"`

if [ ${HTTP_CODE} -ne 200 ]
then
  # 原来不存在bundle
  scp $localNewFile $remoteNewFile
  diff $localNewFile $localNewFile > $remoteDiffFile
else
  # 原来存在bundle
  scp $remoteNewFile $localOldFile
  scp $localOldFile $remoteOldFile
  scp $localNewFile $remoteNewFile

  diff $localNewFile $localOldFile > $remoteDiffFile
fi
