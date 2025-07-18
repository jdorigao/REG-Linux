#!/usr/bin/env python3

from generators.Generator import Generator
import Command

class RuffleGenerator(Generator):

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        commandArray = ["ruffle", "--fullscreen", rom]
        return Command.Command(
            array=commandArray)

    def getMouseMode(self, config, rom):
        return True
