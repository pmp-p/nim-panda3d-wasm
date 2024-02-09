import std/strformat

var ARCH="x86_64"
var SDKROOT = getEnv("SDKROOT","/opt/python-wasm-sdk")

# not used anymore
# -d:usemalloc

# gc : bohem => need libgc.so.1

--colors:on
--threads:off

echo fmt" ==== Panda3D: generic config {ARCH=} from {SDKROOT=} ===="
--cc:clang
--os:linux

--noCppExceptions
--define:noCppExceptions
--exceptions:quirky
--gc:refc
--define:usemalloc
--define:noSignalHandler

#
--define:static

# better debug but optionnal/tweakable
--parallelBuild:1
--opt:speed
--define:debug

when defined(wasi):
    echo "  ===== Panda3D: wasi build ======"
    # overwrite
    ARCH="wasisdk"

    # needed for compiler
    --cc:clang
    --os:linux

    --define:emscripten
    --define:static

    --cpu:wasm32
    switch("clibdir", fmt"{SDKROOT}/devices/{ARCH}/usr/lib/wasm32-wasi")
    switch("passC", fmt"-m32 -mllvm -inline-threshold=1 -O0 -g3 -Djmp_buf=int")

    switch("passL","-lstdc++")


    # more compat but in the long term fix Panda3D instead
    switch("passC", "-D_GNU_SOURCE -D_WASI_EMULATED_MMAN -D_WASI_EMULATED_SIGNAL -D_WASI_EMULATED_PROCESS_CLOCKS -D_WASI_EMULATED_GETPID")
    switch("passL", "-lwasi-emulated-getpid -lwasi-emulated-mman -lwasi-emulated-signal -lwasi-emulated-process-clocks")

    # don't use _start/main but _initialize instead
    switch("passL", "-Wl,--export-all -mexec-model=reactor")


    # better debug but optionnal/tweakable
    --parallelBuild:1
    --opt:none
else:
    echo fmt"  ===== Panda3D: native {ARCH} build ======"
    switch("passL", "-lfreetype -lharfbuzz")
    # -lfftw3 -lassimp")

# static
switch("passL", "-lp3tinydisplay")
# common
switch("passL", "-lc -lz")

# only for script gen which does not pass cincludes
# --passC:-I/opt/python-wasm-sdk/devices/${ARCH}/usr/include/panda3d


switch("nimcache", fmt"{SDKROOT}/nimsdk/cache.{ARCH}")
switch("clibdir", fmt"{SDKROOT}/devices/{ARCH}/usr/lib")
switch("cincludes", fmt"{SDKROOT}/devices/{ARCH}/usr/include/panda3d")

switch("out", fmt"out.{ARCH}")

