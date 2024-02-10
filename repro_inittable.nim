import std/strformat
import std/tables

var
    # initTable will crash on wasi
    table = initTable[string, Table[int, proc () : void] ]()
    # this will not
    # table : Table[string, Table[int, proc () : void] ]


proc renderAnimationFrame() : void {.exportC.} =

    var
        tcb : Table[int, proc () : void]
    echo "begin"
    tcb[1] = proc() = discard
    var notused = table.mGetOrPut("hmm" , tcb )
    echo "end"

    # CRASH HERE

when not defined(wasi):
    echo "native"
    while true:
        renderAnimationFrame()
else:
    echo "wasi"
    proc NimMain(): void {.cdecl, importc.}
    {.pragma: constructor, codegenDecl: "__attribute__((constructor)) $# $#$#", exportc.}
    proc wasm_call_ctors() {.exportc, constructor, cdecl.} = NimMain()

