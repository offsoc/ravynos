/* Copyright (c) 2006-2007 Christopher J. W. Lloyd
 * Copyright (C) 2022-2024 Zoe Knox

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSSocket_bsd.h>
#import <Foundation/NSSelectInputSource.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow-Private.h>
#import <AppKit/NSPanel.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSMenuItem.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSModalSessionX.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSScreen.h>
#import <AppKit/NSColorPanel.h>
#import <AppKit/NSDisplay.h>
#import <AppKit/NSPageLayout.h>
#import <AppKit/NSDocumentController.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSImageView.h>
#import <AppKit/NSSheetContext.h>
#import <AppKit/NSSystemInfoPanel.h>
#import <AppKit/NSAlert.h>
#import <AppKit/NSWorkspace.h>
#import <AppKit/NSDockTile.h>
#import <CoreGraphics/CGWindow.h>
#import <AppKit/NSRaise.h>
#import <AppKit/NSSpellChecker.h>
#import <AppKit/NSStatusItem.h>
#import <objc/message.h>
#import <pthread.h>

#include <sys/types.h>
#include <sys/un.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <unistd.h>

#import <WindowServer/message.h>
#import <WindowServer/rpc.h>

NSString * const NSModalPanelRunLoopMode=@"NSModalPanelRunLoopMode";
NSString * const NSEventTrackingRunLoopMode=@"NSEventTrackingRunLoopMode";

NSString * const NSApplicationWillFinishLaunchingNotification=@"NSApplicationWillFinishLaunchingNotification";
NSString * const NSApplicationDidFinishLaunchingNotification=@"NSApplicationDidFinishLaunchingNotification";

NSString * const NSApplicationWillBecomeActiveNotification=@"NSApplicationWillBecomeActiveNotification";
NSString * const NSApplicationDidBecomeActiveNotification=@"NSApplicationDidBecomeActiveNotification";
NSString * const NSApplicationWillResignActiveNotification=@"NSApplicationWillResignActiveNotification";
NSString * const NSApplicationDidResignActiveNotification=@"NSApplicationDidResignActiveNotification";

NSString * const NSApplicationWillUpdateNotification=@"NSApplicationWillUpdateNotification";
NSString * const NSApplicationDidUpdateNotification=@"NSApplicationDidUpdateNotification";

NSString * const NSApplicationWillHideNotification=@"NSApplicationWillHideNotification";
NSString * const NSApplicationDidHideNotification=@"NSApplicationDidHideNotification";
NSString * const NSApplicationWillUnhideNotification=@"NSApplicationWillUnhideNotification";
NSString * const NSApplicationDidUnhideNotification=@"NSApplicationDidUnhideNotification";

NSString * const NSApplicationWillTerminateNotification=@"NSApplicationWillTerminateNotification";

NSString * const NSApplicationDidChangeScreenParametersNotification=@"NSApplicationDidChangeScreenParametersNotification";

@interface NSDocumentController(forward) 
-(void)_updateRecentDocumentsMenu; 
@end 

@interface NSMenu(private)
-(NSMenu *)_menuWithName:(NSString *)name;
@end

@interface NSDockTile(private)
-initWithOwner:owner;
@end

@implementation NSApplication

id NSApp=nil;

+(NSApplication *)sharedApplication {

   if(NSApp==nil){
      [[self alloc] init]; // NSApp must be nil inside init
   }

   return NSApp;
}

+(void)detachDrawingThread:(SEL)selector toTarget:target withObject:object {
   NSUnimplementedMethod();
}

-(void)_showSplashImage {
   NSImage *image=[NSImage imageNamed:@"splash"];

   if(image!=nil){
    NSSize    imageSize=[image size];
    NSWindow *splash=[[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,imageSize.width,imageSize.height) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    [splash setLevel:NSFloatingWindowLevel];
    
    NSImageView *view=[[NSImageView alloc] initWithFrame:NSMakeRect(0,0,imageSize.width,imageSize.height)];
    
    [view setImage:image];
    [splash setContentView:view];
    [view release];
    [splash setReleasedWhenClosed:YES];
    [splash center];
    [splash orderFront:nil];
    [splash display];
   }
}

-(void)_closeSplashImage {
   int i;
   
   for(i=0;i<[_windows count];i++){
    NSWindow *check=[_windows objectAtIndex:i];
    NSView   *contentView=[check contentView];
    
    if([contentView isKindOfClass:[NSImageView class]])
     if([[[(NSImageView *)contentView image] name] isEqual:@"splash"]){
      [check close];
      return;
     }
   }
}

static NSMenuItem *itemWithTag(NSMenu *root, int tag) {
    NSArray *items = [root itemArray];
    NSMenuItem *item = nil;
    for(int i = 0; i < [items count]; ++i) {
        item = [items objectAtIndex:i];
        if([item tag] == tag)
            return item;
        if([item hasSubmenu]) {
            item = itemWithTag([item submenu], tag);
            if(item)
                return item;
        }
    }
    return nil;
}

-(void)machServiceLoop:(id)object {
    //NSLog(@"starting mach service loop");
    NSTimeInterval lastClickTime = 0;
    NSTimeInterval lastRightClickTime = 0;
    unsigned clickCount = 0;
    unsigned rightClickCount = 0;
    struct timespec ts;

    while(1) {
        ReceiveMessage msg = {0};
        mach_msg_return_t result = mach_msg((mach_msg_header_t *)&msg, MACH_RCV_MSG, 0, sizeof(msg),
            _wsReplyPort, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
        if(result != MACH_MSG_SUCCESS)
            NSLog(@"mach_msg receive error 0x%x", result);
        else {
            switch(msg.header.msgh_id) {
                case MSG_ID_INLINE:
                    switch(msg.code) {
                        case CODE_WINDOW_STATE: {
                            if(msg.len != sizeof(struct wsRPCWindow)) {
                                NSLog(@"Incorrect data size in window state change: %d vs %d",
                                        msg.len, sizeof(struct wsRPCWindow));
                                break;
                            }
                            struct wsRPCWindow *data = (struct wsRPCWindow *)msg.data;
                            int _id = data->windowID;

                            if([bundleID isEqualToString:@"com.ravynos.Dock"]) {
                                NSMutableDictionary *md = [NSMutableDictionary new];
                                [md setObject:[NSNumber numberWithInt:msg.pid] forKey:@"ProcessID"];
                                [md setObject:[NSString stringWithCString:msg.bundleID] forKey:@"BundleID"];
                                [md setObject:[NSNumber numberWithInt:_id] forKey:@"WindowID"];
                                [md setObject:[NSNumber numberWithInt:data->state] forKey:@"State"];

                                [[NSNotificationCenter defaultCenter] 
                                    postNotificationName:@"WSWindowDidChangeState" object:nil
                                    userInfo:md];

                                // We're done here if this message wasn't about Dock.
                                if(strcmp(msg.bundleID, "com.ravynos.Dock"))
                                    break;
                            }

                            NSWindow *window = [self windowWithWindowNumber:_id];
                            if(window == nil) {
                                NSLog(@"WINDOW_STATE: ID %u, not found in window list!", _id);
                                break;
                            }
                            [window processStateUpdate:data];
                            break;
                        }
                        // and all of these should really use Quartz Event Services
                        case CODE_INPUT_EVENT: {
                            struct mach_event me;
                            if(msg.len != sizeof(me)) {
                                NSLog(@"Incorrect data size in input event: %d vs %d", msg.len, sizeof(me));
                                break;
                            }
                            memcpy(&me, msg.data, msg.len);
                            NSWindow *window = (me.windowID == 0)
                                ? [self mainWindow]
                                : [self windowWithWindowNumber:me.windowID];

                            // translate screen to window coords
                            me.x -= [window frame].origin.x;
                            me.y -= [window frame].origin.y;
                            switch(me.code) {
                                case NSKeyUp:
                                case NSKeyDown: {
                                    NSEvent *e = [NSEvent keyEventWithType:me.code
                                                  location:NSMakePoint(me.x, me.y)
                                             modifierFlags:me.mods
                                                    window:window
                                                characters:[[NSString alloc] initWithUTF8String:me.chars]
                               charactersIgnoringModifiers:[[NSString alloc] initWithUTF8String:me.charsIg]
                                                 isARepeat:me.repeat
                                                   keyCode:me.keycode];
                                    [_display postEvent:e atStart:NO];
                                    break;
                                }
                                case NSMouseMoved:
                                case NSMouseEntered:
                                case NSMouseExited: {
                                    NSEvent *e = [NSEvent mouseEventWithType:me.code
                                                        location:NSMakePoint(me.x, me.y)
                                               modifierFlags:me.mods
                                                      window:window
                                                      clickCount:0
                                                      deltaX:me.dx
                                                      deltaY:me.dy];
                                    [_display postEvent:e atStart:NO];
                                    break;
                                }
                                case NSLeftMouseDown:
                                    clock_gettime(CLOCK_MONOTONIC, &ts);
                                    lastClickTime = ts.tv_sec + ts.tv_nsec/1000000000;
                                    clickCount++;
                                case NSLeftMouseUp: {
                                    clock_gettime(CLOCK_MONOTONIC, &ts);
                                    NSTimeInterval now = ts.tv_sec + ts.tv_nsec/1000000000;
                                    if((now - lastClickTime) > [_display doubleClickInterval])
                                        clickCount = 0;

                                    NSEvent *e = [NSEvent mouseEventWithType:me.code
                                                    location:NSMakePoint(me.x, me.y)
                                               modifierFlags:me.mods
                                                      window:window
                                                  clickCount:clickCount
                                                      deltaX:me.dx
                                                      deltaY:me.dy];
                                    [_display postEvent:e atStart:NO];
                                    break;
                                }
                                case NSLeftMouseDragged: {
                                    NSEvent *e = [NSEvent mouseEventWithType:me.code
                                                    location:NSMakePoint(me.x, me.y)
                                               modifierFlags:me.mods
                                                      window:window
                                                  clickCount:0
                                                      deltaX:me.dx
                                                      deltaY:me.dy];
                                    [_display postEvent:e atStart:NO];
                                    break;
                                }
                                case NSRightMouseDown:
                                    clock_gettime(CLOCK_MONOTONIC, &ts);
                                    lastRightClickTime = ts.tv_sec + ts.tv_nsec/1000000000;
                                    rightClickCount++;
                                case NSRightMouseUp: {
                                    clock_gettime(CLOCK_MONOTONIC, &ts);
                                    NSTimeInterval now = ts.tv_sec + ts.tv_nsec/1000000000;
                                    if((now - lastRightClickTime) > [_display doubleClickInterval])
                                        rightClickCount = 0;

                                    NSEvent *e = [NSEvent mouseEventWithType:me.code
                                                    location:NSMakePoint(me.x, me.y)
                                               modifierFlags:me.mods
                                                      window:window
                                                  clickCount:rightClickCount
                                                      deltaX:me.dx
                                                      deltaY:me.dy];
                                    [_display postEvent:e atStart:NO];
                                    break;
                                }
                                case NSRightMouseDragged: {
                                    NSEvent *e = [NSEvent mouseEventWithType:me.code
                                                    location:NSMakePoint(me.x, me.y)
                                               modifierFlags:me.mods
                                                      window:window
                                                  clickCount:0
                                                      deltaX:me.dx
                                                      deltaY:me.dy];
                                    [_display postEvent:e atStart:NO];
                                    break;
                                }
                                default:
                                    NSLog(@"Unhandled input event type %d", me.code);
                                    break;
                            }
                            break;
                        }
                        case CODE_STATUS_ITEM_ADDED:
                        {
			    uint32_t handle;
			    if(msg.len != sizeof(handle)) {
				NSLog(@"weirdness detected! expected size %d, got %d", sizeof(handle), msg.len);
				break;
			    }
			    memcpy(&handle, msg.data, sizeof(handle));
			    NSLog(@"ZMK DEBUG: status item added with handle %u", handle);
			}
                        case CODE_MENU_FOR_APP:
                        {
                            if([bundleID isEqualToString:@"com.ravynos.SystemUIServer"]) {
                                NSMutableData *data = [NSMutableData new];
                                [data appendBytes:msg.data length:msg.len];

                                NSObject *o = nil;
                                @try {
                                    o = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                                }
                                @catch(NSException *localException) {
                                    NSLog(@"%@",localException);
                                }

                                if(o == nil || [o isKindOfClass:[NSDictionary class]] == NO) {
                                    NSLog(@"menuForApp: not a dictionary");
                                    break;
                                }
                                if([(NSDictionary *)o objectForKey:@"MainMenu"] == nil) {
                                    NSLog(@"menuForApp: missing MainMenu key");
                                    break;
                                }
                                if(![[(NSDictionary *)o objectForKey:@"MainMenu"] isKindOfClass:[NSMenu class]]) {
                                    NSLog(@"menuForApp: invalid menu class");
                                    break;
                                }

                                NSMutableDictionary *md = [NSMutableDictionary new];
                                [md setDictionary:(NSDictionary *)o];
                                [md setObject:[NSNumber numberWithInt:msg.pid] forKey:@"ProcessID"];
                                [md setObject:[NSString stringWithCString:msg.bundleID] forKey:@"BundleID"];

                                [[NSNotificationCenter defaultCenter] 
                                    postNotificationName:@"NSMenuDidUpdate" object:nil
                                    userInfo:md];
                                [o release];
                            }
                            break;
                        }
                        case CODE_APP_EXITED:
                        {
                            if([bundleID isEqualToString:@"com.ravynos.SystemUIServer"] ||
                               [bundleID isEqualToString:@"com.ravynos.Dock"]) {
                                NSMutableDictionary *md = [NSMutableDictionary new];
                                [md setObject:[NSNumber numberWithInt:msg.pid] forKey:@"ProcessID"];
                                [md setObject:[NSString stringWithCString:msg.bundleID] forKey:@"BundleID"];
                                [md setObject:[NSString stringWithCString:msg.data] forKey:@"Path"];

                                [[NSNotificationCenter defaultCenter] 
                                    postNotificationName:@"NSApplicationDidQuit" object:nil
                                    userInfo:md];
                            }
                            break;
                        }
                        case CODE_APP_LAUNCHED:
                        {
                            if([bundleID isEqualToString:@"com.ravynos.Dock"]) {
                                NSMutableDictionary *md = [NSMutableDictionary new];
                                [md setObject:[NSNumber numberWithInt:msg.pid] forKey:@"ProcessID"];
                                [md setObject:[NSString stringWithCString:msg.bundleID] forKey:@"BundleID"];
                                [md setObject:[NSString stringWithCString:msg.data] forKey:@"Path"];

                                [[NSNotificationCenter defaultCenter] 
                                    postNotificationName:@"NSApplicationDidLaunch" object:nil
                                    userInfo:md];
                            }
                            break;
                        }
                        case CODE_ITEM_CLICKED:
                        {
                            int itemID;
                            if(msg.len != sizeof(itemID)) {
                                NSLog(@"weirdness detected! expected size %d, got %d", sizeof(itemID), msg.len);
                                break;
                            }
                            memcpy(&itemID, msg.data, sizeof(itemID));
                            NSMenuItem *item = itemWithTag(_mainMenu, itemID);
                            if(item != nil)
                                [self sendAction:[item action] to:[item target] from:item];
                            else
                                NSLog(@"Error: cannot find menu item with tag %d!", itemID);
                            break;
                        }
                        case CODE_ACTIVATION_STATE:
                        {
                            struct mach_activation_data data;
                            if(msg.len != sizeof(data)) {
                                NSLog(@"weirdness detected! expected size %d, got %d", sizeof(data), msg.len);
                                break;
                            }
                            memcpy(&data, msg.data, sizeof(data));
                            if(data.active == 1 && data.windowID != 0) {
                                NSWindow *win = [self windowWithWindowNumber:data.windowID];
                                if(win)
                                    [win showForActivation]; 
                            }
                            if(data.active && !_isActive)
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:NSApplicationWillBecomeActiveNotification
                                                  object:self];
                            else if(!data.active && _isActive)
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:NSApplicationWillResignActiveNotification
                                                  object:self];
                            _isActive = data.active;
                            [self _checkForAppActivation];

                            if([bundleID isEqualToString:@"com.ravynos.SystemUIServer"]) {
                                NSMutableDictionary *md = [NSMutableDictionary new];
                                [md setObject:[NSNumber numberWithInt:msg.pid] forKey:@"ProcessID"];
                                [md setObject:[NSString stringWithCString:msg.bundleID] forKey:@"BundleID"];

                                [[NSNotificationCenter defaultCenter] 
                                    postNotificationName: (_isActive ? NSApplicationDidBecomeActiveNotification
                                                                     : NSApplicationDidResignActiveNotification)
                                                               object:nil
                                                             userInfo:md];
                            } else {
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName: (_isActive ? NSApplicationDidBecomeActiveNotification
                                                                     : NSApplicationDidResignActiveNotification)
                                                               object:self];
                            }
                            break;
                        }
                        case CODE_APP_HIDE:
                        {
                            [self hide:nil];
                            break;
                        }
                        default:
                            NSLog(@"Unknown message code %u from WS", msg.code);

                    }
                    break;
            }
            // we received _something_ so wake the main event loop in case we posted
            if([self _wakeUp] < 0)
                NSLog(@"Error waking runloop - write: %s", strerror(errno));
        }
    }
}

/* Each event notification is 2 chars. Don't read more! */
-(int)_drainPipe {
    char junk[2];
    fd_set fds;
    struct timeval tv = {0};

    FD_ZERO(&fds);
    FD_SET(_machEventPipe[0], &fds);
    if(select(_machEventPipe[0] + 1, &fds, NULL, NULL, &tv) == 1)
        if(FD_ISSET(_machEventPipe[0], &fds))
            return read(_machEventPipe[0], junk, sizeof(junk));
    return 0;
}

