//
//  DrawPic.h
//  PicTest
//
//  Created by Jason_Mac on 2016/11/22.
//  Copyright © 2016年 Jason_Mac. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DrawPic : NSView
{
    NSBezierPath* _bezier ;
    CGPoint _orignal ;
    
    NSMutableDictionary* colorDir ;
    NSMutableDictionary* curveData ;
    NSMutableArray* curveNameArray ;
    double _rationX ;
    double _ratioY ;
    
    NSString* axisName_X ;
    NSString* axisName_Y ;
    NSString* curveChartName ;
    double scale_X ;
    double scale_Y ;
    double stepScale ;
    int dataLenX ;
    int dataLenY ;
}

-(void)addPoint:(NSPoint)point sensorName:(NSString *)curveName  ;
-(void)saveImage:(NSString*)path imageType:(NSBitmapImageFileType)imageType ;
-(void)AddCurve:(NSString*)curveName curveColor:(NSColor *) lineColor ;
-(void)SetTitle:(NSString*)xAxisName YAxis:(NSString*)yAxisName name:(NSString*)curveName ;
-(void)SetRatio:(double)ratioX RatioY:(double)ratioY ;
-(void)SetScale:(double)xScale scaleY:(double)yScale ;
-(void)SetStepScale:(double)scaleStep ;
-(void)SetDateLen:(int)xDataLen YDataLen:(int)yDataLen ;
-(void)clear ;

@end
