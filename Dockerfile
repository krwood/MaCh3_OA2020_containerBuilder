FROM picker24/mach3_t2knovadev:centos_7
RUN mkdir MaCh3
ADD ./MaCh3 /opt/MaCh3
ADD psychemaker.sh /opt

#Untar is automatic with ADD 

RUN yum install -y gsl-devel
RUN yum install -y flex
RUN yum install -y bison

ENV MACH3=/opt/MaCh3
RUN mkdir ${MACH3}/psycheinc \
 && mkdir ${MACH3}/psychestuff \
 && mkdir ${MACH3}/lib \
 && mkdir ${MACH3}/bin \
 && mkdir ${MACH3}/plots \
 && mkdir ${MACH3}/AtmJointFit_Bin 

#PSYCHEMODULES := Enviorment variable set in lukes package

RUN cp -r /opt/nd280/* ${MACH3}/psychestuff
RUN bash -c "source /opt/psychemaker.sh"
WORKDIR /opt/MaCh3
RUN cd ${MACH3}
RUN find psychestuff/psycheCore_3.42/inc/ -name "DataSample.hxx" -exec sed -i "s/#include <TreeManager.hxx>/#include \"TreeManager.hxx\"/g" \{} \; \
    && find psychestuff/psycheCore_3.42/inc/ -name "Header.hxx" -exec sed -i "s/#include <CoreDataClasses.hxx>/#include \"CoreDataClasses.hxx\"/g" \{} \; \
    && find psychestuff/psycheCore_3.42/inc/ -name "Header.hxx" -exec sed -i "s/#include <TChain.h>/#include \"TChain.h\"/g" \{} \;
RUN find . -name "Makefile" -exec sed -i "s/-Werror/-Werror -Wno-deprecated -Wno-return-type/g" \{} \;

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

RUN cd ${MACH3} && make all
#RUN cd ${MACH3} && make
# Create the CMD script
#ADD run.sh ${MACH3}
#RUN chmod +x ${MACH3}/run.sh

# ------------------------------------------------Mach3 part above
# LLikelyhood part

ENV MACH3_MC=~/inputs/NDMC


#CMD [ "/opt/MaCh3/run.sh" ]