-(int)_wakeUp {
    return(write(_machEventPipe[1], "\n", 2));
}

-init {
    if(NSApp)
        NSAssert(!NSApp, @"NSApplication is a singleton");
    NSApp=[self retain];

    if(pipe(_machEventPipe) != 0) {
        NSLog(@"pipe: %s", strerror(errno));
        exit(-1);
    }
    _inputSource = [[NSSelectInputSource socketInputSourceWithSocket:
            [[NSSocket_bsd socketWithDescriptor:_machEventPipe[0]] retain]] retain];
    [_inputSource setSelectEventMask:NSSelectReadEvent];

    //[NSRunLoop mainRunLoop];
    [NSRunLoop currentRunLoop];

    // Create a port with send/receive rights that communicates with WindowServer
    mach_port_t task = mach_task_self();
    if(mach_port_allocate(task, MACH_PORT_RIGHT_RECEIVE, &_wsReplyPort) != KERN_SUCCESS ||
        mach_port_insert_right(task, _wsReplyPort, _wsReplyPort, MACH_MSG_TYPE_MAKE_SEND) != KERN_SUCCESS) {
        NSLog(@"Failed to allocate mach_port _wsReplyPort");
        exit(1);
    }
    [NSThread detachNewThreadSelector:@selector(machServiceLoop:) toTarget:self withObject:nil];

   _wsSvcPort = MACH_PORT_NULL;

   _display=[[NSDisplay currentDisplay] retain];

   _windows=[[NSMutableArray new] retain];
   _mainMenu=nil;

    NSBundle *mainBundle = [NSBundle mainBundle];

   // don't try to find the service if this is the app that provides it...
   bundleID = [mainBundle bundleIdentifier];
    if(bundleID == nil)
        bundleID = [NSString stringWithFormat:@"unix.%u", getpid()];
   if(!([bundleID isEqualToString:@"com.ravynos.WindowServer"])) {
        NSLog(@"Finding service %s (%u)", WINDOWSERVER_SVC_NAME, bootstrap_port);
        if(bootstrap_look_up(bootstrap_port, WINDOWSERVER_SVC_NAME, &_wsSvcPort) != KERN_SUCCESS) {
            NSLog(@"Failed to locate service");
            return nil;
        }

        // register this app with WindowServer so we get events
        PortMessage msg = {0};
        msg.header.msgh_remote_port = _wsSvcPort;
        msg.header.msgh_bits = MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, 0, 0, MACH_MSGH_BITS_COMPLEX);
        msg.header.msgh_id = MSG_ID_PORT;
        msg.header.msgh_size = sizeof(msg);
        msg.msgh_descriptor_count = 1;
        msg.descriptor.type = MACH_MSG_PORT_DESCRIPTOR;
        msg.descriptor.name = _wsReplyPort;
        msg.descriptor.disposition = MACH_MSG_TYPE_MAKE_SEND;
        msg.pid = getpid();
        strncpy(msg.bundleID, [bundleID cString], sizeof(msg.bundleID));

        int ret = 0;
        if((ret = mach_msg((mach_msg_header_t *)&msg, MACH_SEND_MSG|MACH_SEND_TIMEOUT, sizeof(msg), 0, MACH_PORT_NULL,
            2000 /* ms timeout */, MACH_PORT_NULL)) != MACH_MSG_SUCCESS)
            NSLog(@"Failed to register with WS: mach_msg error 0x%x", ret);
   }

   _dockTile=[[NSDockTile alloc] initWithOwner:self];
   _modalStack=[NSMutableArray new];
    
   _lock=NSZoneMalloc(NULL,sizeof(pthread_mutex_t));

   pthread_mutex_init(_lock,NULL);
   
   // We can't display the splash until WindowServer gives us a real display to use. This will
   // come as a mach msg processed by the service loop. Keep polling display until it is ready
   // FIXME: need a timeout here?
    //NSLog(@"waiting for display to become ready");
    while([_display isReady] == NO) {
        usleep(10000);
    }

    [self _showSplashImage];
   
   return NSApp;
}

