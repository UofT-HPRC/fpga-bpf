#!/bin/bash

# A quick and dirty search to help me find the start and end
# of module definitions in a file. Eventually I'll find some
# clever programmatic way to do this, but for now this will
# be fine

inFile=$1

grep -n -e "\<module" $1
grep -n -B 2 ");" $1
