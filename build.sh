reset
SDKROOT=${SDKROOT:-/opt/python-wasm-sdk}
export PATH=${SDKROOT}/nimsdk/Nim/bin:$PATH
WD=$(pwd)
echo "WD=$WD"

rm -v out.*

ARCH=$(arch)
EXE=out.${ARCH}

if ${CI:-false}
then
    echo "skipping native build"
else
    EXE=out.$ARCH
    LD_LIBRARY_PATH=/opt/python-wasm-sdk/devices/${ARCH}/usr/lib \
     PWD=$PWD nim --passL="-lpng -ljpeg $(pkg-config x11 --libs)" -r cpp $@

    if mv out.bmp out.$(arch).bmp
    then
        echo ok
    else
        echo "native build failed"
        #exit 1
    fi

    echo "


=====================================================================


"
fi


ARCH="wasisdk"
EXE=out.${ARCH}
. /opt/python-wasm-sdk/wasm32-wasi-shell.sh

nim -d:wasi -r cpp $@

echo
echo

if [ -f ${WD}/${EXE} ]
then
    WASMTIME_BACKTRACE_DETAILS=1 wasmtime --dir / --env PWD="$(realpath $PWD)" --invoke setup ${WD}/${EXE}
    mv out.bmp out.${ARCH}.bmp
else
    echo "

        BUILD FAILED


"
fi

du -hs out.*

#LD_LIBRARY_PATH=/opt/python-wasm-sdk/devices/x86_64/usr/lib64 ./${EXE}

# --opt:none

#  --incremental:on
# --exceptions:goto --genScript:on
# --passC="-m32 -fno-exceptions"
#  --opt:size
#    \
# --incremental:on
