#!/bin/bash



echo "Compiling CMAKE"
cd /tmp
wget https://github.com/Kitware/CMake/releases/download/v3.30.1/cmake-3.30.1.tar.gz
tar xfvz cmake-3.30.1.tar.gz && cd cmake-3.30.1 > /dev/null
./bootstrap && make -j$(nproc) && make install