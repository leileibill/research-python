from pilawa_instruments import *

import sys
import time
import datetime
import os

import numpy as np
from powerSupply import setVoltage
import matplotlib.pyplot as plt

#==========================================================================
# Instatiation
#==========================================================================


gpib = prologix_serial(port="COM4", baud=115200, debug=False, timeout=5)

# Power supply
power_supply = prologix_6030a(prologix=gpib, addr=5, debug=False)
# power_supply.setLanguage_SCPI()
power_supply.activate()

eload= prologix_6060b(prologix=gpib, addr=6, mode="CURR", rang=6,  debug=False)

meter_Vin = prologix_FLUKE45(prologix=gpib, addr=2, mode="VDC", maxrange="20", nplc="2", debug=False)
meter_Vc = prologix_FLUKE45(prologix=gpib, addr=3, mode="VDC", maxrange="10", nplc="2", debug=False)

meterList = [meter_Vin, meter_Vc]
meter_addrList=[2,3]
scaleList = [5.962, 5.962]

#==========================================================================
# Parameter initialization
#==========================================================================
power_supply.setCurrent(2.1)
power_supply.setVoltage(0)


eload.setMode("CURR")
eload.setSlew(10)
eload.setValue(0.1)

setVoltage(power_supply,50,5)

load_current = np.arange(0.2, 4.0 + 0.1, 0.2)

N=len(load_current)
Vc=[0]*N
Vin=[0]*N
Vcn = [0]*N

#==========================================================================
# File handling
#==========================================================================
delimiter=', '
t=time.strftime('%Y%m%d')
current_directory=os.curdir
print "Current directory: %s" % current_directory
foldername=current_directory + "/data/" + t
print foldername
if not os.path.exists(foldername):
    os.makedirs(foldername)
timestamp = time.strftime('%Y%m%d_%H%M%S')
header_string=("Iout", "Vin", "Vout","Vcn")

#root_filename = sys.argv[1]
filename= "%s_%s.dat" % ("Balance", timestamp)
f=open(foldername + "/" + filename,"w")

f.write(delimiter.join(header_string))
f.write('\n')


#==========================================================================
# Sweep
#==========================================================================

time_to_observe_1=0.5;

for iter in range(N):

    current=load_current[iter]
    eload.setValue(current)
    time.sleep(time_to_observe_1)
    for x in meterList: 
        x.waitForTrigger()
    time.sleep(0.2)

    gpib.trigger_devices(meter_addrList)

    meterdata = []
    for meter,scale in zip(meterList, scaleList):
        data = meter.readData()
        #print ("data:%s" %data) 
        try:
            scaled_value=float(data)*scale
        except:
            scaled_value=0
        meterdata.append(scaled_value)
        #print("%s" %scaled_value)
    vin  = meterdata[0]
    vc = meterdata[1]
    vcn = vc/vin
    print "Load: %.2f Vin: %.2f, Vc: %.2f" % (current, vin, vc)
    f.write("%.2f %.4f %.4f %.4f \n" % (current, vin, vc, vcn))
    # f.write("%s%s%s%s%s%s%s%s%.5f%s%.5f%s%.5f\n" % (str(meterdata[0]), delimiter, str(meterdata[1]), delimiter, str(meterdata[2]), delimiter, str(meterdata[3]),delimiter, pin,delimiter, pout,delimiter, eff))
    Vin[iter]=vin
    Vc[iter]=vc
    Vcn[iter]=vcn
    
    



f.close()
eload.setValue(2)
time.sleep(1)
eload.setValue(0.1)
setVoltage(power_supply,0,10)
gpib.serial.close()


#==========================================================================
# Plot
#==========================================================================



fig=plt.figure()
plt.plot(load_current, Vcn)

plt.ylabel('Normalized capacitor voltage, Vc/Vin')
plt.xlabel('Output Current [A]')
plt.grid(True)
#plt.xlim(0, 5)
#plt.ylim(50, 100)

filename = "%s_%s.png" % ("Balance", timestamp)
plt.savefig(foldername + "/" + filename)
plt.show()