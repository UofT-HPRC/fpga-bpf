#/bin/bash
# I got so tired of doing this manually....

# Call this file as
# mkInstance.sh somefile.v start# end#
# Where start# is the line that says "module" and end# is the last
# line of your module definition

# It will print some very useful code you can copy paste into another
# Verilog file that instantiates somefile.v

# Optionally call
# mkInstance.sh somefile.v start# end# o
# to only have it make output wire declarations (this is a little
# specific to the way I like to do things, so don't feel obligated!)


inFile=$1
firstLine=$2
lastLine=$3
penultimateLine=$(expr $3 - 1)

if [ ! -z $4 ] && [ $4 = "o" ]; then

	sed -r -n -e "$lastLine s/(.)$/\1\;/" -e "$firstLine,$lastLine s/\,/\;/" -e "$firstLine,$lastLine s/output //p"  $inFile

else 

	sed -r -n -e "$lastLine s/(.)$/\1\;/" -e "$firstLine,$lastLine s/\,/\;/" -e "$firstLine,$lastLine s/input wire/reg/p" -e "$firstLine,$lastLine s/output //p"  $inFile

fi


echo ""
sed -r -n -e "$firstLine s/module (\w*)/\1 DUT /p" $inFile
sed -r -n -e "$firstLine,$lastLine s/.*(\<(\w*)),/    \.\1\(\1\)\,/p" $inFile
sed -r -n -e "$penultimateLine s/.*(\<(\w*))$/    \.\1\(\1\)/p" $inFile
sed -r -n -e "$lastLine p" $inFile
