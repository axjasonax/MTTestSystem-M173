//
//  TestEngine.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/18.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "TestEngine.h"
#import "PluginForFather.h"
#import "Config.h"
#import "TestItem.h"
#import "LoadTestItems.h"
#import "zmqSocket.h"
#import "JsonOperate.h"
#import "ZmqItem.h"

#define HEARTNEAT @"FCT_HEARTBEAT"
#define TESTENGINEREP @"TEST_ENGINE_PORT"
#define TESTENGINEPUB @"TEST_ENGINE_PUB"
#define PUBCHANNEL @"PUB_CHANNEL"
#define PUBMODE 1
#define REPMODE 4

#define GROUP @"GROUP"
#define TID @"TID"
#define DESCRIPTION @"DESCRIPTION"
#define FUNCTION @"FUNCTION"
#define TIMEOUT @"TIMEOUT"
#define PARAM1 @"PARAM1"
#define PARAM2 @"PARAM2"
#define UNIT @"UNIT"
#define LOW @"LOW"
#define HIGH @"HIGH"
#define KEY @"KEY"
#define VALUE @"VAL"
#define FAIL_COUNT @"FAIL_COUNT"

#define RESULTKEY @"result"
#define METHODKEY @"method"
#define ARGSKEY @"args"
#define STARTKEY @"start_test"
#define ENDKEY @"end_test"
#define IDKEY @"id"
#define RPCKEY @"jsonrpc"
#define UNITKEY @"unit"
#define TIMEOUTKEY @"timeout"
#define KWARGSKEY @"kwargs"

#define PUBCHANNEL @"PUB_CHANNEL"



@interface TestEngine()
{
    NSArray* _testItems;
    NSArray* _startItems ;
    NSArray* _resetItems ;
    NSArray* _debugItems ;
    NSString *_sn ;
    
    NSMutableArray *_testPlugins;
    NSMutableArray *_reportPlugins;
    NSMutableArray *_zmqTestPlugin ;
    NSMutableDictionary *_testPluginDic ;
    NSMutableDictionary *_reportPluginDic ;
    NSMutableDictionary *_zmqTestPluginDic ;
    NSMutableDictionary *_zmqTestItems ;
    
    NSString *_errInfo;
    int _stationNum ;
    dispatch_once_t ponceToken;
    NSDateFormatter *pfmt;

    id<PluginForFather> _plugin;
    int testingItem ;

    zmqSocket *socketREPEngine ;
    zmqSocket *socketPUBEngine ;
    BOOL isCircleTest ;
    int verbosityLevel  ;
}

@end


@implementation TestEngine

-(instancetype)initWithStationNum:(int)stationNum
{
    if(self = [super init])
    {
        testingItem = 0 ;
        _stationNum = stationNum ;
        _errInfo = @"No Error";
        _sn = @"" ;
        isCircleTest = YES ;
        verbosityLevel = 0 ;
       
        _testItems = [[LoadTestItems getTestItems:[[Config instance].testFilePath objectAtIndex:_stationNum - 1]] copy]  ;
        _startItems = [LoadTestItems getTestItems:[[NSBundle mainBundle] pathForResource:[[Config instance].startFileName objectAtIndex:stationNum - 1] ofType:@"plist"]] ;
        _resetItems = [LoadTestItems getTestItems:[[NSBundle mainBundle] pathForResource:[[Config instance].resetFileName objectAtIndex:stationNum - 1] ofType:@"plist"]] ;
         _zmqTestItems = [[LoadTestItems getDirTestItems:[[Config instance].testFilePath objectAtIndex:_stationNum - 1]] copy] ;
         [self loadPlugin] ;
        socketPUBEngine = [[zmqSocket alloc] init] ;
        socketREPEngine = [[zmqSocket alloc] init] ;
        [self socketPUBEngineStartWork] ;
        [NSThread detachNewThreadSelector:@selector(socketREPEngineStartWork) toTarget:self withObject:nil] ;
    }
    
    return self ;
}

-(void)closeSocket
{
    [socketREPEngine close] ;
    [socketPUBEngine close] ;
}

-(void)socketPUBEngineStartWork
{
    [socketREPEngine bind:([[[Config instance].dirPort objectForKey:TESTENGINEPUB] intValue] + _stationNum - 1) andType:PUBMODE] ;
    [NSThread sleepForTimeInterval:0.5] ;
    
}

