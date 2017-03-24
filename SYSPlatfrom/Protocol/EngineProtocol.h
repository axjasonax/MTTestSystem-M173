//
//  EngineProtocol.h
//  X2AX2B
//
//  Created by hotabbit on 14-8-5.
//  Copyright (c) 2014年 hotabbit. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EngineProtocol <NSObject>

- (id) send:(NSString *)hWnd Message:(NSString *)msg Parameter:(id)parameters;

@end
