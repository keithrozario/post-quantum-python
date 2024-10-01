import os
import ssl

import requests
import urllib3

assert "AWS-LC" in ssl.OPENSSL_VERSION

CERT_STORE = "/etc/ssl/certs/ca-certificates.crt"
ENDPOINT = "https://secretsmanager.us-east-1.amazonaws.com/ping"
GROUP = os.environ["DEFAULT_GROUPS"]

print(f"## Test with {GROUP} against {ENDPOINT} using requests")

response = requests.get(ENDPOINT, timeout=3)
assert response.status_code == 200
print(f"Successfully connected to {ENDPOINT} using {GROUP}")