-(void)socketREPEngineStartWork
{
    [socketREPEngine bind:([[[Config instance].dirPort objectForKey:TESTENGINEREP] intValue] + _stationNum - 1) andType:REPMODE] ;
    [NSThread sleepForTimeInterval:0.5] ;
    NSString *receiveMsg = @"" ;
    
    while (isCircleTest)
    {
        receiveMsg = [socketREPEngine receive] ;
        [self analysisREPMsg:receiveMsg] ;
        
        [NSThread sleepForTimeInterval:0.01] ;
    }
}

-(void)analysisREPMsg:(NSString*)msg
{
    if(msg.length <= 0)
    {
        return ;
    }
    
    if([msg isEqualToString:HEARTNEAT])
    {
        [socketREPEngine send:[HEARTNEAT dataUsingEncoding:NSUTF8StringEncoding]] ;
    }
    else
    {
        NSLog(@"TestEngine Revceive:%@",msg) ;
        NSMutableDictionary *dir = [JsonOperate analysisContent:msg] ;
        
        if([[dir objectForKey:METHODKEY] isEqualToString:STARTKEY])
        {
            [[[NSThread alloc] initWithTarget:self selector:@selector(readyToTest:) object:dir] start] ;
        }
        else if ([[dir objectForKey:METHODKEY] isEqualToString:ENDKEY])
        {
            [[[NSThread alloc] initWithTarget:self selector:@selector(endTestToReset:) object:dir] start] ;
        }
        else
        {
             [[[NSThread alloc] initWithTarget:self selector:@selector(zmqItemTestByReceiveMsg:) object:dir] start] ;
        }
    }
}


-(void)zmqItemTestByReceiveMsg:(NSMutableDictionary*)recDir
{
    ZmqItem *zmqItem = [self getZmqTestItem:recDir] ;
    [self zmqItemTest:zmqItem] ;
}


-(ZmqItem*)getZmqTestItem:(NSMutableDictionary*)receiveDir
{
    ZmqItem *item = [[ZmqItem alloc] init] ;
    item.itemID = [receiveDir objectForKey:IDKEY]  ;
    item.itemArgs = [receiveDir objectForKey:ARGSKEY] ;
    item.jsonRpc = [receiveDir objectForKey:RPCKEY] ;
    item.itemMethod = [receiveDir objectForKey:METHODKEY] ;
    item.itemTimeOut = [[receiveDir objectForKey:KWARGSKEY] objectForKey:TIMEOUTKEY] ;
    item.itemUnit = [[receiveDir objectForKey:KWARGSKEY] objectForKey:UNIT] ;
    
    return item ;
}

-(ZmqItem*)getZmqitem:(NSString*)receiveMsg
{
    ZmqItem *item = [[ZmqItem alloc] init] ;
    
    NSMutableDictionary *dirMsg = [JsonOperate analysisContent:receiveMsg] ;
    
    item.itemID = [dirMsg objectForKey:IDKEY] ;
    item.itemArgs = [dirMsg objectForKey:ARGSKEY] ;
    item.jsonRpc = [dirMsg objectForKey:RPCKEY] ;
    item.itemMethod = [dirMsg objectForKey:METHODKEY] ;
    item.itemTimeOut = [[dirMsg objectForKey:KWARGSKEY] objectForKey:TIMEOUTKEY] ;
    item.itemUnit = [[dirMsg objectForKey:KWARGSKEY] objectForKey:UNIT] ;
    
    return item ;
}

-(void)zmqItemTest:(ZmqItem*)item
{
    [self zmqSingleItemTest:item] ;
    [socketPUBEngine send:[self getTestEnginePubMsg:item]] ;
    [socketREPEngine send:[self getTestEngineRepMsg:item]] ;
    
}

-(void)zmqSingleItemTest:(ZmqItem*)item
{
    for(id<PluginForFather> plugin in _zmqTestPlugin)
    {
        [plugin executeWithParameters:@[[[NSString alloc] initWithFormat:@"%i",_stationNum], item,@""]];
    }
    
    item.itemValue = @"1" ;
}

-(NSData*)getTestEngineRepMsg:(ZmqItem*)item
{
    NSMutableDictionary *repDir = [[NSMutableDictionary alloc] init] ;
    [repDir setObject:item.itemID forKey:IDKEY] ;
    [repDir setObject:item.jsonRpc forKey:RPCKEY] ;
    
    if(item.itemUnit == nil || [item.itemUnit isEqualToString:@""])
    {
        [repDir setObject:item.itemValue forKey:RESULTKEY] ;
    }
    else
    {
        [repDir setObject:[NSNumber numberWithFloat:[item.itemValue floatValue] ] forKey:RESULTKEY] ;
    }
    
    NSString *strRtn = [JsonOperate transToJsonFormat:repDir] ;
    
    return [strRtn dataUsingEncoding:NSUTF8StringEncoding] ;
}

