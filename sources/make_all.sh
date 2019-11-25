#!/bin/bash

#Pro tip: run as
# source make_all.sh 2>&1 >/dev/null | grep -v "No targets specified"

for i in $(find -type d); do
    make -C "$i/" $1
    echo ""
    echo ""
    echo ""
done 
