#!/bin/bash

line=$(iris qlist $ISC_PACKAGE_INSTANCENAME 2>&1) 
state=$(echo $line | cut -d '^' -f4 | cut -d ',' -f1)

if [ $state == "down" ]; then
    iris start $ISC_PACKAGE_INSTANCENAME

    waitISC.sh "$ISC_PACKAGE_INSTANCENAME" 60 "running"
fi

