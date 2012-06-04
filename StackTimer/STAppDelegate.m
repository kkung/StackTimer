//
//  STAppDelegate.m
//  StackTimer
//
//  Created by Jung MinYoung on 12. 6. 1..
//  Copyright (c) 2012년 kkung <kkungkkung@gmail.com>. All rights reserved.
//

#import "STAppDelegate.h"

@implementation STAppDelegate

@synthesize window = _window;
@synthesize timerLabel = _timerLabel;
@synthesize pushButton;
@synthesize popButton;
@synthesize taskLabel;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize timerHudWindow = _timerHud;
@synthesize timerContextTxt = _timerContextTxt;
@synthesize taskTableView = _taskTableView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    

    NSFont* digitFont = [NSFont fontWithName:@"Digital-7" size:80.0];
    [_timerLabel setFont:digitFont];
    
    mainTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTick) userInfo:nil repeats:YES];

    queues = [[NSMutableArray alloc] init];
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StackTaskModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:__managedObjectModel];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appDocumentUrl = [[[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"StackTask/"];
      
    NSError *error;
    
    if ( ![fileManager fileExistsAtPath:[appDocumentUrl path]] ) {
        NSLog(@"Created App support %@", [appDocumentUrl path]);
        if (![fileManager createDirectoryAtPath:[appDocumentUrl path] withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Can not create %@", error);
        };
    }
    
    NSURL *storeUrl = [appDocumentUrl URLByAppendingPathComponent:@"tasks.sqlite"];
    
    if ( ![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]){
        NSLog(@"Init error with persistenStoreConditator %@", error);
    }
    
    self.managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;

    storedTasks = [self reloadData];
    [[self taskTableView] setDataSource:self];
    [[self taskTableView] reloadData];
    
    [self registerHotKey];
}

- (void)onTick
{
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    
    STStackTimer *current_timer = [self currentTimer];
    NSDate *elapsedDate = nil;

    if (current_timer != nil) {
        NSTimeInterval _interval = [current_timer elapsedTime];
        dateString = [self readableTimeInterval:_interval];
    } else {
        elapsedDate = [NSDate date];
        dateString = [formatter stringFromDate:elapsedDate];
    }

    [_timerLabel setTitleWithMnemonic:dateString];
}

- (NSString *)readableTimeInterval:(NSTimeInterval)interval {
    return [NSString stringWithFormat:@"%02li:%02li:%02li",
            lround(floor(interval / 3600.)) % 100,
            lround(floor(interval / 60.)) % 60,
            lround(floor(interval)) % 60];
}

- (void)showPushTaskModal
{
    [[self timerContextTxt] setStringValue:@""];
    
    [[NSApplication sharedApplication] beginSheet:[self timerHudWindow] modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(pushTimerAfterModal:returnCode:contextInfo:) contextInfo:nil];
}

- (void)popTask
{
    if(queues.count == 0 ) {
        return;
    }
    
    STStackTimer *current_timer = [self currentTimer];
    if (current_timer) {
        
        [queues removeObject:current_timer];
        [current_timer stop];
        
        Task *nTask = (Task *)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:[self managedObjectContext]];
        
        nTask.atLaunch = [current_timer atLaunch];
        nTask.totalElapsed = [[NSNumber alloc] initWithDouble:current_timer.elapsedTime];
        nTask.context = current_timer.context;
        
        NSError *error;
        if (![[self managedObjectContext] save:&error]){
            NSLog(@"error while saving coredata %@", error);
        }
        
    }
    
    if (queues.count == 0 ){
        [taskLabel setStringValue:@"StackTimer"];
    } else {
        [taskLabel setStringValue:[self currentTimer].context];
    }
    
    storedTasks = [self reloadData];
    [[self taskTableView] reloadData];
    NSLog(@"Task completed in %f seconds", current_timer.elapsedTime);
}

- (IBAction)pushTimer:(NSButton *)sender {
    [self showPushTaskModal];
    return;
}

- (IBAction)pushTimerAfterModal:(NSWindow *)sheet
                     returnCode:(int)returnCode
                    contextInfo:(void  *)contextInfo {
    
    if ( returnCode == NSOKButton ) {
        STStackTimer *newTimer = [[STStackTimer alloc] init];
        newTimer.context = self.timerContextTxt.stringValue;
        [taskLabel setStringValue:newTimer.context];
        [queues addObject:newTimer];
    }
}

- (IBAction)popTimer:(NSButton *)sender {
    [self popTask];
}

- (STStackTimer *)currentTimer {
    if (queues.count == 0){
        return nil;
    }
    return [queues objectAtIndex:queues.count-1];
}

- (IBAction)pushModalDidGo:(id)sender {
    
    if ( self.timerContextTxt.stringValue.length == 0) {
        return;
    }
    
    [[NSApplication sharedApplication] stopModal];
    [[self timerHudWindow] orderOut:nil];
    
    [[NSApplication sharedApplication] endSheet:self.timerHudWindow returnCode:NSOKButton];

}


- (IBAction)pushModalDidCancel:(id)sender {
    [[NSApplication sharedApplication] stopModal];
    [[self timerHudWindow] orderOut:nil];
    
    [[NSApplication sharedApplication] endSheet:self.timerHudWindow returnCode:NSCancelButton];
}

- (NSArray *)reloadData {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Task"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"atLaunch"
                                                                   ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error
        return nil;
    } else {
        return fetchedObjects;
    }
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [storedTasks count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    Task* nTask = (Task *)[storedTasks objectAtIndex:row];
    NSDateFormatter *formatter;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];

    
    if ( [[tableColumn identifier] isEqualToString:@"atLaunch"] ) {
        return [formatter stringFromDate:nTask.atLaunch];
    } else if ( [[tableColumn identifier] isEqualToString:@"context"] ) {
        return nTask.context;
    } else {
        return [self readableTimeInterval:nTask.totalElapsed.doubleValue];
    }
}

- (void)registerHotKey {
    
    EventHotKeyRef hKeyRef;
    EventHotKeyID hKeyID;
    
    EventTypeSpec eventType;
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    
    InstallApplicationEventHandler(&onHotKeyPressed, 1, &eventType, (__bridge void *)self, NULL);
    
    hKeyID.signature = 'hkS1';
    hKeyID.id = 1;
    RegisterEventHotKey(17, cmdKey + controlKey, hKeyID, GetApplicationEventTarget(), 0, &hKeyRef); // CMD+CTRL+T
    
    
    hKeyID.signature = 'hkS2';
    hKeyID.id = 2;
    RegisterEventHotKey(16, cmdKey + controlKey, hKeyID, GetApplicationEventTarget(), 0, &hKeyRef); // CMD+CTRL+Y
    
    
}

OSStatus onHotKeyPressed(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData)
{
    EventHotKeyID hKeyID;
    GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hKeyID), NULL, &hKeyID);
    
    STAppDelegate *delegate = (__bridge STAppDelegate *)userData;
    switch (hKeyID.id) {
        case 1:
            NSLog(@"Push Task hotkey");
            [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
            [delegate showPushTaskModal];
            break;
        case 2:
            NSLog(@"Pop task hotkey");
            [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
            [delegate popTask];
            break;
    }
    
    return noErr;
}
@end
