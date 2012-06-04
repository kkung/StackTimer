//
//  STStackTimer.m
//  StackTimer
//
//  Created by Jung MinYoung on 12. 6. 1..
//  Copyright (c) 2012년 kkung <kkungkkung@gmail.com>. All rights reserved.
//

#import "STStackTimer.h"

@implementation STStackTimer
@synthesize context;

- (id)init {
    
    self = [super init];
    if ( self != nil ) {
        atLaunch = [NSDate date];
        elapsedTime = 0;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTick) userInfo:nil repeats:YES];
    }
    
    return self;
}

- (void)dealloc {    
    [self stop];    
}

- (void)onTick {
    elapsedTime = abs([atLaunch timeIntervalSinceNow]);
    NSLog(@"elapsed time: %f", elapsedTime);
}

- (NSTimeInterval)elapsedTime {
    return elapsedTime;
}

- (void)stop {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (NSDate *)atLaunch {
    return atLaunch;
}

@end
