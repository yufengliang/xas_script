#!/bin/bash

if [ $# -ge 2 ]; then
	echo "usage: $0 (look for XAS/Spectrum-*/Spectrum-Ave-*)"
	echo "usage: $0 Spectrum_file"
	exit
elif [ $# -eq 1 ]; then
	files=$1
else
	files="XAS/Spectrum-*/Spectrum-Ave-*"
fi

# looking for local minima in each file
# simply using second-order difference, not very robust
for f in $files; do
	echo $f:
	awk '
	{ 
		if ( NR > 2 ) {
			if ( lm1 < lm2 && lm2 > $2 ) {
				print lm1, lm2, $2
				printf "%8.3f  %12.5f\n", le2, lm2
			}
		}
		if ( NR >= 2 ) {
			le1 = le2; lm1 = lm2
		}
		le2 = $1; lm2 = $2;
        }
	' $f
done
