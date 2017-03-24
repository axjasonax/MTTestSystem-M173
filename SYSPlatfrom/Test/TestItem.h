//
//  TestItem.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestItem : NSObject

@property(nonatomic) BOOL     isPass ;
@property(nonatomic) NSNumber *uID ;
@property(nonatomic) NSString *itemName ;
@property(nonatomic) NSString *testCommand ;
@property(nonatomic) NSString *specialCommand ;
@property(nonatomic) NSString *testValue ;
@property(nonatomic) NSString *testReturnStr ;
@property(nonatomic) NSString *spec ;
@property(nonatomic) NSString *fromSpec ;
@property(nonatomic) NSString *toSpec ;
@property(nonatomic) NSString *endStr ;
@property(nonatomic) NSString *mutableEndStr ;
@property(nonatomic) NSString *mutableSubStr ;
@property(nonatomic) NSString *endFormat ;
@property(nonatomic) NSNumber *needLength ;
@property(nonatomic) NSString *unit ;
@property(nonatomic) NSString *upper ;
@property(nonatomic) NSString *lower ;
@property(nonatomic) NSString *type ;
@property(nonatomic) NSString *bufferName ;
@property(nonatomic) NSString *function ;
@property(nonatomic) NSString *errorCode ;
@property(nonatomic) BOOL     isNeedTest ;
@property(nonatomic) BOOL     isNeedClosehardware ;
@property(nonatomic) NSNumber *timeout ;
@property(nonatomic) NSNumber *maxTestTimes ;
@property(nonatomic) BOOL     isFailToStop ;
@property(nonatomic) NSString *parser ;
@property(nonatomic) NSString *hardwareName ;
@property(nonatomic) BOOL     isExcluHardware ;
@property(nonatomic) BOOL     isNeedReset ;
@property(nonatomic) NSArray *beforeItems ;
@property(nonatomic) NSArray *retryItem ;
@property(nonatomic) NSArray *afterItems ;
@property(nonatomic) NSArray *subItems ;
@property(nonatomic) NSString *pdcaAttributeName ;
@property(nonatomic) BOOL     isCalcBeforeItem ;
@property(nonatomic) BOOL     isCalcAfterItem ;
@property(nonatomic) BOOL     isCalcSubItem ;
@property(nonatomic) BOOL     isParallelTest ;
@property(nonatomic) BOOL     isCircleCheck ;
@property(nonatomic) NSNumber *minTickTimes ;
@property(nonatomic) time_t   startTime ;
@property(nonatomic) time_t   endTime ;
@property(nonatomic) NSString *jsonRpc ;
@property(nonatomic) NSString *jid ;

@end
