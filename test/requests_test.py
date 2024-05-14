import requests
import os


# GROUP to Port mapping here:
# https://test.openquantumsafe.org/assignments.json

kyber_endpoint = 'https://test.openquantumsafe.org:6041'
expected_group = 'x25519_kyber512'

# Check environment variables
print(f"## Test with {expected_group} against {kyber_endpoint} using requests")
assert os.environ['DEFAULT_GROUPS'] == expected_group
response = requests.get(kyber_endpoint)
assert response.status_code == 200
print(f"Successfully connected to {kyber_endpoint} using {expected_group}")


