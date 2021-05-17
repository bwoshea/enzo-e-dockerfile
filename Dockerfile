FROM ubuntu:20.10
MAINTAINER  Brian O'Shea, bwoshea@gmail.com

# Install a bunch of packages we need, including everything for Charm++, Grackle, and Enzo-E
# It will also install vim so you have a text editor to work with!
RUN apt-get update
RUN apt-get install -y wget bc csh libhdf5-serial-dev gfortran libtool-bin \
   libpapi-dev libpng-dev zlib1g-dev libboost-all-dev python3 git python3-venv \
   build-essential vim

# Set up environmental variables we're going to need
# Note that CELLO_PREC can be set to 'single' or 'double'
ENV USER_HOME /root
ENV CHARM_VER 6.10.2
ENV CELLO_ARCH linux_gnu
ENV CELLO_PREC single 
ENV LD_LIBRARY_PATH $USER_HOME/local/lib:$LD_LIBRARY_PATH
ENV CHARM_ARGS ++local
ENV HDF5_INC /usr/include/hdf5/serial
ENV HDF5_LIB /usr/lib/x86_64-linux-gnu
ENV CHARM_HOME $USER_HOME/local/charm-v$CHARM_VER
ENV GRACKLE_HOME $USER_HOME/local
ENV VIRTUAL_ENVIRONMENT $USER_HOME/venv

# Soft links so Grackle and Enzo-E can find HDF5
RUN ln -s /usr/lib/x86_64-linux-gnu/libhdf5_serial.so /usr/lib/x86_64-linux-gnu/libhdf5.so

# Set up python 3 virtual environment and add it to the path
RUN python3 -m venv $VIRTUAL_ENVIRONMENT
ENV PATH $VIRTUAL_ENVIRONMENT/bin:$PATH

# Upgrade pip and then install SCons (needed for Enzo-E)
RUN pip install --upgrade pip
RUN pip install scons

# make our working directory 
RUN mkdir -p $USER_HOME/local 

# make charm++
RUN cd $USER_HOME/local ; \
    wget http://charm.cs.illinois.edu/distrib/charm-$CHARM_VER.tar.gz $USER_HOME/local/.; \
    tar xvfz charm-$CHARM_VER.tar.gz ; \
    cd charm-v$CHARM_VER ; \
    ./build charm++ netlrts-linux-x86_64 -j4 --with-production

# make grackle (master branch)
RUN cd $USER_HOME ; \
    git clone -b master https://github.com/grackle-project/grackle $USER_HOME/grackle ; \
    cd $USER_HOME/grackle ; \
    ./configure ; \
    cd src/clib ; \
    make machine-linux-gnu ; \
    make ; \
    make install

# make Enzo-E (master branch)
RUN cd $USER_HOME; \
    git clone -b master https://github.com/enzo-project/enzo-e ; \
    cd enzo-e ; \
    make



