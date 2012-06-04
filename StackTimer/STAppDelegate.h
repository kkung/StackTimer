//
//  STAppDelegate.h
//  StackTimer
//
//  Created by Jung MinYoung on 12. 6. 1..
//  Copyright (c) 2012년 kkung <kkungkkung@gmail.com>. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "STStackTimer.h"
#import "Task.h"

@interface STAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>
{
    NSTimer *mainTimer;
    NSMutableArray *queues;
    NSArray *storedTasks;
}
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *timerLabel;
@property (assign) IBOutlet NSButton *pushButton;
@property (assign) IBOutlet NSButton *popButton;
@property (assign) IBOutlet NSTextField *taskLabel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (assign) IBOutlet NSPanel *timerHudWindow;
@property (assign) IBOutlet NSTextField *timerContextTxt;
@property (assign) IBOutlet NSTableView *taskTableView;

- (void)showPushTaskModal;
- (void)popTask;
@end
