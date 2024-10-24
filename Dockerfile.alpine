FROM alpine:3.20 as builder

ARG GUILE_VERSION=3.0.10

RUN apk update && apk add --no-cache \
      gcc \
      g++ \
      make \
      automake \
      autoconf \
      libtool \
      texinfo \
      gettext-dev \
      libunistring-dev \
      libffi-dev \
      gc-dev \
      gmp-dev \
      libunistring-dev \
      readline-dev \
      wget 

WORKDIR /tmp

# Download and compile Guile
RUN wget https://ftp.gnu.org/gnu/guile/guile-${GUILE_VERSION}.tar.gz && \
    tar xzf guile-${GUILE_VERSION}.tar.gz && \
    cd guile-${GUILE_VERSION} && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    cd .. && \
    rm -rf guile-${GUILE_VERSION} guile-${GUILE_VERSION}.tar.gz
    
# Update dynamic linker run-time bindings
RUN ldconfig /usr/local/lib

# Install guile-json
RUN apk add --no-cache \
    git
RUN git clone https://github.com/aconchillo/guile-json.git && \
    cd guile-json && \
    autoreconf -vif && \
    ./configure && \
    make && \
    make install

# Install guile-gnutls
RUN apk add --no-cache \
    gnutls-dev
RUN git clone https://gitlab.com/gnutls/guile.git && \
    cd guile && \
    autoreconf -vif && \
    ./configure && \
    make && \
    make install

# Install guile-gcrypt
RUN apk add --no-cache \
    libgcrypt-dev 
RUN git clone https://notabug.org/cwebber/guile-gcrypt.git && \
    cd guile-gcrypt && \
    cp ../guile/m4/guile.m4 m4/guile.m4 && \
    autoreconf -vif && \
    ./configure && \
    make && \
    make install


FROM alpine:3.20 as main

# Copy Guile from the builder stage
COPY --from=builder /usr/local /usr/local

# Install runtime dependencies
RUN apk update && apk add --no-cache \
    libgcc \
    libstdc++ \
    libunistring \
    libffi \
    gc \
    gmp \
    readline \
    gnutls \
    libgcrypt \
    gettext

# Update dynamic linker run-time bindings
RUN ldconfig /usr/local/lib

# Set the default command to start an interactive Guile shell.
CMD ["guile"]
