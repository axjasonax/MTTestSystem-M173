//
//  TestItem.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "TestItem.h"

@implementation TestItem

-(instancetype)init
{
    if(self = [super init])
    {
        _uID = [NSNumber numberWithInt:-1] ;
        _itemName = _testCommand = nil ;
        _testValue = _testReturnStr = @"" ;
        _spec = nil;
        _fromSpec = nil ;
        _toSpec = nil ;
        _endStr = nil ;
        _mutableEndStr = nil ;
        _mutableSubStr = nil ;
        _endFormat = nil ;
        _needLength = nil ;
        _unit = nil ;
        _upper = nil ;
        _lower = nil ;
        _type = nil ;
        _bufferName = nil ;
        _function = nil ;
        _errorCode = nil ;
        _isNeedTest = YES ;
        _isNeedClosehardware = NO ;
        _timeout = [NSNumber numberWithInt:2990] ;
        _maxTestTimes = [NSNumber numberWithInt:1] ;
        _isFailToStop = NO ;
        _parser = nil  ;
        _hardwareName = nil ;
        _isExcluHardware = NO ;
        _isNeedReset = NO ;
        _beforeItems = nil ;
        _retryItem = nil ;
        _afterItems =  nil ;
        _subItems = nil ;
        _pdcaAttributeName = nil ;
        _isCalcBeforeItem = NO ;
        _isCalcAfterItem = NO ;
        _isCalcSubItem = NO ;
        _isParallelTest = NO ;
        _isCircleCheck = NO ;
        _minTickTimes = [NSNumber numberWithInt:1] ;
        _startTime = _endTime = 0 ;
        _jsonRpc = _jid = @"" ;
    }
    
    return self ;
}


@end
