from generators.Generator import Generator
from Command import Command
from .azaharConfig import AZAHAR_BIN_PATH, setAzaharConfig
from .azaharControllers import setAzaharControllers

from utils.logger import get_logger
eslog = get_logger(__name__)

class AzaharGenerator(Generator):

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        azaharConfig = setAzaharConfig(system)
        setAzaharControllers(azaharConfig, playersControllers)
        azaharConfig.write()  # UnixSettings method

        commandArray = [AZAHAR_BIN_PATH, rom]
        return Command(array=commandArray)
