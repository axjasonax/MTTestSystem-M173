
#import <Cocoa/Cocoa.h>
#import "CBAuth_API.h"


@interface ControlBits : NSObject
{
	
}

-(BOOL) ControlBitsCheck;
-(NSString*) ControlBitsCheck:(NSString*)station ;

-(BOOL) ControlBitsClearOnPass;
-(BOOL) ControlBitsClearOnFail;

-(NSString *)GetSHA1Password:(NSString *)key1;
-(int) GetFailCount:(NSString *)sn;

-(int)  StationFailCount;
-(BOOL) SetControlBits;

@end
