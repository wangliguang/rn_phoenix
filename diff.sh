#! /bin/bash


newFile='/app/s_phoenix/public/bundle/new.bundle'
oldFile='/app/s_phoenix/public/bundle/old.bundle'
patchFile='/app/s_phoenix/public/bundle/diff.patch'
bundleFile='./index.bundle'
if [ -e $newFile ]; then
    scp $newFile $oldFile && rm $newFile
    scp $bundleFile $newFile
    diff $newFile $oldFile > $patchFile
else
    scp $bundleFile $newFile
    diff $newFile $newFile > $patchFile
fi
