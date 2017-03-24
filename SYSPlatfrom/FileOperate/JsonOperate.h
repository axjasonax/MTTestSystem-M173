//
//  JsonOperate.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonOperate : NSObject

+(NSMutableDictionary*)readFile:(NSString*)filePath ;

+(NSMutableDictionary*)analysisContent:(NSString*)content ;

+(NSMutableDictionary*)analysisNSDataContent:(NSData*)data ;

+(NSString*)transToJsonFormat:(NSMutableDictionary*)dir ;

+(NSData *)transToJasonFormatData:(NSMutableDictionary*)dir ;

+(NSMutableArray*)readCSVFile:(NSString*)filePath ;

@end
