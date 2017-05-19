#!/bin/bash

set -e
set -x

IMAGE_TAG=${1:?Please provide a tag for the image}
GCR_REPO=${2:?Please provide a gcr.io url to upload to}
CLOUD_PROJECT=${3:?Please specify the cloud project deploy to}
CLUSTER_NAME=${4:?Please provide a cluster name to deploy to}
CLUSTER_ZONE=${5:?Please provide a cluster zone to deploy to}
shift 5

# All subsequent arguments must be name-value pairs, which means that there
# should be an even number of arguments.
[[ $[ $# % 2 ] == 0 ]] || exit 1

# Make a substitution in every file in the deployment/ directory
function deployment_substitution() {
  KEY=$1
  VALUE=$2

  for f in deployment/*
  do
    sed --expression="s#${KEY}#${VALUE}#" --in-place $f
  done
}

deployment_substitution '{{IMAGE_URL}}' "${GCR_REPO}:${IMAGE_TAG}"
while [[ $# -ge 2 ]]
do
  NAME=$1
  VALUE=$2
  shift 2
  deployment_substitution "{{${NAME}}}" "${VALUE}"
done

docker build . -t ${GCR_REPO}:${IMAGE_TAG}
gcloud --project=${CLOUD_PROJECT} docker -- push ${GCR_REPO}:${IMAGE_TAG}
gcloud --project=${CLOUD_PROJECT} container clusters get-credentials ${CLUSTER_NAME} --zone=${CLUSTER_ZONE}
kubectl apply -f deployment/
