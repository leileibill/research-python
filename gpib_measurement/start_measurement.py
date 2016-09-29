# Start measurement


from pilawa_instruments import *

import sys
import time
import datetime
import os

import numpy as np


#==========================================================================
# Instatiation
#==========================================================================
gpib  = prologix_serial(port="COM5", baud=115200, debug=False, timeout=5)


power_supply=prologix_6674a(prologix=gpib, addr=6,debug=False)
power_supply.activate()

meter_Vin = prologix_FLUKE45(prologix=gpib, addr=1, mode="VDC", maxrange="60", nplc="2", debug=False)
meter_Iin = prologix_FLUKE45(prologix=gpib, addr=2, mode="ADC", maxrange="2",  nplc="2", debug=False)
meter_Vout = prologix_FLUKE45(prologix=gpib, addr=3, mode="VDC", maxrange="25", nplc="2", debug=False)
meter_Iout = prologix_FLUKE45(prologix=gpib, addr=4, mode="ADC", maxrange="2", nplc="2", debug=False)

eload= prologix_6060b(prologix=gpib, addr=5, mode="CURR", rang=6,  debug=False)