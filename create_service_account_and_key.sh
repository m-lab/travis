#!/bin/bash
#
# Creates a new service account in the given project using a name derived from
# the current git repository. The service account is assigned the given role.
#
# The role should be one of:
#  * cloud-storage-deployer
#  * appengine-flexible-deployer
#
# After creating the service account and assigning a role, a new key is
# generated and written to the output file name.

set -e

BASEDIR="$(dirname "$0")"
source "${BASEDIR}/support.sh"

USAGE="$0 <project> <role> <output-key-file>"
PROJECT=${1:?Please provide the GCP project id: $USAGE}
ROLE=${2:?Please provide the role for service account: $USAGE}
OUTPUT=${3:?Please provide an output filename: $USAGE}
IAM_CONSOLE=https://console.cloud.google.com/iam-admin/iam/project


# Check whether the service account exists.
function service_account_exists () {
  # Use explicit return values (rather than implicit) so we can preserve
  # `set -e` globally.
  if gcloud --project "${PROJECT}" \
      iam service-accounts describe "$1" &> /dev/null ; then
    return 0
  else
    return 1
  fi

}

function main () {
  sanity_check_or_die

  local basename=$( basename `git rev-parse --show-toplevel` )
  # Service account names can have no more than 30 characters.
  local name=${basename:0:16}-travis-deploy
  local account="${name}@${PROJECT}.iam.gserviceaccount.com"
  local iam_url="${IAM_CONSOLE}?project=${PROJECT}"

  if ! service_account_exists "${account}" ; then
    confirm "Really create service account '$account' in project '${PROJECT}'?"
    gcloud --project "${PROJECT}" iam service-accounts create ${name} \
        --display-name ${name}
  else
    echo "$account already exists.."
  fi

  # Assign the given custom role to the service account. It will appear in:
  #    GCP Console "IAM & Admin" -> "IAM" page
  #
  # Setting the same role if it is already present has no effect.
  # Note: the role specified here must have all special characters removed.
  gcloud --project "${PROJECT}" projects add-iam-policy-binding "${PROJECT}" \
      --member "serviceAccount:${account}" \
      --role "projects/${PROJECT}/roles/${ROLE//-/}"

  echo "Creating new key for $account"
  gcloud --project "${PROJECT}" iam service-accounts keys create \
      --iam-account "${account}" "${OUTPUT}"

  echo "Service account '$account' created with role '$ROLE'"
  echo ""
  echo "Visit the GCP IAM & Admin page NOW and verify the configuration."
  echo ""
  echo "Service accounts should have the FEWEST PERMISSIONS POSSIBLE."
  echo ""
  echo "${iam_url}"
  google-chrome "${iam_url}" &> /dev/null || :
}

main
