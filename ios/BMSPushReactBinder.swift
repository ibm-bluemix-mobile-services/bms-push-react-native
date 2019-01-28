//
//  BMSPushReactBinder.swift
//  RNBmdPushReact
//
//  Created by Anantha Krishnan K G on 17/01/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation
import BMSPush
import BMSCore
import BMSAnalyticsAPI
import UIKit

#if swift(>=3.0)
import UserNotifications
import UserNotificationsUI
#endif

@objc public class BMSPushReactBinder: NSObject, BMSPushObserver {
    
    // MARK: Constants
    private let DEVICEID = "deviceId";
    private let CATEGORIES = "categories";
    private let USERID = "userId";
    private let IDENTIFIER_NAME = "IdentifierName";
    private let ACTION_NAME = "actionName";
    private let ICON_NAME = "IconName";
    private let PUSHVARIABLES = "variables";
    
    private let PUSHAPPGUID = "appGUID";
    private let PUSHCLIENTSECRET = "clientSecret";
    private let PUSHREGION = "region";
    private let PUSHOPTIONS = "options";
    
    // MARK: VARIBALES
    @objc public static let sharedInstance = BMSPushReactBinder()
    private var push:BMSPushClient?
    
    var pushUserId = String();
    var shouldRegister:Bool = false
    
    #if swift(>=3.0)
    var bmsPushToken:Data?
    #else
    var bmsPushToken:NSData?
    #endif
    
    var registerPromiseResolve:RCTPromiseResolveBlock?
    var registerPromiseReject:RCTPromiseRejectBlock?
    
    var initPromiseResolve:RCTPromiseResolveBlock?
    var initPromiseReject:RCTPromiseRejectBlock?
    
    // MARK: FUNCTIONS
    public func onChangePermission(status: Bool) {
        
        print("Push Notification is enabled:  \(status)" as NSString)
        if status {
            
            if(initPromiseResolve != nil) {
                initPromiseResolve!("IBM cloud Push Notification init successful")
            }
        } else {
            if(initPromiseReject != nil) {
                initPromiseReject!("400","IBM cloud Push Notification init failed",nil);
            }
        }
    }
    
