import ssl
import socket

assert "AWS-LC" in ssl.OPENSSL_VERSION

HOST = "secretsmanager.us-west-1.amazonaws.com"
CERT_STORE = "/etc/ssl/certs/ca-certificates.crt"


def connect(group: str):
    ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    # NOTE: we set minimum version of TLSv1.3 to prevent the server from
    # down-grading connection to (non-PQ) TLSv1.2 negotiated by ciphersuites
    # rather than (≥ TLSv1.3) SupportedGroups.
    ctx.minimum_version = ssl.TLSVersion.TLSv1_3
    ctx.set_ecdh_curve(group)
    ctx.load_verify_locations(CERT_STORE)
    sock = socket.create_connection((HOST, 443))
    ssock = ctx.wrap_socket(sock, server_hostname=HOST)
    ssock.close()
    print(f"Socket connection with {group} succeeded!")


connect("X25519Kyber768Draft00")
try:
    connect("X25519MLKEM768")
    # If we hit below assert, that indicates that MLKEM has been deployed!
    assert False, "Time to delete all Kyber768 stuff form this PoC!"
except ssl.SSLZeroReturnError as e:
    print("MLKEM isn't fully deployed yet")
    pass
