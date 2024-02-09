import std/tables

var
    # initTable will crash on wasi
    table = initTable[string, Table[int, proc () : void] ]()
    # this will not
    # table : Table[string, Table[int, proc () : void] ]


when defined(wasi):
    proc initialize(argc: cint, args: ptr UncheckedArray[cstring], env: ptr UncheckedArray[cstring]): int {.importc: "main".}


proc setup() : void {.exportC:"setup".} =
    when defined(wasi):
        echo "_initialized"
        discard initialize(0,nil,nil)
    var
        tcb : Table[int, proc () : void]
    echo "begin"
    tcb[1] = proc() = discard
    var notused = table.mGetOrPut("hmm" , tcb )
    echo "end"

    # CRASH HERE

when not defined(wasi):
    setup()
