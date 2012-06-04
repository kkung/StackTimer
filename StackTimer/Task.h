//
//  Task.h
//  StackTimer
//
//  Created by Jung MinYoung on 12. 6. 1..
//  Copyright (c) 2012년 kkung <kkungkkung@gmail.com>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSDate * atLaunch;
@property (nonatomic, retain) NSNumber * totalElapsed;
@property (nonatomic, retain) NSString * context;

@end
