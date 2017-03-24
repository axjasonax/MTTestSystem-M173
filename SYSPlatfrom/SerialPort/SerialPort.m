//
//  SerialPort.m
//  SerialPortDemo
//
//  Created by TOD on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import "SerialPort.h"
#import "SerialDevice.h"
//#define O_RDWR    0x0002

@implementation SerialPort
{
    BOOL mStopped;
}

@synthesize devicePath = _devicePath;
@synthesize newline = _newline;
@synthesize restTime = _rest;
@synthesize readTimeout = _readTimeout;
@synthesize writeTimeout = _writeTimeout;
@synthesize fileDescriptor = _fileDescriptor;
@synthesize Databits_ = _Databits_;

+(NSArray*)GetPortNames
{
    return [[SerialDevice instance] portNames];
}

- (id)init
{
	return [self initWithDevicepath:@""];
}

-(id)initWithDevicepath:(NSString *)fullpath
{
    if (self = [super init]) {
        _rest = 1;
        _fileDescriptor = -1;
        _writeTimeout = 1000;
        _readTimeout = 2000;
        _globalBuffer = [[NSMutableString alloc] init];
        _devicePath = [[NSString alloc] initWithString:fullpath];
        _newline = @"\r\n";
        self.stopped = NO;
    }
    
    return self;
}

-(void) dealloc
{
	if([self IsOpen])
	{
		[self Close];
	}
	
//	[_devicePath release];
	_devicePath = nil;
//	[_globalBuffer release];
	_globalBuffer = nil;
//	[_newline release];
    _newline = nil;
    
	//[super dealloc];
}

-(void)clearPort
{
    [self Close] ;
    
    
    //	[_devicePath release];
    _devicePath = nil;
    //	[_globalBuffer release];
    _globalBuffer = nil;
    //	[_newline release];
    _newline = nil;
}

-(void) setTimeout:(int)readTimeout WriteTimeout:(int)writeTimeout
{
	_readTimeout = readTimeout;
	_writeTimeout = writeTimeout;
}

- (void) setDatabits_:(NSNumber *)Databits_
{
    switch ([Databits_ intValue]) {
        case 5:
            _Databits_ = [NSNumber numberWithInt:0x00000000];
            break;
        case 6:
            _Databits_ = [NSNumber numberWithInt:0x00000100];
            break;
        case 7:
            _Databits_ = [NSNumber numberWithInt:0x00000200];
            break;
        case 8:
            _Databits_ = [NSNumber numberWithInt:0x00000300];
            break;
        default:
            break;
    }
}

- (NSNumber *) Databits_
{
    switch ([_Databits_ intValue]) {
        case 0x00000000:
            return [NSNumber numberWithInt:5];
        case 0x00000100:
            return [NSNumber numberWithInt:6];
        case 0x00000200:
            return [NSNumber numberWithInt:7];
        case 0x00000300:
            return [NSNumber numberWithInt:8];
    }
    return [NSNumber numberWithInt:8];
}

-(void) Close
{
//    [self ReadBuffer] ;
	if([self IsOpen])
	{						
		// Close the _fileDescriptor, that is our responsibility since the fileHandle does not own it
		close(_fileDescriptor);
		_fileDescriptor = -1;
	}
}

-(BOOL) Open
{
    if (_devicePath == nil || [_devicePath isEqual:@""]) {
        return NO;
    }
    
    return [self Open:_devicePath
             BaudRate:[[self Baudrate_] intValue]
              DataBit:[_Databits_ intValue]//[[self Databits_] intValue]
              StopBit:[[self Stopbits_] intValue]
               Parity:[[self Parity_] intValue]
          FlowControl:FLOW_CONTROL_DEFAULT];
}

-(BOOL) IsOpen
{
	return (_fileDescriptor >= 0);
}

-(BOOL) Open:(NSString*) devicepath
{
	return [self Open:devicepath BaudRate:BAUD_DEFAULT DataBit:DATA_BITS_DEFAULT
			  StopBit:StopBitsDefault Parity:Parity_Default FlowControl:FLOW_CONTROL_DEFAULT];	
}

