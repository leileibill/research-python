from pilawa_instruments import *

import sys
import time
import datetime
import os

import numpy as np
from powerSupply import setVoltage
import matplotlib.pyplot as plt
#import matplotlib.lines as lines
#==========================================================================
# Instatiation
#==========================================================================
gpib  = prologix_serial(port="COM3", baud=115200, debug=False, timeout=5)


# Power supply
power_supply=prologix_6030a(prologix=gpib, addr=5,debug=False)
power_supply.activate()


meter_Vin = prologix_FLUKE45(prologix=gpib, addr=1, mode="VDC", maxrange="60", nplc="2", debug=False)
meter_Iin = prologix_FLUKE45(prologix=gpib, addr=2, mode="ADC", maxrange="2",  nplc="2", debug=False)
meter_Vout = prologix_FLUKE45(prologix=gpib, addr=3, mode="VDC", maxrange="25", nplc="2", debug=False)
meter_Iout = prologix_FLUKE45(prologix=gpib, addr=4, mode="ADC", maxrange="2", nplc="2", debug=False)

eload= prologix_6060b(prologix=gpib, addr=6, mode="CURR", rang=6,  debug=False)

meterList = [meter_Vin, meter_Iin, meter_Vout, meter_Iout]
meter_addrList=[1,2,3,4]
scaleList = [1, 1, 1, 1]
#==========================================================================
# Parameter initialization
#==========================================================================
power_supply.setCurrent(6)
setVoltage(power_supply,20)
eload.setMode("CURR",5)
eload.setSlew(10)
eload.setValue(0.4)

#eload.setMode("RES",20)
#eload.setSlew(10)
#eload.setValue(0.01)

load_resistance = [50, 45, 40, 35, 30, 25, 20, 15, 10, 7.5, 5, 4.5, 4, 3.5, 3 ]
load_current= np.arange(0.4,1,0.05)
#meter_Iin.setMode("CURR")
#meter_Iout.setMode("CURR")

N_resistance=len(load_resistance)
N_current=len(load_current)
N=N_current
Iout=[0]*N
Pin=[0]*N
Pout=[0]*N
Eff=[0]*N

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
header_string=("Vin", "Iin", "Vout", "Iout","Pin","Pout","Efficiency")

#root_filename = sys.argv[1]
filename= "%s_%s.dat" % ("SC", timestamp) 
f=open(foldername + "/" + filename,"w")

f.write(delimiter.join(header_string))
f.write('\n')


#==========================================================================
# Sweep
#==========================================================================
time_to_observe_1=2;
#fig=plt.figure()
#line1,=plt.plot(Iout, Eff)
for iter in range(N):
    #res=load_resistance[iter]
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
    pin  = meterdata[0]*meterdata[1]
    pout = meterdata[2]*meterdata[3]
    print("%s  %s  %s  %s" %(meterdata[0],meterdata[1],meterdata[2],meterdata[3]))
    try:
        eff = pout/pin
    except:
        eff = 0
    if eff>1: eff=1
    if eff<0: eff=0
    print "Load: %s Pin: %.5f, Pout: %.5f, Eff: %.5f" % (current, pin, pout, eff)
    f.write("%s%s%s%s%s%s%s%s%.5f%s%.5f%s%.5f\n" % (str(meterdata[0]), delimiter, str(meterdata[1]), delimiter, str(meterdata[2]), delimiter, str(meterdata[3]),delimiter, pin,delimiter, pout,delimiter, eff))
    Pin[iter]=pin
    Pout[iter]=pout
    Eff[iter]=eff*100
    Iout[iter]=meterdata[3]
    
#    line1.set_ydata(Eff)
#    line1.set_xdata(Iout)
#    fig.canvas.draw()
    
    

#==========================================================================
# Plot
#==========================================================================


#plt.ion()
fig=plt.figure()
plt.plot(Iout, Eff)
#ax=fig.add_subplot(111)
#line1,=ax.plot(Iout, Eff)
plt.ylabel('Efficiency [%]')
plt.xlabel('Output Current [A]')
plt.grid(True)
#plt.xlim(0, 5) 
#plt.ylim(50, 100)


f.close()
eload.setValue(0.01)
setVoltage(power_supply,2)
gpib.serial.close()


