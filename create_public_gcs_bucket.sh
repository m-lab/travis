#!/bin/bash
#
# create_public_gcs_bucket.sh creates a new gcs bucket in the currently active
# GCP project and sets the default ACL to public-read.
#
# If the bucket already exists, the ACL is still set to public-read.

BASEDIR="$(dirname "$0")"
source "${BASEDIR}/support.sh"

set -e
USAGE="$0 <project> <bucket>"
PROJECT=${1:?Please provide the GCP project id: $USAGE}
BUCKET=${2:?Please provide GCP bucket name: $USAGE}


# Checks whether the gcs bucket exists.
function gcs_bucket_exists () {
  # Use explicit return values (rather than implicit) so we can preserve
  # `set -e` globally.
  if gsutil acl get "gs://$1" &> /dev/null ; then
    return 0
  else
    return 1
  fi
}


function main () {
  sanity_check_or_die

  if ! gcs_bucket_exists "${BUCKET}" ; then
    confirm "Really create 'gs://${BUCKET}' in project '${PROJECT}'?"
    gsutil mb -p $PROJECT -c multi_regional "gs://${BUCKET}"
  else
    echo "Confirmed bucket 'gs://${BUCKET}' already exists"
  fi

  echo "Setting default object ACL to public-read"
  if ! gsutil defacl set public-read "gs://${BUCKET}" ; then
    echo "Failed to set default ACL on gs://${BUCKET}"
    exit 1
  fi
}


main
