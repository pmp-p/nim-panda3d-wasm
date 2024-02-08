import ../../panda3d/core
import ../task
import ./Messenger
import ./MessengerGlobal

type
  EventManager* = ref object of RootObj
    eventQueue*: EventQueue

proc doEvents*(this: EventManager) =
  while not this.eventQueue.isQueueEmpty():
    var event = this.eventQueue.dequeueEvent()
    var numParams = event.getNumParameters()
    var parameters = newSeq[EventParameter](numParams)

    for i in 0..numParams-1:
      parameters[i] = event.getParameter(i)

    messenger.send(event.name, parameters)

proc eventLoopTask(this: EventManager, task: Task): auto =
  this.doEvents()
  return Task.cont

var
    hold_evmgr : EventManager

proc evltask*(task: Task): int =
    return 1

proc restart*(this: EventManager) =
    echo "  26:begin // EventManager"
    task.init_taskMgr()
    echo "  26:taskMgr.add"
    hold_evmgr = this
    when defined(wasi):
        echo "@@@@@@@@@ SKIPPING taskMgr.add(evltask, 'eventManager') @@@@@@@@"
    else:
        taskMgr.add(evltask, "eventManager")

    echo "  26:end // EventManager"