-(BOOL) Open:(NSString *)devicepath BaudRate:(BaudRate)baudrate DataBit:(DataBits) databit
	 StopBit:(StopBits)stopbit Parity:(Parity)parityvalue 
	 FlowControl:(FlowControls) flowcontrolValue
{
//	if([self IsOpen])
//	{
//		return YES;
//	}

    
    //
    // We only allow three different combinations of ios_base::openmode
    // so we can use a switch here to construct the flags to be used
    // with the open() system call.
    //
    int flags = O_RDWR;
	//
    // Since we are dealing with the serial port we need to use the
    // O_NOCTTY option.
    //
    flags |= O_NOCTTY;
    //
    // Try to open the serial port. 
    //
	
	_devicePath = [devicepath copy];
	
	const char *path = [devicepath fileSystemRepresentation];
	_fileDescriptor = open(path, flags);

    if( _fileDescriptor == -1)
	{
        NSLog(@"port open return value is:%i",_fileDescriptor) ;
		return NO;
    }
    //
    // Initialize the serial port. 
    //
	//
    // Use non-blocking mode while configuring the serial port. 
    //
    flags = fcntl(_fileDescriptor, F_GETFL, 0) ;
	
    if( -1 == fcntl(_fileDescriptor,  F_SETFL, flags | O_NONBLOCK ) )
	{
        NSLog(@"port fcntl return value is:%i",_fileDescriptor) ;
        
        return NO;
    }
    //
    // Flush out any garbage left behind in the buffers associated
    // with the port from any previous operations. 
    //
    if( -1 == tcflush(_fileDescriptor, TCIOFLUSH) )
	{
        NSLog(@"port tcflush return value is:%i",_fileDescriptor) ;
        
        return NO;
    }
    //
    // Set up the default configuration for the serial port. 
    //
    [self setBaudRate:baudrate];
	[self setDataBit:databit];
	[self setStopBit:stopbit];
	[self setParity:parityvalue];
	[self setFlowControl:flowcontrolValue];
	
	// I didn't change this issue because i didn't know wether is OK
	// but I know the issue
	
	[self setVMin:1];
	[self setVTime:0];
	
    
    //
    // Allow all further communications to happen in blocking 
    // mode. 
    //
    flags = fcntl(_fileDescriptor, F_GETFL, 0) ;
	
    if( -1 == fcntl(_fileDescriptor,  F_SETFL, flags & ~O_NONBLOCK ) ) 
	{
        NSLog(@"port fnctl return value is:%i",_fileDescriptor) ;
        
        return NO;
    }
    //
    // If we get here without problems then we are good; return a value
    // different from -1.
    //
	
    return YES;
}

-(BaudRate) setBaudRate:(BaudRate)baudrate
{	
	if( -1 == _fileDescriptor) 
	{
        return BAUD_INVALID ;
    }
	
	switch (baudrate)
	{
		case BAUD_50:
		case BAUD_75:
		case BAUD_110:
		case BAUD_134:
		case BAUD_150:
		case BAUD_200:
		case BAUD_300:
		case BAUD_600:
		case BAUD_1200:
		case BAUD_1800:
		case BAUD_2400:
		case BAUD_4800:
		case BAUD_9600:
		case BAUD_19200:
		case BAUD_38400:
		case BAUD_57600:
		case BAUD_115200:
        case BAUD_230400:
		{
			struct termios term_setting;
			
			if( -1 == tcgetattr(_fileDescriptor, &term_setting) ) 
			{
				return BAUD_INVALID;
			}
			//
			// Modify the baud rate in the term_setting structure.
			//
			cfsetispeed( &term_setting, baudrate);
			cfsetospeed( &term_setting, baudrate );
            term_setting.c_cflag |= CREAD;          // by jackie
//            term_setting.c_iflag |= CRTS_IFLOW;
//            term_setting.c_iflag |= CDTR_IFLOW;
//            term_setting.c_oflag |= CDSR_OFLOW;
//            term_setting.c_oflag |= CCAR_OFLOW;
			//
			// Apply the modified termios structure to the serial 
			// port. 
			//
			if( -1 == tcsetattr(_fileDescriptor, TCSANOW, &term_setting) ) 
			{
				return BAUD_INVALID;				
			}
			
			break ;
		}
			
		default:
			break;
	}
	
	return [self getBaudRate];
}

