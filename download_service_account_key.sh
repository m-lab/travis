#!/bin/bash
#
# Downloads a new key for an existing service account. This may be useful in
# local development and testing. Use setup_service_accounts_for_travis.sh
# for travis.

set -e

BASEDIR="$(dirname "$0")"
source "${BASEDIR}/support.sh"

USAGE="$0 <project> <output-key-file>"
PROJECT=${1:?Please provide the GCP project id: $USAGE}
OUTPUT=${PROJECT}-key.json


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
  local original_user=$( gcloud config get-value core/account )

  echo ""
  echo "Running as: ${original_user}"

  if ! service_account_exists "${account}" ; then
    echo "Error: sorry ${account} does not exist! You must create it first "
    echo "using setup_service_accounts_for_travis.sh"
    exit 1
  fi

  echo "Confirmed: $account exists.."

  if [[ -f ${OUTPUT} ]] ; then
    echo "Found: existing service account key file ${OUTPUT}"
  else
    echo "Downloading: new key for $account"
    gcloud --project "${PROJECT}" iam service-accounts keys create \
        --iam-account "${account}" "${OUTPUT}"
  fi

  echo "
Success!

Now, add this service account to your local environment by running:

  export SERVICE_ACCOUNT_${PROJECT/-/_}=\$( cat ${OUTPUT} )

Then, activate the service account for gcloud commands using:

  ./travis/activate_service_account.sh SERVICE_ACCOUNT_${PROJECT/-/_}

At this point, ALL gcloud operations will use those credentials.

You may restore your user account credentials using:

  gcloud config set core/account ${original_user}
"

}

main