-(NSSelectInputSource *)inputSource {
    return _inputSource;
}

// private internal method (also used by Dock)
-(mach_port_t)_wsServicePort {
    return _wsSvcPort;
}

-(void)dealloc {
    mach_port_deallocate(mach_task_self(),_wsReplyPort);
    [super dealloc];
}

-(NSGraphicsContext *)context {
   NSUnimplementedMethod();
   return nil;
}

-delegate {
   return _delegate;
}

-(NSArray *)windows {
   return _windows;
}

-(NSWindow *)windowWithWindowNumber:(NSInteger)number {
   int i,count=[_windows count];
   
   for(i=0;i<count;i++){
    NSWindow *check=[_windows objectAtIndex:i];

    if((uint32_t)[check windowNumber]==(uint32_t)number)
     return check;
   }
   
   return nil;
}

-(NSMenu *)mainMenu {
   return _mainMenu;
}

-(NSMenu *)menu {
  return [self mainMenu];
}

-(NSMenu *)windowsMenu {
   if(_windowsMenu==nil) {
    _windowsMenu=[[NSApp mainMenu] _menuWithName:@"_NSWindowsMenu"];
    if (_windowsMenu && ![[[_windowsMenu itemArray] lastObject] isSeparatorItem])
     [_windowsMenu addItem:[NSMenuItem separatorItem]];
   }

   return _windowsMenu;
}

-(NSWindow *)mainWindow {
   return _mainWindow;
}

-(void)_setMainWindow:(NSWindow *)window {
   _mainWindow=window;
}

-(NSWindow *)keyWindow {
   return _keyWindow;
}

-(void)_setKeyWindow:(NSWindow *)window {
   _keyWindow=window;
}

-(NSImage *)applicationIconImage {
   return _applicationIconImage;
}

-(BOOL)isActiveExcludingWindow:(NSWindow *)exclude {
   int count=[_windows count];

   while(--count>=0){
    NSWindow *check=[_windows objectAtIndex:count];

    if(check==exclude)
     continue;
     
    if([check _isActive])
     return YES;
   }

   return _isActive;
}

-(BOOL)isActive {
   return [self isActiveExcludingWindow:nil];
}

-(BOOL)isHidden {
	return _isHidden;
}

-(BOOL)isRunning {
   return _isRunning;
}

-(NSWindow *)makeWindowsPerform:(SEL)selector inOrder:(BOOL)inOrder {
   NSUnimplementedMethod();
   return nil;
}

-(void)miniaturizeAll:sender {
   int count=[_windows count];
   
   while(--count>=0)
    [[_windows objectAtIndex:count] miniaturize:sender];
}

-(NSArray *)orderedDocuments {
   NSMutableArray *result=[NSMutableArray array];
   NSArray        *orderedWindows=[self orderedWindows];
   
   for(NSWindow *checkWindow in orderedWindows){
    NSDocument *checkDocument=[[checkWindow windowController] document];
    
    if(checkDocument!=nil)
     [result addObject:checkDocument];
   }
   
   return result;
}

-(NSArray *)orderedWindows {
  extern NSArray *CGSOrderedWindowNumbers();
  
  NSMutableArray *result=[NSMutableArray array];
  NSArray *numbers=CGSOrderedWindowNumbers();
  
  for(NSNumber *number in numbers){
   NSWindow *window=[self windowWithWindowNumber:[number integerValue]];
   
   if(window!=nil && ![window isKindOfClass:[NSPanel class]])
    [result addObject:window];
  }
  
  return result;
}

-(void)preventWindowOrdering {
   NSUnimplementedMethod();
}

-(void)unregisterDelegate {
    if([_delegate respondsToSelector:@selector(applicationWillFinishLaunching:)]){
        [[NSNotificationCenter defaultCenter] removeObserver:_delegate
                                                     name:NSApplicationWillFinishLaunchingNotification object:self];
    }
    if([_delegate respondsToSelector:@selector(applicationDidFinishLaunching:)]){
        [[NSNotificationCenter defaultCenter] removeObserver:_delegate
                                                     name:NSApplicationDidFinishLaunchingNotification object:self];
    }
    if([_delegate respondsToSelector:@selector(applicationDidBecomeActive:)]){
        [[NSNotificationCenter defaultCenter] removeObserver:_delegate
                                                     name: NSApplicationDidBecomeActiveNotification object:self];
    }
    if([_delegate respondsToSelector:@selector(applicationWillTerminate:)]){
        [[NSNotificationCenter defaultCenter] removeObserver:_delegate
                                                     name: NSApplicationWillTerminateNotification object:self];
    }
}

