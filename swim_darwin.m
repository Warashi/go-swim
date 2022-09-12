//go:build darwin

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#import <AppKit/AppKit.h>

@interface InputMethodObserver : NSObject {
  const char* current;
  NSTextInputContext *context;
}
@end

@implementation InputMethodObserver : NSObject
- (id) init {
  self = [super init];
  if (!self) {
    return nil;
  }
  context = [[NSTextInputContext alloc] initWithClient: [NSTextView new]];
  [self update: nil];
  return self;
}

- (void) update: (NSNotification*) notif {
  TISInputSourceRef currentInputSource = TISCopyCurrentKeyboardInputSource();
  NSString *sourceID = (__bridge NSString *)(TISGetInputSourceProperty(currentInputSource, kTISPropertyInputSourceID));
  current = [sourceID UTF8String];
  CFRelease(currentInputSource);
}

- (const char*) current {
  return current;
}
@end

InputMethodObserver *observer;

void init() {
  observer = [[InputMethodObserver alloc] init];
  [[NSDistributedNotificationCenter defaultCenter]
    addObserver: observer
       selector: @selector(update:)
           name: (__bridge NSString*)kTISNotifySelectedKeyboardInputSourceChanged
         object: nil
     suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately
  ];
}

void eventloop() {
    @autoreleasepool {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

const char* get() {
  return [observer current];
}

int set(const char *sourceID) {
  NSString *inputSource = [NSString stringWithUTF8String:sourceID];
  NSDictionary *filter = [NSDictionary dictionaryWithObject:inputSource forKey:(NSString *)kTISPropertyInputSourceID];
  CFArrayRef keyboards = TISCreateInputSourceList((__bridge CFDictionaryRef)filter, false);
  if (keyboards) {
    TISInputSourceRef selected = (TISInputSourceRef)CFArrayGetValueAtIndex(keyboards, 0);
    int ret = TISSelectInputSource(selected);
    CFRelease(keyboards);
    return ret;
  } else {
    return 1;
  }
}
