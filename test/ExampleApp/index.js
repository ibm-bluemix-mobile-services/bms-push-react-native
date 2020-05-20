/**
 * @format
 */

import {AppRegistry} from 'react-native';
import App from './App';
import {name as appName} from './app.json';

import {Push} from 'bmd-push-react-native';
import { DeviceEventEmitter } from 'react-native';

AppRegistry.registerComponent(appName, () => App);



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
"deviceId":"mydeviceId1"
//"variables":{"username":"ananth","accountNumber":"536475869765475869"}
};

Push.init({
	"appGUID":"xxxxx",
	"clientSecret":"xxxxxx",
	"region":"xxxx",
	"options": optionsJson
}).then(function(response) {
    //alert("Success: " + response);
    Push.register({"userId":"ananthreact"}).then(function(response) {
    	Push.retrieveAvailableTags().then(function(response) {
    		alert("get tags : " + response);
    		Push.subscribe(response[0]).then(function(response) {
    			alert("subscribe tags : " + response);

    			Push.retrieveSubscriptions().then(function(response) {


    				alert("retrieveSubscriptions tags : " + response);
                    /*Push.unsubscribe(response[0]).then(function(response) {
                        alert("unsubscribe tags : " + response);
                    }).catch(function(e) {
                        alert("Error : " + e);
                    });*/
                }).catch(function(e){
                	alert("error retrieveSubscriptions : " + e);
                });
            }).catch(function(e) {
            	alert("subscribe tags error : " + e);
            });
        }).catch(function(e) {
        	alert("get tags error : " + e);
        })
    }).catch(function(e) {
    	alert("Register Error: " + e);
    });

}).catch(function(e) {
	alert("Init Error: " + e);
});

DeviceEventEmitter.addListener("onPushReceived", function(notification: Event) {
	alert(JSON.stringify(notification));
});

Push.registerNotificationsCallback("onPushReceived");