#!/bin/bash
#
# This experimental build file exists for the purpose of creating "slim" builds
# of pandas et al that will fit inside the AWS LLambda 50 MB deployment package
# limit. 
#
# The idea of building everything at the same time is to ensure that numpy and
# scipy are using the same statically linked BLAS libraries. These can be
# de-duplicated subsequently.
#
# Run with:
#    docker run --rm -v $PWD:/io quay.io/pypa/manylinux2010_x86_64 /io/slim/build_pandas.sh

export PYTHON_VERSIONS=3.7
export NUMPY_VERSIONS=1.19.2 
export SCIPY_VERSIONS=1.5.2
export PANDAS_VERSIONS=1.1.3

### Configuration above ^^^

# These CFLAGS tell gcc to make the binaries as small on disk as possible.
# See https://towardsdatascience.com/how-to-shrink-numpy-scipy-pandas-and-matplotlib-for-your-data-product-4ec8d7e86ee4
export CFLAGS="-Os -g0 -Wl,--strip-all"

cd /io
./build_openblas.sh
./build_numpies.sh

export NUMPY_VERSION=${NUMPY_VERSIONS}
./build_scipies.sh
./build_pandas.sh
