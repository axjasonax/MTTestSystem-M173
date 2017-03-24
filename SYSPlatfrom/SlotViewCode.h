//
//  SlotViewCode.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UpdateEvent.h"
//#import "UIPluginForFather.h"

@interface SlotViewCode : NSCollectionViewItem<UpdateEvent,NSApplicationDelegate>

-(void)setUseable:(BOOL)isCanUse ;

-(BOOL)isSequencerConnected ;

-(void)Close ;

@end
