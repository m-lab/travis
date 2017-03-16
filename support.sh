#!/bin/bash

# Displays a given message requiring user confirmation before continuing.
function confirm () {
  local msg=$1
  read -p "$msg (y/N): " -n 1 -r
  echo ''
  if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
    echo "Not confirmed. Exiting."
    exit 1
  fi
}


# Checks that the environment is sane.
function sanity_check_or_die () {
  if ! command -v gcloud ; then
    echo "gcloud not found in PATH. Is the Google Cloud SDK installed?"
    echo "https://cloud.google.com/sdk/downloads"
    exit 1
  fi
}


