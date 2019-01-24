#!/bin/bash
#
# schedule_appengine_job.sh uses the Cloud Scheduler API to create AppEngine
# cron jobs.
#
# NOTE: this script DELETEs then CREATEs the job. So, existing jobs will be
# momentarily removed. Updates are not yet supported in gcloud.

set -ex
PROJECT=${1:?Please provide project}

name=${2:?Please provide name}
shift 2  # Pass remaining parameters to command.

# Attempt to delete the job and ignore errors (e.g. does not exist).
gcloud --project "${PROJECT}" \
    beta scheduler jobs delete "${name}" 2> /dev/null || :

# Attempt to create the job.
gcloud --project ${PROJECT} \
    beta scheduler jobs create app-engine "$name" "$@"
