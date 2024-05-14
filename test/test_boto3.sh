#! /bin/bash

export DEFAULT_GROUPS=x25519
python3 boto_client_test.py
export DEFAULT_GROUPS=x25519_kyber512:x25519
python3 boto_client_test.py
export DEFAULT_GROUPS=x25519_kyber512
python3 boto_client_test.py
