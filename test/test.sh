#! /bin/bash

set -e

# the ssl socket test doesn't require setting env variables. instead, it
# configures PQ TLS key exchange directly on a TLS-wrapped TCP socket using
# python's standard library ssl module.
python3 ssl_socket_test.py

# urllib3 issues a warning when it's linked against non-OpenSSL
# libcrypto/libssl. suppress that warning.
export PYTHONWARNINGS="ignore"

# TODO [childw] once ML-KEM is deployed to Secrets Manager endpoings, remove
# all Kyber references

# requests is built on urllib3, which uses CPython's ssl module under the hood.
# our patches to AWS-LC detect key exchange groups from environment variables
# and CPython pathces build the python interpreter runtime against AWS-LC
DEFAULT_GROUPS='X25519Kyber768Draft00:x25519' python3 requests_test.py
DEFAULT_GROUPS='X25519MLKEM768:x25519' python3 requests_test.py

# like requests, boto3 is built on top of urllib3 and will similarly detect PQ
# key exchange configuration from environment variables.
DEFAULT_GROUPS='X25519Kyber768Draft00' python3 boto_client_test.py
DEFAULT_GROUPS='X25519MLKEM768:x25519' python3 boto_client_test.py
