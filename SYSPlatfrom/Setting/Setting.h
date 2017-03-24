//
//  Setting.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/23.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface Setting : NSObject<NSWindowDelegate, NSComboBoxDelegate>
{
    
}

@property BOOL isDeveloper;

@property (assign) IBOutlet  *windows;


@end
