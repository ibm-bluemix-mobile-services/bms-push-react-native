
import { NativeModules,NativeEventEmitter,DeviceEventEmitter } from 'react-native';

const PushModule = NativeModules.RNBmdPushReact;
const eventEmitter = new NativeEventEmitter(NativeModules.RNBmdPushReact)
const emitterMap = new Map();

/**
 * React-Native module to handle devive requests.
 * @module PushNotification
 */

class PushNotification {

     /**
     * Creates a PushNotification instance 
     * @method module:PushNotification#init
     * @param {Object} config  The push initialise parameters like appGUID, clientSecret,region etc.
     * @return The PushNotification object for calls to be linked. 
     */
    init(config) {
        config.hasOption = false;
        console.log("Not Found.");
        Object.keys(config).forEach(key => {
            if (key === "options") {
                console.log("Found.");
                config.hasOption = true;
            }
        });
        return PushModule.initialize(config);
    }
    
    /**
     * Register device to IBM cloud push notifications instance 
     * @method module:PushNotification#register
     * @param {Object} options  The push register parameter like userId.
     * @return Response from the server. 
     */
    register(options) {
        return PushModule.registerDevice(options);
    }

    /**
     * Un-register device to IBM cloud push notifications instance 
     * @method module:PushNotification#unregisterDevice
     * @return Response from the server. 
     */
    unregisterDevice() {
        return PushModule.unregisterDevice();
    }

    /**
     * Retrieve available tags from IBM cloud push notifications instance.
     * @method module:PushNotification#retrieveAvailableTags
     * @return Response from the server. 
     */
    retrieveAvailableTags() {
        return PushModule.retrieveAvailableTags();
    }

    /**
     * Subscribe to a tag in IBM cloud push notifications instance 
     * @method module:PushNotification#subscribe
     * @param {string} tag  The tag name.
     * @return Response from the server. 
     */
    subscribe(tag) {
        return PushModule.subscribe(tag);
    }

    /**
     * Un-subscribe from a tag in IBM cloud push notifications instance 
     * @method module:PushNotification#unsubscribe
     * @param {string} tag  The tag name.
     * @return Response from the server. 
     */
    unsubscribe(tag) {
        return PushModule.unsubscribe(tag);
    }

    /**
     * Retrieve all tag subscriptions of the device from IBM cloud push notifications instance 
     * @method module:PushNotification#retrieveSubscriptions
     * @return Response from the server. 
     */
    retrieveSubscriptions() {
        return PushModule.retrieveSubscriptions();
    }

    /**
     * Method to listen to push events  
     * @method module:PushNotification#registerNotificationsCallback
     * @param {string} eventListenerName  Name of the push event, by default its `BMSPushRecieveListener`.
     */
    registerNotificationsCallback(eventListenerName = 'BMSPushRecieveListener') {

        if (typeof eventListenerName !== 'string') {
            throw new Error(`${eventListenerName} is not of type string`);
        }

        if(!emitterMap.has(eventListenerName)) {
            emitterMap.forEach(function(value, key, map) {
                // value is a EmitterSubscription Object
                // 'remove' is actually removing the subscription
                value.remove();
            })

            emitterMap.set(
                // key -- string
                eventListenerName,
                //value -- EmitterSubscription Object
                eventEmitter.addListener('onBMDPushReceived', function(body) {
                    console.log(body);
                    eventEmitter.emit(eventListenerName, body);
                })
            );
            PushModule.registerNotificationsCallback('onBMDPushReceived');
        }
    }

    /**
     * Method to listen to push status change events 
     * @method module:PushNotification#setNotificationStatusListener
     * @param {string} eventListenerName  Name of the push change event, by default its `onBMSPushStatusListener`.
     */
    setNotificationStatusListener(eventListenerName = 'onBMSPushStatusListener') {
        PushModule.setNotificationStatusListener(eventListenerName);
    }

}

var Push =  new PushNotification();
export  {
    Push
}