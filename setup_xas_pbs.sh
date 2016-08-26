#!/bin/bash

 system_in=$1
 wtime_in=$2
 nproc_in=$3

 if [ $# -ne 3 ]; then
   echo "usage: $0 system wall_time nproc"
   exit
 fi

 function header {
   cat > $1 << EOF
#!/bin/bash
#PBS -q $queue
#PBS -l walltime=$wtime
#PBS -V
#PBS -e $job.err
#PBS -o $job.out
#PBS -N ${system}.$job
#PBS -l mppwidth=$nproc
#PBS -m abe
#PBS -M pcbee912@gmail.com

 . \$PBS_O_WORKDIR/Input_Block.in
 \$SHIRLEY_ROOT/scripts/arvid/XAS_${job}.sh

EOF
}

 # xas

  queue=regular
  wtime=$wtime_in
  job=xas
  system=$system_in
  nproc=$nproc_in

  header $job.sh

 # ref

  queue=regular
  wtime=$wtime_in
  job=ref
  system=$system_in
  nproc=$nproc_in

  header $job.sh

 # ana

  queue=debug
  wtime=00:30:00
  job=ana
  system=$system_in
  nproc=24

  header $job.sh

 # state

  queue=debug
  wtime=00:30:00
  job=state
  system=$system_in
  nproc=24

  header $job.sh
