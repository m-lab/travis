#!/bin/bash
#
# Installs the Google Cloud SDK.
#
# args: any extra components to install

set -e
set -x

if [[ ! -d "${HOME}/google-cloud-sdk/bin" ]]; then
  rm -rf "${HOME}/google-cloud-sdk"

  export CLOUDSDK_CORE_DISABLE_PROMPTS=1
  curl https://sdk.cloud.google.com | bash > /dev/null

fi

source "${HOME}/google-cloud-sdk/path.bash.inc"

# Install components
gcloud config set core/disable_prompts true
if [[ -n "$@" ]]; then
  gcloud components install $@
fi

# Verify installation succeeded.
gcloud version
