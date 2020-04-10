if [ -z $IMAGE_NAME ]; then echo "IMAGE_NAME not set. Aborting."; exit 1; fi
if [ -z $TAG ]; then echo "TAG not set. Aborting."; exit 1; fi
if [ -z $BUILDDIR ]; then echo "BUILDDIR not set. Aborting."; exit 1; fi
REPOSITORY=$BUILDDIR/../images
mkdir -p $REPOSITORY
SINGULARITY_TEMPLATE=$BUILDDIR/../misc/singularity-template.recipe
DOCKER_REPOSITORY="bscdataclay"
SINGULARITY_IMAGE_NAME=${IMAGE_NAME}.${TAG}.sif
DOCKER_IMAGE="${DOCKER_REPOSITORY}\/${IMAGE_NAME}:${TAG}"
printMsg "Creating image $REPOSITORY/${SINGULARITY_IMAGE_NAME} from $DOCKER_IMAGE"
tmpfile=$(mktemp /tmp/singularity-templateXXXXXX.recipe)
sed "s/DOCKER_IMAGE/$DOCKER_IMAGE/g" $SINGULARITY_TEMPLATE >> $tmpfile
singularity build --force --remote $REPOSITORY/${SINGULARITY_IMAGE_NAME} $tmpfile
rm $tmpfile
printMsg "$REPOSITORY/${SINGULARITY_IMAGE_NAME} created!" 