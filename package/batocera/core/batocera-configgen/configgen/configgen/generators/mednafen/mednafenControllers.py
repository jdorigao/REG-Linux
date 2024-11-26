#!/usr/bin/env python

psxJoystick = {
    'a' :             {'button': 'Circle'},
    'b' :             {'button': 'Cross'},
    'x' :             {'button': 'Triangle'},
    'y' :             {'button': 'Square'},
    'start' :         {'button': 'Start'},
    'select' :        {'button': 'Select'},
    'pageup' :        {'button': 'L'},
    'pagedown' :      {'button': 'R'},
    'joystick1left' : {'axis': 'An.Left'},
    'joystick1up' :   {'axis': 'An.Up'},
    'joystick2left' : {'axis': 'RightAn.Left'},
    'joystick2up' :   {'axis': 'RightAn.Up'},
    'up' :            {'hat': 'Up',    'axis': 'Up',    'button': 'Up'},
    'down' :          {'hat': 'Down',  'axis': 'Down',  'button': 'Down'},
    'left' :          {'hat': 'Left',  'axis': 'Left',  'button': 'Left'},
    'right' :         {'hat': 'Right', 'axis': 'Right', 'button': 'Right'},
    'joystick1right' :{'axis': 'An.Right'},
    'joystick1down' : {'axis': 'An.Down'},
    'joystick2right' :{'axis': 'RightAn.Right'},
    'joystick2down' : {'axis': 'RightAn.Down'}
}

# md.input.port1.gamepad6.y joystick 0x0003054c026881100006001100000000 button_4

def generateControllerConfig(cfgConfig, mednafenSystem, controller):

    for system in mednafenSystem:
        # Input device for Virtual Port 1
        cfgConfig.write(system + ".input.port" + str(controller.index) + ".gamepad6." + "\n")

