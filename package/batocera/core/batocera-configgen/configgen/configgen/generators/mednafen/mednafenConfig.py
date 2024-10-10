#!/usr/bin/env python

def generateMednafenConfig(cfgConfig, mednafenSystem):

    for system in mednafenSystem:
        # Enable (automatic) usage of this module.
        cfgConfig.write(system + ".enable 1\n")

        # Stretch to fill screen.
        cfgConfig.write(system + ".stretch full\n")


    # Select sound driver.
    cfgConfig.write("sound.driver sdl\n")

    # Enable sound output.
    cfgConfig.write("sound 1\n")

    # Enable fullscreen mode.
    cfgConfig.write("video.fs 1\n")
    cfgConfig.write("video.fs.display -1\n")

    # Path to directory for firmware.
    cfgConfig.write("filesys.path_firmware firmware\n")

    # Automatically load/save state on game load/close.
    cfgConfig.write("autosave 0\n")

    # Enable cheats.
    cfgConfig.write("cheats 0\n")

    # Exit
    cfgConfig.write("command.exit keyboard 0x0 69\n")

    # Fast-forward
    cfgConfig.write("command.fast_forward keyboard 0x0 53\n")

    # Rewind
    cfgConfig.write("command.state_rewind keyboard 0x0 42\n")

    # Reset
    cfgConfig.write("command.reset keyboard 0x0 67\n")

    # Rotate screen
    cfgConfig.write("command.rotate_screen keyboard 0x0 18+alt\n")

    # Automatically enable FPS display on startup.
    cfgConfig.write("fps.autoenable 0\n")

