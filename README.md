
# react-native-bmd-push-react

IBM Cloud Mobile Services - Client SDK React Native for Push service

This is the Push component of the React Native SDK for [IBM Cloud Mobile Services](https://console.ng.net/docs/mobile/index.html).


## Requirements:

- Xcode 10+
- Android: minSdkVersion 16+, compileSdkVersion 28+
- React Native >= 0.57.8
- React Native cli >= 2.0.1

## Installation

Install the `bmd-push-react-native` using ,

```JS
$ npm install bmd-push-react-native --save
```

### Mostly automatic installation

You can link the package like this,

````JS
$ react-native link bmd-push-react-native
````

### Manual installation

If you want to link it manually ,

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `bmd-push-react-native` and add `RNBmdPushReact.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNBmdPushReact.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
- Add `import com.bmdpush.react.RNBmdPushReactPackage;` to the imports at the top of the file
- Add `new RNBmdPushReactPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
```
include ':bmd-push-react-native'
project(':bmd-push-react-native').projectDir = new File(rootProject.projectDir,     '../node_modules/bmd-push-react-native/android')
```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
```
compile project(':bmd-push-react-native')
```


## Dependencies,

### iOS

#### Carthage 

1. Create a cart file inside the iOS app folder. Carthage file should be like this ,

```
github "ibm-bluemix-mobile-services/bms-clientsdk-swift-push"
```  

2. Do the `carthage update` in terminal.

3. open the Project in XCode and add the frameworks inside the `Embedded Binaries`

#### Add dependencies framework directly .

1.  Drag and drop the [BMSPush.framework](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-push), [BMSCore.framework](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-core) and [BMSAnalyticsAPI.framework](https://github.com/ibm-bluemix-mobile-services/bms-clientsdk-swift-analytics-api) to the iOS app.


### Android 

 Create a [firebase project](https://console.firebase.google.com) and add the following bundle ids for android,

  1. Add `com.bmdpush.react` and `com.ibm.mobilefirstplatform.clientsdk.android.push` .

Download the `google-services.json` and add inside the `node_modules` ➜ `bmd-push-react-native`  ➜ `android`.

## Set up

### iOS 

Open the iOS app in XCode and do the following ,

1. Under the Capabilities section enable the `Push Notifications` 
2. Enable the `Background modes` for `Remote notifications` and `Background fetch`
3. Go to `Build Settings` and make the following changes 

   a. locate `Other Linker Flags` and add `-lc++` , `-ObjC` and `$(inherited)`
   
   b. locate `Framework Search Paths` and add `$(PROJECT_DIR)/Carthage/Build/iOS` as `non-recursive`
   
   c. locate `Library Search Paths` and add `$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)`  as `non-recursive`
   
   d. locate `Always Embed Swift Standard Libraries` and make it `Yes`.


Now you can build and run the iOS app from Xcode or using the `react-native run-ios` command.


### Android 

Add the following inside the `AndroidManifest.xml` file .

1. Add  `xmlns:tools="http://schemas.android.com/tools"` in the `<manifest ...> ` tag

For example 
```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
xmlns:tools="http://schemas.android.com/tools" package="com.pushsample">
```

2. Add the following permissions,

```
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.GET_ACCOUNTS" />
<uses-permission android:name="android.permission.USE_CREDENTIALS" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
```

3. Add `tools:replace="android:allowBackup"` inside the `<application ..>` tag

For example 
```
<application
android:name=".MainApplication"
android:label="@string/app_name"
android:icon="@mipmap/ic_launcher"
android:allowBackup="false"
android:launchMode="singleTask"
android:theme="@style/AppTheme"
tools:replace="android:allowBackup">
```

4. Add the following inside the `<activity android:name=".MainActivity" ....>`,

```
<intent-filter>
<action android:name="yourapp.bundle.IBMPushNotification" />
<category android:name="android.intent.category.DEFAULT" />
</intent-filter>
```

5. Add the following lines,

```
<activity android:name="com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPushNotificationHandler" android:theme="@android:style/Theme.NoDisplay"/>

<service android:exported="true" android:name="com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPushIntentService">
<intent-filter>
<action android:name="com.google.firebase.MESSAGING_EVENT"/>
</intent-filter>
</service>
<service android:exported="true" android:name="com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPush">
<intent-filter>
<action android:name="com.google.firebase.INSTANCE_ID_EVENT"/>
</intent-filter>
</service>
```

Now you can build and run the android app from android studio or using the `react-native run-android` command.


## Usage

### Initialization

Import the following dependecnice ,

```JS
import {Push} from 'react-native-bmd-push-react';
import { DeviceEventEmitter } from 'react-native';
```

To initialize Push use the following code 

```JS

// Initialize for push notifications without passing options
Push.init({
"appGUID":"xxxxxx-xxxx-41xxxx67-xxxxx-xxxxx",
"clientSecret":"xxxxx-xxxxx-xxxx-xxxxx-xxxxxxx",
"region":".ng.bluemix.net"
}).then(function(response) {

alert("InitSuccess: " + response);

}).catch(function(e) {

alert("Init Error: " + e);

});

// Initialize for push notifications with passing options
// Initialize for iOS actionable push notifications, custom deviceId and varibales for Parameterize Push Notifications 

var optionsJson = {"categories": { "Category_Name1":[
{
"IdentifierName":"IdentifierName_1",
"actionName":"actionName_1",
"IconName":"IconName_1"
},
{
"IdentifierName":"IdentifierName_2",
"actionName":"actionName_2",
"IconName":"IconName_2"
}
]},
"deviceId":"mydeviceId",
"variables":{"username":"ananth","accountNumber":"536475869765475869"}
};

Push.init({
"appGUID":"xxxxxx-xxxx-41xxxx67-xxxxx-xxxxx",
"clientSecret":"xxxxx-xxxxx-xxxx-xxxxx-xxxxxxx",
"region":".ng.bluemix.net",
"options": optionsJson
}).then(function(response) {

alert("Init Success: " + response);

}).catch(function(e) {

alert("Init Error: " + e);
});

```

**IMPORTANT: These are the following supported `regions` - `".ng.bluemix.net", ".eu-gb.bluemix.net" , ".au-syd.bluemix.net", ".eu-de.bluemix.net" and ".us-east.bluemix.net"`


### Register for push 

```JS

// Register device for push notification without UserId
var options = {};
Push.register(options).then(function(response) {
alert("Success: " + response);
}).catch(function(e) {
alert("Register Error: " + e);
});

// Register device for push notification with UserId

var options = {"userId":"ananthreact"};
Push.register(options).then(function(response) {
alert("Success: " + response);
}).catch(function(e) {
alert("Register Error: " + e);
});
```

### UnRegister from push 

```JS
push.unregisterDevice().then(function(response) {
alert("Success unregisterDevice : " + response);
}).catch(function(e) {
alert("UnRegister error : " + e);
});
```
### Retrieve Available Tags

```JS
Push.retrieveAvailableTags().then(function(response) {
alert("get tags : " + response);
}).catch(function(e) {
alert("get tags error : " + e);
});
```

### Subscribe to a tag

```JS
Push.subscribe(response[0]).then(function(response) {
alert("subscribe tags : " + response);
}).catch(function(e) {
alert("subscribe tags error : " + e);
});
```

### Retrieve Subscriptions

```JS

Push.retrieveSubscriptions().then(function(response) {
alert("retrieveSubscriptions tags : " + response);
}).catch(function(e){
alert("error retrieveSubscriptions : " + e);
});
```

### Unsubscribe from tag 

```JS
var tag = "tag1";
Push.unsubscribe(tag).then(function(response) {
alert("unsubscribe tag : " + response);
}).catch(function(e) {
alert("Error : " + e);
});
```



### Samples & videos

* Please visit for samples - [Github Sample](https://github.com/ibm-bluemix-push-notifications/bms-samples-react-native-hellopush)

### Learning More

* Visit the **[IBM Cloud Developers Community](https://developer.ibm.com/bluemix/)**.

* [Getting started with IBM MobileFirst Platform for iOS](https://www.ng.bluemix.net/docs/mobile/index.html)

### Connect with IBM Cloud

[Twitter](https://twitter.com/ibmbluemix) |
[YouTube](https://www.youtube.com/playlist?list=PLzpeuWUENMK2d3L5qCITo2GQEt-7r0oqm) |
[Blog](https://developer.ibm.com/bluemix/blog/) |
[Facebook](https://www.facebook.com/ibmbluemix) |
[Meetup](http://www.meetup.com/bluemix/)


=======================
Copyright 2016 IBM Corp.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
