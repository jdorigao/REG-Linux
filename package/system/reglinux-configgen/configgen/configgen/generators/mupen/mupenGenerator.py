#!/usr/bin/env python3

from generators.Generator import Generator
import Command
from . import mupenConfig

class MupenGenerator(Generator):

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):

        # Write the config file
        mupenConfig.writeMupenConfig(system, gameResolution)

        # Command
        commandArray = [mupenConfig.mupenBin, "--corelib", "/usr/lib/libmupen64plus.so.2.0.0", "--gfx", "/usr/lib/mupen64plus/mupen64plus-video-{}.so".format(system.config['core']), "--configdir", mupenConfig.mupenConf, "--datadir", mupenConfig.mupenConf]

        # state_slot option
        if system.isOptSet('state_filename'):
            commandArray.extend(["--savestate", system.config['state_filename']])

        commandArray.append(rom)

        return Command.Command(array=commandArray)
