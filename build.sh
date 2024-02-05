reset
SDKROOT=${SDKROOT:-/opt/python-wasm-sdk}
WD=$(pwd)
echo "WD=$WD"

rm -v out.*

LDP3D="-lfreetype -lharfbuzz -lfftw3 -lc -lz"

ARCH=$(arch)
EXE=out.$ARCH
LDP3D_BASE="-lfreetype -lharfbuzz -lfftw3 -lc -lz"
LDP3D="$LDP3D_BASE -lpng -ljpeg $(pkg-config x11 --libs)"
LD_LIBRARY_PATH=/opt/python-wasm-sdk/devices/x86_64/usr/lib \
 Nim/bin/nim \
 -d:release --colors:on --nimcache:${SDKROOT}/nimsdk/cache.$ARCH \
 --mm:orc --define:noSignalHandler \
 --threads:off -d=usemalloc -d:static \
 --cc:clang --os:linux \
 --clibdir:/opt/python-wasm-sdk/devices/${ARCH}/usr/lib \
 --cincludes:/opt/python-wasm-sdk/devices/${ARCH}/usr/include/panda3d \
 --parallelBuild:1 \
 --noCppExceptions --exceptions:quirky -d:noCppExceptions \
 --opt:size -d:release \
 --passC="-I/opt/python-wasm-sdk/devices/${ARCH}/usr/include/panda3d" --passL="$LDFLAGS $NOMAIN $LDP3D"  -r --out:${EXE} cpp $@

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



EXE=out.wasm

LDP3D="$LDP3D_BASE"
LDFLAGS="-lstdc++ -lwasi-emulated-getpid -lwasi-emulated-mman -lwasi-emulated-signal -lwasi-emulated-process-clocks"
NOMAIN="-Wl,--export-all -mexec-model=reactor"
. /opt/python-wasm-sdk/wasm32-wasi-shell.sh
ARCH=wasisdk
Nim/bin/nim \
 -d:release --colors:on --nimcache:${SDKROOT}/nimsdk/cache.$ARCH \
 --mm:orc --define:noSignalHandler \
 --threads:off -d=usemalloc -d:static \
 --cc:clang --cpu:wasm32 --os:linux \
 -d:emscripten -d:wasi \
 --clibdir:/opt/python-wasm-sdk/devices/${ARCH}/usr/lib \
 --clibdir:/opt/python-wasm-sdk/devices/${ARCH}/usr/lib/wasm32-wasi \
 --cincludes:/opt/python-wasm-sdk/devices/${ARCH}/usr/include/panda3d \
 --parallelBuild:1 \
 --noCppExceptions --exceptions:quirky -d:noCppExceptions \
 --opt:none -d:release \
 --passC="-m32 -Djmp_buf=int -I/opt/python-wasm-sdk/devices/wasisdk/usr/include/panda3d" --passL="-m32 $LDFLAGS $NOMAIN $LDP3D"  -r  --out:${EXE} cpp $@

echo
echo

if [ -f ${WD}/${EXE} ]
then
    WASMTIME_BACKTRACE_DETAILS=1 wasmtime --dir / --invoke setup ${WD}/${EXE}
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
