#Written by Felix Hsiao
#Edit on 11/13/2013 by Josiah McClurg (restored on 1/21/2014)

import time
import array

class prologix_33250a:
    def __init__(self, prologix, addr, function=None, freq=None, ampl=None, offset=None, load='INF', debug=False):
        self.prologix = prologix
        self.addr = addr
        self.function = function  #Default sine
        self.freq = freq  #Default 1 kHz
        self.ampl = ampl  #Default 0.2 Vpp (high-Z); can specify rms
        self.offset = offset  #Default 0
        self.load = load  #Output termination
        self.debug = debug
        self.initialize()

    def initialize(self):
        if self.debug: print 'Initializing address %d for outputting %s ...' %(self.addr, self.function)
        self.prologix.set_address(self.addr)
        if self.debug: print 'Reset'
        self.prologix.write('*RST')
        if self.debug: print 'Clear'
        self.prologix.write('*CLS')
        if self.debug: print 'Set function'
        if self.function is not None:
            # This is the old code. It needed to be updated to allow for the FUNC:USER command
            #self.prologix.write('FUNC %s' %(self.function))
	    f = self.function.split(' ')
            self.function = f[0]

            self.prologix.write('FUNC %s' %(self.function))
            if(self.function == 'USER' and len(f) > 1):
                self.prologix.write('FUNC:USER %s' % f[1])

        if self.debug: print 'Set output termination'
        self.prologix.write('OUTP:LOAD %s' %(self.load))
        if self.freq is not None:
            if self.debug: print 'Set frequency'
            self.prologix.write('FREQ %s' %(self.freq))
        if self.ampl is not None:
            if self.debug: print 'Set amplitude'
            self.prologix.write('VOLT %s' %(self.ampl))
        if self.offset:
            if self.debug: print 'Set offset'
            self.prologix.write('VOLT:OFFS %s' %(self.offset))
        if self.debug: print 'Setup triggering'
        self.prologix.write('TRIG:SOUR BUS')  #Only used for burst and sweep
        if self.debug: print 'Address %d initialized.' %(self.addr)

    def activate(self):
        if self.debug: print 'Starting output from address %d ...' %(self.addr)
        self.prologix.set_address(self.addr)
        self.prologix.write('OUTP ON')
        if self.debug: print 'Address %d output on.' %(self.addr)
    
    def deactivate(self):
        if self.debug: print 'Stopping output from address %d ...' %(self.addr)
        self.prologix.set_address(self.addr)
        self.prologix.write('OUTP OFF')
        if self.debug: print 'Address %d output off.' %(self.addr)

    def configSweep(self, freq1, freq2, centered=False, time=None, type=None):
        if self.debug: print 'Setting up frequency sweep for address %d ...' %(self.addr)
        self.prologix.set_address(self.addr)
        if not centered:  #freq1 and freq2 are start and stop points
            if self.debug: print 'Set frequency endpoints'
            self.prologix.write('FREQ:STAR %s' %(freq1))
            self.prologix.write('FREQ:STOP %s' %(freq2))
        else:  #freq1 is center frequency, freq2 is total span
            if self.debug: print 'Set center frequency and span'
            self.prologix.write('FREQ:CENT %s' %(freq1))
            self.prologix.write('FREQ:SPAN %s' %(freq2))
        if time is not None:  #Default 1 second
            if self.debug: print 'Set sweep time'
            self.prologix.write('SWE:TIME %s' %(time))
        if type is not None:  #Can be LINear or LOGarithmic; default linear
            if self.debug: print 'Set sweep type'
            self.prologix.write('SWE:SPAC %s' %(type))
        if self.debug: print 'SWE ON'
        self.prologix.write('SWE:STAT ON')
        if self.debug: print 'Address %d sweep mode configured.' %(self.addr)

    def configBurst(self, cycles):
        if self.debug: print 'Setting up burst mode for address %d ...' %(self.addr)
        self.prologix.set_address(self.addr)
        if self.debug: print 'Set cycles'
        self.prologix.write('BURS:NCYC %s' %(cycles))
        if self.debug: print 'BURS ON'
        self.prologix.write('BURS:STAT ON')
        if self.debug: print 'Address %d burst mode configured.' %(self.addr)
    
    def checkError(self):
        if self.debug: print 'Checking if error was generated by address %d ...' %(self.addr)
        self.prologix.set_address(self.addr)
        self.prologix.write('SYST:ERR?')
        time.sleep(0.1)
        data = self.prologix.readline()
        if self.debug: print 'Recv:', data
        return data

    # Programs arbitrary waveform with the specified name.
    # Keep in mind that the hardware can only store four arbitrary
    # waveforms. This routine does not currently handle out of memory
    # errors.
    #
    # data is a list of floating point values between -1 and 1. Maximum length is 65536.
    # name is the name of the arbitrary waveform (not case-sensitive). may contain up to 12 characters.
    # nobinary sends the data in ascii format, which is significantly slower and doesn't have any advantages as far as I can tell. this option may be removed in the future.
    def programArbitraryWaveform(self, data, name, nobinary=False):
        self.prologix.set_address(self.addr)
        if((len(data) > 65536) or (len(data) == 0)):
            raise Exception('Data length must be between 1 and 65536')
        if((min(data) < -1.0) or (max(data) > 1.0)):
            raise Exception('Data values must be between -1 and 1.')
        if(len(name) > 12):
            raise Exception('Name is too long.')

        if self.debug: print('Programming arbitrary waveform %s with %d data points.' % (name, len(data)))

        # Convert the data to integer format
        intArr = [int(round(2047*a)) for a in data]

        if nobinary:
            if self.debug:
                if len(data) <= 100:
                    print('Raw ASCII transfer: %s' % intArr)
                else:
                    print('Raw ASCII transfer: [too big to print]')
            self.prologix.write('DATA:DAC VOLATILE, %s' % ", ".join([str(i) for i in intArr]))
        else:
            # Convert the integers to characters, MSB first
            charArr = [i for d in intArr for i in [(d>>8) & 0xFF,d & 0xFF]]
            if self.debug:
                if len(data) <= 100:
                    print('Raw binary transfer: %s' % charArr)
                else:
                    print('Raw binary transfer: [too big to print]')

            # Escape the special characters (CR, LF, ESC, +) so prologix can send them properly.
            charArr2 = []
            for i in charArr:
                if(i == 13 or i == 10 or i == 27 or i == 43):
                    charArr2.append(27)
                charArr2.append(i)

            arr = array.array('B', charArr2)
            binaryBlock = arr.tostring()

            numBytes = len(2*data)
            self.prologix.write('FORM:BORD NORM')
            self.prologix.write('DATA:DAC VOLATILE, #%d%d%s' % (len(str(numBytes)), numBytes, binaryBlock))

        self.prologix.write('DATA:COPY %s' % name)