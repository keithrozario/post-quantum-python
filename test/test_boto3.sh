#! /bin/bash

export DEFAULT_GROUPS='X25519Kyber768Draft00'
python3 boto_client_test.py

export DEFAULT_GROUPS='X25519MLKEM768:x25519'
python3 boto_client_test.py
