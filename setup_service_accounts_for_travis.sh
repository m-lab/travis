#!/bin/bash
#
# setup_service_accounts_for_travis.sh will create service accounts (if missing),
# encode service account credentials (if missing), and set travis environment
# variables to contain the encoded service account credentials so they are
# available for travis `deploy` scripts.
#
# By default, setup_service_accounts_for_travis.sh creates service accounts in
# the standard three projects: mlab-sandbox, mlab-staging, and mlab-oti. If you
# wish to additionally create a service account in the mlab-testing project,
# pass a single parameter, 'mlab-testing'.
#
# In order to perform GCP operations from travis, we must have service account
# credentials available to travis. This script will create service account
# credentials for all three M-Lab projects with a name derived from the git
# repository (to help trace bad behavior back to the source).
#
# To create a service account we must assigning it a role. Since IAM Roles are
# in flux, this script assigns a default minimal-permission role. The user must
# manually create or assign a custom role through the GCP console.
#
# The default role: cloud-storage-deployer
#
# You may assign other custom roles to your service account in GCP Console:
#
#    GCP Console -> IAM & admin -> IAM
#    Select the drop down next to the service account.
#    Look for Custom -> and choose a custom role.
#
# DO NOT ASSIGN standard roles to deployment service accounts. They are almost
# certainly overly permissive.

set -e

BASEDIR="$(dirname "$0")"
source "${BASEDIR}/support.sh"

# If an argument is given, interpret it as requesting mlab-testing keys also.
ADD_TESTING_KEYS=${1:+mlab-testing}


USAGE="$0"
IAM_CONSOLE=https://console.cloud.google.com/iam-admin/iam/project


# service_account_exists checks whether the given account exists in the given
# project.
#
# Args:
#   project: the project name, e.g. mlab-sandbox
#   account: the expected service account name, e.g.
#       ndt-support-travis-deploy@mlab-sandbox.iam.gserviceaccount.com
#
function service_account_exists () {
  local project=$1
  local account=$2

  if gcloud --project "${project}" \
      iam service-accounts describe "$account" &> /dev/null ; then
    return 0
  else
    return 1
  fi
}

# download_service_account_keys downloads new service account credentials. Any
# existing keys are unaffected. However, note that service accounts can have no
# more than 10 keys at once and once that limit is reached creating new keys
# will fail.
#
# Args:
#   project: the project name, e.g. mlab-sandbox
#   account: the expected service account name, e.g.
#       ndt-support-travis-deploy@mlab-sandbox.iam.gserviceaccount.com
#   output: save service account credentials to named file. Contents are
#       overwritten.
#
function download_service_account_keys() {
  local project=$1
  local account=$2
  local output=$3

  echo "Creating new key for $account"
  gcloud --project "${project}" iam service-accounts keys create \
      --iam-account "${account}" "${output}"
}

# service_account_name constructs the GCP service account name for a given
# project and the current git repository name.
#
# Args:
#   project: the project name, e.g. mlab-sandbox
#
function service_account_name() {
  local project=$1
  local basename=$( basename `git rev-parse --show-toplevel` )
  # Service account names can have no more than 30 characters.
  local name=${basename:0:16}-travis-deploy
  echo "${name}@${project}.iam.gserviceaccount.com"
}

# setup_service_account will create a repo service account with default role if
# it does not exist. If the service account already exists, no action is taken.
#
# Args:
#   project: the project name, e.g. mlab-sandbox
#   account: the expected service account name, e.g.
#       ndt-support-travis-deploy@mlab-sandbox.iam.gserviceaccount.com
#
function setup_service_account() {
  local project=$1
  local account=$2
  local name=${account%%@*}
  local iam_url="${IAM_CONSOLE}?project=${project}"

  if service_account_exists "${project}" "${account}" ; then
    echo "Confirmed: $account already exists."
    return
  fi

  # Create service account.
  echo "Creating: '$account' in project '${project}'"
  gcloud --project "${project}" iam service-accounts create ${name} \
      --display-name ${name}

  # Assign a default custom role with minimal permissions. With this
  # assignment, the service account will be listed on:
  #    GCP Console "IAM & Admin" -> "IAM" page

  # NOTE: the output from this command is voluminous, so suppress it.
  gcloud --project "${project}" projects add-iam-policy-binding "${project}" \
      --member "serviceAccount:${account}" \
      --role "projects/${project}/roles/cloudstoragedeployer" &> /dev/null

  echo ""
  echo "Visit the GCP IAM & Admin page NOW and verify the configuration."
  echo "Service accounts should have the FEWEST PERMISSIONS POSSIBLE."
  echo ""
  echo "    ${iam_url}"
  echo ""
  google-chrome "${iam_url}" &> /dev/null || :
}

# setup_project checks the travis environment, and if the service account
# environment variable is missing, it downloads a new key for the repo service
# account and sets the SERVICE_ACCOUNT_<project> environment variable in travis.
#
# Args:
#   project: the project name, e.g. mlab-sandbox
#
function setup_project() {
  local project=$1

  # Do not overwrite the service account env variable if it already exists.
  if travis env list --no-interactive \
      | grep -q ^SERVICE_ACCOUNT_${project/-/_} ; then
    echo -n "Confirmed: SERVICE_ACCOUNT_${project/-/_} already exists."
    echo " Taking no action."
    return
  fi

  # Create (or confirm) the repo service account.
  local account="$( service_account_name ${project} )"
  setup_service_account "${project}" "${account}"

  # Download credentials for the repo service account.
  local output=$( mktemp /tmp/service-account-json.XXXXXXXX )
  download_service_account_keys "${project}" "${account}" "${output}"

  # The contents of the credential file.
  local key="$( cat ${output} )"
  rm -f ${output}

  # Create the new environment variable.
  echo "Setting SERVICE_ACCOUNT_${project/-/_}"
  travis env set --no-interactive SERVICE_ACCOUNT_${project/-/_} "${key}"
}


function main () {
  sanity_check_or_die
  assert_travis_install_or_die
  assert_travis_login_or_die

  # For every project.
  for project in ${ADD_TESTING_KEYS} mlab-sandbox mlab-staging mlab-oti ; do
    setup_project $project
  done

  echo "All known SERVICE_ACCOUNT environment variables."
  travis env list --no-interactive | grep SERVICE_ACCOUNT
}

main
