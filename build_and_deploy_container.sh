#!/bin/bash

# Builds a container and deploys it.
#
# This has a bunch of steps:
#   1 Create a Dockerfile,
#   2 tag it appropriately,
#   3 upload it to the Google Container Repository,
#   4 fill in the deployment templates in the deployment/ directory,
#   5 apply the deployment/ directory to the cluster.

set -e
set -x

source "${HOME}/google-cloud-sdk/path.bash.inc"

USAGE="$0 <image tag> <gcr.io url> <cloud project> <custer name> <cluster zone> [<KEY> <VALUE>]*"
IMAGE_TAG=${1:?Please provide a tag for the image: $USAGE}
GCR_REPO=${2:?Please provide a gcr.io url to upload to: $USAGE}
CLOUD_PROJECT=${3:?Please specify the cloud project deploy to: $USAGE}
CLUSTER_NAME=${4:?Please provide a cluster name to deploy to: $USAGE}
CLUSTER_ZONE=${5:?Please provide a cluster zone to deploy to: $USAGE}
shift 5

# All subsequent arguments must be name-value pairs, which means that there
# should be an even number of arguments.
[[ $[ $# % 2 ] == 0 ]] || exit 1

# Build the image and tag it
docker build . -t ${GCR_REPO}:${IMAGE_TAG}

# Upload the image
gcloud --project=${CLOUD_PROJECT} docker -- push ${GCR_REPO}:${IMAGE_TAG}

# Fill in the deployment template(s)
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

# Apply the deployment/ configs to the cluster in the region
gcloud --project=${CLOUD_PROJECT} container clusters get-credentials ${CLUSTER_NAME} --zone=${CLUSTER_ZONE}
kubectl apply -f deployment/
