# Use Ubuntu 24.04 as the base image
FROM ubuntu:24.04

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
    pkg-config \
    guile-2.2-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Download and install Guile
WORKDIR /tmp
RUN wget ftp://ftp.gnu.org/gnu/guile/guile-${GUILE_VERSION}.tar.gz && \
    zcat guile-${GUILE_VERSION}.tar.gz | tar xvf - && \
    cd guile-${GUILE_VERSION} && \
    ./configure && \
    make && \
    make install

# Install guile-json
RUN git clone https://gitlab.com/guile-proj/guile-json.git && \
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
    autoreconf -vif && \
    ./configure && \
    make && \
    make install

# Clean up temporary files
WORKDIR /
RUN rm -rf /tmp/guile-${GUILE_VERSION}.tar.gz /tmp/guile-${GUILE_VERSION} /tmp/guile-json /tmp/guile /tmp/guile-gcrypt

# Set the default command to start an interactive Guile shell.
CMD ["guile"]
