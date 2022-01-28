#! /bin/bash

HERE=${PWD}

git clone git@github.com:t2k-software/MaCh3.git
cd MaCh3
git checkout t2knova_24Mar2021
source setup_niwgrewight.sh

cd ${HERE}
git clone git@github.com:NVIDIA/cuda-samples.git
cd cuda-samples && git checkout v10.2

cd ${HERE}

sudo docker pull novaexperiment/nova-sl7-novat2k:2020-10-27_freeze

