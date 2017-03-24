//
//  ZmqItem.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/21.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZmqItem : NSObject

@property(nonatomic)NSString *itemID ;
@property(nonatomic)NSArray  *itemArgs ;
@property(nonatomic)NSString *itemMethod ;
@property(nonatomic)NSString *itemUnit ;
@property(nonatomic)NSNumber *itemTimeOut ;
@property(nonatomic)NSString *jsonRpc ;
@property(nonatomic)NSString *itemValue ;
@property(nonatomic)time_t    startTime ;
@property(nonatomic)time_t    endTime ;
@property(nonatomic)NSString *errorCode ;

@end
