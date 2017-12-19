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
#   key: base64 encoded service account key.
function activate_service_account() {
    local key=$1
    local keyfile=$( mktemp )

    echo $key | base64 --decode > ${keyfile}
    gcloud auth activate-service-account --key-file ${keyfile}
    rm -f ${keyfile}
}


# copy_nocache copies src files or directories to the GCS path in dest.
# Uploaded objects will have metadata set to disable caching.
#
# Args:
#  src: a source specification of a source file, dir, or pattern.
#  dest: a destination specification, including GCS bucket and optional path.
function copy_nocache() {
    local src=$1
    local dest=$2
    local cache_control="Cache-Control:private, max-age=0, no-transform"
    gsutil -h "$cache_control" cp -r ${src} ${dest}
}
