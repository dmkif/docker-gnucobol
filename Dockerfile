FROM @@ARCH@@/debian:stable-backports
MAINTAINER Daniel Mulzer <daniel.mulzer@fau.de>
# Install packages necessary to build and run gnucobol
USER root

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install curl tar libncurses5-dev libgmp-dev libdb-dev && \
    apt-get -y autoremove && \
    apt-get -y clean && \ 
    rm -rf /var/lib/apt/lists/*
    

# Set the working directory to tmp
WORKDIR /tmp/

#download and install berkley-db in version 4.8
RUN apt-get update && \
    apt-get -y install build-essential && \
    curl -sLk https://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz | tar xz && \
    cd db-4.8.30.NC && \
    curl -sLk "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" > ./dist/config.sub && \
    curl -sLk "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" > ./dist/config.guess && cd build_unix && \
    ../dist/configure --enable-cxx --prefix=/usr && make install && make clean && \
    cd /tmp/ && \
    rm -rf * && \
    apt-get -y --purge autoremove build-essential && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*


# download and install open-cobol for depencies (libcob >= 4.0)
RUN apt-get update && \
    apt-get -y install autoconf build-essential && \
    curl -sLk https://sourceforge.net/projects/open-cobol/files/gnu-cobol/3.0/gnucobol-3.0-rc1.tar.gz | tar xz && \
    cd gnucobol-3.0-rc1 && ./configure --prefix=/usr && make && make install && ldconfig && cd /tmp/ && rm -rf * && \
    apt-get -y --purge autoremove build-essential && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on Fedora/RHEL,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r cobol -g 1000 && useradd -u 1000 -r -g cobol -m -d /home/cobol -s /bin/bash -c "Cobol user" cobol && \
    chmod 755 /home/cobol
USER cobol

WORKDIR /home/cobol
