#Written by Robert Pilawa
#Last edit on 8/19/2013 by Felix Hsiao

class prologix_2400:
    def __init__(self, prologix=None, addr=None, debug=False):
        self.prologix  = prologix
        self.addr     = addr
        self.debug    = debug
        self.initialize()
    
    def initialize(self):
        self.prologix.set_address(self.addr) # address the proper instrument
        self.prologix.write(":FORM:ELEM VOLT, CURR\n") #setup to read back voltage, current
    
    def readData(self):
        # Read back the data, originally tried fetch here, but read works better as it also initiates the meter
        if self.debug: print "Fetching data from %d:" % self.addr
        self.prologix.set_address(self.addr) # select device
        self.prologix.write("READ?") # fetch value
        data = self.prologix.readline() # read until LF (ascii 10)
        if self.debug: print "Recv:", data
        return data
