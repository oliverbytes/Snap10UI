import bb.cascades 1.0
import bb.system 1.0
import QtQuick 1.0

import "../smaato"
import "../components"

Sheet 
{
    id: sheet
    
    property bool firstTimeSharStoriesTo : true;
    property bool firstTimeRefreshTimer : true;
    property bool firstTimeReceiveSnapsFrom : true;
    property bool firstTimeNumBestFriends : true;
    property bool firstTimeBirthday : true;
    
    property variant theAttachedObjects;

    function createObjects()
    {
        if (!sheet.theAttachedObjects)
        {
            sheet.theAttachedObjects = myAttachedObjects.createObject(sheet);
        }
    }
    
    function destroyObjects()
    {
        if (sheet.theAttachedObjects)
        {
            sheet.theAttachedObjects.destroy();
        }
    }
    
    onOpened: 
    {
        createObjects();    
        
        clearCacheButton.text = "Clear Cache : " + humanFileSize(Qt.app.getCacheSize());
    }
    
    onClosed: 
    {
        destroyObjects();
    }
    
    attachedObjects: 
    [
        ComponentDefinition 
        {
            id: myAttachedObjects
            
            Container 
            {
                id: objects
                
                property alias dialogInteract: dialog
                property alias logoutPromptInteract: logoutPrompt
                
                attachedObjects: 
                [
                    SystemDialog 
                    {
                        id: dialog
                        cancelButton.label: "Cancel"
                        confirmButton.label: "Restart"
                        onFinished: 
                        {
                            if(buttonSelection().label == "Restart")
                            {
                                Qt.app.setSetting("colortheme", theme.selectedOption.text.toLowerCase());
                                Application.requestExit();
                            }
                            else 
                            {
                                theme.selectedIndex = (Qt.app.getSetting("colortheme", "bright") == "bright" ? 0 : 1);
                            }
                            
                            dialog.cancel();
                        }
                    },
                    SystemDialog
                    {
                        id: logoutPrompt
                        title: "Logout"
                        body: "Are you sure you want to logout?"
                        modality: SystemUiModality.Application
                        confirmButton.label: "Logout"
                        confirmButton.enabled: true
                        dismissAutomatically: true
                        cancelButton.label: "Cancel"
                        onFinished: 
                        {
                            if(buttonSelection().label == "Logout")
                            {
                                logoutRequest();
                                
                                Qt.app.setSetting("username", "");
                                Qt.app.setSetting("auth_token", "");
                                
                                var command = new Object();
                                command.action = "loadLoginDetails";
                                command.data   = "data";
                                _app.socketSend(JSON.stringify(command));
                                
                                Qt.snap2chatAPIData.clearFeedsLocally();
                                Qt.snap2chatAPIData.resetAll();
                                
                                Qt.app.showToast("Successfully Logged Out :)");
                                
                                Qt.app.flurryLogEvent("LOGOUT");
                                
                                close();
                                
                                Qt.mainSheet.open();
                            }
                        }
                    }
                ]
            }
        }
    ]
    
    property bool firstRunTheme : true;
    property bool firstRun : true;
    property bool firstRunCamera : true;
    property bool firstRunEnhanceVideoRecorder : true;
    
    Page 
    {
        titleBar: CustomTitleBar 
        {
            closeVisibility: true
            onCloseButtonClicked: 
            {
                close();
            }
        }
        
        ScrollView 
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill

            Container 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                topPadding: 20
                
                Header 
                {
                    title: "SETTINGS"
                }
                
                SegmentedControl
                {
                    id: segmentedSettings
                    selectedIndex: 0
                    options:
                    [
                        Option 
                        {
                            text: "Account"
                            imageSource: "asset:///images/snapchat.png"
                        },
                        Option 
                        {
                            text: "Advanced"
                            imageSource: "asset:///images/automation.png"
                        }
                    ]
                }
                
                Container 
                {
                    layout: DockLayout {}
                    
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    bottomPadding: 20
                    topPadding: 20
                    leftPadding: 20
                    rightPadding: 20
      
                    Container 
                    {
                        visible: segmentedSettings.selectedIndex == 0
                        
                        Header 
                        {
                            title: "ACCOUNT" 
                            subtitle: Qt.snap2chatAPIData.username
                        }
                        
                        Label 
                        {
                            text: "Privacy Settings" 
                        }
                        
                        DropDown 
                        {
                            id: whocansendsnaps
                            selectedIndex: Qt.snap2chatAPIData.snap_p
                            title: "Receive Snaps From"
                            options: 
                            [
                                Option
                                {
                                    text: "Everyone"
                                    value: 0
                                    imageSource: "asset:///images/twopeople.png"
                                },
                                Option
                                {
                                    text: "Friends"   
                                    value: 1 
                                    imageSource: "asset:///images/twopeople.png"
                                }
                            ]
                            
                            onSelectedValueChanged: 
                            {
                                if(!firstTimeReceiveSnapsFrom)
                                {
                                    var params 				= new Object();
                                    params.endpoint			= "/ph/settings";
                                    params.username 		= Qt.snap2chatAPIData.username;
                                    params.timestamp 		= Qt.snap2chatAPIData.getCurrentTimestamp();
                                    params.req_token 		= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                                    
                                    params.action 			= "updatePrivacy";
                                    params.privacySetting 	= selectedValue;
                                    
                                    Qt.snap2chatAPI.request(params);
                                }
                                
                                firstTimeReceiveSnapsFrom = false;
                            }
                        }
                        
                        DropDown 
                        {
                            id: whocanviewstories
                            selectedIndex: (Qt.snap2chatAPIData.storyPrivacy == "EVERYONE" ? 0 : 1)
                            title: "Share Stories To"
                            options: 
                            [
                                Option
                                {
                                    text: "Everyone"    
                                    value: "EVERYONE"
                                    imageSource: "asset:///images/twopeople.png"
                                },
                                Option
                                {
                                    text: "Friends"    
                                    value: "FRIENDS"
                                    imageSource: "asset:///images/twopeople.png"
                                }
                            ]
                            
                            onSelectedValueChanged: 
                            {
                                if(!firstTimeSharStoriesTo)
                                {
                                    var params 				= new Object();
                                    params.endpoint			= "/ph/settings";
                                    params.username 		= Qt.snap2chatAPIData.username;
                                    params.timestamp 		= Qt.snap2chatAPIData.getCurrentTimestamp();
                                    params.req_token 		= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                                    
                                    params.action 			= "updateStoryPrivacy";
                                    params.privacySetting 	= selectedValue;
                                    
                                    Qt.snap2chatAPI.request(params);
                                }
                                
                                firstTimeSharStoriesTo = false;
                            }
                        }
                        
//                        Divider {}
//                        
//                        Label 
//                        {
//                            text: "Mobile #"
//                        }
//                        
//                        DropDown 
//                        {
//                            id: countryCode
//                            title: "Country Code"
//                            
//                            attachedObjects: 
//                            [
//                                ComponentDefinition 
//                                {
//                                    id: optionControlDefinition
//                                    Option {}
//                                }
//                            ]
//                            
//                            onCreationCompleted: 
//                            {
//                                var countryCodesJSONString = Globals.countryCodes;
//
//                                var countryCodesJSON = JSON.parse(countryCodesJSONString);
//
//                                for (var i = 0; i < countryCodesJSON.length; i ++) 
//                                {
//                                    var option 		= optionControlDefinition.createObject();
//                                    option.text 	= countryCodesJSON[i].name;
//                                    option.value 	= countryCodesJSON[i].alpha2;
//                                    countryCode.add(option);
//                                }
//                            }
//                        }
//                        
//                        Container 
//                        {
//                            layout: StackLayout 
//                            {
//                                orientation: LayoutOrientation.LeftToRight
//                            }
//                            
//                            TextField 
//                            {
//                                id: mobileNumber
//                                text: Qt.snap2chatAPIData.mobileNumber
//                                hintText: "Mobile Number"
//                                inputMode: TextFieldInputMode.PhoneNumber
//                                
//                                layoutProperties: StackLayoutProperties 
//                                {
//                                    spaceQuota: 3
//                                }
//                            }
//                            
//                            Button 
//                            {
//                                text: "Save"
//                                horizontalAlignment: HorizontalAlignment.Fill
//                                onClicked:
//                                {
//                                    if(mobileNumber.text.length > 3)
//                                    {
//                                        Qt.progressDialog.body = "Setting your mobile number...";
//                                        Qt.progressDialog.show();
//                                        
//                                        var params 				= new Object();
//                                        params.endpoint			= "/ph/settings";
//                                        params.username 		= Qt.snap2chatAPIData.username;
//                                        params.timestamp 		= Qt.snap2chatAPIData.getCurrentTimestamp();
//                                        params.req_token 		= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
//                                        
//                                        params.action 			= "updatePhoneNumber";
//                                        params.countryCode 		= countryCode.selectedValue;
//                                        params.phoneNumber 		= mobileNumber.text;
//                                        
//                                        Qt.snap2chatAPI.request(params);
//                                    } 
//                                    else 
//                                    {
//                                        Qt.app.showDialog("Attention", "Please enter the mobile number");
//                                    } 
//                                }
//                                
//                                layoutProperties: StackLayoutProperties 
//                                {
//                                    spaceQuota: 1
//                                }
//                            }
//                        }
//
//                        Container 
//                        {
//                            id: verifiy
//                            
//                            Divider {}
//                            
//                            Label 
//                            {
//                                text: "Verify Mobile #"
//                            }
//                            
//                            Container 
//                            {
//                                layout: StackLayout 
//                                {
//                                    orientation: LayoutOrientation.LeftToRight
//                                }
//                                
//                                TextField 
//                                {
//                                    id: verificationCode
//                                    hintText: "4 Digit Verification Code"
//                                    inputMode: TextFieldInputMode.PhoneNumber
//                                    
//                                    layoutProperties: StackLayoutProperties 
//                                    {
//                                        spaceQuota: 3
//                                    }
//                                }
//                                
//                                Button 
//                                {
//                                    text: "Verify"
//                                    horizontalAlignment: HorizontalAlignment.Fill
//                                    onClicked: 
//                                    {
//                                        if(verificationCode.text.length > 3)
//                                        {
//                                            Qt.progressDialog.body = "Verifying mobile number...";
//                                            Qt.progressDialog.show();
//                                            
//                                            var params 				= new Object();
//                                            params.endpoint			= "/ph/settings";
//                                            params.username 		= Qt.snap2chatAPIData.username;
//                                            params.timestamp 		= Qt.snap2chatAPIData.getCurrentTimestamp();
//                                            params.req_token 		= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
//                                            
//                                            params.action 			= "verifyPhoneNumber";
//                                            params.code 			= verificationCode.text;
//                                            
//                                            Qt.snap2chatAPI.request(params);
//                                        } 
//                                        else 
//                                        {
//                                            Qt.app.showDialog("Attention", "Please enter the 4 Digit Code");
//                                        }
//                                    }
//                                    
//                                    layoutProperties: StackLayoutProperties 
//                                    {
//                                        spaceQuota: 1
//                                    }
//                                }
//                            }
//                        }

                        SmaatoAds
                        {
                            id: ads
                        }
    
                        Label 
                        {
                            text: "Email"
                        }
                        
                        Container 
                        {
                            layout: StackLayout 
                            {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            
                            TextField 
                            {
                                id: email
                                text: Qt.snap2chatAPIData.email
                                hintText: "Email Address"
                                inputMode: TextFieldInputMode.EmailAddress
                                
                                layoutProperties: StackLayoutProperties 
                                {
                                    spaceQuota: 3
                                }
                            }
                            
                            Button 
                            {
                                text: "Save"
                                horizontalAlignment: HorizontalAlignment.Fill
                                onClicked: 
                                {
                                    if(email.text.length > 0)
                                    {
                                        Qt.progressDialog.body = "You will receive a verification email notification once this is complete.";
                                        Qt.progressDialog.show();
                                        
                                        var params 				= new Object();
                                        params.endpoint			= "/ph/settings";
                                        params.username 		= Qt.snap2chatAPIData.username;
                                        params.timestamp 		= Qt.snap2chatAPIData.getCurrentTimestamp();
                                        params.req_token 		= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                                        
                                        params.action 			= "updateEmail";
                                        params.email 			= email.text;
                                        
                                        Qt.snap2chatAPI.request(params);
                                    } 
                                    else 
                                    {
                                        Qt.app.showDialog("Attention", "Please enter the email");
                                    }
                                }
                                
                                layoutProperties: StackLayoutProperties 
                                {
                                    spaceQuota: 1
                                }
                            }
                        }
                        
                        Divider {}

                        DropDown 
                        {
                            id: numBestFriends
                            title: "# of Best Friends"
                            selectedIndex: (Qt.snap2chatAPIData.bestfriendsCount - 1)
                            options: 
                            [
                                Option
                                {
                                    text: "3"
                                },
                                Option
                                {
                                    text: "4"
                                },
                                Option
                                {
                                    text: "5"
                                },
                                Option
                                {
                                    text: "6"
                                },
                                Option
                                {
                                    text: "7"
                                }
                            ]
                            
                            onSelectedValueChanged: 
                            {
                                if(!firstTimeNumBestFriends)
                                {
                                    var params 				= new Object();
                                    params.endpoint			= "/bq/set_num_best_friends";
                                    params.username 		= Qt.snap2chatAPIData.username;
                                    params.timestamp 		= Qt.snap2chatAPIData.getCurrentTimestamp();
                                    params.req_token 		= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);

                                    params.num_best_friends = selectedOption.text;
                                    
                                    Qt.snap2chatAPI.request(params);
                                }
                                
                                firstTimeNumBestFriends = false;
                            }
                        }
                        
                        DateTimePicker 
                        {
                            id: birthday
                            visible: false
                            title: "Birthday"
                            value: new Date(Qt.snap2chatAPIData.birthday);
     
                            onExpandedChanged:
                            {
                                if(expanded == false)
                                {
                                    if(!firstTimeBirthday)
                                    {
                                        var birthdayvalue = ((birthday.value.getMonth() + 1) > 9 ? (birthday.value.getMonth() + 1) : "0" + (birthday.value.getMonth() + 1)) + "-" + (birthday.value.getDate() > 9 ? birthday.value.getDate() : "0" + birthday.value.getDate());
                                        
                                        var params 				= new Object();
                                        params.endpoint			= "/ph/settings";
                                        params.username 		= Qt.snap2chatAPIData.username;
                                        params.timestamp 		= Qt.snap2chatAPIData.getCurrentTimestamp();
                                        params.req_token 		= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                                        
                                        params.action 			= "updateBirthday";
                                        params.birthday 		= birthdayvalue;
                                        
                                        Qt.snap2chatAPI.request(params);
                                    }
                                    
                                    firstTimeBirthday = false;
                                }
                            }
                        }
                    }
                    
                    Container 
                    {
                        visible: segmentedSettings.selectedIndex == 1
                        
                        Header 
                        {
                            title: "ADVANCED SNAP10 SETTINGS" 
                            subtitle: Qt.snap2chatAPIData.username
                        }
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            topPadding: 20
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Auto Load Snaps"  
                            }
                            
                            ToggleButton 
                            {
                                id: autoLoadSnaps
                                checked: Qt.app.getSetting("autoLoadSnaps", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    if(_app.purchasedAds)
                                    {
                                        Qt.app.setSetting("autoLoadSnaps", checked);
                                    }
                                    else 
                                    {
                                        Qt.toastX.pop("No need to tap on every snaps to load.\n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                        Qt.proSheet.open();
                                    }
                                }
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Auto Load Stories"  
                            }
                            
                            ToggleButton 
                            {
                                id: autoLoadStories
                                checked: Qt.app.getSetting("autoLoadStories", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    if(_app.purchasedAds)
                                    {
                                        Qt.app.setSetting("autoLoadStories", checked);
                                    }
                                    else 
                                    {
                                        Qt.toastX.pop("No need to tap on every snaps to load.\n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                        Qt.proSheet.open();
                                    }
                                }
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Replay Feature"  
                            }
                            
                            ToggleButton 
                            {
                                id: replayFeature
                                checked: Qt.app.getSetting("replayFeature", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    if(_app.purchasedAds)
                                    {
                                        Qt.app.setSetting("replayFeature", checked);
                                    }
                                    else 
                                    {
                                        Qt.toastX.pop("Be able to replay unlimited times. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                        Qt.proSheet.open();
                                    }
                                }
                            }
                        }
                        
                        Container 
                        {
                            visible: (replayFeature.checked)
                            
                            Divider {}

                            Label 
                            {
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.fontStyle: FontStyle.Italic
                                text: "Note: When this option is turned on. You can replay the snap unlimited times until you clear the cache."
                                multiline: true
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Front Facing Flash"  
                            }
                            
                            ToggleButton 
                            {
                                id: frontFlash
                                checked: Qt.app.getSetting("frontFlash", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    if(_app.purchasedAds)
                                    {
                                        Qt.app.setSetting("frontFlash", checked);
                                    }
                                    else 
                                    {
                                        Qt.toastX.pop("Remove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                        Qt.proSheet.open();
                                    }
                                }
                            }
                        }
                        
                        Container 
                        {
                            visible: (frontFlash.checked)
                            
                            Divider {}

                            Label 
                            {
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.fontStyle: FontStyle.Italic
                                text: "Note: Turning this option on will temporarily make your screen all white until the capture is done."
                                multiline: true
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Auto Open Camera On Start"  
                            }
                            
                            ToggleButton 
                            {
                                id: openCameraOnOpened
                                checked: Qt.app.getSetting("openCameraOnOpened", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    if(_app.purchasedAds)
                                    {
                                        Qt.app.setSetting("openCameraOnOpened", checked);
                                    }
                                    else 
                                    {
                                        Qt.toastX.pop("Remove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                        Qt.proSheet.open();
                                    }
                                }
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Mirror Front Cam Snaps"  
                            }
                            
                            ToggleButton 
                            {
                                id: mirrorFront
                                checked: Qt.app.getSetting("mirrorFront", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    if(_app.purchasedAds)
                                    {
                                        Qt.app.setSetting("mirrorFront", checked);
                                    }
                                    else 
                                    {
                                        Qt.toastX.pop("Remove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                        Qt.proSheet.open();
                                    }
                                }
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Auto Refresh"  
                            }
                            
                            ToggleButton 
                            {
                                id: refreshFeeds
                                checked: Qt.app.getSetting("refreshFeeds", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    if(_app.purchasedAds)
                                    {
                                        Qt.app.setSetting("refreshFeeds", checked);
                                    }
                                    else 
                                    {
                                        Qt.toastX.pop("Remove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                        Qt.proSheet.open();
                                    }
                                }
                            }
                        }
                        
                        Container 
                        {
                            visible: (refreshFeeds.checked)
                            
                            Divider {}
                            
                            Label 
                            {
                                text: "Refresh Every"
                            }
                            
                            TextField
                            {
                                id: refreshFeedsEvery
                                text: (Qt.app.getSetting("refreshFeedsEvery", "80000") / 1000)
                                inputMode: TextFieldInputMode.PhoneNumber
                                onTextChanging:
                                {
                                    if(!firstTimeRefreshTimer)
                                    {
                                        if(!isNaN(text))
                                        {
                                            Qt.app.setSetting("refreshFeedsEvery", (text * 1000))
                                            
                                            var command = new Object();
                                            command.action = "resetTimer";
                                            command.data   = "";
                                            _app.socketSend(JSON.stringify(command));
                                        }
                                    }
                                    
                                    firstTimeRefreshTimer = false;
                                }
                            }
                            
                            Label 
                            {
                                text: "(in seconds) Needs Restart"
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.fontStyle: FontStyle.Italic
                                textStyle.color: Color.Gray
                                multiline: true
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Camera Shutter Sound"  
                            }
                            
                            ToggleButton 
                            {
                                id: shutterSound
                                checked: Qt.app.getSetting("shutterSound", "true");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    if(_app.purchasedAds)
                                    {
                                        Qt.app.setSetting("shutterSound", checked);
                                    }
                                    else 
                                    {
                                        Qt.toastX.pop("Remove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                        Qt.proSheet.open();
                                    }
                                }
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Notifications"  
                            }
                            
                            ToggleButton 
                            {
                                id: notificationsEnabled
                                checked: Qt.app.getSetting("notificationsEnabled", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    if(_app.purchasedAds)
                                    {
                                        Qt.app.setSetting("notificationsEnabled", checked);
                                    }
                                    else 
                                    {
                                        Qt.toastX.pop("Receive notificationsin the Hub even when the app is closed. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                        Qt.proSheet.open();
                                    }
                                }
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Keep Awake"
                            }
                            
                            ToggleButton 
                            {
                                id: keepawake
                                checked: Qt.app.getSetting("keepawake", true);
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    Qt.app.setSetting("keepawake", checked);
                                    setKeepAwake();
                                }
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Enhance Video Recorder"
                            }
                            
                            ToggleButton 
                            {
                                id: enhanceVideoRecorder
                                checked: Qt.app.getSetting("enhanceVideoRecorder", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    Qt.app.setSetting("enhanceVideoRecorder", checked);
                                }
                            }
                        }
                        
                        Container 
                        {
                            visible: (enhanceVideoRecorder.checked)
                            
                            Divider {}

                            Label 
                            {
                                text: "Enabling this option will enhance the video recording performance and speed. But can cause a crash when your device can't carry the process."
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.fontStyle: FontStyle.Italic
                                textStyle.color: Color.Gray
                                multiline: true
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Floating Jump Buttons"  
                                verticalAlignment: VerticalAlignment.Center
                            }
                            
                            ToggleButton 
                            {
                                id: floatingButtons
                                checked: Qt.app.getSetting("floatingButtons", "true");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged:
                                {
                                    Qt.app.setSetting("floatingButtons", checked);
                                }
                            }
                        }
                        
                        Divider {}
                        
                        DropDown 
                        {
                            id: activeFrameShow
                            title: "Active Frame"
                            selectedIndex: (Qt.app.getSetting("activeFrameShow", "splash") == "list" ? 0 : 1);
                            options: 
                            [
                                Option
                                {
                                    text: "Recent Snaps"
                                    value: "list"
                                },
                                Option
                                {
                                    text: "Beautiful Splash Screen"
                                    value: "splash"
                                    imageSource: "asset:///images/splashQ10.jpg"
                                }
                            ]
                            
                            onSelectedValueChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    Qt.app.setSetting("activeFrameShow", selectedValue);
                                    
                                    if(Qt.app.getSetting("activeFrameShow", "list") == "splash")
                                    {
                                        _activeFrame.setSplashImageVisibility(true); 
                                    }
                                    else 
                                    {
                                        _activeFrame.setSplashImageVisibility(false); 
                                    }
                                }
                                else 
                                {
                                    Qt.toastX.pop("Customize the Active Frame.\n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                        }
                        
                        DropDown 
                        {
                            id: videoPlayer
                            title: "Default Video Player"
                            selectedIndex: (Qt.app.getSetting("videoPlayer", "snap2chatVideoPlayer") == "snap2chatVideoPlayer" ? 0 : 1);
                            options: 
                            [
                                Option
                                {
                                    text: "Snap10 Video Player"
                                    imageSource: "asset:///images/snapchat.png"
                                    value: "snap2chatVideoPlayer"
                                },
                                Option
                                {
                                    text: "BB10 Video Player"
                                    value: "bb10VideoPlayer"
                                }
                            ]
                            
                            onSelectedValueChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                
                                }
                                else 
                                {
                                    Qt.toastX.pop("Remove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                                
                                Qt.app.setSetting("videoPlayer", selectedValue);
                            }
                        }
                        
                        DropDown 
                        {
                            id: theme
                            title: "Application Color Theme"
                            selectedIndex: (Qt.app.getSetting("colortheme", "bright") == "bright" ? 0 : 1);
                            options: 
                            [
                                Option
                                {
                                    text: "Bright"
                                    imageSource: "asset:///images/light.png"
                                },
                                Option
                                {
                                    text: "Dark"
                                    imageSource: "asset:///images/dark.png"
                                }
                            ]
                            
                            onSelectedValueChanged: 
                            {
                                if(!firstRunTheme)
                                {
                                    if(_app.purchasedAds)
                                    {
                                        theAttachedObjects.dialogInteract.title = "Attention";
                                        theAttachedObjects.dialogInteract.body = "Changing Color Theme requires an App Restart. After this the application will exit. Just re open it again :)";
                                        theAttachedObjects.dialogInteract.show();
                                    }
                                    else 
                                    {
                                        Qt.toastX.pop("Remove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                        Qt.proSheet.open();
                                    }
                                }
                                
                                firstRunTheme = false; 
                            }
                        }

                        DropDown 
                        {
                            id: orientation
                            visible: (Qt.app.getDisplayHeight() > 730)
                            title: "Preferred Orientation"
                            selectedIndex: Qt.app.getSetting("orientation", 0);
                            enabled: true
                            options: 
                            [
                                Option
                                {
                                    text: "Auto Orient"
                                    imageSource: "asset:///images/orientauto.png"
                                },
                                Option
                                {
                                    text: "Portrait"
                                    imageSource: "asset:///images/orientportrait.png"
                                },
                                Option
                                {
                                    text: "Landscape"
                                    imageSource: "asset:///images/orientlandscape.png"
                                }
                            ]
                            
                            onSelectedIndexChanged: 
                            {
                                Qt.app.setSetting("orientation", selectedIndex);
                                setOrientation();
                            }
                        }

                        DropDown 
                        {
                            id: colorPresets
                            title: "Title Bar Color"
                            selectedIndex: Qt.app.getSetting("titleBarColorIndex", "0")
                            options: 
                            [
                                Option 
                                {
                                    text: "Default"
                                    value: "#2DA667"
                                },
                                Option 
                                {
                                    text: "Silk Black"
                                    value: "#a000000" 
                                },
                                Option 
                                {
                                    text: "Dark Gray"
                                    value: "#333333" 
                                },
                                Option 
                                {
                                    text: "Pure Black"
                                    value: "#000000" 
                                },
                                Option 
                                {
                                    text: "Dark Green"
                                    value: "#055555" 
                                },
                                Option 
                                {
                                    text: "Magenta"
                                    value: "#e710df"
                                },
                                Option 
                                {
                                    text: "Nice Blue"
                                    value: "#05796" 
                                },
                                Option 
                                {
                                    text: "CrackBerry Orange"
                                    value: "#f75e11" 
                                },
                                Option 
                                {
                                    text: "Custom"
                                    value: Qt.app.getSetting("titleBarColor", "#2DA667")
                                }
                            ]
                            
                            onSelectedIndexChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    Qt.app.setSetting("titleBarColorIndex", selectedIndex)
                                }
                            }
                            
                            onSelectedValueChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    titleBarColor.text = selectedValue;
                                    Qt.snap2chatAPIData.titleBarColor = selectedValue;
                                    Qt.app.setSetting("titleBarColor", selectedValue)
                                }
                                else 
                                {
                                    Qt.toastX.pop("Remove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                        }
                        
                        Container 
                        {
                            id: customColor
                            visible: (colorPresets.selectedOption.text == "Custom")
                                
                            layout: StackLayout 
                            {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            
                            TextField 
                            {
                                id: titleBarColor
                                hintText: "Color in HEX"
                                text: Qt.snap2chatAPIData.titleBarColor;
                                
                                onTextChanging: 
                                {
                                    if(text.length > 2)
                                    {
                                        if(_app.purchasedAds)
                                        {
                                            Qt.app.setSetting("titleBarColor", text);
                                        }
                                        
                                        Qt.snap2chatAPIData.titleBarColor = text;
                                    }
                                }
                                
                                layoutProperties: StackLayoutProperties 
                                {
                                    spaceQuota: 1
                                }
                            }
                            
                            Container 
                            {
                                id: titleBarColorPreview
                                background: Color.create(Qt.snap2chatAPIData.titleBarColor);
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                
                                layoutProperties: StackLayoutProperties 
                                {
                                    spaceQuota: 1
                                }
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Pure Dark ListView"  
                            }
                            
                            ToggleButton 
                            {
                                id: pureDarkListView
                                checked: Qt.app.getSetting("pureDarkListView", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    if(_app.purchasedAds)
                                    {
                                        Qt.app.setSetting("pureDarkListView", checked);
                                    }
                                    else 
                                    {
                                        Qt.toastX.pop("Remove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                        Qt.proSheet.open();
                                    }
                                }
                            }
                        }
                        
                        Container 
                        {
                            visible: (pureDarkListView.checked)
                            
                            Divider {}
                            
                            Label 
                            {
                                text: "This only applies when your theme is set to dark and the app needs a restart to take effect."
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.fontStyle: FontStyle.Italic
                                textStyle.color: Color.Gray
                                multiline: true
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "VIP Custom Feed Icons"  
                            }
                            
                            ToggleButton 
                            {
                                id: vipCustomFeedIcons
                                checked: Qt.app.getSetting("vipCustomFeedIcons", "true");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    Qt.app.setSetting("vipCustomFeedIcons", checked);
                                }
                            }
                        }

                        DropDown
                        {
                            id: actionBarScrollBehavior
                            visible: false
                            title: "Action/Tab Bar Scroll Behavior"
                            selectedIndex: Qt.app.getSetting("actionBarScrollBehaviorIndex", "1");
                            options: 
                            [
                                Option 
                                {
                                    text: "Sticky"
                                    value: text
                                },
                                Option 
                                {
                                    text: "Hide On Scroll"
                                    value: text
                                }
                            ]
                            
                            onSelectedIndexChanged: 
                            {
                                Qt.app.setSetting("actionBarScrollBehaviorIndex", selectedIndex);
                            }
                            
                            onSelectedValueChanged: 
                            {
                                Qt.app.setSetting("actionBarScrollBehavior", selectedValue);
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Wipe Cache on App Start"  
                            }
                            
                            ToggleButton 
                            {
                                id: autoWipeCache
                                checked: Qt.app.getSetting("autoWipeCache", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    Qt.app.setSetting("autoWipeCache", checked);
                                }
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Allow Logging"  
                            }
                            
                            ToggleButton 
                            {
                                id: allowLogging
                                checked: Qt.app.getSetting("allowLogging", "false");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged: 
                                {
                                    Qt.app.setSetting("allowLogging", checked);
                                }
                            }
                        }
                        
//                        Divider {}
//                        
//                        Container 
//                        {
//                            horizontalAlignment: HorizontalAlignment.Fill  
//                            
//                            layout: DockLayout {}
//                            
//                            Label
//                            {
//                                text: "Headless State Notifications"  
//                            }
//                            
//                            ToggleButton 
//                            {
//                                id: headlessStateNotifications
//                                checked: Qt.app.getSetting("headlessStateNotifications", "false");
//                                horizontalAlignment: HorizontalAlignment.Right
//                                onCheckedChanged: 
//                                {
//                                    Qt.app.setSetting("headlessStateNotifications", checked);
//                                }
//                            }
//                        }
                        
                        Divider {}
                        
                        Button 
                        {
                            id: clearHubNotifications
                            text: "Clear Notifications in Hub"
                            horizontalAlignment: HorizontalAlignment.Fill
                            onClicked: 
                            {
                                _app.clearNotifications();
                                
                                Qt.app.showToast("Successfully Cleared Notifications in the Hub :)");
                            }
                        }
                        
                        Divider {}
                        
                        Button 
                        {
                            id: copyCache
                            text: "BackUp Cache to Device/Misc/";
                            horizontalAlignment: HorizontalAlignment.Fill
                            onClicked: 
                            {
                                if(_app.purchasedAds)
                                {
                                    Qt.app.backUpCache();
                                    
                                    Qt.app.showToast("Successfully Backed Up Cache to Device/Misc/Snap2ChatCache/ :)");
                                }
                                else 
                                {
                                    Qt.toastX.pop("Remove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                        }
                        
                        Label 
                        {
                            text: "Note: Wait until you see the success message and that means the copying has been completed. The time it takes depends on how big your cache is. But you can already browse the cache folder while it's still being populated."
                            multiline: true
                            textStyle.fontSize: FontSize.XSmall
                        }
                        
                        Divider {}
                        
                        Button 
                        {
                            id: clearCacheButton
                            text: "Clear Cache : " + humanFileSize(Qt.app.getCacheSize());
                            horizontalAlignment: HorizontalAlignment.Fill
                            onClicked: 
                            {
                                var blobsFolder = Qt.app.getHomePath() + "/files/blobs/"
                                Qt.app.wipeFolderContents(blobsFolder);
                                
                                var blobsFolder = Qt.app.getHomePath() + "/files/sent/"
                                Qt.app.wipeFolderContents(blobsFolder);
                               
								text = "Clear Cache : " + humanFileSize(Qt.app.getCacheSize());
								   
								Qt.app.showToast("Successfully Cleared Cache :)");
                            }
                        }
                        
                        Label 
                        {
                            text: "Warning: Clearing Cache will only delete the downloaded snaps and stories."
                            multiline: true
                            textStyle.fontSize: FontSize.XSmall
                        }
                        
                        Divider {}

                        Button 
                        {
                            text: "Reset to Defaults"
                            horizontalAlignment: HorizontalAlignment.Fill
                            onClicked: 
                            {
                                Qt.app.setSetting("titleBarColor", "");
                                Qt.snap2chatAPIData.titleBarColor 	= Qt.app.getSetting("titleBarColor", "#2DA667");

                                Qt.app.setSetting("showTabsOn", "left");
                                theme.selectedIndex = (Qt.app.getSetting("showTabsOn", "bottom") == "bottom" ? 0 : 1);
                                
                                Qt.app.showToast("Settings Successfully Reset :)");
                            }
                        }
                    }
                }
            }
        }

        actions:
        [
            ActionItem
            {
                title: "Logout"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/titleCancel.png"
                onTriggered: 
                {
                    theAttachedObjects.logoutPromptInteract.show();
                }
            }
        ]
    }
    
    onCreationCompleted: 
    {
        createObjects();
        
        setOrientation();
        setKeepAwake();
    }
    
    function setOrientation()
    {
        var orientation = Qt.app.getSetting("orientation", 0);
        
        if(orientation == 0)
        {
            OrientationSupport.supportedDisplayOrientation = 
            SupportedDisplayOrientation.All;  
        }
        else if(orientation == 1)
        {
            OrientationSupport.supportedDisplayOrientation = 
            SupportedDisplayOrientation.DisplayPortrait;  
        }
        else if(orientation == 2)
        {
            OrientationSupport.supportedDisplayOrientation = 
            SupportedDisplayOrientation.DisplayLandscape;  
        }
    }
    
    function setKeepAwake()
    {
        if(Qt.app.getSetting("keepawake", "false") == "true" || Qt.app.getSetting("keepawake", "") == "")
        {
            Application.mainWindow.screenIdleMode = 1;
        }
        else 
        {
            Application.mainWindow.screenIdleMode = 0;
        }
    }
    
    function logoutRequest()
    {
        // --------------------------- JSON OBJECT ------------------------------------ //
        
        var jsonObject 				= new Object();
        
        var cObject 				= new Object();
        cObject["t"] 				= parseInt(Qt.snap2chatAPIData.getCurrentTimestamp() / 1000);
        cObject["c"] 				= 0;
        jsonObject[0] 				= cObject;
        
        var jsonString 				= JSON.stringify(jsonObject);
        
        // --------------------------- EVENTS ARRAY ------------------------------------ //
        
        var eventObject 			= new Object();
        eventObject["eventName"]	= "LOGOUT_DIALOG";
        eventObject["ts"] 			= Qt.snap2chatAPIData.getCurrentTimestamp() - 1;
        
        var eventParams 			= new Object();
        eventParams["result"] 		= "yes";
        eventObject["params"] 		= eventParams;
        
        var eventsArray 			= new Array();
        eventsArray[0] 				= eventObject;
        
        var eventsString 			= JSON.stringify(eventsArray);
        
        var params 					= new Object();
        params.endpoint				= "/ph/logout";
        params.username 			= Qt.snap2chatAPIData.username;
        params.timestamp 			= Qt.snap2chatAPIData.getCurrentTimestamp();
        params.req_token 			= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
        
        params.events				= eventsString;
        params.json					= jsonString;
        params.added_friends_timestamp	= Qt.snap2chatAPIData.addedFriendsTimestamp;
        
        Qt.snap2chatAPI.request(params);
    }
    
    function humanFileSize(bytes) 
    {
        var thresh = 1024;
        
        if(bytes < thresh) return bytes + ' B';
        
        var units = thresh ? ['kB','MB','GB','TB','PB','EB','ZB','YB'] : ['KiB','MiB','GiB','TiB','PiB','EiB','ZiB','YiB'];
        
        var u = -1;
        
        do 
        {
            bytes /= thresh;
            ++u;
        } 
        while(bytes >= thresh);
        
        return bytes.toFixed(1)+' '+units[u];
    }
}