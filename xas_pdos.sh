#!/bin/bash

gen_nscf() {
	cat > nscf.sh << EOF
#!/bin/bash
#SBATCH -p debug
#SBATCH -t 00:30:00
#SBATCH -e nscf.stderr
#SBATCH -o nscf.stdout
#SBATCH -J ${f}.nscf
#SBATCH -n 320
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=pcbee912@gmail.com

cd \$SLURM_SUBMIT_DIR
#PW=/global/u2/y/yfliang/espresso-5.2.0/bin/pw.x
PW=/global/u2/y/yfliang/shirley_QE4.3.git/bin/pw.x
#PW=pw.x
srun -n 320 \$PW -npools 20 < $nscfin > $nscfout
EOF
}

gen_dos() {
	cat > dos.sh << EOF
#!/bin/bash
#SBATCH -p debug
#SBATCH -t 00:30:00
#SBATCH -e dos.stderr
#SBATCH -o dos.stdout
#SBATCH -J ${f}.dos
#SBATCH -n 32
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=pcbee912@gmail.com

cd \$SLURM_SUBMIT_DIR
DOS=/global/u2/y/yfliang/shirley_QE4.3.git/bin/dos.x
PROJWFC=/global/u2/y/yfliang/shirley_QE4.3.git/bin/projwfc.x
#PW=pw.x
srun -n 32 \$DOS  < dos.in > dos.out
srun -n 32 \$PROJWFC  < pdos.in > pdos.out
EOF

	# dname obtained as below
	prefix=$(echo $dname | sed 's/\.save//')
	cat > dos.in << EOF
&inputpp
    outdir='./'
    prefix='$prefix'
    fildos='$prefix.dos'
    DeltaE=0.01
    Emin=-20, Emax=40
    degauss=0.01
 /
EOF

	cat > pdos.in << EOF
 &inputpp
    outdir='./'
    prefix='$prefix'
    DeltaE=0.01
    Emin=-20, Emax=40
    degauss=0.01
 /
EOF

}

folder=$@

for f in $folder; do
	echo working on $f
	mkdir -p ${f}_dos
	cd ${f}_dos
	dsave=$(find ../${f} -name '*CH.save' -type d)
	if [ -z $dsave ]; then
	# Probably this is the GS folder
		dsave=$(find ../${f} -name '*.save' -type d)
		if [ -z $dsave ]; then
			echo Not a valid folder. Skip
			continue
		fi
		echo Found ground state folder $dsave.
		cp ../${f}/*.occup ./
		cp ../${f}/*.scf.in ./
		oldname=$(echo *.scf.in)
		newname=$(echo $oldname|sed 's/scf/nscf/')
		mv $oldname $newname
		sed -i 's/scf/bands/' *.nscf.in
		sed -i 's/outdir.*$/outdir=".\/"/' *.nscf.in
		sed -i '/K_POINTS automatic/ {n; d;}' *.nscf.in
		sed -i '/K_POINTS automatic/a 5 5 5 0 0 0' *.nscf.in
	else
		echo Found CH folder $dsave.
		cp ../${f}/*CH.occup ./
		cp ../${f}/*.nscf.in ./
		sed -i 's/nscf/bands/' *.nscf.in
		sed -i 's/outdir.*$/outdir=".\/"/' *.nscf.in
		sed -i 's/1 1 1/5 5 5/' *.nscf.in
	fi
	sed -i '/prefix/a     verbosity="high"' *.nscf.in
	dname=$(basename $dsave)
	mkdir -p $dname
	cp $dsave/charge-density.dat $dname/
	cp $dsave/spin-polarization.dat $dname/
	cp $dsave/data-file.xml $dname/
	nscfin=$(echo *.nscf.in | awk '{print $1}')
	nscfout=$(echo $nscfin | sed 's/in/out/')
	gen_nscf
	gen_dos
	cd ../
done
