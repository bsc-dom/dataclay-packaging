#!/bin/bash
#===================================================================================
#
# FILE: prepare_docker_builder.sh
#
# USAGE: prepare_docker_builder.sh
#
# DESCRIPTION: Prepare docker buildx to support required platforms
#
# OPTIONS: see function ’usage’ below
# REQUIREMENTS: ---
# BUGS: ---
# NOTES: ---
# AUTHOR: dgasull@bsc.es
# COMPANY: Barcelona Supercomputing Center (BSC)
# VERSION: 1.0
#===================================================================================
PREPAREDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $PREPAREDIR/PLATFORMS.txt

# prepare architectures
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

DOCKER_BUILDER=$(docker buildx create) 
docker buildx use $DOCKER_BUILDER

echo "Checking buildx with available platforms to simulate..."
BUILDER_PLATFORMS=$(docker buildx inspect --bootstrap | grep Platforms | awk -F":" '{print $2}')
IFS=',' read -ra BUILDER_PLATFORMS_ARRAY <<< "$BUILDER_PLATFORMS"
IFS=',' read -ra SUPPORTED_PLATFORMS_ARRAY <<< "$PLATFORMS"
echo "Builder created with platforms: ${BUILDER_PLATFORMS_ARRAY[@]}"	
	
#Print the split string
for i in "${SUPPORTED_PLATFORMS_ARRAY[@]}"
do
	FOUND=false
	SUP_PLATFORM=`echo $i | sed 's/ *$//g'` #remove spaces
	printf "Checking if platform $i can be simulated by buildx..."
	   for j in "${BUILDER_PLATFORMS_ARRAY[@]}"
	   do
	   	B_PLATFORM=`echo $j | sed 's/ *$//g'` #remove spaces
		if [ "$SUP_PLATFORM" == "$B_PLATFORM" ]; then
			FOUND=true
			break
		fi
	done
	if [ "$FOUND" = false ] ; then
		echo "ERROR: missing support for $i in buildx builder."
		echo " Check https://github.com/multiarch/qemu-user-static for more information on how to simulate architectures"
		return -1
	fi
	printf "OK\n"
		
done
	
### docker buildx 
DOCKERX_CACHE=$BUILDDIR/.dockerbuildx
EXTRA_ARGS=""
if [ -f $DOCKERX_CACHE/index.json ]; then 
	echo " -- Found index cache at $DOCKERX_CACHE"
	EXTRA_ARGS="--cache-from=type=local,src=$DOCKERX_CACHE" 
fi