-(NSData*)getTestEnginePubMsg:(ZmqItem*)item
{
    NSMutableDictionary *pubDir = [[NSMutableDictionary alloc] init] ;
    NSMutableDictionary *pubSubDir = [[NSMutableDictionary alloc] init] ;
    [pubSubDir setObject:item.itemTimeOut forKey:TIMEOUTKEY] ;
    [pubSubDir setObject:item.itemUnit forKey:UNITKEY] ;
    [pubSubDir setObject:item.itemValue forKey:RESULTKEY] ;
    [pubDir setObject:item.itemID forKey:IDKEY] ;
    [pubDir setObject:item.jsonRpc forKey:RPCKEY] ;
    [pubDir setObject:item.itemMethod forKey:METHODKEY] ;
    [pubDir setObject:item.itemArgs forKey:ARGSKEY] ;
    [pubDir setObject:pubSubDir forKey:KWARGSKEY] ;
    NSDateFormatter *format = [[NSDateFormatter alloc] init] ;
    format.dateFormat = @"hh:mm:ss.SSS" ;
    NSString *ts = [format stringFromDate:[NSDate date]];

    NSString *msgToSend = [NSString stringWithFormat:@"%@,%@,%@,%@",ts,[NSString stringWithFormat:@"TestEngine_%i",_stationNum],[NSString stringWithFormat:@"%i",verbosityLevel],[JsonOperate transToJsonFormat:pubDir]] ;
    
    return [msgToSend dataUsingEncoding:NSUTF8StringEncoding] ;
}

-(void)readyToTest:(NSMutableDictionary *)dirMsg
{
    BOOL result = YES ;
    NSMutableDictionary *dirStart = [[NSMutableDictionary alloc] init] ;
    
    [dirStart setObject:[dirMsg objectForKey:RPCKEY] forKey:RPCKEY] ;
    [dirStart setObject:[dirMsg objectForKey:IDKEY] forKey:IDKEY] ;
    
    for(TestItem *item in _startItems)
    {
//        [self completeItemTest:item] ;
        
        if(item.unit == nil || [item.unit isEqualToString:@""])
        {
            item.testValue = @"PASS" ;
        }
        else
        {
            item.testValue = @"1" ;
        }
        
        result &= item.isPass ;
    }
    
    [dirStart setObject:@"" forKey:RESULTKEY] ;
    [socketREPEngine send:[JsonOperate transToJasonFormatData:dirStart]] ;
    
}

-(void)endTestToReset:(NSMutableDictionary *)dirMsg
{
    BOOL result = YES ;
    NSMutableDictionary *dirEnd = [[NSMutableDictionary alloc] init] ;
    
    [dirEnd setObject:[dirMsg objectForKey:RPCKEY] forKey:RPCKEY] ;
    [dirEnd setObject:[dirMsg objectForKey:IDKEY] forKey:IDKEY] ;
    
    for(TestItem *item in _resetItems)
    {
        if(item.unit == nil || [item.unit isEqualToString:@""])
        {
            item.testValue = @"PASS" ;
        }
        else
        {
            item.testValue = @"1" ;
        }
//        [self completeItemTest:item] ;
        
        result &= item.isPass ;
    }
    
    [dirEnd setObject:@"" forKey:RESULTKEY] ;
    [socketREPEngine send:[JsonOperate transToJasonFormatData:dirEnd]] ;
}


-(TestItem*)workWithValueByRepMsg:(NSMutableDictionary *)dirRep
{
    TestItem *item = [_zmqTestItems objectForKey:[[NSString alloc] initWithFormat:@"%@_%@",[dirRep objectForKey:METHODKEY],[dirRep objectForKey:ARGSKEY]]] ;
    
    [self completeItemTest:item] ;
    
    NSMutableDictionary *dirReturn = [[NSMutableDictionary alloc] init] ;
    
    [dirReturn setObject:[dirRep objectForKey:IDKEY] forKey:IDKEY] ;
    [dirReturn setObject:[dirRep objectForKey:RPCKEY] forKey:RPCKEY] ;
    
    if([dirRep objectForKey:UNIT] == nil || [[dirRep objectForKey:UNIT] isEqualToString:@""])
    {
//        [dirReturn setObject:item.testValue forKey:RESULTKEY] ;
        [dirReturn setObject:@"1" forKey:RESULTKEY] ;
    }
    else
    {
        [dirReturn setObject:[NSNumber numberWithFloat:[item.testValue floatValue]] forKey:RESULTKEY] ;
    }
    
    [NSThread sleepForTimeInterval:0.2] ;
    
//    NSString *dataToSend = [JsonOperate transToJsonFormat:dirReturn];
//    NSDateFormatter *dateFormat = @"hh:mm:ss.SSS";
//    NSString *ts = [dateFormat stringFromDate:[NSDate date]];
//    
//    NSString *msgToSend = [NSString stringWithFormat:@"%@,%@,%@,%@",ts,[NSString stringWithFormat:@"TestEnfine_%i",_stationNum],[NSString stringWithFormat:@"%i",verbosityLevel],dataToSend] ;
//
//    [socketREPEngine send:dataToSend] ;
    [socketREPEngine send:[JsonOperate transToJasonFormatData:dirReturn]] ;
    
    return item ;
}