-(BaudRate) getBaudRate
{	
	if( -1 == _fileDescriptor) 
	{
        return BAUD_INVALID;
    }
	
    //
    // Get the current terminal settings. 
    //
    struct termios term_setting;
	
    if( -1 == tcgetattr(_fileDescriptor, &term_setting) ) 
	{
        return BAUD_INVALID ;
    }
    //
    // Read the input and output baud rates. 
    //
    speed_t input_baud = cfgetispeed( &term_setting ) ;
    speed_t output_baud = cfgetospeed( &term_setting ) ;
    //
    // Make sure that the input and output baud rates are
    // equal. Otherwise, we do not know which one to return.
    //
    if( input_baud != output_baud ) 
	{
        return BAUD_INVALID; 
    }
	
	BaudRate result = (BaudRate)input_baud;

    return result;
}

-(DataBits) setDataBit:(DataBits)dataBits
{
    if( -1 == _fileDescriptor) 
	{
        return DATA_BITS_INVALID ;
    }
	
    switch(dataBits) 
	{
		case DATA_BITS_5:
		case DATA_BITS_6:
		case DATA_BITS_7:
		case DATA_BITS_8:
		{
			struct termios term_setting ;
			
			if( -1 == tcgetattr(_fileDescriptor, &term_setting)) 
			{
				return DATA_BITS_INVALID ;
			}
			//
			// Set the character size to the specified value. If the character
			// size is not 8 then it is also important to set ISTRIP. Setting
			// ISTRIP causes all but the 7 low-order bits to be set to
			// zero. Otherwise they are set to unspecified values and may
			// cause problems. At the same time, we should clear the ISTRIP
			// flag when the character size is 8 otherwise the MSB will always
			// be set to zero (ISTRIP does not check the character size
			// setting; it just sets every bit above the low 7 bits to zero).
			//
			if( dataBits == DATA_BITS_8 ) 
			{
				term_setting.c_iflag &= ~ISTRIP ; // clear the ISTRIP flag.
			} 
			else 
			{
				term_setting.c_iflag |= ISTRIP ;  // set the ISTRIP flag.
			}
			
			term_setting.c_cflag &= ~CSIZE ;     // clear all the CSIZE bits.
			term_setting.c_cflag |= dataBits ;  // set the character size. 
			//
			// Set the new settings for the serial port. 
			//
			if( -1 == tcsetattr(_fileDescriptor, TCSANOW, &term_setting) ) 
			{
				return DATA_BITS_INVALID ;
			} 
			
			break ;
		}
		default:
			return DATA_BITS_INVALID ;
			break ;
    }
	
    return [self getDataBit];
}

-(DataBits) getDataBit 
{
    if( -1 == _fileDescriptor ) 
	{
        return DATA_BITS_INVALID ;
    }
    //
    // Get the current terminal settings. 
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr(_fileDescriptor, &term_setting) )
	{
        return DATA_BITS_INVALID ;
    }
    //
    // Extract the character size from the terminal settings. 
    //
    int dataBits = (term_setting.c_cflag & CSIZE) ;
	
    switch( dataBits ) 
	{
		case CS5:
			return DATA_BITS_5 ; break ;
		case CS6:
			return DATA_BITS_6 ; break ;
		case CS7: 
			return DATA_BITS_7 ; break ;
		case CS8:
			return DATA_BITS_8 ; break ;
		default:
			//
			// If we get an invalid character, we set the badbit for the
			// stream associated with the serial port.
			//
			return DATA_BITS_INVALID ;
			break ;
    } ;
	
    return DATA_BITS_INVALID ;
}

-(StopBits) setStopBit:(StopBits) stop_bits 
{
    if( -1 == _fileDescriptor) 
	{
        return  STOP_BITS_INVALID;
    }
    //
    // Get the current terminal settings. 
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr(_fileDescriptor, &term_setting) )
	{
		return STOP_BITS_INVALID;
    }
	
    switch( stop_bits ) 
	{
		case StopBitsOne:
			term_setting.c_cflag &= ~CSTOPB ;
			break ;
		case StopBitsTwo:
			term_setting.c_cflag |= CSTOPB ;
			break ;
		default: 
			return  STOP_BITS_INVALID;
			break ;
    }
    //
    // Set the new settings for the serial port. 
    //
    if( -1 == tcsetattr(_fileDescriptor, TCSANOW, &term_setting) )
	{
        return STOP_BITS_INVALID;
    } 
	
	return [self getStopBit];
}