-(void)registerDelegate {
    if([_delegate respondsToSelector:@selector(applicationWillFinishLaunching:)]){
     [[NSNotificationCenter defaultCenter] addObserver:_delegate
       selector:@selector(applicationWillFinishLaunching:)
        name:NSApplicationWillFinishLaunchingNotification object:self];
    }
    if([_delegate respondsToSelector:@selector(applicationDidFinishLaunching:)]){
     [[NSNotificationCenter defaultCenter] addObserver:_delegate
       selector:@selector(applicationDidFinishLaunching:)
        name:NSApplicationDidFinishLaunchingNotification object:self];
    }
    if([_delegate respondsToSelector:@selector(applicationDidBecomeActive:)]){
     [[NSNotificationCenter defaultCenter] addObserver:_delegate
       selector:@selector(applicationDidBecomeActive:)
        name: NSApplicationDidBecomeActiveNotification object:self];
    }
   if([_delegate respondsToSelector:@selector(applicationWillTerminate:)]){
      [[NSNotificationCenter defaultCenter] addObserver:_delegate
                                               selector:@selector(applicationWillTerminate:)
                                                   name: NSApplicationWillTerminateNotification object:self];
   }
   
}

-(void)setDelegate:delegate {
    if (delegate != _delegate) {
        [self unregisterDelegate];
        _delegate=delegate;
        [self registerDelegate];
    }
}

static int _tagAllMenus(NSMenu *menu, int tag) {
    NSArray *items = [menu itemArray];
    for(int i = 0; i < [items count]; ++i) {
        NSMenuItem *item = [items objectAtIndex:i];
        [item setTag:tag++];
        if([item hasSubmenu])
            tag = _tagAllMenus([item submenu], tag);
    }

    return tag;
}

-(void)setMainMenu:(NSMenu *)menu {
   int i,count=[_windows count];

   [_mainMenu autorelease];
   _mainMenu=[menu retain];

   // ensure we have an "Apple" (application) menu
   if([_mainMenu _menuWithName:@"NSAppleMenu"] == nil) {
     NSString *appName = [[NSProcessInfo processInfo] processName];
     NSMenuItem *appleMenuItem = [[NSMenuItem new] retain];
     [appleMenuItem setTitle:appName];
     NSMenu *appleMenu = [[[NSMenu alloc] initApplicationMenu:appName] retain];
     [appleMenuItem setSubmenu:appleMenu];
     [_mainMenu insertItem:appleMenuItem atIndex:0];
   }

   for(i=0;i<count;i++){
    NSWindow *window=[_windows objectAtIndex:i];

    if(![window isKindOfClass:[NSPanel class]])
     [window setMenu:_mainMenu];
   }

    [self sendMenusToWindowServer];
}

/* Make a copy of the menus with nil delegates and targets before
 * sending the menu tree to WindowServer. Otherwise it may reject
 * the menus because of unknown classes.
 * This function is recursive.
 */

-(void)_menuEnumerateAndChange:(NSMenu *)menu {
    NSArray *items = [menu itemArray];
    [menu setDelegate:nil];
    for(int i = 0; i < [items count]; ++i) {
        NSMenuItem *item = [[items objectAtIndex:i] copy];
        [item setTarget:nil];
        [menu removeItemAtIndex:i];
        [menu insertItem:item atIndex:i];
        if([item hasSubmenu])
            [self _menuEnumerateAndChange:[item submenu]];
    }
}

-(void)sendMenusToWindowServer {
    if(_mainMenu == nil)
        return;

    _tagAllMenus(_mainMenu, 1);
    NSMenu *menuCopy = [_mainMenu copy];
    [self _menuEnumerateAndChange:menuCopy];

    NSDictionary *dict = [NSDictionary
        dictionaryWithObjects:@[menuCopy]
        forKeys:@[@"MainMenu"]];

    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:dict];

    Message msg = {0};
    msg.header.msgh_remote_port = _wsSvcPort;
    msg.header.msgh_bits = MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, 0, 0, 0);
    msg.header.msgh_id = MSG_ID_INLINE;
    msg.header.msgh_size = sizeof(msg);
    msg.code = CODE_MENU_FOR_APP;
    msg.pid = getpid();
    strncpy(msg.bundleID, [bundleID UTF8String], sizeof(msg.bundleID));
    int len = MIN([d length], sizeof(msg.data));
    memcpy(msg.data, [d bytes], len);
    msg.len = len;

    if(mach_msg((mach_msg_header_t *)&msg, MACH_SEND_MSG|MACH_SEND_TIMEOUT, sizeof(msg), 0, MACH_PORT_NULL,
            1000 /* ms timeout */, MACH_PORT_NULL) != MACH_MSG_SUCCESS)
        NSLog(@"Failed to send menus to WS");

    [menuCopy release];
    [d release];
}

- (void)addRecentItem:(NSURL *)url {
    Message msg = {0};
    msg.header.msgh_remote_port = _wsSvcPort;
    msg.header.msgh_bits = MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, 0, 0, 0);
    msg.header.msgh_id = MSG_ID_INLINE;
    msg.header.msgh_size = sizeof(msg);
    msg.code = CODE_ADD_RECENT_ITEM;
    strncpy(msg.data, [[url absoluteString] UTF8String], sizeof(msg.data));
    msg.len = strlen(msg.data);

    if(mach_msg((mach_msg_header_t *)&msg, MACH_SEND_MSG|MACH_SEND_TIMEOUT,
        sizeof(msg), 0, MACH_PORT_NULL,
        1000 /* ms timeout */, MACH_PORT_NULL) != MACH_MSG_SUCCESS)
        NSLog(@"Failed to send recent item to WS");
}

- (void)_addStatusItem:(NSStatusItem *)item {
    Message msg = {0};
    msg.header.msgh_remote_port = _wsSvcPort;
    msg.header.msgh_bits = MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, 0, 0, 0);
    msg.header.msgh_id = MSG_ID_INLINE;
    msg.header.msgh_size = sizeof(msg);
    msg.code = CODE_ADD_STATUS_ITEM;

    NSNumber *pid = [NSNumber numberWithUnsignedInt:getpid()];
    NSDictionary *dict = [NSDictionary
        dictionaryWithObjects:@[item,pid]
        forKeys:@[@"StatusItem",@"ProcessID"]];
    NSData *d = [NSKeyedArchiver archivedDataWithRootObject:dict];
    NSObject *o = nil;
    @try {
	o = [NSKeyedUnarchiver unarchiveObjectWithData:d];
    }
    @catch(NSException *localException) {
	NSLog(@"%@",localException);
    }

    if([d length] > sizeof(msg.data)) {
	NSLog(@"Failed to send NSStatusItem to WS: overflow");
	return;
    }

    memcpy(msg.data, [d bytes], [d length]);
    msg.len = [d length];
    [d release];
    [dict release];

    if(mach_msg((mach_msg_header_t *)&msg, MACH_SEND_MSG|MACH_SEND_TIMEOUT,
        sizeof(msg), 0, MACH_PORT_NULL,
        2000 /* ms timeout */, MACH_PORT_NULL) != MACH_MSG_SUCCESS)
        NSLog(@"Failed to send NSStatusItem to WS");
}

-(void)setMenu:(NSMenu *)menu {
   [self setMainMenu:menu];
}

-(void)setApplicationIconImage:(NSImage *)image {
   image=[image retain];
   [_applicationIconImage release];
   _applicationIconImage=image;
   
	[image setName: @"NSApplicationIcon"];
}

-(void)setWindowsMenu:(NSMenu *)menu {
   [_windowsMenu autorelease];
   _windowsMenu=[menu retain];
    [self sendMenusToWindowServer];
}


-(void)addWindowsItem:(NSWindow *)window title:(NSString *)title filename:(BOOL)isFilename {
    NSMenuItem *item;
    
    if ([[self windowsMenu] indexOfItemWithTarget:window andAction:@selector(makeKeyAndOrderFront:)] != -1)
        return;

    if (isFilename)
        title = [NSString stringWithFormat:@"%@  --  %@", [title lastPathComponent],[title stringByDeletingLastPathComponent]];

    item = [[[NSMenuItem alloc] initWithTitle:title action:@selector(makeKeyAndOrderFront:) keyEquivalent:@""] autorelease];
    [item setTarget:window];

    [[self windowsMenu] addItem:item];
    [self sendMenusToWindowServer];
}

