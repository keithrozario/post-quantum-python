"""
Container does not contain wget or curl, so we use this instead
"""

import requests
import os

crt_location = 'https://test.openquantumsafe.org/CA.crt'

test_cert_bundle = requests.get(crt_location, timeout=3)
with open("./CA.crt", 'wb') as crt_file:
    crt_file.write(test_cert_bundle.content)
