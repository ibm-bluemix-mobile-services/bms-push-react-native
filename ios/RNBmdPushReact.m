
#import "RNBmdPushReact.h"
#import "BMDAppDelegate.h"
#import "BMDReactConstants.h"
//#import "RNBmdPushReact-Swift.h"
#import <RNBmdPushReact/RNBmdPushReact-Swift.h>
//@class BMSPushReactBinder;
@implementation RNBmdPushReact

@synthesize registerPromiseReject, registerPromiseResolve, bmdNotificationsCallback;
static BMSPushReactBinder* bmsPushReactBinder = nil;


- (RNBmdPushReact *)init {
    
    bmsPushReactBinder = [BMSPushReactBinder sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoteNotification:) name: REACTBMDPushSendPushNotifications object:nil];
    
    return [super init];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (NSArray<NSString *>*) supportedEvents
{
    return @[@"RNBmdPushReact", @"onBMDPushReceived"];
}
RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(initialize:(NSDictionary*) config  resolveCallback:(RCTPromiseResolveBlock) resolve rejectCallback:(RCTPromiseRejectBlock) reject)
{
    return [bmsPushReactBinder initializeWithAppGUIDWithConfig:config resolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(registerDevice:(NSDictionary*) config resolveCallback:(RCTPromiseResolveBlock) resolve rejectCallback:(RCTPromiseRejectBlock) reject) {
    registerPromiseReject = reject;
    registerPromiseResolve = resolve;
    return [bmsPushReactBinder registerDevice:config resolver:resolve rejecter:reject];
    
}

RCT_EXPORT_METHOD(unRegisterDevice:(RCTPromiseResolveBlock) resolve rejectCallback:(RCTPromiseRejectBlock) reject) {
    return [bmsPushReactBinder unregisterDevice:resolve rejecter:reject];
    
}

RCT_EXPORT_METHOD(retrieveSubscriptions:(RCTPromiseResolveBlock) resolve rejectCallback:(RCTPromiseRejectBlock) reject) {
    return [bmsPushReactBinder retrieveSubscriptions:resolve rejecter:reject];
    
}

RCT_EXPORT_METHOD(retrieveAvailableTags:(RCTPromiseResolveBlock) resolve rejectCallback:(RCTPromiseRejectBlock) reject) {
    return [bmsPushReactBinder retrieveAvailableTags:resolve rejecter:reject];
    
}

RCT_EXPORT_METHOD(subscribe:(NSString *) tag resolveCallback:(RCTPromiseResolveBlock) resolve rejectCallback:(RCTPromiseRejectBlock) reject) {
    return [bmsPushReactBinder subscribe:tag resolver:resolve rejecter:reject];
    
}

RCT_EXPORT_METHOD(unsubscribe:(NSString *) tag resolveCallback:(RCTPromiseResolveBlock) resolve rejectCallback:(RCTPromiseRejectBlock) reject) {
    return [bmsPushReactBinder unsubscribe:tag resolver:resolve rejecter:reject];
    
}

RCT_EXPORT_METHOD(registerNotificationsCallback:(NSString *) callbackid) {
    self.bmdNotificationsCallback = callbackid;
    NSLog(@"got string: %@", callbackid);
    // return [bmsPushReactBinder registerNotificationsCallbackWithCallbackid:callbackid];
    
}


- (void) didReceiveRemoteNotification: (NSNotification*) notification {
    
    if (self.bmdNotificationsCallback != nil && ![self.bmdNotificationsCallback  isEqual: @""]) {
        [self sendEventWithName:self.bmdNotificationsCallback body:[notification userInfo]];
    }
}
// Private functions

-(BOOL) hasPushEnabled {
    
    UIApplication *application = [UIApplication sharedApplication];
    BOOL enabled = [application isRegisteredForRemoteNotifications];
    return enabled;
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}


@end
  
