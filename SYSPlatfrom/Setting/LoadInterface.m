//
//  LoadInterface.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/23.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "LoadInterface.h"
#import "Config.h"
#define PASSWORD @"SWDev.MT"
#import "Setting.h"


@implementation LoadInterface

- (IBAction)Load:(id)sender
{
    if ([[_tfPassword stringValue] isEqual:[Config instance].password] || [[_tfPassword stringValue] isEqual:PASSWORD]) {
        // [_window close];
        [NSApp endSheet:self.window];
        //        [self.window close];
        if(self.winType == 1)
        {
            [((Setting*)(_frmSetting.delegate)) setIsDeveloper: [_tfPassword.stringValue isEqual:PASSWORD]];
            [_frmSetting makeKeyAndOrderFront:self];
        }
        else
        {
            if(_menuLoopTest.state == NSOnState)
            {
                _menuLoopTest.state = NSOffState;
                [Config instance].isEnableLoopTest = NO;
            }
            else
            {
                _menuLoopTest.state = NSOnState;
                [Config instance].isEnableLoopTest = YES;
                [_frmLoopTest makeKeyAndOrderFront:self];
            }
        }
        
        _tfPassword.stringValue = @"";
        [_btnCaution setHidden:YES];
    } else {
        [_tfPassword selectText:_tfPassword.stringValue];
        [_btnCaution setHidden:NO];
    }
}

-(void) awakeFromNib
{
    _loopTimes = @"10";
}

-(void) controlTextDidChange:(NSNotification *)obj
{
    NSString *strLoopTimes = [obj.object stringValue];
    NSError *err = nil;
    NSString *pattern = [[NSString alloc] initWithFormat:@"^[0-9]+$"];
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:&err];
    NSRange range = [regex rangeOfFirstMatchInString:strLoopTimes options:0 range:NSMakeRange(0, strLoopTimes.length)];
    
    if(range.length <= 0 || [strLoopTimes isEqualTo:@"0"])
    {
        [obj.object setStringValue:_loopTimes];
    }
    else
    {
        _loopTimes = strLoopTimes;
    }
}

- (IBAction)Cancel:(id)sender {
    [NSApp endSheet:self.window];
    
}

@end
