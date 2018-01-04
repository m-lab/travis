#!/bin/bash
#
# activate_service_account.sh accepts the name of an environment variable whose
# value contains an unencoded service account key and activates the key to be
# the default authentication on future gcloud operations.
set -e
set -u

USAGE="Usage: $0 <keyname>"
KEYNAME=${1:?Please provide the service account keyname: $USAGE}

# Import support functions from the bash gcloud library.
source "${HOME}/google-cloud-sdk/path.bash.inc"
source $( dirname "${BASH_SOURCE[0]}" )/gcloudlib.sh

# Authenticate all operations using the given service account.
activate_service_account "${KEYNAME}"
