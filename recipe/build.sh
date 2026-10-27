#!/bin/bash

set -ex

if [[ "$mpi" == "nompi" ]]; then
  on_mpi="OFF"
else
  on_mpi="ON"
fi

osx_args=()
if [[ "${target_platform}" == osx-* ]]; then
  # FindSalomePythonLibs looks for 'python-config' on APPLE
  osx_args+=(-DPYTHON_CONFIG_EXECUTABLE="${PREFIX}/bin/python3-config")
  # python extensions must not link libpython (the interpreter is static),
  # the python symbols are resolved when the module is loaded
  export LDFLAGS="${LDFLAGS} -Wl,-undefined,dynamic_lookup"
fi

 # Disable PTScotch because petsc is not built against int64
cmake  -B build . \
    -DCMAKE_BUILD_TYPE="Release" \
    -DPYTHON_ROOT_DIR="${PREFIX}" \
    -DPYTHON_EXECUTABLE:FILEPATH="$PYTHON" \
    -Wno-dev \
    -DCONFIGURATION_ROOT_DIR="${SRC_DIR}/deps/config" \
    -DSALOME_CMAKE_DEBUG=ON \
    -DMED_INT_IS_LONG=ON \
    -DSALOME_USE_MPI=${on_mpi} \
    -DMEDCOUPLING_BUILD_TESTS=OFF \
    -DMEDCOUPLING_BUILD_DOC=OFF \
    -DMEDCOUPLING_USE_64BIT_IDS=ON \
    -DMEDCOUPLING_USE_MPI=${on_mpi} \
    -DMEDCOUPLING_MEDLOADER_USE_XDR=OFF \
    -DXDR_INCLUDE_DIRS="" \
    -DMEDCOUPLING_PARTITIONER_PARMETIS=OFF \
    -DMEDCOUPLING_PARTITIONER_METIS=OFF \
    -DMEDCOUPLING_PARTITIONER_SCOTCH=OFF \
    -DMEDCOUPLING_PARTITIONER_PTSCOTCH=OFF \
    -DMPI_C_COMPILER:PATH="$(which mpicc)" \
    -DMPI_CXX_COMPILER:PATH="$(which mpicxx)" \
    "${osx_args[@]}" \
    ${CMAKE_ARGS}

cd build
make install -j$CPU_COUNT