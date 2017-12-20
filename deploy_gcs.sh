#!/bin/bash
#
# deploy_gcs supports deploying build artifacts to GCS buckets using base64
# encoded service account keys, such as those stored in travis-ci environments.
#
# Examples:
#   # Copies all files matching pattern to the named folder, preserving names.
#   deploy_gcs.sh "$SERVICE_ACCOUNT_mlab_sandbox" \
#       build/*.rpm \
#       gs://example-mlab-sandbox/files/
#
#   # Copies specific file to a folder, preserving the name.
#   deploy_gcs.sh "$SERVICE_ACCOUNT_mlab_sandbox" \
#       build/foobar.rpm \
#       gs://example-mlab-sandbox/files/
#
#   # Copies specific file and renames it in GCS.
#   deploy_gcs.sh "$SERVICE_ACCOUNT_mlab_sandbox" \
#       build/foobar.rpm \
#       gs://example-mlab-sandbox/files/foobar-newname.rpm
set -e
set -u

USAGE="Usage: $0 <key> <src> <dest>"
KEY=${1:?Please provide the base64 encoded service account key: $USAGE}
SRC=${2:?Please provide a source file, dir, or pattern: $USAGE}
DEST=${3:?Please provide a destination bucket with optional path: $USAGE}

# Import support functions from the bash gcloud library.
source "${HOME}/google-cloud-sdk/path.bash.inc"
source $( dirname "${BASH_SOURCE[0]}" )/gcloudlib.sh

# Authenticate all operations using the given service account.
activate_service_account "${KEY}"

# Copy recursively to GCS with caching disabled.
copy_nocache ${SRC} ${DEST}
