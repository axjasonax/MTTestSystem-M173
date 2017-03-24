//
//  LoadInterface.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/23.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface LoadInterface : NSObject<NSControlTextEditingDelegate>
{
    NSString* _user;
    NSString* _password;
    IBOutlet NSSecureTextField *_tfPassword;
    IBOutlet NSButton *_btnCaution;
    
    //Setting
    IBOutlet NSWindow* _frmSetting;
    
    //Loop Test
    IBOutlet NSWindow *_frmLoopTest;
    IBOutlet NSMenuItem *_menuLoopTest;
    
    NSString *_loopTimes;
}
@property (nonatomic) int winType;
@property (assign) IBOutlet NSWindow* window;
@end
