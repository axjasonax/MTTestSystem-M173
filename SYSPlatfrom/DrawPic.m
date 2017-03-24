//
//  DrawPic.m
//  PicTest
//
//  Created by Jason_Mac on 2016/11/22.
//  Copyright © 2016年 Jason_Mac. All rights reserved.
//

#import "DrawPic.h"

@implementation DrawPic

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect] ;
    
    if(self)
    {
        _orignal = NSMakePoint(30,30) ;
        stepScale = 20 ;
        scale_Y = 20 ;
        scale_X = 20 ;
        _rationX = stepScale/scale_X ;
        _ratioY = stepScale/scale_Y ;
        dataLenX = 0 ;
        dataLenY = 0 ;
        
        _bezier = [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height)];
        
        colorDir = [[NSMutableDictionary alloc] init] ;
        curveData = [[NSMutableDictionary alloc] init] ;
        curveNameArray = [[NSMutableArray alloc] init] ;
        axisName_X = @"X" ;
        axisName_Y = @"Y" ;
        curveChartName = @"chart" ;
    }
    
    return self ;
}

- (void)drawRect:(NSRect)dirtyRect {
    @autoreleasepool {
         [super drawRect:dirtyRect];
        
        CGContextRef ref = [[NSGraphicsContext currentContext] graphicsPort] ;
        
        if(_bezier)
        {
            [_bezier removeAllPoints] ;
        }
        
        _bezier = [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height)] ;
        
        [[NSColor lightGrayColor] set] ;
        [_bezier fill] ;
        [self drawAxis] ;
        [_bezier stroke] ;
        [self drawMackLine:ref] ;
        
        for (NSString* curve in curveNameArray) {
            
            [(NSColor*)[colorDir objectForKey:curve] set] ;
            [self drawLine:ref sensorPoints:(NSMutableArray*)[curveData objectForKey:curve]] ;
        }
        
    }
}

-(void)AddCurve:(NSString *)curveName curveColor:(NSColor *)lineColor
{
    [colorDir setObject:lineColor forKey:curveName] ;
    NSMutableArray* array = [[NSMutableArray alloc] init] ;
    [curveData setObject:array forKey:curveName] ;
    [curveNameArray addObject:curveName] ;
}

-(void)SetTitle:(NSString *)xAxisName YAxis:(NSString *)yAxisName name:(NSString *)curveName
{
    axisName_X = xAxisName ;
    axisName_Y = yAxisName ;
    curveChartName = curveName ;
}

-(void)SetRatio:(double)ratioX RatioY:(double)ratioY
{
    _rationX = ratioX ;
    _ratioY = ratioY ;
}

-(void)SetScale:(double)xScale scaleY:(double)yScale
{
    scale_X = xScale ;
    scale_Y = yScale ;
}

-(void)SetStepScale:(double)scaleStep
{
    stepScale = scaleStep ;
}

-(void)SetDateLen:(int)xDataLen YDataLen:(int)yDataLen
{
    dataLenX = xDataLen ;
    dataLenY = yDataLen ;
}

-(void)drawLine:(CGContextRef)ref sensorPoints:(NSArray *)sensorPoints
{
    int index = 0 ;
    NSPointArray points = (NSPointArray)malloc(sizeof(NSPoint) * sensorPoints.count) ;
    
    for(NSValue* v in sensorPoints)
    {
        NSPoint p = [v pointValue] ;
        p.x = _orignal.x + p.x*_rationX ;
        p.y = _orignal.y + p.y*_ratioY ;
        points[index++] = p ;
    }
    
    CGContextAddLines(ref, points, sensorPoints.count);//添加线
    CGContextStrokePath(ref);//根据坐标绘制路径
    free(points);
}


