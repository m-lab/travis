#!/bin/bash
#
# deploy_gcs supports deploying build artifacts to GCS buckets using service
# account keys from the environment, such as those stored in travis-ci.
#
# Examples:
#   # Copies all files matching pattern to the named folder, preserving names.
#   deploy_gcs.sh SERVICE_ACCOUNT_mlab_sandbox \
#       build/*.rpm \
#       gs://example-mlab-sandbox/files/
#
#   # Copies specific file to a folder, preserving the name.
#   deploy_gcs.sh SERVICE_ACCOUNT_mlab_sandbox \
#       build/foobar.rpm \
#       gs://example-mlab-sandbox/files/
#
#   # Copies specific file and renames it in GCS.
#   deploy_gcs.sh SERVICE_ACCOUNT_mlab_sandbox \
#       build/foobar.rpm \
#       gs://example-mlab-sandbox/files/foobar-newname.rpm
set -e
set -u

USAGE="Usage: $0 <keyname> <src> <dest>"
KEYNAME=${1:?Please provide the service account keyname: $USAGE}
shift
# Ensure there are at least two additional parameters.
if [[ $# -lt 2 ]] ; then
    echo $USAGE
    exit 1
fi

# Import support functions from the bash gcloud library.
source "${HOME}/google-cloud-sdk/path.bash.inc"
source $( dirname "${BASH_SOURCE[0]}" )/gcloudlib.sh

# Authenticate all operations using the given service account.
activate_service_account "${KEYNAME}"

# Copy recursively to GCS with caching disabled.
copy_nocache $@
