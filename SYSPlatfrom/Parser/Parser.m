//
//  Resolver.m
//  X2a
//
//  Created by WangJackie on 15/6/23.
//  Copyright (c) 2015年 WangJackie. All rights reserved.
//

#import "Parser.h"
#import "Config.h"

@implementation Parser

- (TestItem *)parse:(NSString *)serialData usingTestUnit:(TestItem *)unit
{
    // 测试项有左截取字符时，处理情况
    if(serialData != nil)
    {
        if (unit.fromSpec != nil) {
            NSRange range = [serialData rangeOfString:unit.fromSpec];
            if (range.length > 0) {         //截取字符串，删除unit.fromSpec
                serialData = [serialData substringFromIndex:range.location + range.length];
            }
        }
        
        // 测试项有右截取字符时，处理情况
        if (unit.toSpec != nil) {
            NSRange range = [serialData rangeOfString:unit.toSpec];
            if (range.length > 0) {
                serialData = [serialData substringToIndex:range.location];  //截取字符串，删除unit.toSpec
            }
        }
        
        //对Read_FATP_SN项特殊处理，在截取左右字符后只取前12位作为测试值(11.12,SN目前后面会跟一个不可见字符)
        if([unit.itemName isEqualTo:@"GetSN"])
        {
            NSError *err = nil;
            NSString *pattern = [[NSString alloc] initWithFormat:@"[0-9A-Z]{17}$"];
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&err];
            NSRange range = [regex rangeOfFirstMatchInString:serialData options:0 range:NSMakeRange(0, serialData.length)];
            if(range.length >= 17)
            {
                serialData =  [serialData substringWithRange:range] ;
                unit.isPass = YES ;
            }
            else
            {
                unit.isPass = NO ;
            }
        }
        else if(unit.spec != nil && ![unit.spec isEqual:@""]) {
            NSRange range = [serialData rangeOfString:unit.spec];
            
            if (range.length > 0) {
                unit.isPass = YES;
            }
            else {
                unit.isPass = NO;
            }
        }
        else if(unit.upper != nil && unit.lower != nil)
        {
            
            if([serialData doubleValue] >= [unit.lower doubleValue] && [serialData doubleValue] <= [unit.upper doubleValue])
            {
                unit.isPass = YES ;
                
                if([unit.lower doubleValue] == 0 && [serialData doubleValue] == 0)
                {
                    unit.isPass = NO ;
                }
            }
            else
            {
                unit.isPass = NO ;
            }
        }

    }
    else
    {
        serialData = @"";
    }
    
    unit.testValue = serialData;
    
    return unit;
}




@end
