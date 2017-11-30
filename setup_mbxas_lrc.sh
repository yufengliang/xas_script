#!/bin/bash

 system_in=$1
 account=$2
 pname=$3
 wtime_in=$4
 nproc_in=$5

 if [ $# -ne 5 ]; then
   echo "usage: $0 xyz_name account partition_name wall_time nproc"
   exit
 fi

 function header {
   cat > $1 << EOF
#!/bin/bash
#SBATCH --account=$account
#SBATCH --partition=$pname
#SBATCH -t $wtime
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

  wtime=$wtime_in
  job=xas
  system=$system_in
  nproc=$nproc_in

  header $job.sh

 # ref

  wtime=$wtime_in
  job=ref
  system=$system_in
  nproc=$nproc_in

  header $job.sh

 # ana

  wtime=00:30:00
  job=ana
  system=$system_in
  nproc=24

  header $job.sh

 # state

  wtime=01:00:00
  job=state
  system=$system_in
  nproc=24

  header $job.sh

 # mbxas

  wtime=$wtime_in
  job=mbxas
  system=$system_in
  nproc=$nproc_in

  header $job.sh