-(void)drawAxis
{
    [[NSColor grayColor] set] ;
    //x axis
    [_bezier moveToPoint:NSMakePoint(_orignal.x, _orignal.y)] ;
    [_bezier lineToPoint:NSMakePoint(self.bounds.size.width, _orignal.y)] ;
    //y axis
    [_bezier moveToPoint:NSMakePoint(_orignal.x, _orignal.y)] ;
    [_bezier lineToPoint:NSMakePoint(_orignal.x, self.bounds.size.height)] ;
    
    //set the attributes
    NSMutableDictionary* attributes = [NSMutableDictionary dictionary] ;
    [attributes setObject:[NSFont fontWithName:@"Times" size:18] forKey:NSFontAttributeName] ;
    [attributes setObject:[NSColor brownColor] forKey:NSForegroundColorAttributeName] ;
    [axisName_X drawAtPoint:NSMakePoint(self.bounds.size.width - 15*axisName_X.length, _orignal.y + 10) withAttributes:attributes] ;
    [axisName_Y drawAtPoint:NSMakePoint(_orignal.x + 5, self.bounds.size.height - 30) withAttributes:attributes] ;
    
    if(![curveChartName isEqualToString:@""])
    {
        [attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName] ;
        [curveChartName drawAtPoint:NSMakePoint((self.bounds.size.width - 40)/2, self.bounds.size.height - 20) withAttributes:attributes] ;
        [attributes setObject:[NSColor brownColor] forKey:NSForegroundColorAttributeName] ;
    }
    
    [attributes setObject:[NSFont fontWithName:@"Times" size:12] forKey:NSFontAttributeName] ;
    
    for(int i = 0;i < self.bounds.size.width;i += stepScale)
    {
        [_bezier moveToPoint:NSMakePoint(_orignal.x + i, _orignal.y)] ;
        [_bezier lineToPoint:NSMakePoint(_orignal.x + i, _orignal.y + 5)] ;
        
        if (i % 60 == 0) {
            NSString* useFormat = [NSString stringWithFormat:@"%@%i%@",@"%0.",dataLenX,@"f"] ;
            NSString * axisMark = [NSString stringWithFormat:useFormat, (double)(i / _rationX)];
            [axisMark drawAtPoint:NSMakePoint(_orignal.x + i - 10, _orignal.y - 20) withAttributes:attributes];
        }
    }
    
    for (int i = 0; i < self.bounds.size.height; i += stepScale) {
        [_bezier moveToPoint:NSMakePoint(_orignal.x, _orignal.y + i)];
        [_bezier lineToPoint:NSMakePoint(_orignal.x + 10, _orignal.y + i)];
        
        if (i % 60 == 0 && i != 0) {
            NSString* usedFormat = [NSString stringWithFormat:@"%@%i%@",@"%0.",dataLenY,@"f"] ;
            NSString* axisMark = [NSString stringWithFormat:usedFormat,(double)(i/_rationX)] ;
            [axisMark drawAtPoint:NSMakePoint(_orignal.x - 30, _orignal.y + i - 5) withAttributes:attributes];
        }
    }
    
}

-(void)addPoint:(NSPoint)point sensorName:(NSString *)curveName
{
    NSValue* v = [NSValue valueWithPoint:point] ;
    
    [[curveData objectForKey:curveName] addObject:v] ;
    
    [self setNeedsDisplay:YES] ;
}

-(void)drawMackLine:(CGContextRef)ref
{
    NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[NSFont fontWithName:@"Times" size:12] forKey:NSFontAttributeName];
    [attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
    
    if([curveNameArray count] == 0)
    {
        return ;
    }
    
    int index = 0 ;
    
    for (NSString* curve in curveNameArray) {
        
        [(NSColor*)[colorDir objectForKey:curve] set] ;
        CGContextMoveToPoint(ref, self.bounds.size.width - 100, self.bounds.size.height - 50 -15*index) ;
        CGContextAddLineToPoint(ref, self.bounds.size.width - 50, self.bounds.size.height - 50 -15*index) ;
        CGContextStrokePath(ref) ;
        [curve drawAtPoint:NSMakePoint(self.bounds.size.width - 45, self.bounds.size.height - 50 -15*index - 6) withAttributes:attributes] ;
        index ++ ;
    }
}

//保存图片
-(void)saveImage:(NSString*)path imageType:(NSBitmapImageFileType)imageType
{
    [self lockFocus];
    NSBitmapImageRep* bits = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
    [self unlockFocus];
    NSDictionary* imageProcess = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:0]
                                                             forKey:NSImageCompressionFactor];
    NSData* imageData = [bits representationUsingType:imageType properties:imageProcess];
    [imageData writeToFile:path atomically:YES];
}

-(void)clear
{
    for (NSString* curve in curveNameArray) {
        
        [[curveData objectForKey:curve] removeAllObjects] ;
    }
}


@end