-(StopBits) getStopBit 
{
    if( -1 == _fileDescriptor )
	{
        return STOP_BITS_INVALID;
    }
    //
    // Get the current terminal settings. 
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr(_fileDescriptor, &term_setting) ) 
	{
        return STOP_BITS_INVALID ;
    }
    //
    // If CSTOPB is set then the number of stop bits is 2 otherwise it
    // is 1.
    //
    if( term_setting.c_cflag & CSTOPB ) 
	{
        return StopBitsTwo ; 
    } 
	else 
	{
        return StopBitsOne ;
    }
}

-(Parity) setParity:(Parity) parityValue 
{
    if( -1 == _fileDescriptor )
	{
        return PARITY_INVALID ;
    }
    //
    // Get the current terminal settings. 
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr(_fileDescriptor, &term_setting) )
	{
        return PARITY_INVALID ;
    }
    //
    // Set the parity in the termios structure. 
    //
    switch( parityValue )
	{
		case PARITY_EVEN:
			term_setting.c_cflag |= PARENB ;
			term_setting.c_cflag &= ~PARODD ;
			break ;
		case PARITY_ODD:
			term_setting.c_cflag |= PARENB ;
			term_setting.c_cflag |= PARODD ;
			break ;
		case PARITY_NONE:
			term_setting.c_cflag &= ~PARENB ;
			break ;
		default:
			return PARITY_INVALID ;
    }
    //
    // Write the settings back to the serial port. 
    //
    if( -1 == tcsetattr(_fileDescriptor, TCSANOW, &term_setting) )
	{
        return PARITY_INVALID ;
    } 
	
    return [self getParity] ;
}

-(Parity) getParity 
{
    if( -1 == _fileDescriptor ) 
	{
        return PARITY_INVALID ;
    }
    //
    // Get the current terminal settings. 
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr(_fileDescriptor, &term_setting) ) 
	{
        return PARITY_INVALID ;
    }
    //
    // Get the parity setting from the termios structure. 
    //
    if( term_setting.c_cflag & PARENB ) 
	{   // parity is enabled.
        if( term_setting.c_cflag & PARODD )
		{ // odd parity
            return PARITY_ODD ; 
        } 
		else 
		{                              // even parity
            return PARITY_EVEN ;
        }
		
    }
	else 
	{                                // no parity.
        return PARITY_NONE ;
    }
	
    return PARITY_INVALID ; // execution should never reach here. 
}

-(FlowControls) setFlowControl:(FlowControls) flow_c 
{
    if( -1 == _fileDescriptor ) 
	{
        return FLOW_CONTROL_INVALID ;
    }
    //
    // Flush any unwritten, unread data from the serial port. 
    //
    if( -1 == tcflush(_fileDescriptor, TCIOFLUSH) )
	{
        return FLOW_CONTROL_INVALID ;
    }
    //
    // Get the current terminal settings. 
    //
    struct termios tset;
	
    int retval = tcgetattr(_fileDescriptor, &tset);
	
    if (-1 == retval)
	{
        return FLOW_CONTROL_INVALID ;
    }
    //
    // Set the flow control. Hardware flow control uses the RTS (Ready
    // To Send) and CTS (clear to Send) lines. Software flow control
    // uses IXON|IXOFF
    //
    if ( FLOW_CONTROL_HARD == flow_c ) 
	{
        tset.c_iflag &= ~ (IXON|IXOFF);
        tset.c_cflag |= CRTSCTS;
        tset.c_cc[VSTART] = _POSIX_VDISABLE;
        tset.c_cc[VSTOP] = _POSIX_VDISABLE;
    } 
	else if ( FLOW_CONTROL_SOFT == flow_c )
	{
        tset.c_iflag |= IXON|IXOFF;
        tset.c_cflag &= ~CRTSCTS;
        tset.c_cc[VSTART] = CTRL_Q;
        tset.c_cc[VSTOP]  = CTRL_S;
    } 
	else 
	{
        tset.c_iflag &= ~(IXON|IXOFF);
        tset.c_cflag &= ~CRTSCTS;
    }
	
    retval = tcsetattr(_fileDescriptor, TCSANOW, &tset);
	
    if (-1 == retval)
	{
        return FLOW_CONTROL_INVALID ;
    }
	
    return [self getFlowControl];
}

