#!/bin/bash
#
# This script decrypts an encrypted file. If the file is a *.tar* file and the
# out-dir is given, then the contents are unpacked in the given out-dir. If key
# or iv are empty strings, the script exits without error.

set -e

USAGE="$0 <key> <iv> <enc-file> <out-file> [out-dir]"
if [[ -z "$1" ]] ; then
  echo "Nothing to decrypt."
  exit 0
fi
KEY=${1:?Please provide encryption KEY: $USAGE}
IV=${2:?Please provide encryption IV: $USAGE}
INPUT=${3:?Please provide encrypted input filename: $USAGE}
OUTPUT=${4:?Please provide output filename: $USAGE}
OUTDIR=${5}

echo "Decrypting: ${INPUT} -> ${OUTPUT}"
openssl aes-256-cbc -d -K "${KEY}" -iv "${IV}" -in "${INPUT}" -out "${OUTPUT}"
# If OUTPUT is a tar file, then unpack the content into OUTDIR.
if [[ -n "${OUTDIR}" && "${OUTPUT}" == *.tar* ]] ; then
    tar -C "${OUTDIR}" -xvf "${OUTPUT}" ;
fi
