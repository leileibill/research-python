from pilawa_instruments import *

import numpy as np

#==========================================================================
# Instatiation
#==========================================================================

socket_powersupply = prologix_socket(host='dhcp101.ece.illinois.edu', port=5025, timeout=10)
power_supply_high = magnapower_XR(prologix=socket_powersupply, addr=1337, mode='VOLT')


def setVoltage(targetVoltage, voltageStep=0.2):
    currentVoltage=power_supply_high.readVoltage()
    for voltage in np.arange(currentVoltage,targetVoltage+voltageStep,voltageStep):
        power_supply_high.setVoltage(voltage)
        sleep(0.1)
    return



socket_powersupply.terminate()

#==========================================================================
