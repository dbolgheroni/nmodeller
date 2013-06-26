#!/bin/sh

echo "modbench, benchmark script for openmodeller/nmodeller"

ninstance=10   

# apresentation
echo "\033[44mblue\033[m bar represents instances of openModeller"
echo "\033[41mred\033[m  bar represents instances of nmodeller"
echo

### openmodeller #######################################################
echo "------------------------------------------------------------------------"
c=1
while [ $c -le $ninstance ]; do
    echo -n "\033[44m "
    /usr/bin/time -p om_console om/job.txt 2>> omtime > /dev/null
    c=$((c+1))
done
echo "\033[m"

# process openModeller times
mv furcata.xml om
cat omtime | grep user | sed -e 's/^user[[:space:]]*//' > _omtime

omtotalt=0
while read t; do
    omtotalt=$(echo "scale=2; $omtotalt + $t" | bc)
done < _omtime

ommeant=$(echo "scale=2; $omtotalt / $ninstance" | bc)

### nmodeller ##########################################################
c=1
while [ $c -le $ninstance ]; do
    echo -n "\033[41m "
    /usr/bin/time -p ./nmodeller 2>> nmtime > /dev/null
    c=$((c+1))
done
echo "\033[m" # remove color
echo "------------------------------------------------------------------------"

# process nmodeller times
cat nmtime | grep user | sed -e 's/^user[[:space:]]*//' > _nmtime

nmtotalt=0
while read t; do
    nmtotalt=$(echo "scale=2; $nmtotalt + $t" | bc)
done < _nmtime

nmmean=$(echo "scale=2; $nmtotalt / $ninstance" | bc)

### RESULTS ############################################################
impper=$(echo "scale=2; (($omtotalt - $nmtotalt) / $nmtotalt) * 100" | bc)
impx=$(echo "scale=2; $omtotalt / $nmtotalt" | bc)
echo "mean: \033[34m$ommeant \033[31m$nmmean\033[m"
echo
banner "${impper}%"
echo "improvement or"
echo
banner "${impx}x"
echo "faster"

# remove temporary files
rm omtime nmtime _omtime _nmtime
