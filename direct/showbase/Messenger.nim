import std/tables
import ../../panda3d/core

type
  DirectObject* = ref object of RootObj
    messengerId: int


type
    t_callback* = proc (args: openArray[EventParameter]) : void {.gcsafe, nimcall.}
    t_slots =  Table[int, t_callback]
    t_callbacks = Table[string, t_slots]

type
  Messenger* = ref object of RootObj
    callbacks: t_callbacks

var nextMessengerId = 1

var
    elem : t_slots # = t_slots() #initTable[int, t_callback]()
    cb : t_callbacks # = initTable[string, t_slots]()

proc accept*(this: Messenger, event: string, obj: DirectObject, function: t_callback) {.gcsafe, nimcall.} =
    if obj.messengerId == 0:
        obj.messengerId = nextMessengerId
        nextMessengerId += 1

    let intkey:int = obj.messengerId

    echo " ----------------- crash here with orc/arc ----------------------"
    echo "---- 1 -----"
    var nouse = elem.mgetOrPut(intkey, function)
    echo "---- 2 -----"
    discard cb.mgetOrPut(event, elem)
    echo "---- 3 -----"
    this.callbacks[event] = cb[event] # ORC infinite loop
    echo " ----------------- or not ----------------------"
    #acceptorDict[][obj.messengerId] = cast[t_callback](function)

proc accept*[T](this: Messenger, event: string, obj: DirectObject, function: proc (param: T)) =
  var acceptorDict = addr this.callbacks.mgetOrPut(event, Table[int, t_callback]())
  if obj.messengerId == 0:
    obj.messengerId = nextMessengerId
    nextMessengerId += 1

  acceptorDict[][obj.messengerId] = (t_callback = function(T.dcast(args[0].getPtr())))

proc ignore*(this: Messenger, event: string, obj: DirectObject) =
  if obj.messengerId == 0:
    return

  if this.callbacks.hasKey(event):
    this.callbacks[event].del(obj.messengerId)

proc ignoreAll*(this: Messenger, obj: DirectObject) =
  if obj.messengerId == 0:
    return

  for event in this.callbacks.keys():
    this.callbacks[event].del(obj.messengerId)

proc send*(this: Messenger, event: string, sentArgs: openArray[EventParameter] = []) =
  if this.callbacks.hasKey(event):
    var acceptorDict = this.callbacks.getOrDefault(event)
    for function in acceptorDict.values:
      function(sentArgs)
