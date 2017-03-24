
#import "ControlBits.h"
#import "Config.h"
#import "SerialPort.h"

@implementation ControlBits

-(BOOL) ControlBitsCheck
{
	size_t size = 0;
	bool rReply = false;
	
	// firstly: get the size of CB list from GH server file
	// if the file is lost or didn't create it will be false
	rReply = ControlBitsToCheck(NULL, &size, NULL);
	
	if(!rReply || size <= 0)
	{
//        cbGetErrMsg(1);
    }
	
	int *array = NULL;
	array = new int[size];
    
	
	char **stationNames = (char**)malloc(size *sizeof(char*));
	
	if(stationNames == NULL)
	{
		//throw TSException("The memory is not enough for controlbits check!", Diagnostic());
	}
	
	for (unsigned int i = 0; i < size; i++)
	{
		stationNames[i] = new char[256];
	}
	
	rReply = ControlBitsToCheck(array, &size, stationNames);
	
	
	for( unsigned int i = 0; i < size; i++)
	{
		delete[] stationNames[i];
		stationNames[i] = NULL;
	}
	
	free(stationNames);
	stationNames = NULL;
	
	delete[] array;
	array = NULL;
	
	return rReply;
}

-(NSString *) ControlBitsCheck:(NSString*)station
{
    size_t size = 0;
    bool rReply = false;
    NSString *result = @"YES";
    SerialPort *port = [[Config instance].portBox objectForKey:[[NSString alloc] initWithFormat:@"%@%@",[Config instance].cbPortKey,[station substringFromIndex:station.length - 1]]];
    
    // firstly: get the size of CB list from GH server file
    // if the file is lost or didn't create it will be false
    rReply = ControlBitsToCheck(NULL, &size, NULL);
    
    if(!rReply || size <= 0)
    {
        //        cbGetErrMsg(1);
    }
    
    int *array = NULL;
    array = new int[size];
    
    
    char *stationNames[size];
    
    for (unsigned int i = 0; i < size; i++)
    {
        stationNames[i] = new char[256];
    }
    
    rReply = ControlBitsToCheck(array, &size, stationNames);
    
    if (rReply) {
        if (!port.IsOpen) {
            if ([port Open]) {
                NSLog(@"DUT port open");
            }
        }
        for (unsigned int i = 0; i < size; i++)
        {
            NSString *command = [NSString stringWithFormat:@"[CBREAD-%d]",array[i]];
            [port WriteLine:command];
            [NSThread sleepForTimeInterval:0.5];
            NSString *value = [port ReadExisting];
            NSLog(@"CBREAD : %@",value);
            
            NSRange range = [value rangeOfString:@">"];
            if (range.length > 0) {
                range.location = range.location-1;
                NSString *str = [value substringWithRange:range];
                if (![str isEqualToString:@"P"]) {
                    NSLog(@"%s",stationNames[i]);
                    NSString *staName = [NSString stringWithCString:stationNames[i] encoding:NSUTF8StringEncoding];
                    return [NSString stringWithFormat:@"0x%x %@",array[i],staName];
                }
            }
        }
        
    }else{
        result = @"SKIP";
    }
    
    for( unsigned int i = 0; i < size; i++)
    {
        delete[] stationNames[i];
        stationNames[i] = NULL;
        free(stationNames[i]);
        stationNames[i] = NULL;
    }
    
    delete[] array;
    array = NULL;
    
    return result;
}


-(BOOL) ControlBitsClearOnPass
{
	size_t size = 0;
	bool rReply = false;
	
	rReply = ControlBitsToClearOnPass(NULL, &size);
	
	if(!rReply || size <= 0)
	{
		return rReply;
	}
	
	int *array = NULL;
	array =	new int[size];
	
	rReply = ControlBitsToClearOnPass(array, &size);
	
	if(!rReply || size <= 0)
	{
		delete[] array;
		array = NULL;
		
		return rReply;
	}
	
	delete []array;
	array = NULL;
	
	return rReply;
}

