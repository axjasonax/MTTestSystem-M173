//
//  SerialPortList.m
//  SerialPortDemo
//
//  Created by TOD on 11/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SerialDevice.h"

//static SerialDevice* _instance = nil;

@implementation SerialDevice

+(SerialDevice *)instance
{
    static SerialDevice* _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
  /*
    @synchronized(self) 
	{
        if (_instance == nil)
		{
#ifndef __OBJC_GC__
			[[self alloc] init]; // assignment not done here
#else
			// Singleton creation is easy in the GC case, just create it if it hasn't been created yet,
			// it won't get collected since globals are strongly referenced.
			_instance = [[self alloc] init];
#endif
		}
    }
	*/
    
    return _instance;
}

#ifdef __OBJC_GC__

+ (id)allocWithZone:(NSZone *)zone
{
    return [super allocWithZone:zone];
}

- (id)copyWithZone:(NSZone *)zone
{
	(void)zone;
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (void)dealloc
{
	[_portNames release], _portNames = nil;
	[super dealloc];
}

#endif

- (NSString *)getNextSerialPort:(io_iterator_t)serialPortIterator
{
	NSString *serialPort = nil;
	
	io_object_t serialService = IOIteratorNext(serialPortIterator);
	
	if (serialService != 0)
	{
		CFStringRef bsdPath = (CFStringRef)IORegistryEntryCreateCFProperty(serialService, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0);
		
		if(bsdPath)
		{
			serialPort = [[NSString alloc] initWithString:(__bridge NSString*)bsdPath];
		}
		
		if(bsdPath != NULL)
		{
			CFRelease(bsdPath);
		}
		

		
		// We have sucked this service dry of information so release it now.
		(void)IOObjectRelease(serialService);
	}
	
	return serialPort;
}

- (void)addAllSerialPortsToArray:(NSMutableArray *)array
{
	kern_return_t kernResult; 
	CFMutableDictionaryRef classesToMatch;
	io_iterator_t serialPortIterator;
	NSString* serialPort;
	
	// Serial devices are instances of class IOSerialBSDClient
	classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
	
	if (classesToMatch != NULL) 
	{
		CFDictionarySetValue(classesToMatch, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDAllTypes));
		
		// This function decrements the refcount of the dictionary passed it
		kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, &serialPortIterator);   
		
		if (kernResult == KERN_SUCCESS)
		{			
			while ((serialPort = [self getNextSerialPort:serialPortIterator]) != nil) 
			{
				[array addObject:serialPort];
			}
			
			(void)IOObjectRelease(serialPortIterator);
		} 
		else
		{
#ifdef AMSerialDebug
			NSLog(@"IOServiceGetMatchingServices returned %d", kernResult);
#endif
		}
	} 
	else
	{
#ifdef AMSerialDebug
		NSLog(@"IOServiceMatching returned a NULL dictionary.");
#endif
	}
}

- (id)init
{
	if ((self = [super init])) 
	{
#if __OBJC_GC__
		_portNames = [[NSMutableArray array] retain];
#else
        _portNames = [[NSMutableArray alloc] init];
#endif
		[self addAllSerialPortsToArray:_portNames];
        
	}
	
	return self;
}

-(NSMutableArray*) portNames
{
#if __OBJC_GC__
    _portNames = [[NSMutableArray array] retain];
#else
    _portNames = [[NSMutableArray alloc] init];
#endif
    [self addAllSerialPortsToArray:_portNames];
    
	return _portNames;
}
@end
