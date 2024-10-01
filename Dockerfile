FROM public.ecr.aws/ubuntu/ubuntu:22.04_stable as build

ARG PYTHON_INSTALL_DIR=/opt/python
ARG AWSLC_INSTALL_DIR=/opt/awslc

ARG TZ=Etc/UTC
ARG PYTHON_DOWNLOAD_DIR=/tmp/python
ARG AWSLC_DOWNLOAD_DIR=/tmp/awslc

RUN apt-get update 

RUN ln -s /usr/share/zoneinfo/$TZ /etc/localtime
RUN echo $TZ > /etc/timezone

RUN apt-get install -y libncurses-dev libbz2-dev libgdbm-dev liblzma-dev libssl-dev tk-dev \
               uuid-dev libreadline-dev libsqlite3-dev libffi-dev gcc make automake \
               wget libgdbm-dev libgdbm-compat-dev git cmake golang golang-1.18 perl llvm

RUN rm -f /usr/bin/go /usr/bin/gofmt \
    && ln -s /usr/lib/go-1.18/bin/go /usr/bin/go \
    && ln -s /usr/lib/go-1.18/bin/gofmt /usr/bin/gofmt

RUN mkdir $AWSLC_DOWNLOAD_DIR
WORKDIR $AWSLC_DOWNLOAD_DIR
RUN git clone -b pq-python https://github.com/WillChilds-Klein/aws-lc .

RUN mkdir $AWSLC_INSTALL_DIR
RUN cmake \
    -Bbuild \
    -DCMAKE_PREFIX_PATH=$AWSLC_INSTALL_DIR \
    -DCMAKE_INSTALL_PREFIX=$AWSLC_INSTALL_DIR \
    -DBUILD_SHARED_LIBS=OFF
RUN make -C build -j install

RUN mkdir $PYTHON_DOWNLOAD_DIR
WORKDIR $PYTHON_DOWNLOAD_DIR
RUN git clone -b pq-tls https://github.com/WillChilds-Klein/cpython .

RUN mkdir $PYTHON_INSTALL_DIR
RUN ./configure \
    --with-openssl=$AWSLC_INSTALL_DIR \
    --with-ensurepip=install \
    --prefix=$PYTHON_INSTALL_DIR \
    --with-builtin-hashlib-hashes=blake2 \
    --with-ssl-default-suites=openssl
RUN make -j install

RUN rm -f /usr/bin/python3 \
    && ln -s $PYTHON_INSTALL_DIR/bin/python3 /usr/bin/python3
RUN python3 -c "import ssl; print(ssl.OPENSSL_VERSION)" | grep AWS-LC

WORKDIR /
RUN rm -f /usr/bin/pip \
    && ln -s $PYTHON_INSTALL_DIR/bin/pip3 /usr/bin/pip
COPY dependencies/requirements.txt .
RUN pip install -r requirements.txt --no-cache-dir

FROM public.ecr.aws/ubuntu/ubuntu:22.04_stable as final

ARG PYTHON_INSTALL_DIR

COPY --from=build $PYTHON_INSTALL_DIR $PYTHON_INSTALL_DIR

RUN mkdir /var/pq_python_test
WORKDIR /var/pq_python_test
COPY test/ .


RUN useradd -rm -d /home/pquser -s /bin/bash -g root -G sudo -u 1001 pquser
RUN chmod -R +x .
RUN chown pquser:root .

USER pquser

HEALTHCHECK CMD ["python3", "check_openssl_version.py"] || exit 1

# TODO [childw] how to build and install latest AWS-LC and python?

CMD [ "/bin/bash", "test.sh"]
