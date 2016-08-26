#!/bin/bash
 
 echo "============ xas ==============="
 ls -ltrc ./XAS/*/*/*CH*.out | grep -v atom

 for nscfout in ./XAS/*/*/*nscf.out
 do
   echo in the non-self-consistent field output $nscfout
   Efermi=`grep 'Fermi energy' $nscfout|awk '{print $5}'`
   Emax=`grep -B 2 'Fermi energy' $nscfout|head -1|awk '{print $NF}'`
   echo Emax = $Emax, Efermi = $Efermi
 done

 echo "============ ref ==============="
 grep -n 'achieved' ./XAS/atom/*/*.out
 grep -n 'achieved' ./XAS/*/GS/*.out

