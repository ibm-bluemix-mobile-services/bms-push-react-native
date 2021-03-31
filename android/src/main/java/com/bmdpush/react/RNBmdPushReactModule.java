
package com.bmdpush.react;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.LifecycleEventListener;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;


import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;


//Push 
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPush;
import com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPushNotificationButton;
import com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPushNotificationCategory;
import com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPushNotificationOptions;
import com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPushNotificationStatus;
import com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPushNotificationStatusListener;
import com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPSimplePushNotification;
import com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPushException;
import com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPushNotificationListener;
import com.ibm.mobilefirstplatform.clientsdk.android.push.api.MFPPushResponseListener;

//Core
import com.ibm.mobilefirstplatform.clientsdk.android.core.api.BMSClient;
import com.ibm.mobilefirstplatform.clientsdk.android.core.api.Request;
import com.ibm.mobilefirstplatform.clientsdk.android.core.api.ResponseListener;

//Utils
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.lang.*;

public class RNBmdPushReactModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

  private final ReactApplicationContext reactContext;

  private static MFPPushNotificationListener notificationListener;

  private static boolean ignoreIncomingNotifications = false;

  private static String DEVICEID = "deviceId";
  private static String CATEGORIES = "categories";
  private static String USERID = "userId";
  private static String IDENTIFIER_NAME = "IdentifierName";
  private static String ACTION_NAME = "actionName";
  private static String ICON_NAME = "IconName";
  private static String PUSHVARIABLES = "variables";


  public RNBmdPushReactModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    reactContext.addLifecycleEventListener(this);
  }

  @Override
  public String getName() {
    return "RNBmdPushReact";
  }

  @ReactMethod
  public void initialize( ReadableMap config ,final Promise callback) throws JSONException {

    String appGUID = config.getString("appGUID");
    String clientSecret = config.getString("clientSecret");
    String region = config.getString("region");    

    // check for values 
    if(checkStringData(appGUID, "appGUID") && checkStringData(clientSecret,"clientSecret") && checkStringData(region,"region")) {

      BMSClient.getInstance().initialize(this.reactContext.getApplicationContext(),this.getRegion(region));
      
      if (config.getBoolean("hasOption")) {
      ReadableMap args = config.getMap("options");
       JSONObject optionsJson = convertMapToJson(args);

        MFPPushNotificationOptions options = getOptions(optionsJson);
        MFPPush.getInstance().initialize(this.reactContext.getApplicationContext(),appGUID,clientSecret,options);
        callback.resolve("Successfully initialised push 1");
      } else {
        MFPPush.getInstance().initialize(this.reactContext.getApplicationContext(),appGUID,clientSecret);
        callback.resolve("Successfully initialised push 2");
      }
      
    } else {
      callback.reject("Error","Push initialization failed");
    }
  }

  @ReactMethod
  public void registerDevice(ReadableMap config, final Promise callback) throws JSONException {

    JSONObject args =
            convertMapToJson(config);
    // check for values
    if(args.has(USERID)){
      String userId = args.getString(USERID);
      this.registerForPush(userId,callback);
    }else{
      this.registerForPush(callback);
    }
  }

  @ReactMethod
  public void unregisterDevice(final Promise callback) {

    MFPPush.getInstance().unregister(new MFPPushResponseListener<String>() {
      @Override
      public void onSuccess(String response) {
        callback.resolve(response);
      }
      @Override
      public void onFailure(MFPPushException exception) {
        callback.reject("Error",exception.toString());
      }
    });
    return;
  }

  @ReactMethod
  public void retrieveSubscriptions(final Promise callback) {

    MFPPush.getInstance().getSubscriptions(new MFPPushResponseListener<List<String>>() {
      @Override
      public void onSuccess(List<String> response) {
        WritableArray result = new WritableNativeArray();
        for(String listItem: response) {
          result.pushString(listItem);
        }
        callback.resolve(result);
      }

      @Override
      public void onFailure(MFPPushException exception) {
        callback.reject("Error", exception.toString());
      }
    });
    return;
  }

  @ReactMethod
  public void retrieveAvailableTags(final Promise callback) {
    MFPPush.getInstance().getTags(new MFPPushResponseListener<List<String>>() {
      @Override
      public void onSuccess(List<String> response) {
        WritableArray result = new WritableNativeArray();
        for(String listItem: response) {
          result.pushString(listItem);
        }
        callback.resolve(result);
      }

      @Override
      public void onFailure(MFPPushException exception) {
        callback.reject("Error", exception.toString());
      }
    });
    return;
  }

  @ReactMethod
  public void subscribe(String tag,final Promise callback) {
    MFPPush.getInstance().subscribe(tag, new MFPPushResponseListener<String>() {
      @Override
      public void onSuccess(String response) {
        callback.resolve(response);
      }

      @Override
      public void onFailure(MFPPushException exception) {
        callback.reject("Error", exception.toString());
      }
    });
    return;
  }

  @ReactMethod
  public void unsubscribe(String tag,final Promise callback) {
    MFPPush.getInstance().unsubscribe(tag, new MFPPushResponseListener<String>() {
      @Override
      public void onSuccess(String response) {
        callback.resolve(response);
      }

      @Override
      public void onFailure(MFPPushException exception) {
        callback.reject(exception.toString());
      }
    });
    return;
  }

  @ReactMethod
  public void registerNotificationsCallback(final String callbackid) {

    if(!ignoreIncomingNotifications) {

      notificationListener = new MFPPushNotificationListener() {
        @Override
        public void onReceive(MFPSimplePushNotification message) {
          WritableMap resultData = new WritableNativeMap();
          resultData.putString("message", message.getAlert());
          resultData.putString("payload", message.getPayload());
          resultData.putString("identifierName", message.actionName);
          reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                  .emit(callbackid, resultData);
        }
      };
      MFPPush.getInstance().listen(notificationListener);

    } else {
      WritableMap resultData = new WritableNativeMap();
      resultData.putString("message", "Error while parsing the message payload");
      reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
              .emit(callbackid, resultData);
    }

    return;
  }

  @ReactMethod
  public void setNotificationStatusListener(final String callbackid) {

    MFPPush.getInstance().setNotificationStatusListener(new MFPPushNotificationStatusListener() {
      @Override
      public void onStatusChange(String messageId, MFPPushNotificationStatus status) {

          WritableMap resultData = new WritableNativeMap();
          resultData.putString("messageId", messageId);
          resultData.putString("status", status.toString());

          reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                  .emit(callbackid, resultData);
      }
    });
  }

  @ReactMethod
  public static void setIgnoreIncomingNotifications(boolean ignore) {
    ignoreIncomingNotifications = ignore;

    if(notificationListener != null) {
      if(ignore) {
        MFPPush.getInstance().hold();
      } else {
        MFPPush.getInstance().listen(notificationListener);
      }
    }

  }

  //Private methods


  @Override
  public void onHostResume() {

    if (!ignoreIncomingNotifications && MFPPush.getInstance() != null && notificationListener != null) {
      MFPPush.getInstance().listen(notificationListener);
    }
  }

  @Override
  public void onHostPause() {

    if (!ignoreIncomingNotifications && MFPPush.getInstance() != null) {
      MFPPush.getInstance().hold();
    }
  }

  @Override
  public void onHostDestroy() {
    System.out.print("Destroyed");
  }


  private void registerForPush(final Promise callback) {

    MFPPush.getInstance().registerDevice(new MFPPushResponseListener<String>() {
      @Override
      public void onSuccess(String response) {

        String message = "";
        try {
          JSONObject responseJson = new JSONObject(response.substring(response.indexOf('{')));
          JSONObject messageJson = new JSONObject();
          messageJson.put("token", responseJson.optString("token"));
          messageJson.put("userId", responseJson.optString("userId"));
          messageJson.put("deviceId", responseJson.optString("deviceId"));
          message = messageJson.toString();
        } catch (JSONException e) {
          throw new RuntimeException(e);
        }
        callback.resolve(message);
      }

      @Override
      public void onFailure(MFPPushException exception) {
        System.out.print(exception.toString());
        callback.reject("Error",exception.toString());
      }
    });
    return;
  }

  private void registerForPush(String userId, final Promise callback) {

    MFPPush.getInstance().registerDeviceWithUserId(userId, new MFPPushResponseListener<String>() {
      @Override
      public void onSuccess(String response) {

        String message = "";
        try {
          JSONObject responseJson = new JSONObject(response.substring(response.indexOf('{')));
          JSONObject messageJson = new JSONObject();
          messageJson.put("token", responseJson.optString("token"));
          messageJson.put("userId", responseJson.optString("userId"));
          messageJson.put("deviceId", responseJson.optString("deviceId"));
          message = messageJson.toString();
        } catch (JSONException e) {
          throw new RuntimeException(e);
        }
        callback.resolve(message);
      }

      @Override
      public void onFailure(MFPPushException exception) {
        System.out.print(exception.toString());
        callback.reject("Error",exception.toString() );
      }
    });
    return;
  }

  static private boolean checkStringData(String value, String idString) {

    if(value != null && !value.isEmpty()) {
      return  true;
    } else  {
      return false;
    }
  }

  private MFPPushNotificationOptions getOptions(JSONObject args) throws JSONException {

    MFPPushNotificationOptions options = new MFPPushNotificationOptions();
    JSONObject clientOptions = args;
    if (clientOptions.has(CATEGORIES) && (clientOptions.optJSONObject(CATEGORIES) != null)) {
      JSONObject result = clientOptions.getJSONObject(CATEGORIES);
      List<MFPPushNotificationCategory> categoryList = new ArrayList<MFPPushNotificationCategory>();
      Iterator<String> keys = result.keys();
      while (keys.hasNext()) {
        String key = keys.next();

        JSONArray resultObject = result.getJSONArray(key);
        List<MFPPushNotificationButton> actionButtons = new ArrayList<MFPPushNotificationButton>();

        for (int i = 0; i < resultObject.length(); i++) {

          JSONObject resultJson = resultObject.getJSONObject(i);
          String identifierName = "";
          String actionName = "";
          String iconName = "";

          if (resultJson.has(IDENTIFIER_NAME)) {
            identifierName = resultJson.getString(IDENTIFIER_NAME);
          }
          if (resultJson.has(ACTION_NAME)) {
            actionName = resultJson.getString(ACTION_NAME);
          }
          if (resultJson.has(ICON_NAME)) {
            iconName = resultJson.getString(ICON_NAME);
          }

          MFPPushNotificationButton actiondButton = new MFPPushNotificationButton.Builder(identifierName)
                  .setIcon(iconName)
                  .setLabel(actionName)
                  .build();

          actionButtons.add(actiondButton);

        }
        MFPPushNotificationCategory category = new MFPPushNotificationCategory.Builder(key).setButtons(actionButtons).build();
        categoryList.add(category);
      }
      options.setInteractiveNotificationCategories(categoryList);
    }
    if (clientOptions.has(DEVICEID) && (clientOptions.optString(DEVICEID) != null)){
      if (!(clientOptions.getString(DEVICEID).equals(""))){
        options.setDeviceid(clientOptions.getString(DEVICEID));
      }
    }

    if (clientOptions.has(PUSHVARIABLES) && (clientOptions.optString(PUSHVARIABLES) != null)){
      if (!(clientOptions.getString(PUSHVARIABLES).equals(""))){
        options.setPushVariables(clientOptions.getJSONObject(PUSHVARIABLES));
      }
    }

    return options;
  }

  private static JSONObject convertMapToJson(ReadableMap readableMap) throws JSONException {
    JSONObject object = new JSONObject();
    ReadableMapKeySetIterator iterator = readableMap.keySetIterator();
    while (iterator.hasNextKey()) {
      String key = iterator.nextKey();
      switch (readableMap.getType(key)) {
        case Null:
          object.put(key, JSONObject.NULL);
          break;
        case Boolean:
          object.put(key, readableMap.getBoolean(key));
          break;
        case Number:
          object.put(key, readableMap.getDouble(key));
          break;
        case String:
          object.put(key, readableMap.getString(key));
          break;
        case Map:
          object.put(key, convertMapToJson(readableMap.getMap(key)));
          break;
        case Array:
          object.put(key, convertArrayToJson(readableMap.getArray(key)));
          break;
      }
    }
    return object;
  }
  private static JSONArray convertArrayToJson(ReadableArray readableArray) throws JSONException {
    JSONArray array = new JSONArray();
    for (int i = 0; i < readableArray.size(); i++) {
      switch (readableArray.getType(i)) {
        case Null:
          break;
        case Boolean:
          array.put(readableArray.getBoolean(i));
          break;
        case Number:
          array.put(readableArray.getDouble(i));
          break;
        case String:
          array.put(readableArray.getString(i));
          break;
        case Map:
          array.put(convertMapToJson(readableArray.getMap(i)));
          break;
        case Array:
          array.put(convertArrayToJson(readableArray.getArray(i)));
          break;
      }
    }
    return array;
  }
  /**
   * Get region for Core SDK.
   * @param bluemixRegion - New cloud url
   */
  private String getRegion(final String bluemixRegion) {
    String region = BMSClient.REGION_US_SOUTH;
    switch(bluemixRegion) {
      case "us-south":
      region = BMSClient.REGION_US_SOUTH;
      break;
      case "eu-gb":
      region = BMSClient.REGION_UK;
      break;
      case "au-syd":
      region = BMSClient.REGION_SYDNEY;
      break;
      case "eu-de":
      region = BMSClient.REGION_GERMANY;
      break;
      case "us-east":
      region = BMSClient.REGION_US_EAST;
      break;
      case "jp-tok":
      region = BMSClient.REGION_TOKYO;
      break;
      case "jp-osa":
      region = BMSClient.REGION_JP_OSA;
      break;
      default:
      region = BMSClient.REGION_US_SOUTH;
    }
    return region;
  }
}




