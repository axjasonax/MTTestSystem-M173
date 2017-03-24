//
//  SlotViewCode.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "SlotViewCode.h"
#import "ImageManager.h"
#import "Config.h"
#import "LoadTestItems.h"
#import "JsonOperate.h"
#import "zmqSocket.h"
#import "TestEngine.h"
#import "expToStartSequ.h"

#define UID @"ID"
#define ITEMNAME @"ItemName"
#define UPPER @"Upper"
#define LOWER @"Lower"
#define VALUE @"Value"
#define UNIT @"Unit"
#define RESULT @"result"
#define SUBITEMS @"subItems"

#define SATEMACHREQPORTKEY @"SEQUENCER_PORT"
#define GUISUBPORTKEY @"SEQUENCER_PUB"

#define REQMode 3
#define SUBMode 2
#define HEARTBEAT @"FCT_HEARTBEAT"
#define PUBCHANNEL @"PUB_CHANNEL"

#define EVENTKEY @"event"
#define GROUPKEY @"group"
#define TIDKEY @"tid"
#define RESULTKEY @"result"
#define HIGHKEY @"high"
#define LOWKEY @"low"
#define UNITKEY @"unit"
#define VERSIONKEY @"version"
#define NAMEKEY @"name"
#define DATAKEY @"data"
#define VALUEKEY @"value"

#define FGROUP @"GROUP"
#define FUNIT  @"UNIT"
#define FLOW   @"LOW"
#define FHIGH  @"HIGH"
#define FTID   @"TID"
#define FVALUE @"VAL"
#define FRESULT @"RESULT"

#define RPASS @"PASS"
#define RFAIL @"FAIL"
#define RSKIP @"SKIP"

#define LOADFILE @"load"
#define RUNTEST @"run"
#define JSONRPC @"jsonrpc"
#define IDKEY @"id"
#define METHOD @"method"
#define ARGS @"args"
#define JSONVERSION @"2.0"

#define ERRORKEY @"error"
#define MESSAGEKEY @"message"

@interface SlotViewCode ()
{
    IBOutlet NSOutlineView *_outlineview ;
    IBOutlet NSTextField *_tbTestTime ;
    IBOutlet NSButton *_btnStart ;
    IBOutlet NSTextView *_errorMsg ;
    IBOutlet NSImageView *_image ;
    IBOutlet NSTextField *_tbSN ;
    IBOutlet NSTextField *_lbSN ;
    IBOutlet NSButton *_btnClear ;
    
    NSArray *testItems ;
    NSMutableArray *dataSource ;
    NSMutableDictionary *dirNameAndID ;
    BOOL isTesting ;
    BOOL isUseable ;
    zmqSocket *socketREQStateMachine ;
    zmqSocket *socketSUBGUI ;
    BOOL isCircleTesing ;
    int stationNum ;
    BOOL isReadyToTest ;
    BOOL isCloseSW ;
    NSString *_version ;
    NSString *_name ;
    NSString *_tempGroup ;
    NSString *_tempTID ;
    BOOL _tempResult ;
    NSMutableDictionary *_tempDir ;
    NSMutableDictionary *_storeItemIndex ;
    int _currentIndex ;
    TestEngine *engine ;
    int itemIndex ;
    expToStartSequ *expwork ;
    NSString *_errorInfo ;
    BOOL isSuccessedComm ;
    NSMutableString *failItemIndex ;
}

@property (strong,nonatomic) ImageManager *imgManager ;

@end