-(void)changeWindowsItem:(NSWindow *)window title:(NSString *)title filename:(BOOL)isFilename {

 	if ([title length] == 0) {
    // Windows with no name aren't in the Windows menu
		[self removeWindowsItem:window];
	} else {
		int itemIndex = [[self windowsMenu] indexOfItemWithTarget:window andAction:@selector(makeKeyAndOrderFront:)];
		
		if (itemIndex != -1) {
			NSMenuItem *item = [[self windowsMenu] itemAtIndex:itemIndex];
			
			if (isFilename)
				title = [NSString stringWithFormat:@"%@  --  %@",[title lastPathComponent], [title stringByDeletingLastPathComponent]];
			
			[item setTitle:title];
			[[self windowsMenu] itemChanged:item];
		} 
		else
			[self addWindowsItem:window title:title filename:isFilename];
	}
    [self sendMenusToWindowServer];
}

-(void)removeWindowsItem:(NSWindow *)window {
    int itemIndex = [[self windowsMenu] indexOfItemWithTarget:window andAction:@selector(makeKeyAndOrderFront:)];
    
    if (itemIndex != -1) {
        [[self windowsMenu] removeItemAtIndex:itemIndex];

        if ([[[[self windowsMenu] itemArray] lastObject] isSeparatorItem]){
            [[self windowsMenu] removeItem:[[[self windowsMenu] itemArray] lastObject]];
          }
    }
    [self sendMenusToWindowServer];
}

-(void)updateWindowsItem:(NSWindow *)window {
   NSMenu *menu=[self windowsMenu];
   int     itemIndex=[[self windowsMenu] indexOfItemWithTarget:window andAction:@selector(makeKeyAndOrderFront:)];
   
   if(itemIndex!=-1){
    NSMenuItem *item=[menu itemAtIndex:itemIndex];
    
   }
    [self sendMenusToWindowServer];
}

-(BOOL)openFiles
{
   BOOL opened = NO;
   if(_delegate) {
      id nsOpen = [[NSUserDefaults standardUserDefaults] objectForKey:@"NSOpen"];
      NSArray *openFiles = nil;
      if ([nsOpen isKindOfClass:[NSString class]] && [nsOpen length]) {
         openFiles = [NSArray arrayWithObject:nsOpen];
      } else if ([nsOpen isKindOfClass:[NSArray class]]) {
         openFiles = nsOpen;
      }
      if ([openFiles count] > 0) {
         if ([openFiles count] == 1 && [_delegate respondsToSelector: @selector(application:openFile:)]) {

            if([_delegate application: self openFile: [openFiles lastObject]]) {
               opened = YES;
            }
         } else {
            if ([_delegate respondsToSelector: @selector(application:openFiles:)]) {
               [_delegate application: self openFiles: openFiles];
               opened = YES;

            } else if ([_delegate respondsToSelector: @selector(application:openFile:)]) {
               for (NSString *aFile in openFiles) {
                  opened |= [_delegate application: self openFile: aFile];
               }
            }
         }
      }
      [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NSOpen"];
   }
   return opened;
}

-(void)finishLaunching {
   NSAutoreleasePool *pool=[NSAutoreleasePool new];
   BOOL               needsUntitled=YES;

   NS_DURING
    [[NSNotificationCenter defaultCenter] postNotificationName: NSApplicationWillFinishLaunchingNotification object:self];
   NS_HANDLER
    [self reportException:localException];
   NS_ENDHANDLER

	// Load the application icon if we have one
	NSString* iconName = [[[NSBundle mainBundle] infoDictionary]
						  objectForKey:@"CFBundleIconFile"];
	if (iconName) {
		iconName = [iconName stringByAppendingPathExtension: @"icns"];
		NSImage* image = [NSImage imageNamed: iconName];
		[self setApplicationIconImage: image];
	}

    /* If there are no menus loaded (e.g. we have no nib), make sure we at least have
     * the application menu
     */
    if([self mainMenu] == nil)
        [self setMenu:[NSMenu new]];
	
// Give us a first event
   [NSTimer scheduledTimerWithTimeInterval:0.1 target:nil
     selector:NULL userInfo:nil repeats:NO];

   [self _closeSplashImage];

   NSDocumentController *controller = nil;
   id types=[[[NSBundle mainBundle]
		 infoDictionary]
		objectForKey:@"CFBundleDocumentTypes"];
   if([types count] > 0)
       controller = [NSDocumentController sharedDocumentController];

   if ([self openFiles]) {
      needsUntitled = NO;
   }

   if(needsUntitled && _delegate &&
      [_delegate respondsToSelector: @selector(applicationShouldOpenUntitledFile:)]) {
       needsUntitled = [_delegate applicationShouldOpenUntitledFile: self];
   }

   if(needsUntitled && _delegate && [_delegate respondsToSelector: @selector(applicationOpenUntitledFile:)]) {
     needsUntitled = ![_delegate applicationOpenUntitledFile: self];
   }

   if(needsUntitled && controller && ![controller documentClassForType:[controller defaultType]]) {
       needsUntitled = NO;
   }

   if(needsUntitled && controller) {
       [controller _updateRecentDocumentsMenu]; 
       [controller newDocument: self];
   }
   
   NS_DURING
    [[NSNotificationCenter defaultCenter] postNotificationName:NSApplicationDidFinishLaunchingNotification object:self];
   NS_HANDLER
    [self reportException:localException];
   NS_ENDHANDLER

   [pool release];
}

-(void)_checkForReleasedWindows {
   int  count=[_windows count];

   while(--count>=0){
    NSWindow *check=[_windows objectAtIndex:count];

    if([check retainCount]==1){
    
        // Use the setters here - give a chance to the observer to notice something happened
        if(check==_keyWindow) {
            [self _setKeyWindow:nil];
        }
      
        if(check==_mainWindow) {
            [self _setMainWindow:nil];
        }

     [_windows removeObjectAtIndex:count];
   }
}
}

-(void)_checkForTerminate {
   int  count=[_windows count];

   while(--count>=0){
    NSWindow *check=[_windows objectAtIndex:count];

    if(![check isKindOfClass:[NSPanel class]] && [check isVisible]){
     return;
    }
   }

   [self terminate:self];
}

-(void)_checkForAppActivation {
    if([self isActive])
        [_windows makeObjectsPerformSelector:@selector(_showForActivation)];
    else
        [_windows makeObjectsPerformSelector:@selector(_hideForDeactivation)];
}

-(void)run {

  static BOOL didlaunch = NO;
  NSAutoreleasePool *pool;

  _isRunning=YES;

  if (!didlaunch) {
    didlaunch = YES;
    [self finishLaunching];
  }

   do {
    // There is another pool inside nextEventMatchingMask. Do we really need this one?
    pool = [NSAutoreleasePool new];
    NSEvent           *event;

    event=[self nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantFuture] inMode:NSDefaultRunLoopMode dequeue:YES];

    NS_DURING
     [self sendEvent:event];

    NS_HANDLER
     [self reportException:localException];
    NS_ENDHANDLER

    [self _checkForReleasedWindows];
    [self _checkForTerminate];

    [pool release];
   }while(_isRunning);
}

-(BOOL)_performKeyEquivalent:(NSEvent *)event {
    if (event.charactersIgnoringModifiers.length > 0) {
    /* order is important here, views may want to handle the event before menu*/

        if([[self keyWindow] performKeyEquivalent:event])
            return YES;
        if([[self mainWindow] performKeyEquivalent:event])
            return YES;
        if([[self mainMenu] performKeyEquivalent:event])
            return YES;
    }
// documentation says to send it to all windows
   return NO;
}

-(void)sendEvent:(NSEvent *)event {
    if(event == nil)
        return;

   if([event type]==NSKeyDown){
    unsigned modifierFlags=[event modifierFlags];

    if(modifierFlags&(NSCommandKeyMask|NSAlternateKeyMask))
     if([self _performKeyEquivalent:event])
      return;
   }

   [[event window] sendEvent:event];
}

// This method is used by NSWindow
-(void)_displayAllWindowsIfNeeded {
   [[NSApp windows] makeObjectsPerformSelector:@selector(displayIfNeeded)];
}

