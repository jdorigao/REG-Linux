#!/usr/bin/env python3

import configparser
import systemFiles
import os.path

flycastCustom = systemFiles.CONF + '/flycast'
flycastConfig = flycastCustom + '/emu.cfg'
flycastSaves = systemFiles.savesDir + '/dreamcast'
flycastBios = systemFiles.BIOS + '/dc'
flycastVMUBlank = '/usr/share/reglinux/configgen/data/dreamcast/vmu_save_blank.bin'
flycastVMUA1 = flycastSaves + '/flycast/vmu_save_A1.bin'
flycastVMUA2 = flycastSaves + '/flycast/vmu_save_A2.bin'
flycastBin = '/usr/bin/flycast'

def writeFlycastConfig(system, gameResolution):
    Config = configparser.ConfigParser(interpolation=None)
    Config.optionxform = str
    if os.path.exists(flycastConfig):
        try:
            Config.read(flycastConfig)
        except:
            pass

    # create the config file
    createFlycastConfig(Config, system, gameResolution)

    # update the configuration file
    if not os.path.exists(os.path.dirname(flycastConfig)):
        os.makedirs(os.path.dirname(flycastConfig))
    with open(flycastConfig, 'w+') as cfgfile:
        Config.write(cfgfile)
        cfgfile.close()

def createFlycastConfig(Config, system, gameResolution):
    if not Config.has_section("input"):
            Config.add_section("input")

    if not Config.has_section("config"):
        Config.add_section("config")

    if not Config.has_section("window"):
        Config.add_section("window")

    # ensure we are always fullscreen
    Config.set("window", "fullscreen", "yes")

    # set video resolution
    Config.set("window", "width", str(gameResolution["width"]))
    Config.set("window", "height", str(gameResolution["height"]))

    # set render resolution - default 480 (Native)
    if system.isOptSet("flycast_render_resolution"):
        Config.set("config", "rend.Resolution", str(system.config["flycast_render_resolution"]))
    else:
        Config.set("config", "rend.Resolution", "480")

    # wide screen mode - default off
    if system.isOptSet("flycast_ratio"):
        Config.set("config", "rend.WideScreen", str(system.config["flycast_ratio"]))
    else:
        Config.set("config", "rend.WideScreen", "no")

    # rotate option - default off
    if system.isOptSet("flycast_rotate"):
        Config.set("config", "rend.Rotate90", str(system.config["flycast_rotate"]))
    else:
        Config.set("config", "rend.Rotate90", "no")

    # renderer - default: OpenGL
    if system.isOptSet("flycast_renderer") and system.config["flycast_renderer"] == "0":
        if system.isOptSet("flycast_sorting") and system.config["flycast_sorting"] == "3":
            # per pixel
            Config.set("config", "pvr.rend", "3")
        else:
            # per triangle
            Config.set("config", "pvr.rend", "0")
    elif system.isOptSet("flycast_renderer") and system.config["flycast_renderer"] == "4":
        if system.isOptSet("flycast_sorting") and system.config["flycast_sorting"] == "3":
            # per pixel
            Config.set("config", "pvr.rend", "5")
        else:
            # per triangle
            Config.set("config", "pvr.rend", "4")
    else:
        Config.set("config", "pvr.rend", "0")
        if system.isOptSet("flycast_sorting") and system.config["flycast_sorting"] == "3":
            # per pixel
            Config.set("config", "pvr.rend", "3")
    # anisotropic filtering
    if system.isOptSet("flycast_anisotropic"):
        Config.set("config", "rend.AnisotropicFiltering", str(system.config["flycast_anisotropic"]))
    else:
        Config.set("config", "rend.AnisotropicFiltering", "1")

    # transparent sorting
    # per strip
    if system.isOptSet("flycast_sorting") and system.config["flycast_sorting"] == "2":
        Config.set("config", "rend.PerStripSorting", "yes")
    else:
        Config.set("config", "rend.PerStripSorting", "no")

    # [Dreamcast specifics]
    # language
    if system.isOptSet("flycast_language"):
        Config.set("config", "Dreamcast.Language", str(system.config["flycast_language"]))
    else:
        Config.set("config", "Dreamcast.Language", "1")

    # region
    if system.isOptSet("flycast_region"):
        Config.set("config", "Dreamcast.Region", str(system.config["flycast_language"]))
    else:
        Config.set("config", "Dreamcast.Region", "1")

    # save / load states
    if system.isOptSet("flycast_loadstate"):
        Config.set("config", "Dreamcast.AutoLoadState", str(system.config["flycast_loadstate"]))
    else:
        Config.set("config", "Dreamcast.AutoLoadState", "no")
    if system.isOptSet("flycast_savestate"):
        Config.set("config", "Dreamcast.AutoSaveState", str(system.config["flycast_savestate"]))
    else:
        Config.set("config", "Dreamcast.AutoSaveState", "no")

    # windows CE
    if system.isOptSet("flycast_winCE"):
        Config.set("config", "Dreamcast.ForceWindowsCE", str(system.config["flycast_winCE"]))
    else:
        Config.set("config", "Dreamcast.ForceWindowsCE", "no")

    # DSP
    if system.isOptSet("flycast_DSP"):
            Config.set("config", "aica.DSPEnabled", str(system.config["flycast_DSP"]))
    else:
        Config.set("config", "aica.DSPEnabled", "no")

    # Guns (WIP)
    # Guns crosshairs
    if system.isOptSet("flycast_lightgun1_crosshair"):
        Config.set("config", "rend.CrossHairColor1", + str(system.config["flycast_lightgun1_crosshair"]))
    else:
        Config.set("config", "rend.CrossHairColor1", "0")
    if system.isOptSet("flycast_lightgun2_crosshair"):
        Config.set("config", "rend.CrossHairColor2", + str(system.config["flycast_lightgun2_crosshair"]))
    else:
        Config.set("config", "rend.CrossHairColor2", "0")
    if system.isOptSet("flycast_lightgun3_crosshair"):
        Config.set("config", "rend.CrossHairColor3", + str(system.config["flycast_lightgun3_crosshair"]))
    else:
        Config.set("config", "rend.CrossHairColor3", "0")
    if system.isOptSet("flycast_lightgun4_crosshair"):
        Config.set("config", "rend.CrossHairColor4", + str(system.config["flycast_lightgun4_crosshair"]))
    else:
        Config.set("config", "rend.CrossHairColor4", "0")

    # custom : allow the user to configure directly emu.cfg via system.conf via lines like : dreamcast.flycast.section.option=value
    for user_config in system.config:
        if user_config[:8] == "flycast.":
            section_option = user_config[8:]
            section_option_splitter = section_option.find(".")
            custom_section = section_option[:section_option_splitter]
            custom_option = section_option[section_option_splitter+1:]
            if not Config.has_section(custom_section):
                Config.add_section(custom_section)
            Config.set(custom_section, custom_option, system.config[user_config])

