#! /bin/bash

localNewFile='./new.bundle'

mv localNewFile `date +"%s"`
ls ls -l | grep "^-" | wc -l