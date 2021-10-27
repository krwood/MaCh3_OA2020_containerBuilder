FROM nvidia/cuda:10.2-devel-centos7

ENV CUDAPATH=/usr/local/cuda

ENV DEBIAN_FRONTEND noninteractive

RUN mkdir MaCh3
ADD ./MaCh3 /opt/MaCh3

# the base container provided by nvidia doesn't include some include
# files (needed by MaCh3) for some reason... pulling them in manually:
RUN mkdir -p /usr/local/cuda/samples/common/
ADD ./cuda-samples/Common /usr/local/cuda/samples/common/inc
ENV MACH3 /opt/MaCh3

RUN yum -y install wget \
 && yum -y install dnf-plugins-core \
 && yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && yum -y update \
 && yum -y group install "Development Tools" \
 ## Needed for the old configure ROOT build
 && yum -y install file \
 && yum -y install tar \
 ## ROOT deps
 && yum -y install git \
 && yum -y install cmake3 \
 && yum -y install gcc-c++ \
 && yum -y install gcc \
 && yum -y install binutils \
 && yum -y install libX11-devel \
 && yum -y install libXpm-devel \
 && yum -y install libXft-devel \
 && yum -y install libXext-devel \
 && yum -y install openssl-devel \
 ## ROOT optional deps
 && yum -y install gcc-gfortran \
 && yum -y install pcre-devel \
 && yum -y install mesa-libGL-devel \
 && yum -y install mesa-libGLU-devel \
 && yum -y install glew-devel \
 && yum -y install ftgl-devel \
 && yum -y install mysql-devel \
 && yum -y install fftw-devel \
 && yum -y install cfitsio-devel \
 && yum -y install graphviz-devel \
 && yum -y install avahi-compat-libdns_sd-devel \
 && yum -y install openldap-devel \
 && yum -y install python2-devel \
 && yum -y install libxml2-devel \
 && yum -y install gsl-devel \
 && yum -y install imake \
 && yum -y install openssh-clients \
 && yum -y install procmail \
 && yum -y install patch \
 && yum -y install make \
 && yum -y install libdrm-devel \
 && yum -y install ncurses-devel \
 && yum -y install openmotif \
 ## Required by the packages used downstream (some gotchas here)
 && yum -y install which \
 && yum -y install cmake \
 && yum -y install ed \
 && yum -y install automake \
 && yum -y install perl \
 && yum -y install libXt-devel \
 && yum -y install openmotif-devel \
 && yum -y install csh

## Get a copy of ROOT
RUN wget https://root.cern.ch/download/root_v5.34.36.source.tar.gz \
 && tar -zxvf root_v5.34.36.source.tar.gz \
 && rm root_v5.34.36.source.tar.gz

## Now build root
RUN cd root \
 && ./configure --enable-minuit2 --enable-python --enable-roofit --disable-x11 --disable-mysql \
  --with-python-incdir=/usr/include/python2.7/ --with-python-libdir=/usr/lib64/ \
 && make -j 8

ENV ROOTSYS=/root
ENV PATH=/root/bin:$PATH
ENV LD_LIBRARY_PATH=/root/lib:$LD_LIBRARY_PATH
ENV LIBPATH=/root/lib

# Now build MaCh3
#RUN cd ${ROOTSYS}; source bin/thisroot.sh
# && cd ${MACH3} \
# && find . -name "Makefile" -exec sed -i "s/-Werror/-Werror -Wno-deprecated -Wno-return-type/g" \{} \;

RUN find ${MACH3}/configs/ -name "SK*2020.cfg" -exec sed -i "s/inputs\/SK_19b_13av7_/~\/inputs\/SK_19b_13av7_/g" \{} \;

#Setting important env variables
ENV MULTITHREAD=1
ENV OMP_NUM_THREADS=8

# For T2K-NOvA running
#ENV EXTLLHDIR=${MACH3}/PackagedLikelihood/DummyLLH 
#ENV MAKEPACKAGED=true 

ENV LD_LIBRARY_PATH=${MACH3}/lib:${MACH3}/NIWGReWeight:${MACH3}/PackagedLikelihood/DummyLLH/lib:${LD_LIBRARY_PATH}

ENV NIWG=${MACH3}/NIWGReWeight
ENV PATH=${NIWG}/app:${MACH3}/bin:${PATH}

RUN cd /opt/MaCh3/NIWGReWeight && make

#RUN cd ${MACH3} && make all
RUN cd ${MACH3} && make
# Create the CMD script
#ADD run.sh ${MACH3}
#RUN chmod +x ${MACH3}/run.sh

ENV MACH3_MC=~/inputs/NDMC



