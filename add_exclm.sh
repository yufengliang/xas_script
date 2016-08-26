#!/bin/bash

for f in XAS/*/*/*.scf.out; do
	echo dealing with $f
	ener=$(grep "   total energy   " $f | tail -1)
	echo $ener
	echo ! $ener >> $f
done
