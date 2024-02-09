import std/os # getEnv
import std/strformat
import std/tables


var
    # {.gcsafe, nimcall.}

    # initTable will crash

    table = initTable[string, Table[int, proc (args: openArray[string]) : void] ]()


when defined(wasi):
    proc initialize(argc: cint, args: ptr UncheckedArray[cstring], env: ptr UncheckedArray[cstring]): int {.importc: "main".}


proc setup() : void {.exportC:"setup".} =
    when defined(wasi):
        echo "_initialized"
        discard initialize(0,nil,nil)

    # alloc something dynamic
    # var cwd = getEnv("PWD","./")

    var
        tcb : Table[int, proc (args: openArray[string]) : void]

    echo "begin"
    tcb[1] = proc(args: openArray[string]) = discard

    var notused = table.mGetOrPut("hmm" , tcb )
    #echo fmt"{notused}"
    echo "end"

when not defined(wasi):
    setup()
