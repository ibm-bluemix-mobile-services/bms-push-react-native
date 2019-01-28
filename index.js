
import { NativeModules,NativeEventEmitter,DeviceEventEmitter } from 'react-native';

const PushModule = NativeModules.RNBmdPushReact;
const eventEmitter = new NativeEventEmitter(NativeModules.RNBmdPushReact)
const emitterMap = new Map();


class PushNotification {

    init(config: Object) {
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
    
    register(options: Object) {
        return PushModule.registerDevice(options);
    }

    unregisterDevice() {
        return PushModule.unregisterDevice();
    }

    retrieveAvailableTags() {
        return PushModule.retrieveAvailableTags();
    }

    subscribe(tag: string) {
        return PushModule.subscribe(tag);
    }

    unsubscribe(tag: string) {
        return PushModule.unsubscribe(tag);
    }

    retrieveSubscriptions() {
        return PushModule.retrieveSubscriptions();
    }

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

    setNotificationStatusListener(eventListenerName = 'onBMSPushStatusListener') {
        PushModule.setNotificationStatusListener(eventListenerName);
    }

}

var Push =  new PushNotification();
export  {
    Push
}