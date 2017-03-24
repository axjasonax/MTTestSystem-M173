//
//  Config.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "Config.h"
#import "JsonOperate.h"
#import "SerialPort.h"
#define CONFIG_NAME @"config"
#define SERIAL @"SERIAL"

@interface Config()
{
    NSMutableDictionary *configData ;
}
@property (nonatomic) NSMutableArray* devices;

@end

@implementation Config


+ (Config *)instance
{
    static Config* _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[Config alloc] init];
    });
    
    return _instance;
}

-(instancetype)init
{
    if(self = [super init])
    {
        [self loadFile] ;
    }
    
    return self ;
}


-(void)loadFile
{
    NSString* configPath = [[NSBundle mainBundle ] pathForResource:CONFIG_NAME ofType:@"plist"];
    configData = [[NSMutableDictionary alloc] initWithContentsOfFile:configPath];
    
    if(configPath != nil)
    {
        self.devices                = [configData objectForKey:@"devices"];
        self.jsonFilePath           = [configData objectForKey:@"jsonFilePath"] ;
        self.softwareName           = [configData objectForKey:@"softwareName"] ;
        self.slotCount              = [[configData objectForKey:@"slotCount"] intValue] ;
        self.softwareVersion        = [configData objectForKey:@"softwareVersion"] ;
        self.isAutoGetSN            = [[configData objectForKey:@"isAutoGetSN"] boolValue] ;
        self.startFileName          = [configData objectForKey:@"startFileName"] ;
        self.resetFileName          = [configData objectForKey:@"resetFileName"] ;
        self.testFileName           = [configData objectForKey:@"testFileName"] ;
        self.reportPlugin           = [configData objectForKey:@"reportPlugin"] ;
        self.testPlugin             = [configData objectForKey:@"testPlugin"] ;
        self.zmqTestPlugin          = [configData objectForKey:@"zmqTestPlugin"] ;
        self.uartLogFloderPath      = [configData objectForKey:@"uartLogFloderPath"] ;
        self.isDebugMode            = [[configData objectForKey:@"isDebugMode"] boolValue] ;
        self.tmpBlobFilePath        = [configData objectForKey:@"tmpBlobFilePath"] ;
        self.sequenceFilepath       =  [NSString stringWithFormat:@"%@%@", NSHomeDirectory(),[configData objectForKey:@"sequenceFilePath"]] ;
        self.jsonrpcVersion         = [configData objectForKey:@"jsonrpcVersion"] ;
        self.idValue                = [configData objectForKey:@"idValue"] ;
        self.pubChannel             = [configData objectForKey:@"pubChannel"] ;
        self.cbPortKey              = [configData objectForKey:@"cbPortKey"] ;
        self.testplanFilePath       = [[NSBundle mainBundle ] pathForResource:[configData objectForKey:@"testplanFilePath" ] ofType:@"csv"];
        self.expFilepath            = [configData objectForKey:@"expFilepath"] ;
        self.password               = [configData objectForKey:@"password"] ;
        self.cbPassword             = [configData objectForKey:@"cbPassword"] ;
        self.testfunctionDir        = [configData objectForKey:@"testFunctionDir"] ;
    }
    
    self.dirPort = [JsonOperate readFile:[[NSBundle mainBundle] pathForResource:self.jsonFilePath ofType:@"json"] ] ;
    self.isEnableLoopTest = NO ;
}



// 初始化串口设备
- (void) deviceInit
{
    _portBox = [[NSMutableDictionary alloc] init];
    
    if(_portList == nil)
    {
        _portList = [[NSMutableArray alloc] init] ;
    }
    
    [_portList removeAllObjects] ;
    
    for (NSDictionary* info in self.devices)
    {
        if ([[info objectForKey:@"communication_mode"] isEqual:SERIAL]) { // 指定通信方式
            NSString* deviceType = [info objectForKey:@"deviceType"]; // 指定设备
            NSString* name = [info objectForKey:@"name"];             // 串口名称
            NSNumber* baudrate = [info objectForKey:@"baudrate"];
            NSNumber* databits = [info objectForKey:@"databits"];
            NSNumber* stopbits = [info objectForKey:@"stopbits"];
            NSNumber* parity = [info objectForKey:@"parity"];
            [_portList addObject:name] ;
            
            if (deviceType != nil && ![deviceType isEqualToString:@""]) {
                SerialPort* port = [[SerialPort alloc] initWithDevicepath:name];
                [port setBaudrate_:baudrate];
                [port setDatabits_:databits];
                [port setStopbits_:stopbits];
                [port setParity_:parity];
                [_portBox setObject:port forKey:deviceType];
                
                
            }
        }
    }
    
    
}


-(NSString*)sequenceFilepath
{
    if(_sequenceFilepath == nil)
    {
        _sequenceFilepath = [[NSString alloc] init] ;
    }
    
    if(_sequenceFilepath.length > 0)
    {
        if([_sequenceFilepath pathExtension] == nil || [[_sequenceFilepath pathExtension] isEqualToString:@""])
        {
            _sequenceFilepath = [_sequenceFilepath stringByAppendingPathExtension:@"py"] ;
        }
    }
    
    return _sequenceFilepath ;
    
}

-(NSMutableDictionary*)dirPort
{
    if(_dirPort == nil)
    {
        _dirPort = [[NSMutableDictionary alloc] init] ;
    }
    
    return _dirPort;
}

-(NSArray*)startFileName
{
    if(_startFileName == nil)
    {
        _startFileName = [[NSMutableArray alloc] init] ;
    }
    
    return _startFileName ;
}


-(NSString*)ipAddress
{
    if(_ipAddress == nil)
    {
        NSHost *myhost =[NSHost currentHost];
        _ipAddress = [[myhost addresses] objectAtIndex:1] ;
    }
    
    return _ipAddress ;
}

-(NSString*)testplanVersion
{
    if(_testplanVersion == nil)
    {
        _testplanVersion = [[NSString alloc] init] ;
    }
    
    return _testplanVersion ;
}

-(NSMutableArray*)testFilePath
{
    if(_testFilePath== nil)
    {
        _testFilePath = [[NSMutableArray alloc] init] ;
        
        for(NSString *str in self.testFileName)
        {
            NSString* filePath = [[NSBundle mainBundle ] pathForResource:str ofType:@"csv"];
            [_testFilePath addObject:filePath] ;
        }
    }
    
    return _testFilePath ;
}




@end
