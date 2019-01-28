
#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

#else
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"

#endif
#import <Foundation/Foundation.h>

@class BMSPushReactBinder;
@interface RNBmdPushReact : RCTEventEmitter<RCTBridgeModule>

@property (readwrite, nonatomic) RCTPromiseRejectBlock registerPromiseReject;
@property (readwrite, nonatomic) RCTPromiseResolveBlock registerPromiseResolve;
@property (readwrite, nonatomic) NSString* bmdNotificationsCallback;

@end
  
