set -e

sudo docker build -t pq-tls -f Dockerfile .
sudo docker run \
    -e AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id) \
    -e AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key) \
    --rm \
    -it pq-tls:latest \
    ${@:-}
