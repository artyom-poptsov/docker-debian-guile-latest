### Dockerfile for a Debian distribution with the latest stable GNU
### Guile version.

FROM debian:latest
MAINTAINER Artyom V. Poptsov <poptsov.artyom@gmail.com>

RUN apt-get update -qq && apt-get -qqy install \
    autoconf \
    automake \
    make \
    gcc \
    g++ \
    libtool \
    gettext \
    texinfo \
    flex \
    pkg-config \
    libgmp-dev \
    libunistring-dev \
    libffi-dev \
    libatomic-ops-dev \
    git

RUN useradd -ms /bin/bash guile-user
RUN echo 'guile-user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN [ -d /home/guile-user/src/dist/ ] || mkdir -p /home/guile-user/src/dist/

WORKDIR /home/guile-user/src/dist/


### Install Boehm GC needed for GNU Guile.

RUN git clone https://github.com/ivmai/bdwgc.git
WORKDIR /home/guile-user/src/dist/bdwgc/
RUN git checkout gc7_6_0
RUN ./autogen.sh
RUN ./configure --prefix=/usr
RUN make install


### Install the latest GNU Guile version.

WORKDIR /home/guile-user/src/dist/

# Clone the  Guile repository.
RUN git clone git://git.sv.gnu.org/guile.git

WORKDIR /home/guile-user/src/dist/guile

RUN autoreconf \
    --verbose \
    --install \
    --force
RUN ./configure
RUN make
RUN make \install

### Clone the Guile-SSH repository.

WORKDIR /home/guile-user/src/dist/

# Pull the Guile-SSH repository.
RUN git clone https://github.com/artyom-poptsov/guile-ssh.git

### Dockerfile ends here.
