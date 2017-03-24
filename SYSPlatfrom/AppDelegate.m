//
//  AppDelegate.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import "LoadInterface.h"

@interface AppDelegate ()
{
    IBOutlet NSWindow *loadinterface ;
}

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
@synthesize slotview1 = _slotview1 ;
@synthesize app = _app ;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    self.window.title = [[NSString alloc] initWithFormat:@"%@_%@",[Config instance].softwareName,[Config instance].softwareVersion] ;
    _bootMenu.title = [Config instance].softwareName ;
    self.slotviewcode1  = [[SlotViewCode alloc] initWithNibName:@"SlotView" bundle:nil] ;
    [self.slotviewcode1 setTitle:@"station1"] ;
    [_slotview1 addSubview:self.slotviewcode1.view] ;
    
//    self.slotviewcode2 = [[SlotViewCode alloc] initWithNibName:@"SlotView" bundle:nil] ;
//    [self.slotviewcode2 setTitle:@"station2"] ;
    
    
    [NSThread detachNewThreadSelector:@selector(updateHardwareLinkStatus) toTarget:self withObject:nil] ;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void)updateHardwareLinkStatus
{
    while (true)
    {
        if([self.slotviewcode1 isSequencerConnected])
        {
            
        }
        else
        {
            
        }
        
        [NSThread sleepForTimeInterval:1] ;
    }
}

- (IBAction)btnMenuSetting:(id)sender
{
    ((LoadInterface *)loadinterface.delegate).winType = 1;
    [NSApp beginSheet:loadinterface
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];

}
- (IBAction)btnMenuLoopTest:(id)sender
{
    ((LoadInterface *)loadinterface.delegate).winType = 2;
    [NSApp beginSheet:loadinterface
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo:NULL];
}
- (IBAction)btnMenuQuit:(id)sender
{
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [loadinterface close];
    
}

-(BOOL)windowShouldClose:(id)sender
{
    [self.slotviewcode1 Close] ;
    [self.slotviewcode2 Close] ;
    
    [_app terminate:self] ;
    
    return YES ;
}

@end
