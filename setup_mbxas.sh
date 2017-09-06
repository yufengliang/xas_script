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
#SBATCH -p $queue
#SBATCH -t $wtime
# SBATCH -p debug
# SBATCH -t 00:30:00
#SBATCH -e $job.err
#SBATCH -o $job.out
#SBATCH -J ${system}.$job
#SBATCH -n $nproc
# SBATCH --mail-type=FAIL
# SBATCH --mail-user=pcbee912@gmail.com

 . \$SLURM_SUBMIT_DIR/Input_Block.in
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

  queue=regular
  wtime=01:00:00
  job=state
  system=$system_in
  nproc=24

  header $job.sh

 # mbxas

  queue=regular
  wtime=$wtime_in
  job=mbxas
  system=$system_in
  nproc=$nproc_in

  header $job.sh
