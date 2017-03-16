#!/bin/bash
#
# This script decrypts an encrypted file.

set -e

USAGE="$0 <iv> <key> <enc-file> <out-file> [out-dir]"
IV=${1:?Please provide encryption IV: $USAGE}
KEY=${2:?Please provide encryption KEY: $USAGE}
INPUT=${3:?Please provide encrypted input filename: $USAGE}
OUTPUT=${4:?Please provide output filename: $USAGE}
OUTDIR=${5}

if [[ -n "${IV}" ]] ; then
  echo "Decrypting: ${INPUT} -> ${OUTPUT}"
  openssl aes-256-cbc -d -K "${KEY}" -iv "${IV}" -in "${INPUT}" -out "${OUTPUT}"
  # If OUTPUT is a tar file, then unpack the content into OUTDIR.
  if [[ -n "${OUTDIR}" && "${OUTPUT}" == *.tar ]] ; then
      tar -C "${OUTDIR}" -xvf "${OUTPUT}" ;
  fi
fi
