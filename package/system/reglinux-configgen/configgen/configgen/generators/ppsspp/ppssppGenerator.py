#!/usr/bin/env python3

from generators.Generator import Generator
import Command
from . import ppssppConfig

class PPSSPPGenerator(Generator):

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):

        # Write the PPSSPP config file
        ppssppConfig.writePPSSPPConfig(system)

        # The command to run
        commandArray = [ppssppConfig.ppssppBin]
        commandArray.append(rom)
        commandArray.append("--fullscreen")

        # Adapt the menu size to low defenition
        # I've played with this option on PC to fix menu size in Hi-Resolution and it not working fine. I'm almost sure this option break the emulator (Darknior)
        if PPSSPPGenerator.isLowResolution(gameResolution):
            commandArray.extend(["--dpi", "0.5"])

        # state_slot option
        if system.isOptSet('state_filename'):
            commandArray.append("--state={}".format(system.config['state_filename']))

        return Command.Command(array=commandArray)

    @staticmethod
    def isLowResolution(gameResolution):
        return gameResolution["width"] <= 480 or gameResolution["height"] <= 480
