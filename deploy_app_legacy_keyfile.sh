#!/bin/bash
#
# Performs an AppEngine deployment using service account credentials.

set -x
set -e

PROJECT=${1:?Please provide the GCP project id}
KEYFILE=${2:?Please provide the service account key file}
BASEDIR=${3:?Please provide the base directory containing app.yaml}
APPYAML=${4:-app.yaml}
TRAVIS_COMMIT=${TRAVIS_COMMIT:-unknown}
TRAVIS_TAG=${TRAVIS_TAG:-empty_tag}

# Add gcloud to PATH.
source "${HOME}/google-cloud-sdk/path.bash.inc"

# All operations are performed as the service account named in KEYFILE.
# For all options see:
# https://cloud.google.com/sdk/gcloud/reference/auth/activate-service-account
gcloud auth activate-service-account --key-file "${KEYFILE}"

# For all options see:
# https://cloud.google.com/sdk/gcloud/reference/config/set
gcloud config set core/project "${PROJECT}"
gcloud config set core/disable_prompts true
gcloud config set core/verbosity info

# Make build artifacts available to docker build.
pushd "${BASEDIR}"
  # Substitute useful travis env variables into appengine env variables.
  # Each deployment may use only a subset of these, which is fine.
  yaml=`cat $APPYAML`
  echo "$yaml" | envsubst '$TRAVIS_TAG, $TRAVIS_COMMIT, $INJECTED_BUCKET, $INJECTED_PROJECT, $INJECTED_DATASET' > $APPYAML

  # Automatically promote the new version to "serving".
  # For all options see:
  # https://cloud.google.com/sdk/gcloud/reference/app/deploy
  gcloud ${BETA} app deploy --promote ${APPYAML}
popd

exit 0
