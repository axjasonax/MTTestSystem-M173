//
//  Socket.m
//  ZMQTest
//
//  Created by Jason_Mac on 2017/3/18.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "zmqSocket.h"
#import "zmq.h"

@interface zmqSocket()
{
    void* content ;
    void* socket ;
    int modetype ;
    NSString *errorinfo ;
    int sendMode ;
    int receivemode ;
    NSLock *lock ;
}

@end

@implementation zmqSocket


-(instancetype)init
{
    if(self = [super init])
    {
        errorinfo = [[NSString alloc] init] ;
        sendMode = 0 ;
        receivemode = 0 ;
        lock = [[NSLock alloc] init] ;
    }
    
    return self ;
}

-(BOOL)connect:(NSString *)ipaddress andPort:(int)port andType:(int)type
{
    BOOL flag = YES ;
    int rtn = 0 ;
    content = zmq_ctx_new() ;
    content = zmq_init(1) ;
    socket = zmq_socket(content,type) ;
    NSString *endPoint = [[NSString alloc] initWithFormat:@"tcp://%@:%i",ipaddress,port] ;
    
    NSLog(@"Address:%@ mode:%i",endPoint,type) ;
    rtn = zmq_connect(socket,[endPoint UTF8String]) ;
    
    return flag ;
}

-(BOOL)connect:(NSString *)ipaddress andPort:(int)port andType:(int)type andChannel:(NSString *)channel
{
    BOOL flag = YES ;
    int rtn = 0 ;
    NSData *channelData = [channel dataUsingEncoding:NSUTF8StringEncoding] ;
    content = zmq_ctx_new() ;
    content = zmq_init(1) ;
    socket = zmq_socket(content,type) ;
    NSString *endPoint = [[NSString alloc] initWithFormat:@"tcp://%@:%i",ipaddress,port] ;
    
    NSLog(@"Address:%@ mode:%i",endPoint,type) ;
    
    if(type == ZMQ_SUB)
    {
        rtn = zmq_setsockopt(socket,ZMQ_SUBSCRIBE,[channelData bytes],[channelData length]) ;
    }
    rtn = zmq_connect(socket,[endPoint UTF8String]) ;
    
    return flag ;

}




-(BOOL)bind:(int)port andType:(int)type
{
    BOOL flag = YES ;
    int rtn = 0 ;
    content = zmq_init(1) ;
    socket = zmq_socket(content,type) ;
    NSString* strAddress = [[NSString alloc] initWithFormat:@"tcp://*:%i",port] ;
    NSLog(@"Address:%@ mode:%i",strAddress,type) ;
    
    rtn = zmq_bind(socket,[strAddress UTF8String]) ;
    
    if(rtn != 0)
    {
        flag = NO ;
    }
    
    errorinfo = [[NSString alloc] initWithUTF8String:zmq_strerror(rtn)] ;
    
    return flag ;

}


-(BOOL)send:(NSData *)cmd
{
    [lock lock] ;
    BOOL flag = YES ;
    int rtn =  0 ;
    zmq_msg_t msg ;
    rtn = zmq_msg_init_size(&msg,[cmd length]) ;
    [cmd getBytes:zmq_msg_data(&msg) length:zmq_msg_size(&msg)];
    rtn = zmq_msg_send(&msg,socket,sendMode) ;
    errorinfo = [[NSString alloc] initWithUTF8String:zmq_strerror(rtn)] ;
    rtn = zmq_msg_close(&msg) ;
    [lock unlock] ;
    return flag ;
}


-(NSString *)receive
{
    int rtn = 0 ;
    zmq_msg_t msg ;
    rtn = zmq_msg_init(&msg) ;
    rtn = zmq_msg_recv(&msg,socket,receivemode) ;
    errorinfo = [[NSString alloc] initWithUTF8String: zmq_strerror(rtn)] ;
    size_t length = zmq_msg_size(&msg);
    NSData *data = [NSData dataWithBytes:zmq_msg_data(&msg) length:length];
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    zmq_msg_close(&msg) ;
    
    return str ;

}

-(NSString*)getErrorInfo
{
    return errorinfo ;
}

-(void)setSendMode:(int)mode
{
    sendMode = mode ;
}

-(void)setReceiveMode:(int)mode
{
    receivemode = mode ;
}

-(void)close
{
    
}

@end
