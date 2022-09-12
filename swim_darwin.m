//go:build darwin

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

const char* get() {
  TISInputSourceRef currentInputSource = TISCopyCurrentKeyboardInputSource();
  NSString *sourceID = (__bridge NSString *)(TISGetInputSourceProperty(currentInputSource, kTISPropertyInputSourceID));
  const char *cstrSourceID = [sourceID UTF8String];
  CFRelease(currentInputSource);
  return cstrSourceID;
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
