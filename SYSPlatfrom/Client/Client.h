//
//  ClientManage.h
//  SocketTest
//
//  Created by Jason_Mac on 2016/12/27.
//  Copyright © 2016年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

@interface Client : NSObject<GCDAsyncSocketDelegate>
-(instancetype)initClient:(NSString *)ipAddress andPort:(NSUInteger)port andDelegate:(id)dele;
-(BOOL)connect ;
-(void)disconnect ;
-(BOOL)isConnected;
-(void)sendData:(NSString *)data ;
-(NSString *)getAllData ;
-(NSString *)ReadTo:(NSString*)data timeOut:(double)timeout Interval:(double) interval ;
-(NSString *)ReadRegularLen:(int)len timeOut:(double)timeout Interval:(double) interval ;
-(NSString *)ReadRegularFormat:(NSString *)format timeOut:(double)timeout Interval:(double)interval ;
-(NSString *)ReadMutableEndStr:(NSString*)data andSubStr:(NSString*)subStr timeOut:(double)timeout Interval:(double) interval ;
-(NSString *)getErrorInfo ;

@end
