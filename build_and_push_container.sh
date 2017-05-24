#!/bin/bash

# Builds a container, tags it, and pushes it to GCR

set -e
set -x

source "${HOME}/google-cloud-sdk/path.bash.inc"

USAGE="$0 <image url> <cloud project>"
IMAGE_URL=${1:?Please provide a full docker image url: $USAGE}
CLOUD_PROJECT=${2:?Please specify the cloud project deploy to: $USAGE}

# Build the image and tag it
docker build . -t ${IMAGE_URL}

# Upload the image
gcloud --project=${CLOUD_PROJECT} docker -- push ${IMAGE_URL}
