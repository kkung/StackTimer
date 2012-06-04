//
//  STStackTimer.h
//  StackTimer
//
//  Created by Jung MinYoung on 12. 6. 1..
//  Copyright (c) 2012년 kkung <kkungkkung@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STStackTimer : NSObject {
    NSTimer *timer;
    NSDate  *atLaunch;
    NSTimeInterval elapsedTime;
    NSString *context;
    
}

@property(nonatomic, strong) NSString *context;

- (NSTimeInterval)elapsedTime;
- (void)stop;
- (NSDate *)atLaunch;
@end
