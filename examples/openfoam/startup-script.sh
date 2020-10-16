#!/bin/bash

INSTALL_ROOT="/usr/local"
OPENMPI_VERSION="v4.0.5"

## Install the GCC-9 devtoolset
yum -y update
yum install -y centos-release-scl-rh
yum install -y devtoolset-9-toolchain
source /opt/rh/devtoolset-9/enable

## Install additional dependencies
yum install -y flex bison zlib-devel boost-devel ncurses-devel libXt-devel

## Install CMake 3.18.4
wget https://github.com/Kitware/CMake/releases/download/v3.18.4/cmake-3.18.4.tar.gz --directory-prefix=/tmp
cd /tmp
tar -xvzf cmake-3.18.4.tar.gz
cd /tmp/cmake-3.18.4
./bootstrap --prefix=${INSTALL_ROOT}/cmake
make -j 8
make install

## Install OpenMPI
git clone --depth 1 -b ${OPENMPI_VERSION} https://github.com/open-mpi/ompi.git /tmp/ompi
cd /tmp/ompi
./autogen.pl
./configure --prefix=${INSTALL_ROOT}/openmpi
make -j
make install
cat > /etc/profile.d/openmpi.sh <<EOL
#!/bin/bash

export PATH=\${PATH}:${INSTALL_ROOT}/openmpi/bin
export PATH=\${PATH}:${INSTALL_ROOT}/openmpi/include
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:${INSTALL_ROOT}/openmpi/lib

export MPICXX=${INSTALL_ROOT}/openmpi/bin/mpic++
export MPICC=${INSTALL_ROOT}/openmpi/bin/mpicc
export MPIFC=${INSTALL_ROOT}/openmpi/bin/mpif90
export MPIEXEC=${INSTALL_ROOT}/openmpi/bin/mpiexec

source /opt/rh/devtoolset-9/enable
EOL

source /etc/profile.d/openmpi.sh


## Install OpenFoam-Dev

git clone --depth 1 https://github.com/OpenFOAM/OpenFOAM-dev.git ${INSTALL_ROOT}/openfoam/OpenFOAM-dev
git clone --depth 1 https://github.com/OpenFOAM/ThirdParty-dev.git ${INSTALL_ROOT}/openfoam/ThirdParty-dev

# Link MPI compilers
ln -s ${INSTALL_ROOT}/openmpi/mpicc ${INSTALL_ROOT}/openfoam/OpenFOAM-dev/bin/mpicc
ln -s ${INSTALL_ROOT}/openmpi/mpirun ${INSTALL_ROOT}/openfoam/OpenFOAM-dev/bin/mpirun

# Install Third Party dependencies
cd ${INSTALL_ROOT}/openfoam/ThirdParty-dev
./Allwmake
wmRefresh

# Install OpenFOAM
cd ${INSTALL_ROOT}/openfoam/OpenFOAM-dev
./Allwmake -j

cat > /etc/profile.d/openfoam.sh <<EOL
#!/bin/bash
export PATH=\${PATH}:${INSTALL_ROOT}/openfoam/OpenFOAM-dev/bin
source ${INSTALL_ROOT}/openfoam/OpenFOAM-dev/etc/bashrc
EOL