@implementation SlotViewCode

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    isCircleTesing = YES ;
    isTesting = NO ;
    isReadyToTest = NO ;
    isUseable = YES ;
    isCloseSW = NO ;
    _version = @"" ;
    _name = @"" ;
    _tempGroup = @"" ;
    _tempTID = @"" ;
    _errorInfo = @"" ;
    _tempResult = NO ;
    _currentIndex = 0 ;
    isSuccessedComm = NO ;
    itemIndex = 0 ;
    dirNameAndID = [[NSMutableDictionary alloc] init] ;
    _storeItemIndex = [[NSMutableDictionary alloc] init] ;
    _imgManager = [[ImageManager alloc] init] ;
    failItemIndex = [[NSMutableString alloc] init] ;
    
    stationNum = [[self.title substringFromIndex:self.title.length - 1] intValue] ;
    [NSThread sleepForTimeInterval:1] ;
    [self initInterface] ;
    testItems = [[LoadTestItems getTestItems:[[Config instance].testFilePath objectAtIndex:stationNum - 1]] copy] ;
    
    if(expwork == nil)
    {
        expwork = [[expToStartSequ alloc] init] ;
        [expwork start:stationNum] ;
    }

    
    if(socketREQStateMachine == nil)
    {
        socketREQStateMachine = [[zmqSocket alloc] init] ;
        [NSThread detachNewThreadSelector:@selector(socketREQStateMachineStartWork) toTarget:self withObject:nil] ;
    }
    
    if(socketSUBGUI == nil)
    {
        socketSUBGUI = [[zmqSocket alloc] init] ;
        
        [NSThread detachNewThreadSelector:@selector(socketSUBGUIStartWork) toTarget:self withObject:nil] ;

    }

    [self outlineviewInit] ;
    
    if(engine == nil)
    {
        engine = [[TestEngine alloc] initWithStationNum:stationNum] ;
    }
    
    }


-(void)Close
{
    [socketSUBGUI close] ;
    [socketREQStateMachine close] ;
    [engine Close] ;
    [expwork close] ;
}

-(BOOL)isSequencerConnected
{
    return isSuccessedComm ;
}

-(void)socketREQStateMachineStartWork
{
    [socketREQStateMachine connect:@"localhost" andPort:([[[Config instance].dirPort objectForKey:SATEMACHREQPORTKEY] intValue] - 1 + stationNum) andType:REQMode] ;
    [NSThread sleepForTimeInterval:0.5] ;
}


-(BOOL)socketREQSendStart
{
    NSError *err = nil ;
    NSMutableDictionary *dirsend = [[NSMutableDictionary alloc] init] ;
    [dirsend setObject:[Config instance].jsonrpcVersion forKey:JSONRPC] ;
    [dirsend setObject:[Config instance].idValue forKey:IDKEY] ;
    [dirsend setObject:LOADFILE forKey:METHOD] ;
    NSMutableArray *arr = [[NSMutableArray alloc] init] ;
    [arr addObject:[[Config instance].testFilePath objectAtIndex:stationNum - 1]] ;
    [dirsend setObject:arr forKey:ARGS] ;
    NSString *testplanFile = [Config instance].testplanFilePath ;
    NSArray *pathArr = @[testplanFile] ;
    
    NSDictionary *loadfile = @{JSONRPC:JSONVERSION, IDKEY:[Config instance].idValue, METHOD:LOADFILE,ARGS:pathArr};

    [socketREQStateMachine send:[NSJSONSerialization dataWithJSONObject:loadfile options:0 error:&err]] ;
    NSString *reqReceive = [socketREQStateMachine receive] ;
    
    while (reqReceive.length == 0) {
        [NSThread sleepForTimeInterval:0.01] ;
        reqReceive = [socketREQStateMachine receive] ;
    }
    
    if([reqReceive containsString:ERRORKEY])
    {
        NSString *error = [[[JsonOperate analysisContent:reqReceive] objectForKey:ERRORKEY] objectForKey:MESSAGEKEY] ;
        _errorInfo = [NSString stringWithFormat:@"Fail to load testplan fail:The error message is:%@\r加载testplan文件失败， 错误信息为：%@",error,error] ;
        _errorMsg.string = _errorInfo ;
        
        return NO ;
    }
    
     NSDictionary *reqDic = @{JSONRPC:JSONVERSION, IDKEY:[Config instance].idValue, METHOD:RUNTEST};
    
    
    [socketREQStateMachine send:[NSJSONSerialization dataWithJSONObject:reqDic options:0 error:&err]] ;
    
    NSString *strRtn = [socketREQStateMachine receive] ;
    
    if([strRtn containsString:@"error"])
    {
        NSString *error = [[[JsonOperate analysisContent:strRtn] objectForKey:ERRORKEY] objectForKey:MESSAGEKEY] ;
        _errorInfo = [NSString stringWithFormat:@"Fail to start test:The error message is:%@\r启动测试失败， 错误信息为：%@",error,error] ;
        _errorMsg.string = _errorInfo ;
        
        return NO ;
    }
    
    return YES ;
}

