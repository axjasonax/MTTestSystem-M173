//
//  UIPluginForFather.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#ifndef UIPluginForFather_h
#define UIPluginForFather_h

@protocol UIPluginForFather <NSObject>

- (void) flushUI:(NSString *)testResult row:(NSInteger)row isPass:(BOOL)passed;
@optional
- (void) displayTesttime:(double)time;
- (void) displayErrorInfo:(NSString *)errInfo;
@property (nonatomic) BOOL isStopTesting;
@end




#endif /* UIPluginForFather_h */
