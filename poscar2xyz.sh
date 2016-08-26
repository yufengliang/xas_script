#!/bin/bash

  [ $# -ne 4 ] && echo usage: $0 n1 n2 n3 poscar
  [ $# -ne 4 ] && exit

  # input: coord.dat (in crystal coordinate) output: supercell
  fil=$4
  nx=$1; ny=$2; nz=$3
  n=($1 $2 $3)
  
  function len() {
    echo $@|awk '{printf "%6.4f", sqrt($1^2+$2^2+$3^2)*$4*$5}'
  }

  function angle() {
    local len1=$(len $1 $2 $3 1.0 1.0)
    local len2=$(len $4 $5 $6 1.0 1.0)
    echo $@|awk -v len1=$len1 -v len2=$len2 '{printf "%14.12f", ($1*$4+$2*$5+$3*$6)/len1/len2}'
  }

  # Lattice Constant

  descr=$(sed -n '1p' $fil)
  fac=$(sed -n '2p' $fil)
  A=$(len $( sed -n '3p' $fil ) $fac $1)
  B=$(len $( sed -n '4p' $fil ) $fac $2)
  C=$(len $( sed -n '5p' $fil ) $fac $3)
  echo A=$A
  echo B=$B
  echo C=$C
  echo COSBC=$(angle $( sed -n '4p' $fil ) $( sed -n '5p' $fil ))
  echo COSAC=$(angle $( sed -n '5p' $fil ) $( sed -n '3p' $fil ))
  echo COSAB=$(angle $( sed -n '3p' $fil ) $( sed -n '4p' $fil ))
 
  # echo $natline
  natline=6
  str=`sed -n '6p' $fil`
  if [[ "$str" == *[A-Za-z]* ]]; then
    #sed -n '6p' $fil
    natline=7
  fi

  nat=$(sed -n "$natline p" $fil|awk '{sum = 0; for (i=1;i<=NF;i++) sum+=$i; print sum}') 
  # line 1: number of atoms
  echo "$nat*$nx*$ny*$nz"|bc
  # line 2: description of the structure
  echo $descr $nx x $ny x $nz supercell
  elem=$(sed -n "$((natline+1)) p" $fil)
 
  awk -v nx=$nx -v ny=$ny -v nz=$nz -v natline=$natline -v nat=$nat '
  NR==natline-1 {split($0, elem, " ")}
  NR==natline {split($0, enum, " "); typ=1; iatom=0;}
  NR>=natline+2 && NR<=natline+nat+1 {
    if (iatom == enum[typ] ) {typ+=1; iatom=0}
    for (ix = 0; ix < nx; ix++)
      for (iy = 0; iy < ny; iy++)
        for (iz = 0; iz < nz; iz++)
          printf("%s %16.13f  %16.13f  %16.13f\n",elem[typ],($1+ix)/nx,($2+iy)/ny,($3+iz)/nz)
    iatom+=1
  }' \
  $fil


