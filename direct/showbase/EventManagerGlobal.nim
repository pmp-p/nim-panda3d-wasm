import ../../panda3d/core
import ./EventManager

var
    eventMgr* : EventManager


proc init_evmgr*()=
    echo "  8"
    if eventMgr != nil:
        echo "EventManager : not null"
    else:
        echo "new EventManager"
        eventMgr = EventManager(eventQueue: EventQueue.getGlobalEventQueue())
    echo "  15"


init_evmgr()
