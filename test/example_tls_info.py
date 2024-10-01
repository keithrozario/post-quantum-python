import requests
import urllib3
from urllib3.connection import VerifiedHTTPSConnection

SOCK = None

_orig_connect = urllib3.connection.VerifiedHTTPSConnection.connect


def _connect(self):
    global SOCK
    _orig_connect(self)
    SOCK = self.sock


requests.packages.urllib3.connection.VerifiedHTTPSConnection.connect = _connect

requests.get("https://yahoo.com", timeout=3)
tlscon = SOCK.connection
print("hello")
