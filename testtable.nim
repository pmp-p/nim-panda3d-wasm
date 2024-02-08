import std/os # getEnv
import std/tables

when defined(wasi):
    proc initialize(argc: cint, args: ptr UncheckedArray[cstring], env: ptr UncheckedArray[cstring]): int {.importc: "main".}

type
    t_callback* = proc (args: openArray[string]) : void {.gcsafe.}
    t_slot = Table[int, t_callback]
    t_callbacks = Table[string, t_slot]


proc proc_cb(args: openArray[string]) : void =
    echo "cb"

var cb = initTable[string, t_slot]()

when defined(nobug):
    var elem : t_slot


proc setup() : void {.exportC:"setup".} =
    when defined(wasi):
        discard initialize(0, nil,nil)
        echo "_initialized"
        discard

    # alloc something dynamic
    let cwd = getEnv("PWD","./")

    when not defined(nobug):
        var elem = initTable[int, t_callback]()
    else:
        elem = initTable[int, t_callback]()

    var intkey:int = 1
    var fnptr = elem.mgetOrPut( intkey , proc_cb )

    discard cb.mgetOrPut("string", elem )

    echo "setup:end"

when not defined(wasi):
    setup()
# else call with "wasmtime --dir / --invoke setup a.out.wasm"
