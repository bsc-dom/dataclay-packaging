#! /bin/bash
## Script to build a singularity image for each bscdataclay docker image (latest)
## Run with sudo privileges

if [ $(id -u) != "0" ]; then
	echo "[ERROR] Running $0 requires root privileges"
	exit
fi

function extract_env {
	# Function to extract env variables from Dockerfiles (needed for Singularity)
	# Syntax for specifying environment variables needed at runtime:
	#   #beginENVruntime
	#   .... dockerfile commands ...
	#   ENV var0=aaa
	#   .... dockerfile commands ...
	#   ENV var1=bbb
	#   .... dockerfile commands ...
	#   #endENVruntime

	if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
		echo 'Usage: ./$0 <Dockerfile_path>'
	else
		sed -n '/#beginENVruntime/,/#endENVruntime/p' $@ | grep ^ENV | sed 's/^ENV /\texport /g'
	fi
}


SINGULARITY_FOLDER=singularity_build

rm -rf $SINGULARITY_FOLDER
mkdir -p $SINGULARITY_FOLDER
ENV_FROM=""

for IMAGE in base logicmodule dsjava dspython client
do
	RECIPE="$SINGULARITY_FOLDER/$IMAGE.recipe"
	echo -e "Bootstrap: docker\nFrom: bscdataclay/$IMAGE:latest\n\n%environment" > $RECIPE
	ENV_FROM="$ENV_FROM $IMAGE"
	for DOCKERFILE_PATH in $ENV_FROM
	do
		extract_env $DOCKERFILE_PATH/Dockerfile >> $RECIPE
	done
	singularity build "$SINGULARITY_FOLTER/$IMAGE.img" $RECIPE
done
