#!/bin/bash
set -e

# Manylinux, openblas version, lex_ver
source /io/common_vars.sh

if [ -z "$SCIKIT_IMAGE_VERSIONS" ]; then
    SCIKIT_IMAGE_VERSIONS="0.12.3"
fi

CYTHON_VERSION=0.23.4

# Install blas
get_blas

get_freetype

# Directory to store wheels
rm_mkdir unfixed_wheels

# Compile wheels
for PYTHON in ${PYTHON_VERSIONS}; do
    PIP="$(cpython_path $PYTHON)/bin/pip"
    for SCIKIT_IMAGE in ${SCIKIT_IMAGE_VERSIONS}; do
        if [ $(lex_ver $PYTHON) -ge $(lex_ver 3.5) ] ; then
            NUMPY_VERSION=1.9.1
        else
            NUMPY_VERSION=1.7.2
        fi
        echo "Building scikit-image $SCIKIT_IMAGE for Python $PYTHON"
        # Put numpy and scipy into the wheelhouse to avoid rebuilding
        $PIP wheel -f $WHEELHOUSE -f $MANYLINUX_URL -w tmp \
            "numpy==$NUMPY_VERSION" "scipy==$SCIPY_VERSION"
        $PIP install -f tmp "numpy==$NUMPY_VERSION" "scipy"
        # Add numpy and scipy  to requirements to avoid upgrading
        $PIP wheel -f tmp -w unfixed_wheels "numpy==$NUMPY_VERSION" \
            "scipy==$SCIPY_VERSION" "scikit-image==$SCIKIT_IMAGE"
    done
done

# Bundle external shared libraries into the wheels
repair_wheelhouse unfixed_wheels $WHEELHOUSE