-(void)setStationNum:(int)stationNum
{
    _stationNum = stationNum ;
}

-(void)SetSN:(NSString *)scanSN
{
    _sn = scanSN ;
}

-(void)Close
{
    [socketPUBEngine close];
    [socketREPEngine close] ;
}

-(void)loadPlugin
{
    //seperate measeure classes from record classes(added by jack on the afternoon of Sep. 1st);
    _testPlugins = [[NSMutableArray alloc] init];
    _reportPlugins = [[NSMutableArray alloc] init];
    _testPluginDic = [[NSMutableDictionary alloc] init];
    _reportPluginDic = [[NSMutableDictionary alloc] init];
    _zmqTestPlugin = [[NSMutableArray alloc] init] ;
    _zmqTestPluginDic = [[NSMutableDictionary alloc] init]  ;
    
    for(NSString *testPluginname in [Config instance].testPlugin)
    {//
        _plugin = (id<PluginForFather>)[[NSClassFromString(testPluginname) alloc] init];
        @try
        {
            if(_plugin != nil)
            {
                [_plugin initializeWithParameters:@[@"", [_testItems objectAtIndex:0]]];
                [_testPlugins addObject:_plugin];
                [_testPluginDic setObject:_plugin forKey:testPluginname];
            }
        }
        @catch(NSException *ex)
        {
            NSLog(@"Exception: %@", [ex description]);
        }
    }
    
    for(NSString *reportPluginName in [Config instance].reportPlugin)
    {
        _plugin = (id<PluginForFather>)[[NSClassFromString(reportPluginName) alloc] init];
        @try
        {
            if(_plugin != nil)
            {
                [_plugin initializeWithParameters:@[@"", [_testItems objectAtIndex:0]]];
                [_reportPlugins addObject:_plugin];
                [_reportPluginDic setObject:_plugin forKey:reportPluginName];
            }
        }
        @catch(NSException *ex)
        {
            NSLog(@"Exception: %@", [ex description]);
        }
    }
    
    
    for(NSString *zmqtestPluginName in [Config instance].zmqTestPlugin)
    {
        _plugin = (id<PluginForFather>)[[NSClassFromString(zmqtestPluginName) alloc] init] ;
        
        @try
        {
            [_plugin initializeWithParameters:@[@"", [_testItems objectAtIndex:0]]];
            [_zmqTestPlugin addObject:_plugin] ;
            [_zmqTestPluginDic setObject:_plugin forKey:zmqtestPluginName] ;
        }
        @catch(NSException *ex)
        {
             NSLog(@"Exception: %@", [ex description]);
        }
    }
    
}


/*****************     ^^^^^Test^^^^^***********************/


-(void)startTest
{
    [[[NSThread alloc] initWithTarget:self selector:@selector(test) object:nil] start] ;
}

-(void)socketTestBody
{
    
}

-(void)testBody
{
    for(TestItem *item in _testItems)
    {
        if(item.isParallelTest)
        {
            [[[NSThread alloc] initWithTarget:self selector:@selector(completeItemTest:) object:item] start] ;
        }
        else
        {
            [self completeItemTest:item] ;
        }
    }
}

-(void)testItemByKey:(NSString*)key
{
    TestItem *item = [_zmqTestItems objectForKey:key] ;
    
    if(item.isParallelTest)
    {
        [[[NSThread alloc] initWithTarget:self selector:@selector(completeItemTest:) object:item] start] ;

    }
    else
    {
        [self completeItemTest:item] ;
    }
}