-(NSData*)trans:(NSDictionary *)dir
{
    NSMutableData *data = [[NSMutableData alloc] init] ;
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data] ;
    [archiver encodeObject:dir forKey:@"talkData"] ;
    [archiver finishEncoding] ;
    
    return data ;
}

-(void)socketSUBGUIStartWork
{
    [socketSUBGUI connect: @"localhost" andPort: ([[[Config instance].dirPort objectForKey:GUISUBPORTKEY] intValue] -1 + stationNum) andType:SUBMode andChannel:[[Config instance].dirPort objectForKey:PUBCHANNEL]] ;
    [NSThread sleepForTimeInterval:0.5] ;
    NSString *guiSUBRtnValue = [[NSString alloc] init] ;
    
    while (isCircleTesing)
    {
        guiSUBRtnValue = [socketSUBGUI receive] ;
        
        if(guiSUBRtnValue.length > 0)
        {
            [self analysisGuiSUBValue:guiSUBRtnValue] ;
        }
        
        [NSThread sleepForTimeInterval:0.001] ;
    }
}

-(void)analysisGuiSUBValue:(NSString*)value
{
    if([value containsString:HEARTBEAT])
    {
        isSuccessedComm = YES ;
    }
    
    if(!isTesting)
    {
        return ;
    }
    
    if([value containsString:@"event"])
    {
        NSMutableDictionary *dirvalue = [JsonOperate analysisContent:value] ;
        
        int states = [[dirvalue objectForKey:EVENTKEY] intValue] ;
        NSString *getTid ;
        
        switch (states) {
            case 0:
                _version = [[dirvalue objectForKey:DATAKEY] objectForKey:VERSIONKEY] ;
                _name = [[dirvalue objectForKey:DATAKEY] objectForKey:NAMEKEY]  ;
                [self clearInterface] ;
                failItemIndex = [[NSMutableString alloc] init] ;
                break;
            case 1:
                if([[[dirvalue objectForKey:DATAKEY] objectForKey:RESULTKEY] intValue] == 0)
                {
                    [self testResultToDo:NO] ;
                }
                else if([[[dirvalue objectForKey:DATAKEY] objectForKey:RESULTKEY] intValue] == 1)
                {
                    [self testResultToDo:YES] ;
                }
                
                break ;
            case 2:
                _tempGroup = [[dirvalue objectForKey:DATAKEY] objectForKey:GROUPKEY] ;
                _tempTID   = [[dirvalue objectForKey:DATAKEY] objectForKey:TIDKEY] ;
                
                _currentIndex = itemIndex ;
//                _currentIndex = [[_storeItemIndex objectForKey:[NSString stringWithFormat:@"%@&%@",_tempGroup,_tempTID]] intValue] ;
                [self showIndexItem:_currentIndex] ;
                itemIndex ++ ;
                
                break ;
            case 3:
                getTid= [[dirvalue objectForKey:DATAKEY] objectForKey:TIDKEY] ;
                
                if([[dirvalue objectForKey:DATAKEY] objectForKey:TIDKEY] == nil || [[[dirvalue objectForKey:DATAKEY] objectForKey:TIDKEY] isEqualToString:@""])
                {
                   [[dataSource objectAtIndex:_currentIndex] setObject:@"SKIP"forKey:FRESULT] ;
                }
                else
                {
                    _tempResult = [[[dirvalue objectForKey:DATAKEY] objectForKey:RESULT] boolValue] ;
                    
                    [failItemIndex appendString:_tempResult?@"":[NSString stringWithFormat:@"%i,",_currentIndex+1]] ;
                    
                    [[dataSource objectAtIndex:_currentIndex] setObject:(_tempResult ? @"PASS":@"FAIL") forKey:FRESULT] ;
                }
                
                if([getTid isEqualToString:_tempTID])
                {
                    [[dataSource objectAtIndex:_currentIndex] setObject:[[dirvalue objectForKey:DATAKEY] objectForKey:VALUEKEY] forKey:FVALUE] ;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [_outlineview reloadData] ;
//                        [_outlineview scrollRowToVisible:_currentIndex]  ;
                        
                    }) ;
                    
                }
                
                break ;
            default:
                break;
        }
    }
}



