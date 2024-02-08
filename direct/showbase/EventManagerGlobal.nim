import ../../panda3d/core
import ./EventManager

var
    eventMgr* : EventManager


proc init_evmgr*()=
    echo "  9:begin // EventManagerGlobal"
    if eventMgr != nil:
        echo "  9:EventManager : not null"
    else:
        echo "  9:new EventManager <<<<<======"
        eventMgr = EventManager(eventQueue: EventQueue.getGlobalEventQueue())
    if eventMgr.eventQueue != nil:
        echo "  9:eventMgr.eventQueue : not null"
    echo "  9:end // EventManagerGlobal"


init_evmgr()
