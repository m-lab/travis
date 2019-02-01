#!/bin/bash
#
# Load k8s cluster credentials for kubectl and run a given command.

set -x
set -e
set -u

USAGE="$0 <project> <cluster> <command>"
PROJECT=${1:?Please provide the project: $USAGE}
CLUSTER=${2:?Please provide the cluster: $USAGE}
shift 2

# Add gcloud to PATH.
source "${HOME}/google-cloud-sdk/path.bash.inc"
source $( dirname "${BASH_SOURCE[0]}" )/gcloudlib.sh

# Note: service account environment variables should be defined by
# setup_service_accounts_for_travis.sh.
KEYNAME="SERVICE_ACCOUNT_${PROJECT/-/_}"
# Authenticate all operations using the given service account.
activate_service_account "${KEYNAME}"

# For all options see:
# https://cloud.google.com/sdk/gcloud/reference/config/set
gcloud config set core/project "${PROJECT}"
gcloud config set core/disable_prompts true
gcloud config set core/verbosity info

# Identify the cluster ZONE.
ZONE=$( gcloud container clusters list \
  --format='table[no-heading](locations[0])' \
  --filter "name='${CLUSTER}'" )

if [[ -z "${ZONE}" ]] ; then
  echo "ERROR: could not find zone for ${CLUSTER}"
  echo "ERROR: does cluster exist?"
  exit 1
fi

# Get credentials for accessing the k8s cluster.
gcloud container clusters get-credentials ${CLUSTER} --zone ${ZONE}

# Make the project and cluster available to sub-commands.
export ZONE
export PROJECT
export CLUSTER

# Run command given on the rest of the command line.
$@
