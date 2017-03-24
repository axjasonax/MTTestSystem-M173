//
//  Socket.h
//  ZMQTest
//
//  Created by Jason_Mac on 2017/3/18.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface zmqSocket : NSObject

-(BOOL)connect:(NSString*)ipaddress andPort:(int)port andType:(int)type;

-(BOOL)connect:(NSString *)ipaddress andPort:(int)port andType:(int)type andChannel:(NSString *)channel ;

-(BOOL)bind:(int)port andType:(int)type;

-(BOOL)send:(NSData*)cmd ;

-(NSString *)receive ;

-(NSString *)getErrorInfo ;

-(void)setSendMode:(int)mode ;

-(void)setReceiveMode:(int)mode ;

-(void)close ;

@end
