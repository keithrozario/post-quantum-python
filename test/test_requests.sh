#! /bin/bash

export DEFAULT_GROUPS='x25519'
python3 download_crt.py
export REQUESTS_CA_BUNDLE="$PWD/CA.crt"
export DEFAULT_GROUPS='x25519_kyber512'
python3 requests_test.py
unset REQUESTS_CA_BUNDLE
export DEFAULT_GROUPS='x25519'
