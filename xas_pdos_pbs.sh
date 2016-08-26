#!/bin/bash

gen_nscf() {
	cat > nscf.sh << EOF
#!/bin/bash
#PBS -q debug
#PBS -l walltime=00:30:00
#PBS -V
#PBS -e stderr
#PBS -o stdout
#PBS -N ${f}_dos
#PBS -l mppwidth=480

cd \$PBS_O_WORKDIR
#PW=/global/u2/y/yfliang/espresso-5.2.0/bin/pw.x
PW=/global/u2/y/yfliang/shirley_QE4.3.git/bin/pw.x
#PW=pw.x
aprun -n 480 \$PW -npools 20 < $nscfin > $nscfout
EOF
}

gen_dos() {
	cat > dos.sh << EOF
#!/bin/bash
#PBS -q debug
#PBS -l walltime=00:30:00
#PBS -V
#PBS -e stderr
#PBS -o stdout
#PBS -N dos
#PBS -l mppwidth=48

cd \$PBS_O_WORKDIR
DOS=/global/u2/y/yfliang/shirley_QE4.3.git/bin/dos.x
PROJWFC=/global/u2/y/yfliang/shirley_QE4.3.git/bin/projwfc.x
#PW=pw.x
aprun -n 48 \$DOS  < dos.in > dos.out
aprun -n 48 \$PROJWFC  < pdos.in > pdos.out
EOF

	# dname obtained as below
	prefix=$(echo $dname | sed 's/\.save//')
	cat > dos.in << EOF
&inputpp
    outdir='./'
    prefix='$prefix'
    fildos='$prefix.dos'
    DeltaE=0.01
    Emin=0, Emax=20
    degauss=0.01
 /
EOF

	cat > pdos.in << EOF
 &inputpp
    outdir='./'
    prefix='$prefix'
    DeltaE=0.01
    Emin=0, Emax=20
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
