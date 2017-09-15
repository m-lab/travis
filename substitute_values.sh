#!/bin/bash

# Replaces values in a container config.

set -e
# No set -x in order to prevent spamming build logs. When there are thousands of
# deployments, setting -x causes tens of thousands of loglines to appear, and
# Travis has a hardcoded upper limit of 10000 before their nice log viewer just
# gives up.

source "${HOME}/google-cloud-sdk/path.bash.inc"

USAGE="$0 <directory> [<KEY> <VALUE>]*"
DIRECTORY=${1:?Please provide directory full of files: $USAGE}
shift 1

# All subsequent arguments must be name-value pairs, which means that there
# should be an even number of arguments.
[[ $[ $# % 2 ] == 0 ]] || exit 1

# Fill in the deployment template(s)
# Make a substitution in every file in the deployment/ directory
function deployment_substitution() {
  KEY=$1
  VALUE=$2

  for f in ${DIRECTORY}/*
  do
    newf=$(mktemp)
    sed -e "s#${KEY}#${VALUE}#"  < "${f}" > "${newf}"
    mv -f "${newf}" "${f}"
  done
}

while [[ $# -ge 2 ]]
do
  NAME=$1
  VALUE=$2
  shift 2
  deployment_substitution "{{${NAME}}}" "${VALUE}"
done