    private override init() {
        super.init()
        push =  BMSPushClient.sharedInstance
        push?.delegate = self
        print("BMSPushReactBinder init")
        
        // NOTIFICATION OBSERVERS FOR APPDELEGATE METHODS
        NotificationCenter.default.addObserver(self, selector: #selector(BMSPushReactBinder.didRegisterForRemoteNotifications(notification:)), name: NSNotification.Name(rawValue: REACTBMDPushDidRegisterForRemoteNotificationsWithDeviceToken), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BMSPushReactBinder.didFailToRegisterForRemoteNotifications(notification:)), name: NSNotification.Name(rawValue: REACTBMDushDidFailToRegisterForRemoteNotificationsWithError), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BMSPushReactBinder.didReceiveRemoteNotification(notification:)), name: NSNotification.Name(rawValue: REACTBMDPushDidReceiveRemoteNotifications), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BMSPushReactBinder.didReceiveRemoteNotification(notification:)), name: NSNotification.Name(rawValue: REACTBMDPushHandleActionWithIdentifier), object: nil)
    }
    
    
    @objc public func initializeWithAppGUID (config: NSDictionary, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        self.initPromiseResolve = resolve
        self.initPromiseReject = reject
        if config.count <= 0 {
            print("Empty config in init")
            let message = "Empty config in init"
            reject("\(404)", message, nil)
            return
        }
        
        guard let appGUID = config.value(forKey: PUSHAPPGUID) as? String else {
            print("Empty appGUID in init")
            let message = "Empty appGUID in init"
            reject("\(404)", message, nil)
            return
        }
        
        guard let clientSecret = config.value(forKey: PUSHCLIENTSECRET)as? String else {
            print("Empty clientSecret in init")
            let message = "Empty clientSecret in init"
            reject("\(404)", message, nil)
            return
        }
        
        guard let region = config.value(forKey: PUSHREGION) as? String else {
            print("Empty region in init")
            let message = "Empty region in init"
            reject("\(404)", message, nil)
            return
        }
        
        BMSClient.sharedInstance.initialize(bluemixRegion: region)
        
        if let bmsNotifOptions = config.value(forKey: PUSHOPTIONS) as? NSDictionary  {
            
            if bmsNotifOptions.count > 0 {
                
                var categoryArray = [BMSPushNotificationActionCategory]()
                let notifOptions = BMSPushClientOptions();
                
                if bmsNotifOptions[CATEGORIES] != nil {
                    guard let result = bmsNotifOptions.value(forKey:CATEGORIES) as? [String:AnyObject] else {
                        print("init error: Invalid BMSPush Options")
                        let message = "init error: Invalid BMSPush Options"
                        reject("\(404)", message, nil)
                        return
                    }
                    if(result.count > 0){
                        for name in result{
                            
                            let identifiers:NSArray = (name.value) as! NSArray
                            var actionArray = [BMSPushNotificationAction]()
                            for identifier in identifiers {
                                
                                let resultJson = identifier as? NSDictionary
                                let identifierName = resultJson?.value(forKey: IDENTIFIER_NAME);
                                let actionName = resultJson?.value(forKey: ACTION_NAME);
                                
                                actionArray.append(BMSPushNotificationAction(identifierName: identifierName as! String, buttonTitle:actionName as! String, isAuthenticationRequired: false, defineActivationMode: UIUserNotificationActivationMode.foreground))
                            }
                            let category = BMSPushNotificationActionCategory(identifierName: name.key , buttonActions: actionArray)
                            categoryArray.append(category)
                        }
                        notifOptions.setInteractiveNotificationCategories(categoryName: categoryArray)
                    }
                }
                
                if bmsNotifOptions[DEVICEID] != nil {
                    guard let deviceId = bmsNotifOptions.value(forKey:DEVICEID) as? String else {
                        print("init error: Invalid BMSPush Options")
                        let message = "init error: Invalid BMSPush Options"
                        reject("\(404)", message, nil)
                        return
                    }
                    notifOptions.setDeviceId(deviceId: deviceId)
                }
                if bmsNotifOptions[PUSHVARIABLES] != nil {
                    guard let variables = bmsNotifOptions.value(forKey:PUSHVARIABLES) as? [String: String] else {
                        print("init error: Invalid BMSPush Options")
                        let message = "init error: Invalid BMSPush Options"
                        reject("\(404)", message, nil)
                        return
                    }
                    notifOptions.setPushVariables(pushVariables: variables)
                }
                let push = BMSPushClient.sharedInstance;
                push.initializeWithAppGUID(appGUID: appGUID, clientSecret: clientSecret, options: notifOptions);
            } else {
                print("init error: Invalid BMSPush Options")
                let message = "init error: Invalid BMSPush Options"
                reject("\(404)", message, nil)
                return
            }
        } else {
            
            push?.initializeWithAppGUID(appGUID: appGUID, clientSecret: clientSecret)
        }
    }
    
    @objc public func registerDevice(_ config: NSDictionary,
                                     resolver resolve: @escaping RCTPromiseResolveBlock,
                                     rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        if let userId = config.value(forKey: USERID) as? String{
            self.pushUserId = userId
        }
        self.registerPromiseResolve = resolve
        self.registerPromiseReject = reject
        shouldRegister = true;
        registerforPush()
    }
    
    @objc public func unregisterDevice(_ resolve: @escaping RCTPromiseResolveBlock,
                                       rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        push?.unregisterDevice(completionHandler: { (response, statusCode, error) in
            
            if error.isEmpty {
                
                let message = response?.description
                UIApplication.shared.unregisterForRemoteNotifications()
                resolve(message);
            } else {
                
                let message = error.description
                reject("\(statusCode ?? 404)",message,error as? Error)
            }
        })
        
    }
    
    @objc public func retrieveSubscriptions(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        push?.retrieveSubscriptionsWithCompletionHandler { (response, statusCode, error) -> Void in
            
            if error.isEmpty {
                let message = response?.description
                resolve(message);
            }
            else {
                
                print( "Error during retrieveSubscriptions \(error) ")
                let message = error.description
                reject("\(statusCode ?? 404)", message, error as? Error)
            }
        }
        
    }
    
    @objc public func retrieveAvailableTags(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        push?.retrieveAvailableTagsWithCompletionHandler(completionHandler: { (response, statusCode, error) in
            
            if error.isEmpty {
                
                let message = response?.description
                resolve(message);
                
            }
            else{
                
                print( "Error during retrieveAvailableTags \(error) ")
                let message = error.description
                reject("\(statusCode ?? 404)", message, error as? Error)
            }
        })
        
    }
    
    
    @objc public func subscribe(_ tag: String , resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        if tag.isEmpty {
            
            print( "Error during subscribe: empty tag")
            let message = "Error during subscribe: empty tag"
            reject("\(404)", message, nil)
        } else {
            
            let tagsArray = [tag]
            push?.subscribeToTags(tagsArray: tagsArray as NSArray, completionHandler: { (response, statusCode, error) -> Void in
                
                if error.isEmpty {
                    
                    let message = response?.description
                    resolve(message);
                    
                    
                }else{
                    
                    print( "Error during subscribe Tags \(error) ")
                    let message = error.description
                    reject("\(statusCode ?? 404)", message, error as? Error)
                }
            });
        }
    }
    
    
    @objc public func unsubscribe(_ tag: String , resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
        
        if tag.isEmpty {
            
            let message = "Error during unsubscribe: empty tag"
            print( message)
            reject("\(404)", message, nil)
        } else {
            
            let tagsArray = [tag]
            push?.unsubscribeFromTags(tagsArray: tagsArray as NSArray, completionHandler: { (response, statusCode, error) -> Void in
                
                if error.isEmpty {
                    
                    let message = response?.description
                    resolve(message);
                    
                }else{
                    
                    print( "Error during unsubscribe Tags \(error) ")
                    let message = error.description
                    reject("\(statusCode ?? 404)", message, error as? Error)
                }
            });
        }
    }
    
    @objc func didFailToRegisterForRemoteNotifications(notification:Notification) {
        
        
        guard let error = notification.object as? Error else {
            if self.registerPromiseReject != nil {
                self.registerPromiseReject!("\(404)","didFailToRegisterForRemoteNotifications",nil)
            }
            return
        }
        if self.registerPromiseReject != nil {
            self.registerPromiseReject!("\(404)","didFailToRegisterForRemoteNotifications",error)
        }
    }
    
    @objc func didRegisterForRemoteNotifications(notification:Notification) {
        
        guard let token = notification.object as? Data else {
            print("Error wile getting token")
            return
        }
        bmsPushToken = token
        registerforPush()
    }
    
    func registerforPush() {
        
        if let token = bmsPushToken , shouldRegister {
            
            if pushUserId.isEmpty {
                
                push?.registerWithDeviceToken(deviceToken: token, completionHandler: { (response, statusCode, error) in
                    
                    if (!error.isEmpty) {
                        let message = error.description
                        // call error callback
                        if self.registerPromiseReject != nil {
                            self.registerPromiseReject!("\(statusCode ?? 404)",message,error as? Error)
                        }
                    }
                    else {
                        if self.registerPromiseResolve != nil {
                            self.registerPromiseResolve!(response)
                        }
                    }
                })
            } else {
                
                push?.registerWithDeviceToken(deviceToken: token, WithUserId: self.pushUserId, completionHandler: { (response, statusCode, error) in
                    if (!error.isEmpty) {
                        let message = error.description
                        // call error callback
                        if self.registerPromiseReject != nil {
                            self.registerPromiseReject!("\(statusCode ?? 404)",message,error as? Error)
                        }
                    }
                    else {
                        if self.registerPromiseResolve != nil {
                            self.registerPromiseResolve!(response)
                        }
                    }
                })
            }
        } else {
            
            print("Error in token")
        }
    }
    
    
    @objc func didReceiveRemoteNotification(notification:Notification) {
        
        guard let userinfo = notification.userInfo else {
            return
        }
        
        var notif: [String : AnyObject] = [:]
        
        if let _ = userinfo["has-template"] as? Int {
            BMSPushClient.sharedInstance.didReciveBMSPushNotification(userInfo: userinfo) { (res, error) in
                return
            }
        } else {
            
            notif["message"] = ((userinfo["aps"] as! NSDictionary).value(forKey: "alert") as! NSDictionary).value(forKey: "body") as AnyObject?
            
            notif["payload"] = userinfo["payload"] as AnyObject?
            notif["url"] = userinfo["url"] as AnyObject?
            notif["sound"] = (userinfo["aps"] as! NSDictionary).value(forKey: "sound") as AnyObject?
            notif["badge"] = (userinfo["aps"] as! NSDictionary).value(forKey: "badge") as AnyObject?
            
            notif["action-loc-key"] = ((userinfo["aps"] as! NSDictionary).value(forKey: "alert") as! NSDictionary).value(forKey: "action-loc-key") as AnyObject?
            
            if let actionName = userinfo["identifierName"] {
                notif["identifierName"] = actionName as AnyObject
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: REACTBMDPushSendPushNotifications) , object: nil, userInfo: notif)
        }
    }
    
}
