# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04 as build

# Set an argument for the Guile version, default to 3.0.10
ARG GUILE_VERSION=3.0.10

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    zlib1g-dev \
    gnutls-bin \
    libgnutls28-dev \
    libgcrypt-dev \
    autoconf \
    libtool \
    libffi-dev \
    libgmp-dev \
    libc6-dev \
    libltdl-dev \
    libunistring-dev \
    libgc-dev \
    pkg-config \
    texinfo \
    libtool-bin \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Download and install Guile
RUN wget ftp://ftp.gnu.org/gnu/guile/guile-${GUILE_VERSION}.tar.gz && \
    zcat guile-${GUILE_VERSION}.tar.gz | tar xvf - && \
    cd guile-${GUILE_VERSION} && \
    ./configure && \
    make && \
    make install

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib
ENV LD_RUN_PATH $LD_RUN_PATH:/usr/local/lib

# Install guile-json
RUN git clone https://github.com/aconchillo/guile-json.git && \
    cd guile-json && \
    autoreconf -vif && \
    ./configure && \
    make && \
    make install

# Install guile-gnutls
RUN git clone https://gitlab.com/gnutls/guile.git && \
    cd guile && \
    autoreconf -vif && \
    ./configure && \
    make && \
    make install

# Install guile-gcrypt
RUN git clone https://notabug.org/cwebber/guile-gcrypt.git && \
    cd guile-gcrypt && \
    cp ../guile/m4/guile.m4 m4/guile.m4 && \
    autoreconf -vif && \
    ./configure && \
    make && \
    make install

# Clean up temporary files
WORKDIR /
RUN rm -rf /tmp/guile-${GUILE_VERSION}.tar.gz /tmp/guile-${GUILE_VERSION} /tmp/guile-json /tmp/guile /tmp/guile-gcrypt


FROM ubuntu:24.04 as main

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib \
    LD_RUN_PATH=$LD_RUN_PATH:/usr/local/lib

RUN mkdir -p /usr/lib/x86_64-linux-gnu
COPY --from=build /usr/local/bin /usr/local/bin \
                  /usr/local/lib /usr/local/lib \
                  /usr/local/share /usr/local/share \
                  /usr/lib/x86_64-linux-gnu/*.so* /usr/lib/x86_64-linux-gnu

# Set the default command to start an interactive Guile shell.
CMD ["guile"]
