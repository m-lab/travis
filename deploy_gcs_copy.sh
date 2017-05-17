#!/bin/bash
#
# Copies local files to a given GCS bucket.
set -x
set -e

USAGE="$0 <key-file> <source> <dest>"
KEYFILE=${1:?Please provide the service account key file: $USAGE}
SOURCE=${2:?Please provide source pattern: $USAGE}
GSPATH=${3:?Please provide GCS destination - gs://path: $USAGE}
GSUTIL_CP_FLAGS=${4}

# Add gcloud to PATH.
source "${HOME}/google-cloud-sdk/path.bash.inc"

# All operations are performed as the service account named in KEYFILE.
# For all options see:
# https://cloud.google.com/sdk/gcloud/reference/auth/activate-service-account
gcloud auth activate-service-account --key-file "${KEYFILE}"

# For this to succeed, the specified bucket must have ACLs to allow WRITE
# access for the service account associated with the keyfile. Update the ACL
# from a privileged account using:
#   gsutil acl ch -u SERVICE_ACCT_NAME@PROJECT.iam.gserviceaccount.com:WRITE \
#      gs://BUCKET
gsutil cp ${GSUTIL_CP_FLAGS} ${SOURCE} "${GSPATH}"

exit 0
