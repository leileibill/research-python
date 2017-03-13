from pilawa_instruments import *

import numpy as np
import time

def setVoltage(power_supply, targetVoltage, voltageStep=1):
    currentVoltage=float(power_supply.readVoltage())
    if np.abs(currentVoltage-targetVoltage)<0.5:
        power_supply.setVoltage(targetVoltage)
    else:
        if currentVoltage>targetVoltage:
            voltageStep=-voltageStep
        for voltage in np.arange(currentVoltage,targetVoltage+voltageStep/10.0,voltageStep/10.0):
            power_supply.setVoltage(voltage)
            time.sleep(0.1)
    return

def zeroVoltage():
    gpib  = prologix_serial(port="COM5", baud=115200, debug=False, timeout=5)

    power_supply=prologix_6674a(prologix=gpib, addr=7,debug=False)

    power_supply.activate()

    setVoltage(power_supply,0)
    power_supply.deactivate()
    gpib.serial.close()
    return
