### Dockerfile for a Debian distribution with the latest stable GNU
### Guile version.

FROM debian:latest
MAINTAINER Artyom V. Poptsov <poptsov.artyom@gmail.com>


### Install basic packages.

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


### Install the latest libssh version.

RUN apt-get -qqy install cmake libssl-dev
WORKDIR /home/guile-user/src/dist/
RUN git clone https://git.libssh.org/projects/libssh.git libssh
RUN [ -d ./libssh/build ] || mkdir -p ./libssh/build
WORKDIR /home/guile-user/src/dist/libssh/build
RUN git checkout libssh-0.7.3
RUN cmake ../
RUN make
RUN make install


### Clone the Guile-SSH repository.

WORKDIR /home/guile-user/src/dist/

# Pull the Guile-SSH repository.
RUN git clone https://github.com/artyom-poptsov/guile-ssh.git
WORKDIR /home/guile-user/src/dist/guile-ssh/
RUN autoreconf -vif
RUN ./configure
RUN LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):/usr/local/lib make
RUN make \install

RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/usr-local.conf
RUN ldconfig


### This image would be unfinished without GNU Emacs.

RUN apt-get install -qqy emacs-nox


### Go back to the home dir.

WORKDIR /home/guile-user/

### Dockerfile ends here.