-(FlowControls) getFlowControl
{
    if( -1 == _fileDescriptor ) 
	{
        return FLOW_CONTROL_INVALID ;
    }
    //
    // Get the current terminal settings.
    //
    struct termios tset ;
	
    if( -1 == tcgetattr(_fileDescriptor, &tset) ) 
	{
        return FLOW_CONTROL_INVALID ;
    }
    //
    // Check if IXON and IXOFF are set in c_iflag. If both are set and
    // VSTART and VSTOP are set to 0x11 (^Q) and 0x13 (^S) respectively,
    // then we are using software flow control.
    //
    if( (tset.c_iflag & IXON)         &&
	   (tset.c_iflag & IXOFF)        &&
	   (CTRL_Q == tset.c_cc[VSTART]) &&
	   (CTRL_S == tset.c_cc[VSTOP] ) ) 
	{
        return FLOW_CONTROL_SOFT ;
    }
	else if ( ! ( (tset.c_iflag & IXON) ||(tset.c_iflag & IXOFF) ) )
	{
        if ( tset.c_cflag & CRTSCTS ) 
		{
            //
            // If neither IXON or IXOFF is set then we must have hardware flow
            // control.
            //
            return FLOW_CONTROL_HARD ;
        } 
		else 
		{
            return FLOW_CONTROL_NONE ;
        }
    }
    //
    // If none of the above conditions are satisfied then the serial
    // port is using a flow control setup which we do not support at
    // present.
    //
    return FLOW_CONTROL_INVALID ;
}

-(short) setVMin:(short) vminValue
{
    if( -1 == _fileDescriptor ) 
	{
        return -1 ;
    }
	
    if ( vminValue < 0 || vminValue > 255 ) 
	{
        return -1 ;
    }
	
    //
    // Get the current terminal settings. 
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr(_fileDescriptor, &term_setting) ) 
	{
        return -1 ;
    }
	
    term_setting.c_cc[VMIN] = (cc_t)vminValue;
    //
    // Set the new settings for the serial port. 
    //
    if( -1 == tcsetattr(_fileDescriptor, TCSANOW, &term_setting) ) 
	{
        return -1 ;
    } 
	
    return [self getVMin];
}

-(short) getVMin
{
    if( -1 == _fileDescriptor )
	{
        return -1 ;
    }
    //
    // Get the current terminal settings. 
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr(_fileDescriptor, &term_setting) ) 
	{
        return -1 ;
    }
	
    return term_setting.c_cc[VMIN];
}

- (short) setVTime:(short) vtime 
{
    if( -1 == _fileDescriptor )
	{
        return -1 ;
    }
	
    if ( vtime < 0 || vtime > 255 ) 
	{
        return -1 ;
    };
	
    //
    // Get the current terminal settings. 
    //
	
    struct termios term_setting ;
	
    if( -1 == tcgetattr(_fileDescriptor, &term_setting) ) 
	{
        return -1 ;
    }
	
    term_setting.c_cc[VTIME] = (cc_t)vtime;
    //
    // Set the new settings for the serial port. 
    //
    if( -1 == tcsetattr(_fileDescriptor, TCSANOW, &term_setting) )
	{
        return -1 ;
    }
	
    return [self getVTime];
}

-(short) getVTime 
{
    if( -1 == _fileDescriptor ) 
	{
        return -1 ;
    }
    //
    // Get the current terminal settings. 
    //
    struct termios term_setting ;
	
    if( -1 == tcgetattr(_fileDescriptor , &term_setting) )
	{
        return -1 ;
    }
	
    return term_setting.c_cc[VTIME];
}

-(void)Set_globalBuffer:(NSString*)buffer
{
    [_globalBuffer setString:buffer];
//	[_globalBuffer release];
//	[buffer retain];	
//	_globalBuffer = [NSMutableString stringWithString:buffer];
}

