//
//  ZmqItem.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/21.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "ZmqItem.h"

@implementation ZmqItem

-(instancetype)init
{
    if(self = [super init])
    {
        _itemTimeOut = [NSNumber numberWithInt:3000] ;
        _itemID = @"" ;
        _itemArgs = @"" ;
        _itemUnit = @"" ;
        _itemMethod = @"" ;
        _jsonRpc = @"" ;
        _itemValue = @"" ;
        _startTime = _endTime = 0 ;
        _errorCode = @"" ;
    }
    
    return self ;
}

-(void)setItemID:(NSString *)itemID
{
    if(_itemID != nil)
    {
        _itemID = itemID ;
    }
}

-(void)setJsonRpc:(NSString *)jsonRpc
{
    if(jsonRpc != nil)
    {
        _jsonRpc = jsonRpc ;
    }
}

-(void)setItemUnit:(NSString *)itemUnit
{
    if(itemUnit != nil)
    {
        _itemUnit = itemUnit ;
    }
}

-(void)setItemTimeOut:(NSNumber *)itemTimeOut
{
    if(itemTimeOut != nil)
    {
        _itemTimeOut = itemTimeOut ;
    }
}

-(void)setItemValue:(NSString *)itemValue
{
    if(itemValue != nil)
    {
        _itemValue = itemValue ;
    }
}

-(void)setItemMethod:(NSString *)itemMethod
{
    if(itemMethod != nil)
    {
        _itemMethod = itemMethod ;
    }
}

-(void)setItemArgs:(NSString *)itemArgs
{
    if(itemArgs != nil)
    {
        _itemArgs = itemArgs ;
    }
}

@end
