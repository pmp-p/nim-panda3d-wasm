import ../panda3d/core

{.emit: """/*TYPESECTION*/
#include "asyncTask.h"

N_LIB_PRIVATE N_NIMCALL(void, unrefEnv)(void *envp);

class NimTask final : public AsyncTask {
public:
  typedef int TaskProc(PT(AsyncTask) task, void *env);

  NimTask(TaskProc *proc, void *env) : _proc(proc), _env(env) {}

  virtual ~NimTask() {
    if (_env != nullptr) {
      unrefEnv(_env);
    }
  }

  ALLOC_DELETED_CHAIN(NimTask);

  virtual DoneStatus do_task() {
    return (DoneStatus)_proc(this, _env);
  }

private:
  TaskProc *_proc;
  void *_env;
};
""".}

type
  Task* = AsyncTask

type
  DoneStatus {.pure.} = enum
    done = 0
    cont = 1
    again = 2
    pickup = 3
    exit = 4

template done*(_: typedesc[Task]): DoneStatus =
  DoneStatus.done

template cont*(_: typedesc[Task]): DoneStatus =
  DoneStatus.cont

template again*(_: typedesc[Task]): DoneStatus =
  DoneStatus.again

template pickup*(_: typedesc[Task]): DoneStatus =
  DoneStatus.pickup

template exit*(_: typedesc[Task]): DoneStatus =
  DoneStatus.exit

type
  TaskManager* = ref object of RootObj
    mgr: AsyncTaskManager
    running: bool

proc add*(this: TaskManager, function: (proc(task: Task): int), name: string, sort: int = 0) : AsyncTask {.discardable.} =
  var procp = rawProc(function);
  var envp = rawEnv(function);
  if envp != nil:
    GC_ref(cast[RootRef](envp))

  {.emit: """
  `result` = new NimTask((NimTask::TaskProc *)`procp`, `envp`);
  `this`->mgr->add(`result`.p());
  """.}

proc stop*(this: TaskManager) =
  this.running = false

proc run*(this: TaskManager) =
  this.running = true
  while this.running:
    this.mgr.poll()

var
    taskMgr* :TaskManager

proc init_taskMgr*()=
    if taskMgr != nil:
        echo "  87:taskMgr: not null"
    else:
        echo "  87:new taskMgr <<<<<<<===== "
        taskMgr = new(TaskManager)
    if taskMgr.mgr != nil:
        echo "  87:taskMgr.mgr: not null"
    else:
        echo "  87:new taskMgr.mgr <<<<<<<===== "
        taskMgr.mgr = AsyncTaskManager.getGlobalPtr()

init_taskMgr()