-(void)completeItemTest:(TestItem*)item
{
    testingItem ++ ;
    [self itemTest:item] ;
    [self itemReport:item] ;
    
    if(![Config instance].isDebugMode)
    {
        [self itemSendLogToLogger:item] ;
    }
    
    testingItem-- ;

}

-(void)itemTest:(TestItem *)item
{
    BOOL result = YES ;
    
    BOOL isNeedTest = item.isNeedTest ;
    
    time_t tmStart,tmEnd = 0 ;
    time(&tmStart) ;
    
    for(TestItem *beforeItem in item.beforeItems)
    {
        if(!isNeedTest)
        {
            beforeItem.isPass = YES ;
            beforeItem.testReturnStr = beforeItem.testValue = @"SKIP" ;
            continue ;
        }
        
        [self singleItemTest:beforeItem] ;
        
        if(item.isCalcBeforeItem)
        {
            result &= beforeItem.isPass ;
        }
    }
    
    for(TestItem *subItem in item.subItems)
    {
        if(!isNeedTest)
        {
            subItem.isPass = YES ;
            subItem.testReturnStr = subItem.testValue = @"SKIP" ;
            continue ;
        }
        
        [self singleItemTest:subItem] ;
        
        if(item.isCalcSubItem)
        {
            result &= subItem.isPass ;
        }
    }
    
    [self singleItemTest:item] ;
    item.isPass &= result ;
    
    if(item.retryItem != nil && item.isNeedReset && !item.isPass)
    {
        if(isNeedTest)
        {
            for(TestItem *retryItem in item.retryItem)
            {
                [self singleItemTest:retryItem] ;
            }
            
            [self singleItemTest:item] ;
        }
    }
    
    for(TestItem *afterItem in item.afterItems)
    {
        if(!isNeedTest)
        {
            afterItem.isPass = YES ;
            afterItem.testReturnStr = afterItem.testValue = @"SKIP" ;
            continue ;
        }
        
        [self singleItemTest:afterItem] ;
    }
    
    time(&tmEnd) ;
    item.startTime = tmStart ;
    item.endTime   = tmEnd ;
}

-(void)singleItemTest:(TestItem *)item
{
    if(!item.isNeedTest)
    {
        item.isPass = YES ;
        item.testValue = item.testReturnStr = @"SKIP" ;
        return ;
    }
    
    time_t tmStart,tmEnd = 0 ;
    time(&tmStart) ;;
    
    for(int i = 0; i < [item.maxTestTimes intValue];i++)
    {
        for(id<PluginForFather> plugin in _testPlugins)
        {
            [plugin executeWithParameters:@[[[NSString alloc] initWithFormat:@"%i",_stationNum], item,@""]];
            
            if(item.isPass)
            {
                break ;
            }
        }
    }
    
    time(&tmEnd) ;
    
    item.startTime = tmStart ;
    item.endTime = tmEnd ;
}


-(void)itemReport:(TestItem *)item
{
    for(TestItem *befortItem in item.beforeItems)
    {
        [self singleItemTest:befortItem] ;
    }
    
    for(TestItem *subItem in item.subItems)
    {
        [self singleItemTest:subItem] ;
    }
    
    [self singleItemTest:item] ;
    
    for(TestItem *afterItem in item.afterItems)
    {
        [self singleItemTest:afterItem] ;
    }
}


-(void)singleItemReport:(TestItem *)item
{
    for(id<PluginForFather> plugin in _reportPlugins)
    {
        [plugin executeWithParameters:@[[[NSString alloc] initWithFormat:@"%i",_stationNum], item, _sn]];
    }
}


/*****************    ^^^^^ZMQ communication^^^^^    ***************************/


-(void)itemSendLogToLogger:(TestItem*)item
{
    [socketPUBEngine send:[self getMsgSendToLogger:item]] ;
}

-(NSString*)getMsgSendToLogger:(TestItem*)logitem
{
    NSMutableDictionary *dirSend = [[NSMutableDictionary alloc] init] ;
//    NSString *pubData = [NSString stringWithFormat:@"%@,%@,%ld,%@,%@"
//                         , [[Config instance].dirPort objectForKey:PUBCHANNEL]
//                         , ts, level, idStr, info];

    
    return [JsonOperate transToJsonFormat:dirSend] ;
}

-(void)itemSendToSequ:(TestItem*)item
{
    [socketREPEngine send:[self getMsgSendToSequ:item]] ;
}


-(NSString*)getMsgSendToSequ:(TestItem*)resultItem
{
    NSString *resultMsg = [[NSString alloc] init] ;
    
    return resultMsg ;
}


@end