-(int) GetNumOfDataInBuffer
{
	int result = 0;
	int err = ioctl(_fileDescriptor, FIONREAD, (char *)&result);
	
	if (err != 0)
	{
		result = -1;
	}
	
	return result;
}


-(NSString*)ReadBuffer
{
	char chr_to_str[SERIALPORT_MAXBUFSIZE] = "";
	size_t num = 0;
	
	if( [self GetNumOfDataInBuffer] > 0 )
	{
		num = read(_fileDescriptor,&chr_to_str,SERIALPORT_MAXBUFSIZE);
		
		chr_to_str[num + 1] = '\0';
		
		for(int i = 0;i < num;i++)
		{
			if(chr_to_str[i] == '\0')
			{
				chr_to_str[i] = ' ';
			}
		}
		
		NSString* readBuffer = [[NSString alloc] initWithCString:chr_to_str encoding:NSUTF8StringEncoding];
        
        if (readBuffer != nil)
        {
            if([_globalBuffer length] > 0)
            {
                [_globalBuffer appendString:readBuffer];
            }
            else
            {
                [_globalBuffer setString:readBuffer];
            }
        }
        
		
//		[readBuffer autorelease];
    }
	
//	[pool release];
    
    return _globalBuffer;
}

//private
-(void) ReadSerialPort
{
//	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	char chr_to_str[SERIALPORT_MAXBUFSIZE] = "";
	size_t num = 0;
	
	if( [self GetNumOfDataInBuffer] > 1 ) 
	{
		num = read(_fileDescriptor,&chr_to_str,SERIALPORT_MAXBUFSIZE);
		
		chr_to_str[num + 1] = '\0';
		
		for(int i = 0;i < num;i++)
		{
			if(chr_to_str[i] == '\0')
			{
				chr_to_str[i] = ' ';
			}
		}
		
		NSString* readBuffer = [[NSString alloc] initWithCString:chr_to_str encoding:NSUTF8StringEncoding];
        
        if (readBuffer != nil)
        {		
            if([_globalBuffer length] > 0)
            {
                [_globalBuffer appendString:readBuffer];	
            }
            else
            {
                [_globalBuffer setString:readBuffer];
            }
        }

		
	//	[readBuffer autorelease];
    }
	
//	[pool release];
}

-(NSString*) ReadExisting
{
//	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
    NSMutableString* existing = [[NSMutableString alloc] init];
    int times = 0 ;
    
    while ([self GetNumOfDataInBuffer] > 0) {
        [self ReadBuffer];
        times ++ ;
        [NSThread sleepForTimeInterval:0.01];
        
        if(times >= 500)
        {
            break ;
        }
    }
	
    [existing appendString:_globalBuffer];
    [self Set_globalBuffer:@""];
//	[pool release];
	
	return existing;
}

-(NSString*) ReadLine
{
	return [self ReadTo:@"\n"];
}


-(NSString*)CircleReadTo:(NSString*)data
{
    if(data.length == 0)
    {
        return @"" ;
    }
    
    NSMutableString *rtnValue = [[NSMutableString alloc] init] ;
    
    while (!self.stopped)
    {
        [self ReadBuffer] ;
        
        if([_globalBuffer containsString:data])
        {
            break ;
        }
        
        [NSThread sleepForTimeInterval:0.001] ;
    }
    
    
    [rtnValue appendString:_globalBuffer] ;
    
    [_globalBuffer setString:@""] ;
    return rtnValue ;
}

-(NSString*) ReadTo:(NSString*)data
{
	return [self ReadTo:data Timeout:_readTimeout ReadInterval:_rest];
}

