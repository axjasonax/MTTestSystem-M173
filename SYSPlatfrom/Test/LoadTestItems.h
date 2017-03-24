//
//  LoadTestItems.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadTestItems : NSObject

+(NSMutableArray*)getTestItems:(NSString*)filePath ;

+(NSMutableDictionary*)getDirTestItems:(NSString*)filePath ;


@end
