if [ -z $IMAGE_NAME ]; then echo "IMAGE_NAME not set. Aborting."; exit 1; fi
if [ -z $TAG ]; then echo "TAG not set. Aborting."; exit 1; fi
if [ -z $BUILDDIR ]; then echo "BUILDDIR not set. Aborting."; exit 1; fi

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

REPOSITORY=$BUILDDIR/../../orchestration/singularity/images
DOCKER_REPOSITORY="bscdataclay"
LOCAL_REGISTRY="localhost:5000"
FROM_DOCKER="${LOCAL_REGISTRY}/${IMAGE_NAME}"
mkdir -p $REPOSITORY

# Start a docker registry
if docker ps -a | grep -q dataclay-registry; then 
	docker start dataclay-registry
else 
	docker run -d -p 5000:5000 --restart=always --name dataclay-registry registry:2
fi

# Use local registry to use local docker images 
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "WARNING: Using singularity build script will use local Docker images. Please, make sure to build them"
echo "WARNING: Local registry called dataclay-registry will be created and Docker images will be pushed there to be used by singularity"
echo "WARNING: Make sure to have {"insecure-registries" : ["localhost:5000","127.0.0.1:5000"]} in your ~/.docker/config.json and restart docker service"
echo "WARNING: Images will be created in dataclay-packaging/orchestration/singularity/images folder for better usability"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
SINGULARITY_TEMPLATE=$BUILDDIR/../misc/singularity-template.recipe
SINGULARITY_IMAGE_NAME=${IMAGE_NAME}.${TAG}.sif
SINGULARITY_LOCAL_REGISTRY="${LOCAL_REGISTRY}\/${IMAGE_NAME}:latest"
printMsg "Creating image $REPOSITORY/${SINGULARITY_IMAGE_NAME} from $SINGULARITY_LOCAL_REGISTRY"
tmpfile=$(mktemp /tmp/singularity-templateXXXXXX.recipe)
docker tag $DOCKER_REPOSITORY/${IMAGE_NAME}:${TAG} ${FROM_DOCKER}:latest
docker push ${FROM_DOCKER}:latest
sed "s/DOCKER_IMAGE/${SINGULARITY_LOCAL_REGISTRY}/g" $SINGULARITY_TEMPLATE >> $tmpfile
export SINGULARITY_NOHTTPS=1
singularity build --force --fakeroot $REPOSITORY/${SINGULARITY_IMAGE_NAME} $tmpfile
rm $tmpfile
printMsg "$REPOSITORY/${SINGULARITY_IMAGE_NAME} created!" 

# Stop registry
docker stop dataclay-registry
sleep 2