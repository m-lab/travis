#!/bin/bash

# Replaces values in a container config.

set -e
set -x

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
    sed --expression="s#${KEY}#${VALUE}#" --in-place $f
  done
}

while [[ $# -ge 2 ]]
do
  NAME=$1
  VALUE=$2
  shift 2
  deployment_substitution "{{${NAME}}}" "${VALUE}"
done
