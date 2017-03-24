//
//  TestEngine.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/18.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestEngine : NSObject

-(instancetype)initWithStationNum:(int)stationNum ;

-(void)setStationNum:(int)stationNum ;

-(void)startTest ;

-(void)SetSN:(NSString*)scanSN ;

-(void)Close ;

@end
