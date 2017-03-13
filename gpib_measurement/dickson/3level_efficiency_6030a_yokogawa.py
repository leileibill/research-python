from pilawa_instruments import *

import sys
import time
import datetime
import os

import numpy as np
from powerSupply import setVoltage
import matplotlib.pyplot as plt

# ==========================================================================
# Instatiation
# ==========================================================================



gpib = prologix_serial(port="COM4", baud=115200, debug=False, timeout=5)

# Power supply
power_supply = prologix_6030a(prologix=gpib, addr=5, debug=False)
# power_supply.setLanguage_SCPI()
power_supply.activate()

eload= prologix_6060b(prologix=gpib, addr=6, mode="CURR", rang=6,  debug=False)
#
meter_In = prologix_wt310(prologix=gpib, addr=2, debug=False, mode='DC')
meter_Out = prologix_wt310(prologix=gpib, addr=1, debug=False, mode='DC')
# meter_Vout = prologix_FLUKE45(prologix=gpib, addr=3, mode="VDC", maxrange="25", nplc="2", debug=False)
# meter_Iout = prologix_FLUKE45(prologix=gpib, addr=4, mode="ADC", maxrange="2", nplc="2", debug=False)


# ==========================================================================
# Parameter initialization
# =========================================================================/

eload.setMode("RES")
eload.setSlew(10)
eload.setValue(20)

power_supply.setCurrent(4.1)
power_supply.setVoltage(0)
setVoltage(power_supply,48,5)

# eload.setMode("CURR")
# eload.setSlew(10)
# eload.setValue(0.1)

load_resistance = [20, 15, 12, 10, 9, 8, 7, 6.5, 6, 5.5, 5, 4.5, 4]
# load_resistance = [50, 45, 40, 35, 30, 25, 20, 15, 12, 10, 8, 7, 6, 5, 4.5, 4, 3.5, 3, 2.75, 2.5]
load_current = np.arange(0.2, 1.0 + 0.1, 0.1)


N_resistance = len(load_resistance)
N_current = len(load_current)
N = N_resistance
Iout_array = [0] * N
Pin_array = [0] * N
Pout_array = [0] * N
Eff_array = [0] * N

# ==========================================================================
# File handling
# ==========================================================================
delimiter = ', '
t = time.strftime('%Y%m%d')
current_directory = os.curdir
print "Current directory: %s" % current_directory
foldername = current_directory + "/data/" + t
print foldername
if not os.path.exists(foldername):
    os.makedirs(foldername)
timestamp = time.strftime('%Y%m%d_%H%M%S')
header_string = ("Vin", "Iin", "Vout", "Iout", "Pin", "Pout", "Efficiency")

# root_filename = sys.argv[1]
filename = "%s_%s.dat" % ("3level", timestamp)
# filename= "SCRegulation_60_32V.dat"
f = open(foldername + "/" + filename, "w")

f.write(delimiter.join(header_string))
f.write('\n')

# ==========================================================================
# Sweep
# ==========================================================================
time_to_observe_1 = 2;

# import matplotlib as mpl
# mpl.use('Qt4Agg')
# plt.ion()
# line1, = plt.plot(Iout_array, Eff_array)

for iter in range(N):
    value=load_resistance[iter]
    # value = load_current[iter]
    eload.setValue(value)
    time.sleep(time_to_observe_1)
    # for x in meterList:
    #     x.waitForTrigger()
    # time.sleep(0.2)

    # gpib.trigger_devices(meter_addrList)
    meterdata = []
    # for meter, scale in zip(meterList, scaleList):
    data = meter_In.getLastSample()
    [Vin, Iin, Pin] = [abs(float(x)) for x in data.split(',')]

    data = meter_Out.getLastSample()
    [Vout, Iout, Pout] = [abs(float(x)) for x in data.split(',')]

    print [Vin, Iin, Pin]
    print [Vout, Iout, Pout]

    try:
        Eff = Pout / Pin
    except:
        Eff = 0
    if Eff > 1: Eff = 1
    if Eff < 0: Eff = 0
    print "Load: %s Pin: %.5f, Pout: %.5f, Eff: %.5f" % (value, Pin, Pout, Eff)
    print("\n")

    f.write("%.5f%s%.5f%s%.5f%s%.5f%s%.5f%s%.5f%s%.5f\n" % (
    Vin, delimiter, Iin, delimiter, Vout, delimiter,Iout, delimiter,
    Pin, delimiter, Pout, delimiter, Eff))

    Pin_array[iter] = Pin
    Pout_array[iter] = Pout
    Eff_array[iter] = Eff * 100
    Iout_array[iter] = Iout

    # line1.set_ydata(Eff_array)
    # line1.set_xdata(Iout_array)
    # plt.draw()

f.close()
eload.setMode("RES")
eload.setValue(10)
time.sleep(time_to_observe_1)
eload.setValue(20)
setVoltage(power_supply, 0, 10)
gpib.serial.close()

# ==========================================================================
# Plot
# ==========================================================================
plt.plot(Iout_array, Eff_array,'o-')
plt.ylabel('Efficiency [%]')
plt.xlabel('Output Current [A]')
plt.grid(True)
# plt.xlim(0, 5)
plt.ylim(90, 100)

filename = "%s_%s.png" % ("SC_Regulation", timestamp)
plt.savefig(foldername + "/" + filename)
plt.show()



