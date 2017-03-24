//
//  SerialPortList.h
//  SerialPortDemo
//
//  Created by TOD on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/serial/IOSerialKeys.h>

//@class SerialPort;

@interface SerialDevice : NSObject
{
@private
	NSMutableArray* _portNames;
}

+(SerialDevice*) instance;
-(NSString *) getNextSerialPort:(io_iterator_t)serialPortIterator;
-(NSMutableArray*) portNames;   //get serial port lists

@end
