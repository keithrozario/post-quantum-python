ARG PYTHON_MAJOR_VERSION=3.12
ARG PYTHON_VERSION=3.12.0
ARG PYTHON_INSTALL_DIR=/opt/python

FROM openquantumsafe/oqs-ossl3:interop as build

ARG PYTHON_VERSION
ARG PYTHON_INSTALL_DIR

ARG TZ=Etc/UTC
ARG OPENSSL_DIR=/opt/openssl32
ARG PYTHON_DOWNLOAD_DIR=/tmp/python

RUN apt update && apt upgrade -y

RUN ln -s /usr/share/zoneinfo/$TZ /etc/localtime
RUN echo $TZ > /etc/timezone

RUN apt install -y libncurses-dev libbz2-dev libgdbm-dev liblzma-dev libssl-dev tk-dev \
               uuid-dev libreadline-dev libsqlite3-dev libffi-dev gcc make automake \
               wget libgdbm-dev libgdbm-compat-dev
# for --enable-optimizations
RUN apt install -y llvm

# Download Python
RUN mkdir $PYTHON_DOWNLOAD_DIR
WORKDIR $PYTHON_DOWNLOAD_DIR
RUN wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz && \
        tar -xvf Python-$PYTHON_VERSION.tgz

# Build python with statically linked openssl
WORKDIR $PYTHON_DOWNLOAD_DIR/Python-$PYTHON_VERSION
ENV LDFLAGS="-L$OPENSSL_DIR/lib -L$OPENSSL_DIR/lib64"
ENV LD_LIBRARY_PATH="$OPENSSL_DIR/lib:$OPENSSL_DIR/lib64"
ENV CPPFLAGS="-I$OPENSSL_DIR/include -I$OPENSSL_DIR/include/openssl"
RUN ./configure --with-openssl=$OPENSSL_DIR --with-ensurepip=install --prefix=$PYTHON_INSTALL_DIR/ --with-openssl-rpath=auto --enable-optimizations --with-lto
RUN make -j$(nproc)
RUN make install

# Set group back to x25519 (or pip won't work!)
ENV DEFAULT_GROUPS=x25519  
WORKDIR /
RUN ln -s $PYTHON_INSTALL_DIR/bin/pip3 /usr/bin/pip
COPY dependencies/requirements.txt .
RUN pip install -r requirements.txt


# Final image
FROM openquantumsafe/oqs-ossl3:interop as final

ARG PYTHON_MAJOR_VERSION
ARG PYTHON_INSTALL_DIR

COPY --from=build $PYTHON_INSTALL_DIR $PYTHON_INSTALL_DIR

RUN ln -s $PYTHON_INSTALL_DIR/bin/python$PYTHON_MAJOR_VERSION /usr/bin/python3
RUN ln -s $PYTHON_DIR/bin/pip3 /usr/bin/pip

RUN mkdir /var/pq_python_test
WORKDIR /var/pq_python_test
COPY test/ .
RUN chmod -R +x .

ENTRYPOINT [ "/bin/bash"]