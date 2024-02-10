#!/bin/bash
reset
SDKROOT=${SDKROOT:-/opt/python-wasm-sdk}
pushd $SDKROOT
    . ${CONFIG:-config}
popd

WD=$(pwd)
echo "WD=$WD"

rm -v out.*

ARCH=$(arch)
EXE=out.${ARCH}

mkdir -p ${SDKROOT}/src

if ${CI:-false}
then
    echo "skipping native build"
else

    if [ -d ${SDKROOT}/build/panda3d-host ]
    then
        echo "
        Panda3D ${ARCH} already built
"
    else
        mkdir ${SDKROOT}/build/panda3d-host
        pushd ${SDKROOT}/build/panda3d-host
        if [ -d ${SDKROOT}/src/panda3d ]
        then
            echo "
        Panda3D source found
"
        else
            pushd ${SDKROOT}/src
            #$GITGET webgl-port https://github.com/pmp-p/panda3d panda3d
            $GITGET master https://github.com/panda3d/panda3d panda3d
            popd
        fi

        chmod +x cmake-builds.sh

        mv -vf ${WD}/cmake-builds.sh ${SDKROOT}/src/panda3d/
        ${SDKROOT}/src/panda3d/cmake-builds.sh host
        popd
    fi

    EXE=out.$ARCH
    LD_LIBRARY_PATH=/opt/python-wasm-sdk/devices/${ARCH}/usr/lib \
     PWD=$WD nim --passL="-lpng -ljpeg $(pkg-config x11 --libs)" -r cpp $@

    if mv out.bmp out.$(arch).bmp
    then
        echo ok
    else
        echo "native build failed"
    fi

    echo "

=====================================================================

"
fi


ARCH="wasisdk"

if [ -d ${SDKROOT}/build/panda3d-wasisdk ]
then
    echo "
        Panda3D ${ARCH} already built
"
else
    mkdir ${SDKROOT}/build/panda3d-wasisdk
    pushd ${SDKROOT}/build/panda3d-wasisdk
    if [ -d ${SDKROOT}/src/panda3d ]
    then
        echo "
        Panda3D source found
"
    else
        pushd ${SDKROOT}/src
        $GITGET master https://github.com/panda3d/panda3d panda3d
        popd
        mv -vf ${WD}/cmake-builds.sh ${SDKROOT}/src/panda3d/
    fi

    ${SDKROOT}/src/panda3d/cmake-builds.sh
    popd
fi

. $NIMSDK/nimsdk_env.sh


EXE=out.${ARCH}

nim -d:wasi -r cpp $@

# --incremental:on
# --exceptions:goto --genScript:on
# --passC="-m32 -fno-exceptions"
#  --opt:size

echo
echo

if [ -f ${WD}/${EXE} ]
then
    WASMTIME_BACKTRACE_DETAILS=1 wasmtime --dir / --env PWD="$(realpath $PWD)" --invoke renderAnimationFrame ${WD}/${EXE}
    mv out.bmp out.${ARCH}.bmp
else
    echo "

        BUILD FAILED

"
fi

du -hs out.*