-(void)showIndexItem:(int)index
{
    int rowHeight = [_outlineview rowHeight] ;
    NSRect rect = [_outlineview rectOfRow:index] ;
    NSRect visibleRect = [_outlineview visibleRect] ;
    NSPoint point = NSMakePoint(0,0 ) ;
    point.y = rect.origin.y + rowHeight - visibleRect.size.height/2 ;
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        if(index == 0)
        {
            [_outlineview scrollRowToVisible:0] ;
        }
        else if(point.y > 0)
        {
            [_outlineview scrollPoint:point] ;
           
        }
         [_outlineview selectRowIndexes:[[NSIndexSet alloc]initWithIndex:index]  byExtendingSelection:YES] ;
        
//        [_outlineview reloadData] ;
    }) ;

}


-(void)testResultToDo:(BOOL)isPassTest
{
    isTesting = NO ;
    
    dispatch_async(dispatch_get_main_queue()
                   , ^(){
                        _image.image = isPassTest ? self.imgManager.imgPass:self.imgManager.imgFail ;
                       [_btnStart setEnabled:YES];
                       [_outlineview reloadData] ;
                       [_tbSN setEditable:YES] ;
                       
                       if(failItemIndex.length > 0)
                       {
                           _errorMsg.textColor = [NSColor redColor] ;
                           _errorMsg.string = [NSString stringWithFormat:@"Fail item ID :%@",failItemIndex] ;
                           
                       }
                   }) ;
}


-(void)analysisStateMchValue:(NSString*)value
{
    
    if(value.length <= 0)
    {
        return ;
    }
    
    NSLog(@"%@:station%i:%@",@"stateMachineREQ",stationNum,value) ;
    
    if([value containsString:@"{"])
    {
        
    }
}

-(void)setUseable:(BOOL)isCanUse
{
    isUseable = isCanUse ;
}

-(ImageManager*) imgManager
{
    if(_imgManager == nil)
    {
        _imgManager = [[ImageManager alloc] init] ;
    }
    
    return _imgManager ;
}

-(void)initInterface
{
    [_btnClear setHidden:[Config instance].isAutoGetSN] ;
    [_tbSN setEnabled:![Config instance].isAutoGetSN] ;
    _image.image = self.imgManager.imgReady ;
    _image.imageScaling = NSImageScaleAxesIndependently;
}


-(NSMutableDictionary*)singleTestItem:(TestItem*)singleitem andIsTotalCopy:(BOOL)istotalCopy andID:(float)fID
{
    NSMutableDictionary* dir = [[NSMutableDictionary alloc] init] ;
    
    [dir setObject:[NSNumber numberWithFloat:fID] forKey:UID] ;
    [dir setObject:singleitem.itemName forKey:ITEMNAME] ;
    [dir setObject:singleitem.upper forKey:UPPER] ;
    [dir setObject:singleitem.lower forKey:LOWER] ;
    [dir setObject:singleitem.unit forKey:UNIT] ;
    
    if(istotalCopy)
    {
        [dir setObject:singleitem.testValue forKey:VALUE] ;
        
        if(singleitem.isNeedTest)
        {
            [dir setObject:@"SKIP" forKey:RESULT] ;
        }
        else
        {
            [dir setObject:singleitem.isPass?@"PASS":@"FAIL" forKey:RESULT] ;
        }
    }
    
    return dir ;
}


-(void)outlineviewInit
{
    
    if(dataSource == nil)
    {
        dataSource = [[NSMutableArray alloc] init] ;
    
        NSString *indexKey = @"" ;
        NSMutableArray *arrShow = [JsonOperate readCSVFile:[[Config instance].testFilePath objectAtIndex:[[self.title substringFromIndex:self.title.length - 1] intValue] -1]] ;
        [dataSource removeAllObjects] ;
        int uid = 1 ;
        
        for(NSDictionary *dir in arrShow)
        {
            NSMutableDictionary *dirobj = [[NSMutableDictionary alloc] init] ;
            [dirobj setObject:[NSNumber numberWithInt:uid] forKey:UID] ;
            [dirobj setObject:[dir objectForKey: FGROUP] forKey:FGROUP] ;
            [dirobj setObject:[dir objectForKey:FTID] forKey:FTID] ;
            [dirobj setObject:[dir objectForKey:FHIGH] forKey:FHIGH ];
            [dirobj setObject:[dir objectForKey:FLOW] forKey:FLOW] ;
            [dirobj setObject:[dir objectForKey:FUNIT] forKey:FUNIT] ;
            [dirobj setObject:@"" forKey:FVALUE] ;
            [dirobj setObject:@"" forKey:FRESULT] ;
            
            indexKey = [NSString stringWithFormat:@"%@&%@",[dir objectForKey:FGROUP],[dir objectForKey:FTID]] ;
            [_storeItemIndex setObject:[NSNumber numberWithInt:uid - 1] forKey:indexKey] ;
            [dataSource addObject:dirobj] ;
            
            uid++ ;
        }
    }
        
    dispatch_async(dispatch_get_main_queue(), ^(){
            [_outlineview reloadData] ;
        });
    itemIndex = 0 ;
}