-(NSString*) ReadToRegularLen:(int)dataLen Timeout:(int)Timeout ReadInterval:(double)restTime
{
    if(dataLen == 0)
    {
        return @"" ;
    }
    
    NSMutableString* result = [[NSMutableString alloc] init];
    HiperTimer* hp = [[HiperTimer alloc] init];
    
    [hp Start];
    
    while (!self.stopped)
    {
        [self ReadBuffer];
        
        if(_globalBuffer.length >= dataLen)
        {
            break ;
        }
        
        if([hp durationMillisecond] >= Timeout)
        {
            break;
        }
        
        [NSThread sleepForTimeInterval:restTime / 1000.0];
    }
    
    if (_globalBuffer.length >= dataLen)
    {
        [result appendString:[_globalBuffer substringToIndex:dataLen]];
//        result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* remainbuff = [_globalBuffer substringFromIndex:dataLen];
        [_globalBuffer setString:remainbuff];
    }
    
    return result;

}

-(NSString*) ReadToRegularFormat:(NSString *)pattern Timeout:(int)Timeout ReadInterval:(double)restTime
{
    if([pattern length] == 0)
    {
        return @"" ;
    }
    
    NSRange range ;
    NSString* result = @"" ;
    NSError* err = [[NSError alloc] init] ;
    HiperTimer* hp = [[HiperTimer alloc] init] ;
    NSRegularExpression* regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&err] ;
    [hp Start] ;
    
    while (!self.stopped) {
        [self ReadBuffer] ;
        range = [regex rangeOfFirstMatchInString:_globalBuffer options:0 range:NSMakeRange(0, _globalBuffer.length)];
        
        if (range.length > 0) {
            break;
        }
        
        if([hp durationMillisecond] >= Timeout)
        {
            break;
        }
        
        [NSThread sleepForTimeInterval:restTime / 1000.0];
    }
    
    if(range.length >0 )
    {
        result = _globalBuffer ;
        result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [_globalBuffer setString:@""];
    }
    
    return result ;
}


-(NSString*) ReadTo:(NSString*)data Timeout:(int)Timeout ReadInterval:(double)restTime
{
//	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	
	if([data length] == 0)
	{
		return @"";
	}
	
	NSRange range;

    NSString* result = @"";
	HiperTimer* hp = [[HiperTimer alloc] init];
	[hp Start];
	
	while (!self.stopped)
	{
        [self ReadBuffer];

        range = [_globalBuffer rangeOfString:data];
        
        if (range.length > 0) {
            break;
        }
		
		if([hp durationMillisecond] >= Timeout)
		{
		    break;
		}
		
		[NSThread sleepForTimeInterval:restTime / 1000.0];
	}
	
    
    result = _globalBuffer ;
    
    [_globalBuffer setString:@""] ;
    
//	if (range.length > 0)
//	{
//        result = [_globalBuffer substringToIndex:range.location + range.length];
//        result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        NSString* remainbuff = [_globalBuffer substringFromIndex:range.location + range.length];
//        [_globalBuffer setString:remainbuff];
//	}
//    else
//    {
//        result = _globalBuffer ;
//        
//        [_globalBuffer setString:@""] ;
//    }
	
	
	return result;
}

-(NSString*)ReadMutableEndStr:(NSString *)data TimeOut:(int)Timeout ReadInterval:(double)restTime
{
    if(data.length == 0)
    {
        return @"" ;
    }
    
    NSString* result ;
    NSRange range;
    NSString* tempStr ;
    BOOL isFind = NO ;
    
    NSArray* array = [data componentsSeparatedByString:@";"] ;
    
    HiperTimer* hp = [[HiperTimer alloc] init];
    [hp Start];
    
    while (!self.stopped)
    {
        [self ReadBuffer];
        
        for (NSString* str in array)
        {
            range = [_globalBuffer rangeOfString:data] ;
            
            if (range.length > 0)
            {
                tempStr = str ;
                isFind = YES ;
                break;
            }
        }
        
        if(isFind)
        {
            break ;
        }
        
        if([hp durationMillisecond] >= Timeout)
        {
            break;
        }
        
        [NSThread sleepForTimeInterval:restTime / 1000.0];
    }
    
    
    result = _globalBuffer ;
    
    [_globalBuffer setString:@""] ;
    
//    if (range.length > 0)
//    {
//        result = [_globalBuffer substringToIndex:range.location + range.length];
//        result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        NSString* remainbuff = [_globalBuffer substringFromIndex:range.location + range.length];
//        [_globalBuffer setString:remainbuff];
//    }
    
    return result ;
}

