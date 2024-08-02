#! /bin/bash

export DEFAULT_GROUPS=x25519
python3 boto_client_test.py
export DEFAULT_GROUPS=x25519_kyber512:x25519
python3 boto_client_test.py
# TODO [childw] below is supposed to be a hybrid-only ciphre pref, NO classical-only
#export DEFAULT_GROUPS=x25519_kyber512
python3 boto_client_test.py