-(BOOL) ControlBitsClearOnFail
{
    size_t size = 0;
    bool rReply = false;
    
    rReply = ControlBitsToClearOnFail(NULL, &size);
    
    if(!rReply || size <= 0)
    {
        return rReply;
    }
    
    int *array = NULL;
    array =	new int[size];
    
    rReply = ControlBitsToClearOnFail(array, &size);
    
    if(!rReply || size <= 0)
    {
        delete[] array;
        array = NULL;
        
        return rReply;
    }
    
    delete []array;
    array = NULL;
    
    return rReply;
}

//return the max value of allowed fail station counter.
-(int) StationFailCount
{
	int result = StationFailCountAllowed();
	
	return result;
}

// if true :Station go ahead and Set the control bit;
//   false :Station do not Set the control bit.
-(BOOL)SetControlBits
{
	return StationSetControlBit();
}


-(int) GetFailCount:(NSString *)sn
{
    return GetCountCBsToClearOnFailSN(sn.UTF8String);
}


//获取SHA1 密码
-(NSString *)GetSHA1Password:(NSString *)key1
{
    NSString *key = @"1a8650b2af9c5611da72c00475f51e94392e495c";
    int len1 = (int)key.length / 2;
    unsigned char temChar1[len1];
    
    if(key.length > 0 && key.length % 2 == 0)     //偶数
    {
        for(int i = 0; i < len1; i++)
        {
            int tmp;
            NSRange rang = NSMakeRange(0 + 2 * i, 2);
            sscanf([key substringWithRange:rang].UTF8String, "%x",&tmp);
            temChar1[i] = tmp;
//            temChar1[i] = *[key substringWithRange:rang].UTF8String;
            NSLog(@"tmp = %d",tmp);
        }
    }
    NSLog(@"temChar1 : %s",temChar1);
    
    int len2 = (int)key1.length / 2;
    unsigned char temChar2[len2];
    
    if(key1.length > 0 && key1.length % 2 == 0)     //偶数
    {
        for(int i = 0; i < len2; i++)
        {
            int tmp;
            NSRange rang = NSMakeRange(0 + 2 * i, 2);
            sscanf([key1 substringWithRange:rang].UTF8String, "%x",&tmp);
            temChar2[i] = tmp;
//            temChar2[i] = *[key substringWithRange:rang].UTF8String;
        }
    }
    NSLog(@"temChar2 : %s",temChar2);
    unsigned char *password = CreateSHA1(temChar1, temChar2);
    
    
    NSString *passwordStr = [[NSString alloc] init];
    
    if(len1 == len2)
    {
        unsigned char number[len1];
        
        memcpy(number, password, len1);
        
        
        for(int i = 0 ;i < len1;i++)
        {
            NSString *temp;
            temp = [NSString stringWithFormat:@"%X",number[i]];
            if(1 == temp.length)
            {
                temp = [NSString stringWithFormat:@"0%@",temp];
            }
            
            passwordStr = [passwordStr stringByAppendingFormat:@"%@",temp];
        }
        
    }
    
    FreeSHA1Buffer(password);
    
    return passwordStr;
}

-(NSString *)getCBCommand:(NSString *)result andCBnonce:(NSString *)cbnonce
{
    time_t nowTime;
    time(&nowTime);
    
    NSString *password = [[self GetSHA1Password:cbnonce] substringFromIndex:2];
    
    NSString *swVersion = @"0";
    NSString *version = [[Config instance].softwareVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
    version = [version substringFromIndex:1];
    if (version.length < 4) {
        version = [swVersion stringByAppendingString:version];
    }
    
    NSString* combinedCommand = [NSString stringWithFormat:@"[CBWRITE-0x0b-%@-%ld-%@-%@]",password,nowTime,version,result];
    
    return combinedCommand;
}


@end
