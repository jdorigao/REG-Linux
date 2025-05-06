#!/usr/bin/env python3

from generators.Generator import Generator
import Command
import os
from shutil import copyfile
from os.path import isdir
from os.path import isfile
from . import flycastConfig

class FlycastGenerator(Generator):

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):

        # Write the flycast config
        flycastConfig.writeFlycastConfig(system, gameResolution)

        # internal config
        if not isdir(flycastConfig.flycastSaves):
            os.mkdir(flycastConfig.flycastSaves)
        if not isdir(flycastConfig.flycastSaves + "/flycast"):
            os.mkdir(flycastConfig.flycastSaves + "/flycast")
        # vmuA1
        if not isfile(flycastConfig.flycastVMUA1):
            copyfile(flycastConfig.flycastVMUBlank, flycastConfig.flycastVMUA1)
        # vmuA2
        if not isfile(flycastConfig.flycastVMUA2):
            copyfile(flycastConfig.flycastVMUBlank, flycastConfig.flycastVMUA2)

        # Environment variables
        environment = {
            "FLYCAST_DATADIR":flycastConfig.flycastSaves,
            "FLYCAST_BIOS_PATH":flycastConfig.flycastBios
        }

        # the command to run
        commandArray = [flycastConfig.flycastBin]
        commandArray.append(rom)

        return Command.Command(array=commandArray, env=environment)
