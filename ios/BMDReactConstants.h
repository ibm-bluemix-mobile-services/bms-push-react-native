//
//  BMDReactConstants.h
//  RNBmdPushReact
//
//  Created by Anantha Krishnan K G on 17/01/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BMDReactConstants : NSObject

extern NSString *const REACTBMDPushDidRegisterForRemoteNotificationsWithDeviceToken;
extern NSString *const REACTBMDushDidFailToRegisterForRemoteNotificationsWithError;
extern NSString *const REACTBMDPushHandleActionWithIdentifier;
extern NSString *const REACTBMDPushDidReceiveRemoteNotifications;
extern NSString *const REACTBMDPushSendPushNotifications;
extern NSString *const REACTBMDUIApplicationDidFinishLaunchingNotifications;

@end

NS_ASSUME_NONNULL_END