-(NSEvent *)nextEventMatchingMask:(unsigned int)mask untilDate:(NSDate *)untilDate inMode:(NSString *)mode dequeue:(BOOL)dequeue {
   NSEvent *nextEvent=nil;
   
   do {
   NSAutoreleasePool *pool=[NSAutoreleasePool new];

   NS_DURING
    //[NSClassFromString(@"Win32RunningCopyPipe") performSelector:@selector(createRunningCopyPipe)];

    // This should happen before _makeSureIsOnAScreen so we don't reposition done windows
    [self _checkForReleasedWindows];

    [[NSApp windows] makeObjectsPerformSelector:@selector(_makeSureIsOnAScreen)];
 
    [self _checkForAppActivation];
     [self _displayAllWindowsIfNeeded];

     nextEvent=[_display nextEventMatchingMask:mask untilDate:untilDate inMode:mode dequeue:dequeue];

     if([nextEvent type]==NSAppKitSystem){
      [nextEvent release];
      nextEvent=nil;
     }
     
   NS_HANDLER
    [self reportException:localException];
   NS_ENDHANDLER

   [pool release];
   }while(nextEvent==nil && [untilDate timeIntervalSinceNow]>0);

   if(nextEvent!=nil){
    nextEvent=[nextEvent retain];

    pthread_mutex_lock(_lock);
     [_currentEvent release];
     _currentEvent=nextEvent;
    pthread_mutex_unlock(_lock);
   }

   return [nextEvent autorelease];
}

-(NSEvent *)currentEvent {
   /* Apps do use currentEvent from secondary threads and it doesn't crash on OS X, so we need to be safe here too. */
   NSEvent *result;

    pthread_mutex_lock(_lock);
     result=[_currentEvent retain];
    pthread_mutex_unlock(_lock);
   
   return [result autorelease];
}

-(void)discardEventsMatchingMask:(unsigned)mask beforeEvent:(NSEvent *)event {
   [_display discardEventsMatchingMask:mask beforeEvent:event];
}

-(void)postEvent:(NSEvent *)event atStart:(BOOL)atStart {
   [_display postEvent:event atStart:atStart];
}

-_searchForAction:(SEL)action responder:target {
  // Search a responder chain 

   while (target != nil) {

    if ([target respondsToSelector:action])
     return target;
          
    if([target respondsToSelector:@selector(nextResponder)])
     target = [target nextResponder];
    else
     break;
   }
  
   return nil;
}

-_searchForAction:(SEL)action window:(NSWindow *)window {
 // Search a windows responder chain and window
 // The window check is done seperately from the responder chain
 // in case the responder chain is broken

// FIXME: should a windows delegate and windowController be checked if a window is found in a responder chain too ?
// Document based facts:
//  An NSWindow's next responder should be the window controller
//  An NSWindow's delegate should be the document
// - This probably means the windowController check is duplicative, but need to make the next responder is window controller

   id check=[self _searchForAction:action responder:[window firstResponder]];
   
   if(check!=nil)
    return check;

   if ([[window delegate] respondsToSelector:action])
    return [window delegate];
    
   if ([[window windowController] respondsToSelector:action])
    return [window windowController];

   return nil;
}

-targetForAction:(SEL)action {
  return [self targetForAction:action to:nil from:nil];
}

-targetForAction:(SEL)action to:target from:sender {
  if (target == nil) 
    {
      target = [self _searchForAction:action window:[self keyWindow]];
      if (target)
        return target;
      
      if ([self mainWindow] != [self keyWindow]) 
        {
          target = [self _searchForAction:action window:[self mainWindow]];
          if (target)
            return target;
        }
    }
  else 
    {
      target = [self _searchForAction:action responder:target];
      if (target)
        return target;
    }
  
  NSDocumentController *documentController = [NSDocumentController sharedDocumentController];
  if ([[documentController currentDocument] respondsToSelector:action])
    return [documentController currentDocument];
  
  if([self respondsToSelector:action])
    return self;
  
  if([[self delegate] respondsToSelector:action])
    return [self delegate];
  
  if([documentController respondsToSelector:action])
    return documentController;
  
  return nil; 
}

-(BOOL)sendAction:(SEL)action to:target from:sender {
  if([target respondsToSelector:action])
    {
      [target performSelector:action withObject:sender];
      return YES;
    }
  
  target=[self targetForAction:action to:target from:sender];
  if (target != nil) 
    {
      [target performSelector:action withObject:sender];
      return YES;
    }
  
  return NO;
}

-(BOOL)tryToPerform:(SEL)selector with:object {
  if ([self respondsToSelector:selector]) 
    {
      [self performSelector:selector withObject:object];
      return YES;
    }
  
  if ([[self delegate] respondsToSelector:selector]) 
    {
      [[self delegate] performSelector:selector withObject:object];
      return YES;
    }
  
  return NO;
}

-(void)setWindowsNeedUpdate:(BOOL)value {
   _windowsNeedUpdate=value;
   NSUnimplementedMethod();
}

-(void)updateWindows {
   [_windows makeObjectsPerformSelector:@selector(update)];
}

-(void)activateIgnoringOtherApps:(BOOL)flag {
   NSUnimplementedMethod();
}

-(void)deactivate {
   NSUnimplementedMethod();
}

-(NSWindow *)modalWindow {
   return [[_modalStack lastObject] modalWindow];
}

-(NSModalSession)beginModalSessionForWindow:(NSWindow *)window {
   NSModalSessionX *session=[NSModalSessionX sessionWithWindow:window];

   [_modalStack addObject:session];

   [window _hideMenuViewIfNeeded];
   if(![window isVisible]){
    [window center];
   }
   [window makeKeyAndOrderFront:self];

   return session;
}

-(int)runModalSession:(NSModalSession)session {
    while([session stopCode]==NSRunContinuesResponse) {
        NSAutoreleasePool *pool=[NSAutoreleasePool new];
        NSEvent           *event=[self nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate date] inMode:NSModalPanelRunLoopMode dequeue:YES];
        
        if(event==nil){
            [pool release];
            break;
        }
        
        NSWindow          *window=[event window];
        
        
        // in theory this could get weird, but all we want is the ESC-cancel keybinding, afaik NSApp doesn't respond to any other doCommandBySelectors...
        if([event type]==NSKeyDown && window == [session modalWindow])
            [self interpretKeyEvents:[NSArray arrayWithObject:event]];
        
        if(window==[session modalWindow] || [window worksWhenModal])
            [self sendEvent:event];
        else if([event type]==NSLeftMouseDown)
            [[session modalWindow] makeKeyAndOrderFront:self];
        else {
            // We need to preserve some events which are not processed in the modal loop and requeue them.
            // The particular case we need to handle is mouse down. run modal. then actually receive the mouse up when the modal is done.
            // So we know this works in Cocoa, save the mouse up here.
            // We don't want to save mouse moved or such.
            // There is kind of adhoc, probably a better way to do it, find out which combinations should work (e.g. mouse enter, do we get mouse exit?) 
            if([[session unprocessedEvents] count]==0){
                
                switch([event type]){
                        
                    case NSLeftMouseUp:
                    case NSRightMouseUp:
                        [session addUnprocessedEvent: event];
                        break;
                        
                    default:
                        // don't save
                        break;
                }
            }
        }
        [pool release];
    }
    
    
    return [session stopCode];
}

-(void)endModalSession:(NSModalSession)session {
    if(session!=[_modalStack lastObject])   
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %s] modal session %@ is not the current one %@",isa,sel_getName(_cmd),session,[_modalStack lastObject]];
    
    for(NSEvent *requeue in [session unprocessedEvents]){
        [self postEvent:requeue atStart:YES];
    }
    
    [[session modalWindow] _showMenuViewIfNeeded];
    [_modalStack removeLastObject];
}

-(void)stopModalWithCode:(int)code {
    // This should silently ignore any attempt to end a session when there is none.
   [[_modalStack lastObject] stopModalWithCode:code];
}

-(void)_mainThreadRunModalForWindow:(NSMutableDictionary *)values {
   NSWindow *window=[values objectForKey:@"NSWindow"];
   
   NSModalSession session=[self beginModalSessionForWindow:window];
   int result;

   while((result=[NSApp runModalSession:session])==NSRunContinuesResponse){
    //NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0.1];
    [[NSRunLoop currentRunLoop] runMode:NSModalPanelRunLoopMode beforeDate:[NSDate distantFuture]];
   }
   
   [self endModalSession:session];

   [values setObject:[NSNumber numberWithInteger:result] forKey:@"result"];
}

-(int)runModalForWindow:(NSWindow *)window {
   NSMutableDictionary *values=[NSMutableDictionary dictionary];
   
   [values setObject:window forKey:@"NSWindow"];
   
   [self performSelectorOnMainThread:@selector(_mainThreadRunModalForWindow:) withObject:values waitUntilDone:YES modes:[NSArray arrayWithObjects:NSDefaultRunLoopMode,NSModalPanelRunLoopMode,nil]];
   
   NSNumber *result=[values objectForKey:@"result"];
   
   return [result integerValue];
}


-(void)stopModal {
   [self stopModalWithCode:NSRunStoppedResponse];
}

