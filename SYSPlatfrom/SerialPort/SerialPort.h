//
//  SerialPort.h
//  SerialPortDemo
//
//  Created by TOD on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.


#import <Cocoa/Cocoa.h>
#import <termios.h>
#import <sys/ioctl.h>
#import "HiperTimer.h"
#import "Stoppable.h"

typedef enum 
{	
	PARITY_NONE = 0,
	PARITY_ODD = 1,
	PARITY_EVEN = 2,
	Parity_Default = PARITY_NONE,
	PARITY_INVALID
} Parity;

typedef enum 
{	
	StopBitsOne = 1,
	StopBitsTwo = 2,
	StopBitsDefault = StopBitsOne,
	STOP_BITS_INVALID
} StopBits;

typedef enum
{
	BAUD_50      = B50,
	BAUD_75      = B75,
	BAUD_110     = B110,
	BAUD_134     = B134,
	BAUD_150     = B150,
	BAUD_200     = B200,
	BAUD_300     = B300,
	BAUD_600     = B600,
	BAUD_1200    = B1200,
	BAUD_1800    = B1800,
	BAUD_2400    = B2400,
	BAUD_4800    = B4800,
	BAUD_9600    = B9600,
	BAUD_19200   = B19200,
	BAUD_38400   = B38400,
	BAUD_57600   = B57600,
	BAUD_115200  = B115200,
	BAUD_230400  = B230400,
#ifdef __linux__
	BAUD_460800 = B460800,
#endif
	BAUD_DEFAULT = BAUD_115200,
	BAUD_INVALID
} BaudRate;

typedef enum  
{
	DATA_BITS_5 = CS5,
	DATA_BITS_6 = CS6,
	DATA_BITS_7 = CS7,
	DATA_BITS_8 = CS8,
	DATA_BITS_DEFAULT = DATA_BITS_8,
	DATA_BITS_INVALID
} DataBits;

typedef enum   
{
	FLOW_CONTROL_HARD,
	FLOW_CONTROL_SOFT,
	FLOW_CONTROL_NONE,
	FLOW_CONTROL_DEFAULT = FLOW_CONTROL_NONE,
	FLOW_CONTROL_INVALID
} FlowControls;



#define SERIALPORT_MAXBUFSIZE  8192UL

#define CTRL_Q  0x11
#define CTRL_S  0x13 

@interface SerialPort : NSObject<Stoppable>
{
@private
	NSString *_devicePath;
	NSString *_newline;
	NSMutableString *_globalBuffer;

	double _rest;
	int _readTimeout;
	int _writeTimeout;
	int _fileDescriptor;
}

@property(readwrite, copy) NSString *devicePath;
@property(readwrite, copy) NSString *newline;
@property(readwrite, copy) NSNumber *Baudrate_;
@property(readwrite, copy) NSNumber *Databits_;
@property(readwrite, copy) NSNumber *Stopbits_;
@property(readwrite, copy) NSNumber *Parity_;
@property(readwrite) double restTime;
@property(readwrite) int readTimeout;
@property(readwrite) int writeTimeout;
@property(readonly) int fileDescriptor;

+(NSArray*)GetPortNames;
-(id) initWithDevicepath:(NSString*)fullpath;

-(BOOL) Open;
-(BOOL) Open:(NSString*) devicepath;
-(BOOL) Open:(NSString *)devicepath BaudRate:(BaudRate)baudrate DataBit:(DataBits) databit
	 StopBit:(StopBits)stopbit Parity:(Parity)parityvalue FlowControl:(FlowControls) flowcontrolValue;
-(BOOL) IsOpen;
-(void) Close;
-(void)clearPort ;

-(int) GetNumOfDataInBuffer;

-(NSString*) ReadLine;
-(NSString*) ReadExisting;
-(NSString*) CircleReadTo:(NSString*)data ;
-(NSString*) ReadTo:(NSString*)data;
-(NSString*) ReadTo:(NSString*)data Timeout:(int)Timeout ReadInterval:(double)restTime;
-(NSString*) ReadToRegularLen:(int)dataLen Timeout:(int)Timeout ReadInterval:(double)restTime ;
-(NSString*) ReadToRegularFormat:(NSString*)pattern Timeout:(int)Timeout ReadInterval:(double)restTime ;
-(NSString*) ReadMutableEndStr:(NSString*)data TimeOut:(int)Timeout ReadInterval:(double)restTime ;
-(const char*) ReadBytes:(int)timeout;
-(const char*) readBytesOfCount:(int)count;
-(NSString*) ReadSerialPortToChar:(char) strEnd;

-(void) Write:(NSString*)data;
-(void) WriteLine:(NSString*)data;
-(void) WriteData:(NSData*)data;
-(void) WriteBytes:(const char*) data Len:(int)length;

-(BaudRate) setBaudRate:(BaudRate)baudrate;
-(BaudRate) getBaudRate;

-(DataBits) setDataBit:(DataBits)dataBit;
-(DataBits) getDataBit;

-(StopBits) setStopBit:(StopBits) stop_bits;
-(StopBits) getStopBit;

-(Parity) setParity:(Parity) parityValue;
-(Parity) getParity;

-(FlowControls) setFlowControl:(FlowControls) flow_c;
-(FlowControls) getFlowControl;

-(void) setTimeout:(int)readTimeout WriteTimeout:(int)writeTimeout;
@end
