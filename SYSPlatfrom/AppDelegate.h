//
//  AppDelegate.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SlotViewCode.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSApplication *app ;
@property (nonatomic) IBOutlet NSCollectionView *slotview1  ;
@property (assign) IBOutlet NSMenuItem *bootMenu ;
@property (nonatomic) SlotViewCode *slotviewcode1 ;
@property (nonatomic) SlotViewCode *slotviewcode2 ;

@property (nonatomic) NSArray *slotviewcodeArray ;

@end

