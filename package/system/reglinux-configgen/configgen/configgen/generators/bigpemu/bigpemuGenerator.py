from generators.Generator import Generator
from Command import Command
from os import path, makedirs
from .bigpemuConfig import setBigemuConfig, BIGPEMU_BIN_PATH, BIGPEMU_CONFIG_DIR

class BigPEmuGenerator(Generator):

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        # Create the directory if it doesn't exist
        if not path.exists(BIGPEMU_CONFIG_DIR):
            makedirs(BIGPEMU_CONFIG_DIR)

        # Update configuration
        setBigemuConfig(system, gameResolution, playersControllers)

        commandArray = [BIGPEMU_BIN_PATH, rom]
        return Command(array=commandArray)
