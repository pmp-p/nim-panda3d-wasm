import std/strformat  # fmt

import ./Messenger
import ./MessengerGlobal

export Messenger.DirectObject

proc accept*(this: DirectObject, event: string, function: t_callback) =
  messenger.accept(event, this, function)

#proc accept*(this: DirectObject, event: string, function: proc ()) =
#  messenger.accept(event, this, function)

#proc accept*[T](this: DirectObject, event: string, function: proc (param: T)) =
#  messenger.accept(event, this, function)

proc ignore*(this: DirectObject, event: string) =
  messenger.ignore(event, this)

proc ignoreAll*(this: DirectObject) =
  messenger.ignoreAll(this)

proc send*(this: DirectObject, event: string) =
    echo fmt"@@@@@@@@@@ DirectObject: sending {event=}"
    messenger.send(event, [])