-(void)clearInterface
{
    
    if(dataSource == nil)
    {
        dataSource = [[NSMutableArray alloc] init] ;
    }
    
    NSString *indexKey = @"" ;
    NSMutableArray *arrShow = [JsonOperate readCSVFile:[[Config instance].testFilePath objectAtIndex:[[self.title substringFromIndex:self.title.length - 1] intValue] -1]] ;
    [dataSource removeAllObjects] ;
    int uid = 1 ;
    
    for(NSDictionary *dir in arrShow)
    {
        NSMutableDictionary *dirobj = [[NSMutableDictionary alloc] init] ;
        [dirobj setObject:[NSNumber numberWithInt:uid] forKey:UID] ;
        [dirobj setObject:[dir objectForKey: FGROUP] forKey:FGROUP] ;
        [dirobj setObject:[dir objectForKey:FTID] forKey:FTID] ;
        [dirobj setObject:[dir objectForKey:FHIGH] forKey:FHIGH ];
        [dirobj setObject:[dir objectForKey:FLOW] forKey:FLOW] ;
        [dirobj setObject:[dir objectForKey:FUNIT] forKey:FUNIT] ;
        [dirobj setObject:@"" forKey:FVALUE] ;
        [dirobj setObject:@"" forKey:FRESULT] ;
        
        indexKey = [NSString stringWithFormat:@"%@&%@",[dir objectForKey:FGROUP],[dir objectForKey:FTID]] ;
        [_storeItemIndex setObject:[NSNumber numberWithInt:uid - 1] forKey:indexKey] ;
        [dataSource addObject:dirobj] ;
        
        uid++ ;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        //    [_outlineview reloadData] ;
        _image.image = self.imgManager.imgTesting ;
    });
    itemIndex = 0 ;
}

/************    interface action   ***********/

- (IBAction)btnStart:(id)sender
{
    
//    if(!isSuccessedComm)
//    {
//        NSAlert *alert = [[NSAlert alloc] init] ;
//        alert.messageText = @"Sequencer isn't working now !" ;
//        [alert runModal] ;
//        
//        return ;
//    }
    
    if([self socketREQSendStart])
    {
        [_btnStart setEnabled:NO] ;
        isTesting = YES ;
        [NSThread detachNewThreadSelector:@selector(updateTestTime) toTarget:self withObject:nil] ;
    }
}


// 检测SN，启动测试
- (void) controlTextDidChange:(NSNotification *)obj
{
    if([[obj.object identifier] isEqualToString:@"_tfSN"])
    {
        if([obj.object stringValue].length == 12)
        {
            [obj.object setEditable:NO ] ;
            [_btnStart setEnabled:NO] ;
            isTesting = YES ;
            [NSThread detachNewThreadSelector:@selector(updateTestTime) toTarget:self withObject:nil] ;
        }
    }
}


-(void)updateTestTime
{
     NSDate *dStart = [NSDate date];
    
     NSTimeInterval interval ;
    
    while (isTesting) {
        
        [NSThread sleepForTimeInterval:0.1] ;
        interval = -dStart.timeIntervalSinceNow ;
        dispatch_async(dispatch_get_main_queue()
                       , ^(){
        _tbTestTime.stringValue =[[NSString alloc] initWithFormat:@"Test time: %0.1lf S", interval];
                       }) ;
    }
}

- (void) displayTesttime:(double)time
{
    _tbTestTime.stringValue =[[NSString alloc] initWithFormat:@"Test time: %0.1lf S", time];
}


- (void)displayErrorInfo:(NSString *)errInfo
{
    if([errInfo isEqual:@"No Error"])
    {
        [_errorMsg setTextColor:[NSColor blackColor]];
    }
    else
    {
        [_errorMsg  setTextColor:[NSColor redColor]];
    }
    
    _errorMsg.string = errInfo;
}

