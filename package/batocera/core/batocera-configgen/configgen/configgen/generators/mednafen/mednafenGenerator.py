#!/usr/bin/env python

from generators.Generator import Generator
import batoceraFiles
import Command
import os
from utils.logger import get_logger
from . import mednafenConfig
from . import mednafenControllers

eslog = get_logger(__name__)

mednafenConfigDir = batoceraFiles.HOME + "/.mednafen"
mednafenConfigFile = mednafenConfigDir + "/mednafen.cfg"

mednafenSystem = { "apple2", "gb", "gba", "gg", "lynx", "md", "nes", "ngp", "pce", "pce_fast", "pcfx", "psx", "sasplay", "sms", "snes", "snes_faust", "ss", "ssfplay", "vb", "wswan" }

class MednafenGenerator(Generator):

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):

        if not os.path.exists(mednafenConfigDir):
            os.makedirs(mednafenConfigDir)

        # If config file already exists, delete it
        if os.path.exists(mednafenConfigFile):
            os.unlink(mednafenConfigFile)

        # Create the config file and fill it with basic data
        cfgConfig = open(mednafenConfigFile, "w")

        # Basic settings
        mednafenConfig.generateMednafenConfig(cfgConfig, mednafenSystem)

        # TODO: Controls configuration
        for index in playersControllers :
            controller = playersControllers[index]

            # We only care about player 1
            if controller.player != "1":
                continue

            mednafenControllers.generateControllerConfig(cfgConfig, mednafenSystem, controller)
            break

        # Close config file as we are done
        cfgConfig.close()

        commandArray = [batoceraFiles.batoceraBins[system.config['emulator']]]
        commandArray += [ rom ]
        return Command.Command(array=commandArray, env={"XDG_CONFIG_HOME":batoceraFiles.CONF, "XDG_CACHE_HOME":batoceraFiles.SAVES})

