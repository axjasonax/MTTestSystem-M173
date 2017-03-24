//
//  Config.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject
+(Config*)instance ;

@property(nonatomic) NSString *softwareName ;
@property(nonatomic) NSString *softwareVersion ;
@property(nonatomic) NSString *ipAddress ;
@property(nonatomic) NSString *jsonrpcVersion ;
@property(nonatomic) NSString *idValue ;
@property(nonatomic) NSString *pubChannel ;
@property(nonatomic) NSString *testplanVersion ;
@property(nonatomic) NSString *cbPortKey ;
@property(nonatomic) NSString *testplanFilePath ;
@property(nonatomic) NSString *expFilepath ;
@property(nonatomic) NSString *password ;
@property(nonatomic) NSString *cbPassword ;


@property(nonatomic) BOOL isDebugMode ;
@property(nonatomic) BOOL isAutoGetSN ;
@property(nonatomic) BOOL isEnableLoopTest ;
@property(nonatomic) int slotCount ;
@property(nonatomic) int looptimes ;
@property(nonatomic) NSString *jsonFilePath ;
@property(nonatomic) NSString *uartLogFloderPath ;
@property(nonatomic) NSString *csvLogFloderPath ;
@property(nonatomic) NSString *sequenceFilepath ;

@property(nonatomic) NSMutableArray *startFileName ;
@property(nonatomic) NSMutableArray *resetFileName ;
@property(nonatomic) NSMutableArray *testFileName ;
@property(nonatomic) NSMutableArray *testFilePath ;
@property(nonatomic) NSMutableArray *testPlugin ;
@property(nonatomic) NSMutableArray *reportPlugin ;
@property(nonatomic) NSMutableArray *zmqTestPlugin ;
@property(nonatomic) NSMutableArray *tmpBlobFilePath ;

@property(nonatomic) NSMutableDictionary *dirPort ;
@property(nonatomic) NSMutableDictionary* portBox;
@property(nonatomic) NSMutableArray* portList ;
@property(nonatomic) NSMutableDictionary *testfunctionDir ;

@end
