#! /bin/bash


localNewFile='./index.bundle'

cd ./bundle
touch $localNewFile
mv $localNewFile `date +"%s".bundle`
count=`ls -l | grep "^-" | wc -l`
echo $count
if [  $count -gt 8 ]; then
    oldFile=`ls -t * | tail -1`
    rm $oldFile
fi