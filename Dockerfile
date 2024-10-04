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

# downlaod and patch aws-lc source
RUN mkdir $AWSLC_DOWNLOAD_DIR
WORKDIR $AWSLC_DOWNLOAD_DIR
RUN git clone -b main https://github.com/aws/aws-lc .
COPY patches/aws-lc.patch $AWSLC_DOWNLOAD_DIR
RUN cat $AWSLC_DOWNLOAD_DIR/aws-lc.patch | patch -p1 -d .
# assert that the patch was applied
RUN git diff | wc -l | xargs test 0 -lt

# downlaod and patch python source
RUN mkdir $PYTHON_DOWNLOAD_DIR
WORKDIR $PYTHON_DOWNLOAD_DIR
RUN git clone -b main https://github.com/python/cpython .
COPY patches/cpython.patch $PYTHON_DOWNLOAD_DIR
RUN cat $PYTHON_DOWNLOAD_DIR/cpython.patch | patch -p1 -d .
# assert that the patch was applied
RUN git diff | wc -l | xargs test 0 -lt

# build and install AWS-LC
WORKDIR $AWSLC_DOWNLOAD_DIR
RUN mkdir $AWSLC_INSTALL_DIR
RUN cmake \
    -Bbuild \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$AWSLC_INSTALL_DIR \
    -DCMAKE_INSTALL_PREFIX=$AWSLC_INSTALL_DIR \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=OFF
RUN make -C build -j install

# build and install CPython interpreter linked against AWS-LC
WORKDIR $PYTHON_DOWNLOAD_DIR
RUN mkdir $PYTHON_INSTALL_DIR
RUN ./configure \
    --with-openssl=$AWSLC_INSTALL_DIR \
    --with-ensurepip=install \
    --prefix=$PYTHON_INSTALL_DIR \
    --with-builtin-hashlib-hashes=blake2 \
    --with-ssl-default-suites=openssl
RUN make -j install

# use newly build CPython as system python
RUN rm -f /usr/bin/python3 \
    && ln -s $PYTHON_INSTALL_DIR/bin/python3 /usr/bin/python3

# assert that CPython is built against AWS_LC
RUN python3 -c "import ssl; print(ssl.OPENSSL_VERSION)" | grep AWS-LC

# install other pip dependencies
WORKDIR /
RUN rm -f /usr/bin/pip \
    && ln -s $PYTHON_INSTALL_DIR/bin/pip3 /usr/bin/pip
COPY requirements.txt .
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

CMD [ "/bin/bash", "test.sh"]
