import requests
import os


kyber_endpoint = 'https://secretsmanager.us-east-1.amazonaws.com/ping'
expected_group = 'x25519_kyber512'

# Check environment variables
print(f"## Test with {expected_group} against {kyber_endpoint} using requests")
assert os.environ['DEFAULT_GROUPS'] == expected_group
response = requests.get(kyber_endpoint, timeout=3)
assert response.status_code == 200
print(f"Successfully connected to {kyber_endpoint} using {expected_group}")


