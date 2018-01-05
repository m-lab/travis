#!/bin/bash
#
# Performs an AppEngine deployment using service account credentials.

set -x
set -e

PROJECT=${1:?Please provide the GCP project id}
KEYFILE=${2:?Please provide the service account key file}
BASEDIR=${3:?Please provide the base directory containing app.yaml}
APPYAML=${4:-app.yaml}

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
gcloud config set core/verbosity debug

# Make build artifacts available to docker build.
pushd "${BASEDIR}"
  # Substitute useful travis env variables into appengine env variables.
  yaml_text=`cat $APPYAML`
  echo $yaml_text | sed "s/__COMMIT_HASH__/$TRAVIS_COMMIT/" | sed "s/__RELEASE_TAG__/$TRAVIS_TAG/" > $APPYAML

  # Automatically promote the new version to "serving".
  # For all options see:
  # https://cloud.google.com/sdk/gcloud/reference/app/deploy
  gcloud ${BETA} app deploy --promote ${APPYAML}
popd

exit 0