-(void)abortModal {
   [self stopModalWithCode:NSRunAbortedResponse];
}

// cancel modal windows
-(void)cancel:sender {
    if ([self modalWindow] != nil)
        [self abortModal];
}

-(void)beginSheet:(NSWindow *)sheet modalForWindow:(NSWindow *)window modalDelegate:modalDelegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo {
    NSSheetContext *context=[NSSheetContext sheetContextWithSheet:sheet modalDelegate:modalDelegate didEndSelector:didEndSelector contextInfo:contextInfo frame:[sheet frame]];

	if ([[NSUserDefaults standardUserDefaults] boolForKey: @"NSRunAllSheetsAsModalPanel"]) {
        // Center the sheet on the window
        NSPoint windowCenter = NSMakePoint(NSMidX([window frame]), NSMidY([window frame]));
        NSPoint sheetCenter = NSMakePoint(NSMidX([sheet frame]), NSMidY([sheet frame]));
        NSPoint origin = [sheet frame].origin;
        origin.x += windowCenter.x - sheetCenter.x;
        origin.y += windowCenter.y - sheetCenter.y;
        [sheet setFrameOrigin:origin];
        
		[sheet _setSheetContext: context];
		[sheet setLevel: NSModalPanelWindowLevel];
		NSModalSession session = [self beginModalSessionForWindow: sheet];
		[context setModalSession: session];
		while([NSApp runModalSession:session] == NSRunContinuesResponse){
			[[NSRunLoop currentRunLoop] runMode:NSModalPanelRunLoopMode beforeDate:[NSDate distantFuture]];
		}
		[self endModalSession:session];
	} else {
		[window _attachSheetContextOrderFrontAndAnimate:context];
	}
}

-(void)endSheet:(NSWindow *)sheet returnCode:(int)returnCode {
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey: @"NSRunAllSheetsAsModalPanel"]) {
		NSSheetContext* context = [sheet _sheetContext];
		NSModalSession session = [context modalSession];
		[session stopModalWithCode: NSRunStoppedResponse];
		IMP function=[[context modalDelegate] methodForSelector:[context didEndSelector]];
		
		if(function!=NULL) {
			function([context modalDelegate],[context didEndSelector],sheet,returnCode,[context contextInfo]);
		}
		[sheet _setSheetContext: nil];
		
	} else {
	
   int count=[_windows count];

   while(--count>=0){
    NSWindow       *check=[_windows objectAtIndex:count];
    NSSheetContext *context=[check _sheetContext];
    IMP             function;
    
    if([context sheet]==sheet){
     [[context retain] autorelease];

     [check _detachSheetContextAnimateAndOrderOut];

     function=[[context modalDelegate] methodForSelector:[context didEndSelector]];
     
     if(function!=NULL)
      function([context modalDelegate],[context didEndSelector],sheet,returnCode,[context contextInfo]);

     return;
    }
   }
	}
}

-(void)endSheet:(NSWindow *)sheet {
   [self endSheet:sheet returnCode:0];
}

-(void)reportException:(NSException *)exception {
   NSLog(@"NSApplication got exception: %@",exception);
}

-(void)_attentionTimer:(NSTimer *)timer {
   [_windows makeObjectsPerformSelector:@selector(_flashWindow)];
}

-(int)requestUserAttention:(NSRequestUserAttentionType)attentionType {
   [_attentionTimer invalidate];
   _attentionTimer=[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(_attentionTimer:) userInfo:nil repeats:YES];

   return 0;
}

-(void)cancelUserAttentionRequest:(int)requestNumber {
   NSUnimplementedMethod();
}

-(void)runPageLayout:sender {
   [[NSPageLayout pageLayout] runModal];
}

-(void)orderFrontColorPanel:(id)sender {
   [[NSColorPanel sharedColorPanel] orderFront:sender];
}

-(void)orderFrontCharacterPalette:sender {
   NSUnimplementedMethod();
}

-(void)hide:sender {//deactivates the application and hides all windows
	if (!_isHidden)
	{
		[[NSNotificationCenter defaultCenter]postNotificationName:NSApplicationWillHideNotification object:self];
		[_windows makeObjectsPerformSelector:@selector(_forcedHideForDeactivation)];//do no use orderOut here ist causes the application to quit if no window is visible
		[[NSNotificationCenter defaultCenter]postNotificationName:NSApplicationDidHideNotification object:self];
	}
	_isHidden=YES;
	
}

-(void)hideOtherApplications:sender {
   NSUnimplementedMethod();
}

-(void)unhide:sender 
{
	
	if (_isHidden)
	{
		[[NSNotificationCenter defaultCenter]postNotificationName:NSApplicationWillUnhideNotification object:self];
		[_windows makeObjectsPerformSelector:@selector(_showForActivation)];//only shows previously hidden windows
		[[NSNotificationCenter defaultCenter]postNotificationName:NSApplicationDidUnhideNotification object:self];
	}
	_isHidden=NO;
	//[self activateIgnoringOtherApps:NO]
	
}

-(void)unhideAllApplications:sender {
   NSUnimplementedMethod();
}

-(void)unhideWithoutActivation {
	if (_isHidden)
	{
		
		[[NSNotificationCenter defaultCenter]postNotificationName:NSApplicationWillUnhideNotification object:self];
		[_windows makeObjectsPerformSelector:@selector(_showForActivation)];//only shows previously hidden windows
		[[NSNotificationCenter defaultCenter]postNotificationName:NSApplicationDidUnhideNotification object:self];
	}
	_isHidden=NO;
}

-(void)stop:sender {
   if([_modalStack lastObject]!=nil){
    [self stopModal];
    return;
   }
   
   _isRunning=NO;
}

-(void)terminate:sender 
{
  [[NSDocumentController sharedDocumentController] closeAllDocumentsWithDelegate:self 
                                                             didCloseAllSelector:@selector(_documentController:didCloseAll:contextInfo:)
                                                                     contextInfo:NULL];
}

-(void)_documentController:(NSDocumentController *)docController didCloseAll:(BOOL)didCloseAll contextInfo:(void *)info
{
  // callback method for terminate:
  if (didCloseAll)
    {
      if ([_delegate respondsToSelector:@selector(applicationShouldTerminate:)])
        [self replyToApplicationShouldTerminate: [_delegate applicationShouldTerminate:self] == NSTerminateNow];
      else
        [self replyToApplicationShouldTerminate:YES];
    }
}

-(void)replyToApplicationShouldTerminate:(BOOL)terminate 
{
  if (terminate == YES)
    {
      [[NSNotificationCenter defaultCenter] postNotificationName:NSApplicationWillTerminateNotification object:self];
      
      //[NSClassFromString(@"Win32RunningCopyPipe") performSelector:@selector(invalidateRunningCopyPipe)];
      
      exit(0);
    }
}

-(void)replyToOpenOrPrint:(NSApplicationDelegateReply)reply {
   NSUnimplementedMethod();
}

-(void)arrangeInFront:sender {
#define CASCADE_DELTA	20		// ? isn't there a call for this?
    NSMutableArray *visibleWindows = [NSMutableArray new];
    NSRect rect=[[[NSScreen screens] objectAtIndex:0] frame], winRect;
    NSArray *windowsItems = [[self windowsMenu] itemArray];
    int i, count=[windowsItems count];

    for (i = 0 ; i < count; ++i) {
        id target = [[windowsItems objectAtIndex:i] target];

        if ([target isKindOfClass:[NSWindow class]])
            [visibleWindows addObject:target];
    }

    count = [visibleWindows count];
    if (count == 0)
        return;

    // find screen center.
    // subtract window w,h /2
    winRect = [[visibleWindows objectAtIndex:0] frame];
    rect.origin.x = (rect.size.width/2) - (winRect.size.width/2);
    rect.origin.x -= count*CASCADE_DELTA/2;
    rect.origin.x=floor(rect.origin.x);

    rect.origin.y = (rect.size.height/2) + (winRect.size.height/2);
    rect.origin.y += count*CASCADE_DELTA/2;
    rect.origin.y=floor(rect.origin.y);

    for (i = 0; i < count; ++i) {
        [[visibleWindows objectAtIndex:i] setFrameTopLeftPoint:rect.origin];
        [[visibleWindows objectAtIndex:i] orderFront:nil];

        rect.origin.x += CASCADE_DELTA;
        rect.origin.y -= CASCADE_DELTA;
    }
}

-(NSMenu *)servicesMenu {
   return [[NSApp mainMenu] _menuWithName:@"_NSServicesMenu"];
}

-(void)setServicesMenu:(NSMenu *)menu {
   NSUnimplementedMethod();
}

-servicesProvider {
   return nil;
}

