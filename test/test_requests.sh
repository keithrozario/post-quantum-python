#! /bin/bash

export DEFAULT_GROUPS='X25519Kyber768Draft00:x25519'
python3 requests_test.py

export DEFAULT_GROUPS='X25519MLKEM768:x25519'
python3 requests_test.py
