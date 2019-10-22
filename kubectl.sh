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

# Identify the cluster LOCATION, which is either a zone or a region.
LOCATION=$( gcloud container clusters list \
  --format='table[no-heading](location)' \
  --filter "name='${CLUSTER}'" )

if [[ -z "${LOCATION}" ]] ; then
  echo "ERROR: could not find location for ${CLUSTER}"
  echo "ERROR: does cluster exist?"
  exit 1
fi

# Get credentials for accessing the k8s cluster.
zone=".*-[a-z]"
region=".*[a-z][1-9]"
if [[ ${LOCATION} =~ ${zone} ]] ; then
  gcloud container clusters get-credentials ${CLUSTER} --zone ${LOCATION}
elif [[ ${LOCATION} =~ ${region} ]] ; then
  gcloud container clusters get-credentials ${CLUSTER} --region ${LOCATION}
else
  echo "ERROR: $LOCATION does not match zone or region pattern."
  exit 1
fi

# Make the project and cluster available to sub-commands.
export PROJECT
export CLUSTER

# Run command given on the rest of the command line.
$@
