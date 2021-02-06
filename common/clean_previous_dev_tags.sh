#!/bin/bash -e

#=== FUNCTION ================================================================
# NAME: remove_tag
# DESCRIPTION: Remove tag from DockerHub
#=============================================================================
function remove_dev_tags {
  IMAGE=$1
  YEAR=$(date -u +"%Y")
  if [ -z $EXCEPTIONS_PATTERN ]; then
    TAGS_TO_DELETE=$(./get_all_tags.sh "${ORGANIZATION}/$IMAGE" | grep $YEAR)
  else
    TAGS_TO_DELETE=$(./get_all_tags.sh "${ORGANIZATION}/$IMAGE" | grep $YEAR | grep -v $EXCEPTIONS_PATTERN)
  fi
  for TAG in ${TAGS_TO_DELETE[@]}; do
    echo "****** Removing tag ${ORGANIZATION}/${IMAGE}/tags/${TAG}/ *******"
    TOKEN=`curl -s -H "Content-Type: application/json" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token`
    curl "https://hub.docker.com/v2/repositories/${ORGANIZATION}/${IMAGE}/tags/${TAG}/" \
    -X DELETE \
    -H "Authorization: JWT ${TOKEN}"
  done
}

if [ "$#" -lt 2 ]; then
    echo "ERROR: missing parameter. Usage $0 docker_username docker_password [exceptions_grep_pattern]"
    echo " where exceptions_grep_pattern: grep pattern of dev tags to exclude like 20210506"
    exit 1
fi
USERNAME="$1"
PASSWORD="$2"
if [ "$#" -gt 2 ]; then
  EXCEPTIONS_PATTERN=$3
fi
ORGANIZATION="bscdataclay"
TAG="tag"

login_data() {
cat <<EOF
{
  "username": "$USERNAME",
  "password": "$PASSWORD"
}
EOF
}

remove_dev_tags logicmodule
remove_dev_tags dsjava
remove_dev_tags dspython
remove_dev_tags client
remove_dev_tags initializer
