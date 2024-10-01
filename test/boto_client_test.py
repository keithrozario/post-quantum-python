from botocore.exceptions import SSLError
import boto3
from botocore.config import Config
import os

# reduce max attempts to speed up test (no retries on failure)
config = Config(retries={"total_max_attempts": 1})
region = "ap-southeast-1"
secretsmanager = boto3.client("secretsmanager", region_name=region, config=config)
dynamodb = boto3.client("dynamodb", region_name=region, config=config)

GROUP = os.environ["DEFAULT_GROUPS"]

print(f"## Test with {GROUP} in {region}")

if "x25519" in GROUP.split(":"):
    assert dynamodb.list_tables()["ResponseMetadata"]["HTTPStatusCode"] == 200
    print(f"GOOD: Successfully connected to DynamoDB endpoint with {GROUP}")
else:
    try:
        dynamodb.list_tables()
        assert False  # should never reach this line.
    except SSLError:
        print(f"GOOD: Failed connected to DynamoDB endpoint with {GROUP} - expected")

assert secretsmanager.list_secrets()["ResponseMetadata"]["HTTPStatusCode"] == 200
print(f"GOOD: Successfully connected to SecretsManager endpoint with {GROUP}")

print(f"## END Test {GROUP}n\n")
