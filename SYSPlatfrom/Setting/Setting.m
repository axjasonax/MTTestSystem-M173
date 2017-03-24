//
//  Setting.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/23.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "Setting.h"
#import "Config.h"


@implementation Setting
{
    IBOutlet NSTextField *_tfLoopTimes;
    IBOutlet NSWindow *_frmLoopTest;
    IBOutlet NSMenuItem *menuLoopTest ;
}

- (IBAction)btnSetLoopTest:(id)sender {
    menuLoopTest.state = NSOnState;
    [Config instance].isEnableLoopTest = YES;
    [Config instance].looptimes = [_tfLoopTimes.stringValue intValue];
    [_frmLoopTest close];
}


@end
