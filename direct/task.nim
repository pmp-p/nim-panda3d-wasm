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

    TDoneStatus* {.pure.} = enum
        done = 0
        cont = 1
        again = 2
        pickup = 3
        exit = 4

    t_callback = proc(task: Task): TDoneStatus


template done*(_: typedesc[Task]): TDoneStatus =
  TDoneStatus.done

template cont*(_: typedesc[Task]): TDoneStatus =
  TDoneStatus.cont

template again*(_: typedesc[Task]): TDoneStatus =
  TDoneStatus.again

template pickup*(_: typedesc[Task]): TDoneStatus =
  TDoneStatus.pickup

template exit*(_: typedesc[Task]): TDoneStatus =
  TDoneStatus.exit

type
  TaskManager* = ref object of RootObj
    mgr: AsyncTaskManager
    running: bool

proc add*(this: TaskManager, function: t_callback, name: string, sort: int) : Task {.discardable.} =
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

var taskMgr* = new(TaskManager)
taskMgr.mgr = AsyncTaskManager.getGlobalPtr()

