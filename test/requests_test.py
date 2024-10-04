import os
import ssl

import requests


assert "AWS-LC" in ssl.OPENSSL_VERSION

GROUP = os.environ["DEFAULT_GROUPS"]
REGION = "us-east-1"
ENDPOINT = f"https://secretsmanager.{REGION}.amazonaws.com/ping"

print(
    f"requests:\tConnecting to {REGION} SecretsManager endpoint with {GROUP}... ",
    end="",
)
response = requests.get(ENDPOINT, timeout=3)
assert response.status_code == 200
print("ok")
