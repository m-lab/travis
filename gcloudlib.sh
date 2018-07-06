#!/bin/bash
#
# A library of common operations around gcloud / gsutil cli.

# activate_service_account takes a base64 encoded service account key, decodes
# it, and activates it so that future gcloud operations are authenticated using
# that service account.
#
# For more information, see:
#   https://cloud.google.com/sdk/gcloud/reference/auth/activate-service-account
#
# Args:
#   keyname: name of environment variable that contains a service account key.
function activate_service_account() {
    local keyname=$1
    local keyfile=$( mktemp )

    # Unconditionally disable command echo to protect the key. Run in a subshell
    # to localize the effect of set +x.
    ( set +x; echo "${!keyname}" > ${keyfile} )
    gcloud auth activate-service-account --key-file ${keyfile}
    rm -f ${keyfile}
}


# copy_nocache copies src files or directories to the GCS path in dest.
# Uploaded objects will have metadata set to disable caching.
#
# Args:
#  copyfiles: the source and dest files, dirs, or patterns.
function copy_nocache() {
    local copyfiles=$@
    local cache_control="Cache-Control:private, max-age=0, no-transform"
    gsutil -h "$cache_control" cp -r $copyfiles
}


# gce_run_command() runs an arbitrary command on a GCE VM over SSH.
#
# Args:
#   project: name of the project in which the GCE VM resides.
#   zone: zone in which the GCE VM resides.
#   name: name of the GCE VM.
#   command: the command to run.
gce_run_command() {
  local project="$1"
  local zone="$2"
  local name="$3"
  local command="$4"

  gcloud config set project $project
  gcloud config set compute/zone $zone
  gcloud compute ssh $name --command "$command"
}
