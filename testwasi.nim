
# Panda3D compiled with python-wasm-sdk wasi env.
#    ${SDKROOT}/devices/x86_64/usr/bin/cmake ${SRCDIR} \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DHAVE_THREADS=NO \
#     -DHAVE_EGL=NO -DHAVE_GL=NO -DHAVE_GLX=NO -DHAVE_X11=NO -DHAVE_GLES1=NO -DHAVE_GLES2=NO \
#     -DHAVE_OPENSSL=NO \
# -DHAVE_AUDIO=1 -DHAVE_PYTHON=0\
# -DHAVE_OPUS=NO \
#     -DHAVE_HARFBUZZ=NO -DHAVE_FREETYPE=NO \
#     -DPHAVE_IOSTREAM=1 -DHAVE_TINYDISPLAY=1 -DHAVE_TIFF=NO  \
#    \
#    -DCMAKE_SYSTEM_NAME=WASI \
#    -DWASISDK=${SDKROOT}/wasisdk \
#    -DWASI_SDK_PREFIX=${WASI_SDK_PREFIX} \
#    \
#     -DHAVE_NET=NO -DWANT_NATIVE_NET=NO -DDO_PSTATS=NO \
#     -DHAVE_PYTHON=NO -DZLIB_ROOT=${WASI_SYSROOT} \
#    \
#     -DHOST_PATH_PZIP=/opt/python-wasm-sdk/build/panda3d-host/bin/pzip \
#     -DCMAKE_INSTALL_PREFIX=${PREFIX} \
#

import std/os # getEnv
import std/strformat  # fmt
import std/math

import panda3d/core
import direct/showbase
import direct/task
import direct/actor
import direct/interval



when not defined(wasi):
    import std/posix



var
    base* : ShowBase
    True = true
    False = false

proc spin_cam(t:float) : void =
  var angleDegrees = t * 6.0
  var angleRadians = angleDegrees * (PI / 180.0)
  base.camera.setPos(20 * sin(angleRadians), -20 * cos(angleRadians), 3)
  base.camera.setHpr(angleDegrees, 0, 0)


proc spinCameraTask(task: Task): auto =
    spin_cam(task.time)
    return Task.cont


when defined(wasi):
    proc initialize(argc: cint, args: ptr UncheckedArray[cstring], env: ptr UncheckedArray[cstring]): int {.importc: "main".}

proc setup() : void {.exportC:"setup".} =
    when defined(wasi):
        discard initialize(0, nil,nil)
        echo "_initialized"
        discard

    var
        cwd = getEnv("PWD","./")

    base = ShowBase()

    echo fmt"Work Directory : {cwd}"

    discard load_prc_file(init_fileName(fmt"{cwd}/wasi.prc"))
    discard load_prc_file_data("",fmt"model-path {cwd}" )

    when defined(wasi):
        echo "hello wasi"
    else:
        discard load_prc_file_data("", "load-display x11display")
        discard load_prc_file_data("", "window-type offscreen")


    echo "setup:begin"

    echo "base.openDefaultWindow"
    base.open_default_window()

    echo "base.disableMouse"
    base.disable_mouse()

    base.win.set_clear_color((1,1,0,0))


    echo "base.loader.load_model"
    var
        env = base.loader.load_model("models/environment")

    if env:
        echo "reparent_to/set_scale/set_pos"
        env.reparent_to(base.render)
        env.set_scale(0.25, 0.25, 0.25)
        env.set_pos(-8, 42, 0)
        echo "105"
        if false:
            echo "actor"
            var
                pandaActor = Actor()

            # crash init_libchar missing ?
            pandaActor.loadModel("models/panda-model")

            pandaActor.loadAnims({"walk": "models/panda-walk4"})

            pandaActor.setScale(0.005, 0.005, 0.005)
            pandaActor.reparentTo(render)
            pandaActor.loop("walk")


            # Create the four lerp intervals needed for the panda to
            # walk back and forth.
            var posInterval1 = pandaActor.posInterval(13,
                                                      (0, -10, 0),
                                                      startPos=(0, 10, 0))
            var posInterval2 = pandaActor.posInterval(13,
                                                      (0, 10, 0),
                                                      startPos=(0, -10, 0))
            var hprInterval1 = pandaActor.hprInterval(3,
                                                      (180, 0, 0),
                                                      startHpr=(0, 0, 0))
            var hprInterval2 = pandaActor.hprInterval(3,
                                                      (0, 0, 0),
                                                      startHpr=(180, 0, 0))

            # Create and play the sequence that coordinates the intervals.
            var pandaPace = Sequence(posInterval1, hprInterval1,
                                     posInterval2, hprInterval2,
                                     name="pandaPace")

            pandaPace.loop()
            #base.taskMgr.add(spinCameraTask, "SpinCameraTask")

    echo "base.step"
    base.step()
    base.step()
    base.send("window-event")
    var
        i = 0
    while i<60:
        #spin_cam(1)
        base.step()
        i = i + 1
        when not defined(wasi):
            discard usleep(1)
    echo "155"
    if base.win.save_screenshot(fmt"{cwd}/out.bmp", "from pview"):
        echo "screenshot:ok"
    else:
        echo "screenshot:error"
        var
            result : Filename = base.win.saveScreenshotDefault(fmt"{cwd}/out")
        echo result

    echo "setup:end"

when not defined(wasi):
    echo "native"
    setup()