-(void)setServicesProvider:provider {
}

-(void)registerServicesMenuSendTypes:(NSArray *)sendTypes returnTypes:(NSArray *)returnTypes {
   //tiredofthesewarnings NSUnsupportedMethod();
}

-validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType {
   NSUnimplementedMethod();
   return nil;
}


-(void)orderFrontStandardAboutPanel:sender {
   [self orderFrontStandardAboutPanelWithOptions:nil];
}

-(void)orderFrontStandardAboutPanelWithOptions:(NSDictionary *)options {
    NSSystemInfoPanel *standardAboutPanel = [[NSSystemInfoPanel 
standardAboutPanel] retain]; 
   [standardAboutPanel showInfoPanel:self withOptions:options]; 

}

-(void)activateContextHelpMode:sender {
   NSUnimplementedMethod();
}

-(void)showGuessPanel:sender {
	[[[NSSpellChecker sharedSpellChecker] spellingPanel] makeKeyAndOrderFront: self];
}

-(void)showHelp:sender
{
	NSString *helpBookFolder = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleHelpBookFolder"];
	if(helpBookFolder != nil) {
		BOOL isDir;
		NSString *folder = [[NSBundle mainBundle] pathForResource:helpBookFolder ofType:nil];
		if(folder != nil && [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&isDir] && isDir) {
			NSBundle* helpBundle = [NSBundle bundleWithPath: folder];
			if (helpBundle) {
				NSString *helpBookName = [[helpBundle infoDictionary] objectForKey:@"CFBundleHelpTOCFile"];
				if(helpBookName != nil) {
					NSString* helpFilePath = [helpBundle pathForResource: helpBookName ofType: nil];
					if (helpFilePath) {
						if([[NSWorkspace sharedWorkspace] openFile:helpFilePath withApplication:@"Help Viewer"]==YES) {
							return;
						}
					}
				}
				// Perhaps there's an index.html file that'll be usable?
				NSString* helpFilePath = [helpBundle pathForResource: @"index" ofType: @"html"];
				if (helpFilePath) {
					if([[NSWorkspace sharedWorkspace] openFile:helpFilePath withApplication:@"Help Viewer"]==YES) {
						return;
					}
				}
			}
		}
	}
	
   NSString *processName = [[NSProcessInfo processInfo] processName];
   NSAlert *alert = [[NSAlert alloc] init];
   [alert setMessageText: NSLocalizedStringFromTableInBundle(@"Help", nil, [NSBundle bundleForClass: [NSApplication class]], @"Help alert title")];
   [alert setInformativeText:[NSString stringWithFormat: NSLocalizedStringFromTableInBundle(@"Help isn't available for %@.", nil, [NSBundle bundleForClass: [NSApplication class]], @""), processName]];
   [alert runModal];
   [alert release];
}

-(NSDockTile *)dockTile {
   return _dockTile;
}

- (void)doCommandBySelector:(SEL)selector {
    if ([_delegate respondsToSelector:selector])
        [_delegate performSelector:selector withObject:nil];
    else
        [super doCommandBySelector:selector];
}

-(void)_addWindow:(NSWindow *)window {
   [_windows addObject:window];
}

-(void)_removeWindow:(NSWindow *)window {
    [_windows removeObject:window];
}

-(void)_windowWillBecomeActive:(NSWindow *)window {
   [_attentionTimer invalidate];
   _attentionTimer=nil;
   
   if(![self isActive]){
    [[NSNotificationCenter defaultCenter] postNotificationName:NSApplicationWillBecomeActiveNotification object:self];
   }
}

-(void)_windowDidBecomeActive:(NSWindow *)window {
    if(![self isActiveExcludingWindow:window]){
        if(_wsSvcPort) {
            Message msg = {0};
            msg.header.msgh_remote_port = _wsSvcPort;
            msg.header.msgh_bits = MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, 0, 0, 0);
            msg.header.msgh_id = MSG_ID_INLINE;
            msg.header.msgh_size = sizeof(msg);
            msg.code = CODE_APP_BECAME_ACTIVE;

            unsigned int pid = getpid();
            msg.len = sizeof(pid);
            memcpy(msg.data, &pid, msg.len);

            if(mach_msg((mach_msg_header_t *)&msg, MACH_SEND_MSG|MACH_SEND_TIMEOUT,
                sizeof(msg), 0, MACH_PORT_NULL,
                1000 /* ms timeout */, MACH_PORT_NULL) != MACH_MSG_SUCCESS)
                NSLog(@"Failed to send activation state to WS");
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NSApplicationDidBecomeActiveNotification object:self];
   }
}

-(void)_windowWillBecomeDeactive:(NSWindow *)window {
   if(![self isActiveExcludingWindow:window]){
	   [[NSNotificationCenter defaultCenter] postNotificationName:NSApplicationWillResignActiveNotification object:self];
   }
}

-(void)_windowDidBecomeDeactive:(NSWindow *)window {
    if(![self isActive]){
        if(_wsSvcPort) {
            Message msg = {0};
            msg.header.msgh_remote_port = _wsSvcPort;
            msg.header.msgh_bits = MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, 0, 0, 0);
            msg.header.msgh_id = MSG_ID_INLINE;
            msg.header.msgh_size = sizeof(msg);
            msg.code = CODE_APP_BECAME_INACTIVE;

            unsigned int pid = getpid();
            msg.len = sizeof(pid);
            memcpy(msg.data, &pid, msg.len);

            if(mach_msg((mach_msg_header_t *)&msg, MACH_SEND_MSG|MACH_SEND_TIMEOUT,
                sizeof(msg), 0, MACH_PORT_NULL,
                1000 /* ms timeout */, MACH_PORT_NULL) != MACH_MSG_SUCCESS)
                NSLog(@"Failed to send activation state to WS");
        } 
        // Exposed menus are running tight event tracking loops and would remain visible when the app deactivates (making
        // the UI less than community minded) - unfortunately because they're in these tracking loops they're waiting
        // on events and even though they could receive the notification sent here they can't deal with it until an event is
        // received to let them proceed. This special event type was added to help them get unstuck and remove the menu on
        // deactivation
        NSEvent* appKitEvent = [NSEvent otherEventWithType: NSAppKitDefined location: NSZeroPoint modifierFlags: 0 timestamp: 0 windowNumber: 0 context: nil subtype: NSApplicationDeactivated data1: 0 data2: 0];
        [self postEvent: appKitEvent atStart: YES];
	   
        [[NSNotificationCenter defaultCenter] postNotificationName:NSApplicationDidResignActiveNotification object:self];
    }
}

//private method called when the application is reopened
-(void)_reopen {
    BOOL doReopen=YES;
    if ([_delegate respondsToSelector:@selector(applicationShouldHandleReopen:hasVisibleWindows:)])
        doReopen=[_delegate applicationShouldHandleReopen:self hasVisibleWindows:!_isHidden];
    if(!doReopen)
        return;
    if(_isHidden)
        [self unhide:nil];
}

@end


int NSApplicationMain(int argc, const char *argv[]) {
    __NSInitializeProcess(argc, argv);

    NSAutoreleasePool *pool=[NSAutoreleasePool new];
    NSBundle *bundle=[[NSBundle mainBundle] retain];
    Class     class=[bundle principalClass];
    NSString *nibFile=[[bundle infoDictionary] objectForKey:@"NSMainNibFile"];

    if (argc > 1) {
        NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:argc-1];
        for (int i = 1; i < argc; i++)
            if (argv[i][0] != '-')
                [arguments addObject:[NSString stringWithUTF8String:argv[i]]];
            else if (argv[i][1] == '-' && argv[i][2] == '\0')
                break;
            else // (argv[i][0] == '-' && argv[i] != "--")
                if (*(int64_t *)argv[i] != *(int64_t *)"-NSOpen")
                    i++;

        if (argc = [arguments count])
            [[NSUserDefaults standardUserDefaults] setObject:((argc == 1) ? [arguments lastObject] : arguments) forKey:@"NSOpen"];
    }

//     [NSClassFromString(@"Win32RunningCopyPipe") performSelector:@selector(startRunningCopyPipe)];

    if(class==Nil)
        class=[NSApplication class];

    [[class sharedApplication] retain];

    nibFile=[nibFile stringByDeletingPathExtension];

    if(![NSBundle loadNibNamed:nibFile owner:NSApp])
        NSLog(@"Unable to load main nib file %@",nibFile);

    [pool release];

    [NSApp run];

    [NSApp release];
    [bundle release];

    return 0;
}

void NSUpdateDynamicServices(void) {
    NSUnimplementedFunction();
}

BOOL NSPerformService(NSString *itemName, NSPasteboard *pasteboard) {
    NSUnimplementedFunction();
    return NO;
}
