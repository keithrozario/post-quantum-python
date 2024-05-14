from botocore.exceptions import SSLError
import boto3
from botocore.config import Config
import os

# reduce max attempts to speed up test (no retries on failure)
config = Config(retries = {'total_max_attempts': 1})
region = 'ap-southeast-1'
kms_client=boto3.client('kms', region_name=region, config=config)
dynamodb_client=boto3.client('dynamodb', region_name=region, config=config)

OPENSSL_GROUP = os.environ['DEFAULT_GROUPS']

print(f"## Test with {OPENSSL_GROUP} in {region}\n")

if 'x25519' in OPENSSL_GROUP.split(':'):
    assert dynamodb_client.list_tables()['ResponseMetadata']['HTTPStatusCode'] == 200
    print(f"GOOD: Successfully connected to DynamoDB endpoint with {OPENSSL_GROUP}")
else:
    try:
         dynamodb_client.list_tables()
         assert False # should never reach this line.
    except SSLError:
        print(f"GOOD: Failed connected to DynamoDB endpoint with {OPENSSL_GROUP} - expected")
        
assert kms_client.list_keys()['ResponseMetadata']['HTTPStatusCode'] == 200
print(f"GOOD: Successfully connected to KMS endpoint with {OPENSSL_GROUP}")

print(f"## END Test {OPENSSL_GROUP}\n\n")