/*****************            ^^^^Item Sourcce^^^^            *******************/

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    long childNumber = 0;
    
    if(item)
    {
        return [[item valueForKeyPath:SUBITEMS] count] ;
    }
    else
    {
        childNumber = dataSource.count ;
    }
    
    return childNumber;
}

-(BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(nonnull id)item
{
    if([[item valueForKey:SUBITEMS] count] > 0)
    {
        return YES ;
    }
    else
    {
        return NO ;
    }
}

-(id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    id childItem = nil;
    if(item)
    {
        childItem = [[item objectForKey:SUBITEMS] objectAtIndex:index] ;
    }
    else
    {
        childItem = dataSource[index] ;
    }
    
    return childItem;
}


/*********************************************************************************/



/******************       ^^^^^^outlineview delegate^^^^^^       ****************/


//Here to manager the information of outlineview
-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if([tableColumn identifier])
    {
        NSTableCellView *cellView = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
        
        if([[tableColumn identifier] isEqualToString:UID])
        {
            for(NSControl *cr in cellView.subviews)
            {
                if([cr isKindOfClass:NSTextField.class])
                {
                    cr.hidden = [Config instance].isDebugMode ;
                    cr.stringValue =  [item objectForKey:UID] ;
                }
                else
                {
                    cr.hidden = ![Config instance].isDebugMode ;
                    [(NSButton*)cr setState:[[item objectForKey:@"isNeedtest"] isEqualToString:@"YES"]] ;
                    [(NSButton*)cr setTitle:[item objectForKey:UID]] ;
                }
            }
            
        }
        else if([[tableColumn identifier] isEqualToString:FVALUE] || [[tableColumn identifier] isEqualToString:FRESULT])
        {
            NSString *result = [item objectForKey:FRESULT] ;
            NSString *value = [item valueForKeyPath:tableColumn.identifier];
            value = value ? value : @"";
            cellView.textField.stringValue = value;
            
            if([result isEqualToString:RPASS])
            {
                cellView.textField.textColor = [NSColor blueColor] ;
            }
            else if([result isEqualToString:RFAIL])
            {
                cellView.textField.textColor = [NSColor redColor] ;
            }
            else if ([result isEqualToString:RSKIP])
            {
                cellView.textField.textColor = [NSColor blackColor] ;
            }
            
        }
        else
        {
            NSString *value = [item valueForKeyPath:tableColumn.identifier];
            value = value ? value : @"";
            cellView.textField.stringValue = value;
        }
        
        return cellView ;
    }
    else
    {
        return nil ;
    }
}


-(BOOL)outlineView:(NSOutlineView *)outlineView shouldExpandItem:(id)item
{
    if([[item objectForKey:SUBITEMS] count] > 0)
    {
        return YES ;
    }
    else
    {
        return NO;
    }
}


-(void)outlineViewItemDidCollapse:(NSNotification *)notification
{
    NSOutlineView *outlineView = (NSOutlineView *)notification.object;
    [outlineView reloadData];
}

-(void)outlineViewItemDidExpand:(NSNotification *)notification
{
    NSOutlineView *outlineView = (NSOutlineView *)notification.object;
    [outlineView reloadData];
}


//-(void)outlineView:(NSOutlineView *)outlineView didAddRowView:(nonnull NSTableRowView *)rowView forRow:(NSInteger)row
//{
//    //   Here to change the backgroundcolor of each row
//    //    if([[[_outlineview itemAtRow:row] objectForKey:@"Result"] intValue] > 4)
//    //    {
//    //        rowView.backgroundColor = [NSColor greenColor] ;
//    //    }
//    //    else
//    //    {
//    //        rowView.backgroundColor = [NSColor redColor] ;
//    //    }
//}

/*****************************************************************************/

-(void)testBeginWithItem:(TestItem *) unit atRow:(NSInteger) row
{
    [_outlineview selectRowIndexes:[[NSIndexSet alloc]initWithIndex:row] byExtendingSelection:YES] ;
}

-(void)testEndWithItem:(TestItem *) unit atRow:(NSInteger) row
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[dataSource objectAtIndex:row] setObject:unit.testValue forKey:VALUE] ;
        [_outlineview reloadData] ;
    }) ;
    
}



@end
