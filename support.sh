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

function assert_travis_install_or_die() {
  if ! type -p travis > /dev/null ; then
    echo 'travis not found in PATH. Is the travis CLI installed?'
    echo 'https://github.com/travis-ci/travis.rb#installation'
    exit 1
  fi
}

function assert_travis_login_or_die() {
  if ! travis whoami > /dev/null ; then
    echo 'Please login to travis: travis login --auto'
    exit 1
  fi
}
