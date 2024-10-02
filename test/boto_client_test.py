import os
import ssl

import boto3

assert "AWS-LC" in ssl.OPENSSL_VERSION

GROUP = os.environ["DEFAULT_GROUPS"]
REGION = "ap-southeast-1"

print(f"boto:\tConnecting to {REGION} SecretsManager endpoint with {GROUP}... ", end="")
secretsmanager = boto3.client("secretsmanager", region_name=REGION)
assert secretsmanager.list_secrets()["ResponseMetadata"]["HTTPStatusCode"] == 200
print("ok")