-(void) Write:(NSString*)data
{	
//	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
	
	NSData *dataValue = [data dataUsingEncoding:NSUTF8StringEncoding];
	[self WriteData:dataValue];
	
//	[pool release];
}

-(void) WriteLine:(NSString*)data
{
	NSString* dataline = [[NSString alloc] initWithFormat:@"%@%@", data, _newline];
	[self Write:dataline];
//	[dataline release];
}

-(void) WriteData:(NSData*)data
{
	if([self IsOpen])
	{
		const char *dataBytes = (const char*)[data bytes];
		NSUInteger dataLen = [data length];
		
        write(_fileDescriptor, dataBytes, dataLen);
	}
}

-(const char*) ReadBytes:(int)timeout
{
	//NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	char chr_to_str[SERIALPORT_MAXBUFSIZE] = "";
	static char result[SERIALPORT_MAXBUFSIZE] = "";
	size_t num = 0;
	
	HiperTimer* hp = [[HiperTimer alloc] init];
	
	[hp Start];
	
	while (1)
	{
		if([self GetNumOfDataInBuffer] > 0)
		{
			num = read([self fileDescriptor],&chr_to_str,SERIALPORT_MAXBUFSIZE);
			
			unsigned long len = strlen(result);
			
			for (int i = 0; i < num; i++)
			{
				result[len + i] = chr_to_str[i];
			}
			
			//len = strlen(result);
			
//			if (result[len -1] == 0x0a && result[len - 2] == 0x0d)
//			{
//				break;
//			}
		}
		
		if ([hp durationMillisecond] >= timeout)
		{
			break;
		}
        
        [NSThread sleepForTimeInterval:0.01];
	}
	
	//[pool release];
	
	return (const char*)result;
}

-(const char*) readBytesOfCount:(int) count
{
    char buffer[SERIALPORT_MAXBUFSIZE] = "";
    char result[SERIALPORT_MAXBUFSIZE] = "";
    long num, length = 0;
    
    while([self GetNumOfDataInBuffer] > 0)
    {
        num = read(self.fileDescriptor, &buffer, SERIALPORT_MAXBUFSIZE);
        
        for(int i = 0; i < num ; i++)
        {
            result[length + i] = buffer[i];
        }
        
        length += num;
    }
    
    long startIdx = length - count;
    
    char *rValue;
    rValue = (char*)malloc(count);
    memset(rValue, 0, count);
    for(int i = 0; i<count; i++)
    {
        rValue[i] = result[startIdx + i];
    }
    
    return (const char*)rValue;
}

-(void) WriteBytes:(const char*) data Len:(int)length
{
	if([self IsOpen])
	{
		write([self fileDescriptor], data, length);
	}
}

-(NSString*) ReadSerialPortToChar:(char) strEnd
{
    //  NSString* stringResult = @"";
    
	char chr_to_str[SERIALPORT_MAXBUFSIZE] = "";
	size_t num = 0;
    [_globalBuffer setString:@""];
    while (YES)
    {
        BOOL isFind = NO;
        [NSThread sleepForTimeInterval:0.1];
        if( [self GetNumOfDataInBuffer] > 1 )
        {
            num = read([self fileDescriptor],&chr_to_str,SERIALPORT_MAXBUFSIZE);
            
            chr_to_str[num] = '\0';
            
            for(int i = 0;i < num;i++)
            {
                if(chr_to_str[i] == '\0')
                {
                    chr_to_str[i] = ' ';
                }
            }
            
            // printf("----\n");
            for (int j = 0; j < num; j++)
            {
                //   printf("%c",chr_to_str[j]);
                if (chr_to_str[j] == strEnd)
                {
                    chr_to_str[j+1] = '\0';
                    isFind =YES;
                }
            }
        }
        
        NSString* readBuffer = [[NSString alloc] initWithCString:chr_to_str encoding:NSUTF8StringEncoding];
        
        [_globalBuffer appendString:readBuffer];
        
        
        if (isFind == YES)
        {
            break;
        }
    }
    
    
    return [_globalBuffer copy];
}

/**************  stoppable implement  ***************/

-(void)setStopped:(BOOL)stopped
{
    mStopped = stopped;
}

-(BOOL)stopped
{
    return mStopped;
}

/****************************************************/

@end
