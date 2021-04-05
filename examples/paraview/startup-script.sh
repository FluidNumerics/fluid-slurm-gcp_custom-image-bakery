#!/bin/bash

INSTALL_ROOT="/usr/local"
OPENMPI_VERSION="v4.0.5"
PARAVIEW_VERSION="v5.9.0"

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

export PATH=${PATH}:${INSTALL_ROOT}/openmpi/bin
export PATH=${PATH}:${INSTALL_ROOT}/openmpi/include
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${INSTALL_ROOT}/openmpi/lib
export MPICXX=${INSTALL_ROOT}/openmpi/bin/mpic++
export MPICC=${INSTALL_ROOT}/openmpi/bin/mpicc
export MPIFC=${INSTALL_ROOT}/openmpi/bin/mpif90
export MPIEXEC=${INSTALL_ROOT}/openmpi/bin/mpiexec

# Install additional dependencies
yum install -y python3-devel curl-devel epel-release \
               git-core chrpath libtool make which \
               libX11-devel libXdamage-devel libXext-devel libXt-devel libXi-devel \
               libxcb-devel xorg-x11-xtrans-devel libXcursor-devel libXft-devel \
               libXinerama-devel libXrandr-devel libXrender-devel libxkbcommon-x11 \
               mesa-libGL-devel mesa-libGLU-devel mesa-dri-drivers libglvnd-gles


# Install Ninja 1.10.1
wget https://github.com/ninja-build/ninja/releases/download/v1.10.1/ninja-linux.zip --directory-prefix=/tmp
cd /tmp
unzip ninja-linux.zip
mv ninja /usr/bin/
ln -s /usr/bin/ninja /usr/bin/ninja-build


## Install Paraview via Paraview-Superbuild
mkdir -p ${INSTALL_ROOT}/paraview
git clone --recursive --branch ${PARAVIEW_VERSION} --depth 1 https://gitlab.kitware.com/paraview/paraview-superbuild.git ${INSTALL_ROOT}/paraview/paraview-superbuild
cd ${INSTALL_ROOT}/paraview

${INSTALL_ROOT}/cmake/bin/cmake -GNinja \
                                -Dsuperbuild_download_location="${INSTALL_ROOT}/paraview/dependencies" \
                                -Dparaview_FROM_GIT=ON \
                                -Dparaview_FROM_SOURCE_DIR=OFF \
                                -DSUPERBUILD_PROJECT_PARALLELISM=8 \
                                -DENABLE_python2=OFF \
                                -DENABLE_python3=ON \
                                -DBUILD_TESTING=OFF \
                                -DCMAKE_BUILD_TYPE=Release \
                                -DBUILD_SHARED_LIBS=ON \
                                -DENABLE_boost=ON \
                                -DENABLE_ffmpeg=OFF \
                                -DENABLE_fontconfig=ON \
                                -DENABLE_matplotlib=ON \
                                -DENABLE_mpi=ON \
                                -DMPI_CXX_COMPILER=${MPICXX} \
                                -DMPI_C_COMPILER=${MPICC}  \
                                -DMPI_Fortran_COMPILER=${MPIFC} \
                                -DMPIEXEC_EXECUTABLE=${MPIEXEC} \
                                -DENABLE_netcdf=ON \
                                -DENABLE_numpy=ON \
                                -DENABLE_paraview=ON \
                                -DENABLE_python=ON \
                                -DENABLE_qt5=OFF \
                                -DENABLE_osmesa=ON \
                                -DENABLE_scipy=ON \
                                -DENABLE_tbb=ON \
                                -DENABLE_zfp=ON \
                                -DPARAVIEW_DEFAULT_SYSTEM_GL=ON \
                                -DUSE_NONFREE_COMPONENTS=ON \
                                -DENABLE_adios2=ON \
                                -DENABLE_cosmotools=ON \
                                -DENABLE_las=ON \
                                -DENABLE_mesa=OFF \
                                -DENABLE_mili=ON \
                                -DENABLE_nvidiaindex=ON \
                                -DENABLE_ospray=ON \
                                -DENABLE_paraviewweb=OFF \
                                -DENABLE_silo=ON \
                                -DENABLE_visitbridge=ON \
                                -DENABLE_vortexfinder2=ON \
                                -DENABLE_vrpn=ON \
                                -DENABLE_vtkm=ON \
                                -DENABLE_xdmf3=ON \
                                -DCMAKE_INSTALL_PREFIX="${INSTALL_ROOT}/paraview" \
                                ${INSTALL_ROOT}/paraview/paraview-superbuild

ninja
ninja


cat > /etc/profile.d/paraview.sh <<EOL
#!/bin/bash
export PATH=\${PATH}:${INSTALL_ROOT}/paraview/install/bin
export PATH=\${PATH}:${INSTALL_ROOT}/openmpi/bin
export PATH=\${PATH}:${INSTALL_ROOT}/openmpi/include
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:${INSTALL_ROOT}/openmpi/lib

export MPICXX=${INSTALL_ROOT}/openmpi/bin/mpic++
export MPICC=${INSTALL_ROOT}/openmpi/bin/mpicc
export MPIFC=${INSTALL_ROOT}/openmpi/bin/mpif90
export MPIEXEC=${INSTALL_ROOT}/openmpi/bin/mpiexec

source /opt/rh/devtoolset-9/enable
EOL
