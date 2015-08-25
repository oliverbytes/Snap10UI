import bb.cascades 1.0
import bb.system 1.0
import QtQuick 1.0
import nemory.Snap2ChatAPISimple 1.0
import nemory.SelfaceAPI 1.0

import "sheets"
import "pages"
import bb.platform 1.2

TabbedPane
{
    id: tabbedPane
    showTabsOnActionBar: true
    property bool uiHeadlessConnected : false;
    property bool checkedAnnouncements : false;
    property bool checkedAnnouncementsHub : false;
    property variant theAttachedObjects
    
    property string parseStatus : "rt1L7Rirpt"
    property string parseAnnouncementPro : "Dm8PGAc0h1"
    property string parseAnnouncementLite : "o8JnmT1O7M"

    property bool isSynchronized : false;
    
    onCreationCompleted: 
    {
        Qt.storePaymentManager = storePaymentManager;
        storePaymentManager.setConnectionMode(1); // 1 PRODUCTION 0 SANDBOX
        
        if(_app.getSetting("purchasedAds", "false") == "true")
        {
            Qt.purchasedAds = true; 
        }
        else 
        {
            Qt.purchasedAds = false;
            
            var hubAdCount = parseInt(_app.getSetting("hubAdCount", "0"));
            
            console.log("hubAdCount: " + hubAdCount);
            
            if(hubAdCount <= 3)
            {
                hubAdCount = hubAdCount + 1;
                
                _app.setSetting("hubAdCount", hubAdCount)
            }
            else 
            {
                _app.notify("Enable SnapChat Notifications", "Receive Notifications even when the app is not open. Unlock all the awesome features for just one payment and for a very good price. Open Snap10 now and Upgrade to PRO. :)\n\nClick any X of the Advertisement to Upgrade.");
                
                _app.setSetting("hubAdCount", "0")
            }
        }
        
        Qt.app 					= _app;
        Qt.snap2chatAPIData 	= _snap2chatAPIData;
        Qt.uiHeadlessConnected  = uiHeadlessConnected;
        Qt.profileObject        = new Object();
        Qt.shoutBoxTab          = shoutBoxTab;
        Qt.snap2chatAPI         = snap2chatAPI;
        Qt.refreshTimer         = refreshTimer;
        Qt.mainSheet            = mainSheet;
        Qt.dialogX 		        = dialogX;

        Application.aboutToQuit.connect(onAboutToQuit);
        _app.socketReceived.connect(socketReceived);
        _app.cameraErrorSignal.connect(cameraErrorSignal);
        _app.invokedExtendedSearch.connect(invokedExtendedSearch);
        _app.invokedCompose.connect(invokedCompose);
        _app.invokedOpenConversation.connect(invokedOpenConversation);
        
        creationCompletedTimer.start();
        
        //theCreationCompleted();
        
        var data           = new Object();
        var params         = new Object();
        
        params.endpoint    = "classes/Status/" + parseStatus;
        params.data        = JSON.stringify(data);
        
        selfaceAPI.get(params);
    }
    
    function theCreationCompleted()
    {
        if (!tabbedPane.theAttachedObjects)
        {
            tabbedPane.theAttachedObjects = myAttachedObjects.createObject(tabbedPane);
            
            //Qt.snap2chatAPI 		= theAttachedObjects.snap2chatAPIInteract;
            Qt.progressDialog 		= theAttachedObjects.progressDialogInteract;
            Qt.invokeShare 			= theAttachedObjects.invokeShareInteract;
            Qt.aboutSheet 			= theAttachedObjects.aboutSheetInteract;
            Qt.loginSheet 			= theAttachedObjects.loginSheetInteract;
            Qt.registerSheet 		= theAttachedObjects.registerSheetInteract;
            //Qt.mainSheet 			= theAttachedObjects.mainSheetInteract;
            Qt.settingsSheet 		= theAttachedObjects.settingsSheetInteract;
            //Qt.refreshTimer 		= theAttachedObjects.refreshTimerInteract;
            Qt.shoutSheet			= theAttachedObjects.shoutSheetInteract;
            Qt.uploadingSnapsSheet	= theAttachedObjects.uploadingSnapsSheetInteract;
            Qt.profileSheet			= theAttachedObjects.profileSheetInteract;
            Qt.proSheet			    = theAttachedObjects.proSheetInteract;
            Qt.toastX               = toastX;
            Qt.invokeBrowser        = invokeBrowser;
            Qt.announcementSheet    = announcementSheet;
        }
        
        _app.checkSharedFilesPermission();
        
        if(Qt.app.getSetting("activeFrameShow", "list") == "splash")
        {
            _activeFrame.setSplashImageVisibility(true); 
        }
        else 
        {
            _activeFrame.setSplashImageVisibility(false); 
        }
    }
    
    function onAboutToQuit()
    {
        //_app.log();
    }
    
    function socketReceived(data)
    {
        var jsonCommand = new Object();
        var dataString = "";
        
        if(data.length > 0)
        {
            try
            {
                jsonCommand = JSON.parse(data);
                
                if(jsonCommand.action.length > 0)
                {
                    dataString = JSON.stringify(jsonCommand.data);
                    
                    if (jsonCommand.action == "parseUpdatesJSON" && !_snap2chatAPIData.isInFriendChooser)
                    {
                        if(jsonCommand.httpcode == "200" && dataString.length > 0)
                        { 
                            _snap2chatAPIData.parseUpdatesJSON(dataString);
                            
                            syncActiveFrame();
                            
                            _snap2chatAPIData.loading = false;
                        }
                        else if(jsonCommand.httpcode == "0")
                        {
                            _app.showToast("Looks like you have no internet connection. Please double check and try again.");
                            
                            _snap2chatAPIData.loading = false;
                        }
                        else if(jsonCommand.httpcode != "200" && jsonCommand.httpcode != "204")
                        {
                            Qt.app.flurryLogError("ERROR HTTP: " + jsonCommand.httpcode + ", RESPONSE: " + dataString);
                            
                            if(jsonCommand.httpcode == "401")
                            {
                                Qt.app.setSetting("username", "");
                                Qt.app.setSetting("auth_token", "");
                                
                                Qt.snap2chatAPIData.clearFeedsLocally();
                                Qt.snap2chatAPIData.resetAll();
                                
                                Qt.mainSheet.open();
                                
                                Qt.app.showDialog("Attention", "Looks like you've logged in from another app. Please re-sign in :)");
                                
                                _snap2chatAPIData.loading = false;
                            }
                        }
                    }
                    else if (jsonCommand.action == "startLoading")
                    {
                        _snap2chatAPIData.loading = true;
                    }
                    else if (jsonCommand.action == "stopLoading")
                    {
                        _snap2chatAPIData.loading = false;
                    }
                    else if (jsonCommand.action == "connected")
                    {
                        isSynchronized = true;
                        
                        Qt.aboutSheet.connected();
                        
                        var command = new Object();
                        command.action = "connected";
                        command.data = "data";
                        _app.socketSend(JSON.stringify(command));
                        
                        console.log("***** QML HEADLESS CONNECTED SUCCESSFULLY *****");
                    }
                }
                
                console.log("***** QML action: " + jsonCommand.action + ", code: " + jsonCommand.httpcode + ", data: " + dataString);
            }
            catch(err)
            {
                console.log("*** QML PARSING ERROR: " + err + ", " + jsonCommand);
                
                _snap2chatAPIData.loading = false;
                
                //_app.showToast("Snap2Chat encountered some issues, could you please restart the app?");
            }
        }
    }

    function invokedOpenConversation(data)
    {
        console.log("***** QML invokedOpenConversation: " + JSON.stringify(data));
        
        var dataJSON 	= JSON.parse(data);

        var command 	= new Object();
        command.action 	= "markAsRead";
        command.data 	= JSON.stringify(dataJSON);
        _app.socketSend(JSON.stringify(command));
        
        console.log("QML DATA JSON: " + JSON.stringify(dataJSON))
    }   
    
    function invokedCompose(data)
    {
        console.log("***** QML invokedCompose: " + JSON.stringify(data));
        
        var parameters 				= new Object();
        parameters.replyMode 		= false;
        parameters.recipient 		= "";
        parameters.postToShoutBox 	= false;
        _app.openCameraTab(parameters);
    }   
    
    function invokedExtendedSearch(data)
    {
        console.log("***** QML invokedExtendedSearch: " + JSON.stringify(data))
    }
    
    function cameraErrorSignal(error)
    {
        theAttachedObjects.dialogInteract.title = "Action Failed";
        theAttachedObjects.dialogInteract.body = error;
        theAttachedObjects.dialogInteract.show();
    }
    
    function topInitialization()
    {
        _app.loadUpdatesSignal.connect(loadUpdates);
        _app.loadStoriesSignal.connect(loadStories);
        _app.openCameraTabSignal.connect(openCameraTab);
        _app.redrawTabsSignal.connect(redrawTabs);

        _app.clearNotificationEffects();
        Application.awake.connect(awaken);
        Application.thumbnail.connect(thumbnailed);
    
        if(!isLoggedIn())
        {
            Qt.mainSheet.open();
        }
        else
        {
            initialize(false);
        }
        
        var command = new Object();
        command.action = "connect";
        command.data = "data";
        _app.socketSend(JSON.stringify(command));
    }

    function initialize(fromLogin)
    {
        _snap2chatAPIData.titleBarColor 	= _app.getSetting("titleBarColor", "#2DA667");
        
        _app.flurrySetUserID(_snap2chatAPIData.username);
        
        console.log("********* QML USERNAME = " + _snap2chatAPIData.username + ", AUTH_TOKEN = " + _snap2chatAPIData.auth_token + " ********* ");
        
        if(_app.getSetting("openCameraOnOpened", "false") == "true")
        {
            var parameters 				= new Object();
            parameters.replyMode 		= false;
            parameters.recipient 		= "";
            parameters.postToShoutBox 	= false;
            _app.openCameraTab(parameters);
        }
        
        if(!fromLogin)
        {
            _snap2chatAPIData.loading = true;
            _app.loadUpdates();
            _app.loadStories();
        }
        else 
        {
            _app.loadStories();
        }

        startRefreshTimer();
        
        cameraInitializer.start();
        
        announcementsTimer.start();
    }
    
    onActiveTabChanged: 
    {
        activeTab.load();
        
        feedsTab.newContentAvailable = false;
        feedsTab.unreadContentCount = 0;
        
        if(activeTab == theCameraTab)
        {
            Qt.snap2chatAPIData.isInCamera = true;
        }
        else 
        {
            theCamera.turnOffVideoFlash();
            
            Qt.snap2chatAPIData.isInCamera = false;
        }
    }
    
    Tab 
    {
        id: feedsTab
        title: "Feeds"
        description: _snap2chatAPIData.feedsDataModel.size() + " Snaps"
        imageSource: "asset:///images/tabFeeds.png"
        
        attachedObjects: ComponentDefinition
        {
            id: feedsComponent
            source: "asset:///pages/Feeds.qml"
        }
        
        function load(){}
    }
    
    Tab 
    {
        id: storiesTab
        title: "Stories"
        description: _snap2chatAPIData.storiesDataModel.size() + " Stories"
        imageSource: "asset:///images/ic_notes.png"
        
        attachedObjects: ComponentDefinition 
        {
            id: storiesComponent
            source: "asset:///pages/Stories.qml"
        }
        
        function load(){}
    }
    
    Tab 
    {
        id: friendsTab
        title: "Friends"
        description: _snap2chatAPIData.friendsDataModel.size() + " Friends"
        imageSource: "asset:///images/tabFriends.png"
        
        attachedObjects: ComponentDefinition 
        {
            id: friendsComponent
            source: "asset:///pages/Friends.qml"
        }
        
        function load(){}
    }
    
    Tab 
    {
        id: friendRequestsTab
        title: "Friend Requests"
        description: _snap2chatAPIData.friendRequestsDataModel.size() + " Friend Requests"
        imageSource: "asset:///images/tabAddFriend.png"
        
        attachedObjects: ComponentDefinition 
        {
            id: friendRequestsComponent
            source: "asset:///pages/FriendRequests.qml"
        }
        
        function load(){}
    }
    
    Tab 
    {
        id: shoutBoxTab
        title: "Shout Box"
        imageSource: "asset:///images/tabFlirt.png"
        
        attachedObjects: ComponentDefinition 
        {
            id: shoutboxComponent
            source: "asset:///pages/ShoutBox.qml"
        }
        
        function load()
        {
            shoutboxComponent.load();
        }
    }
    
    Tab 
    {
        id: extendedProfileTab
        title: "My Profile"
        description: "Your Profile Information"
        imageSource: "asset:///images/tabAccount.png"
        
        ExtendedProfile 
        {
            id: myprofile
        }
        
        function load()
        {
            myprofile.load();
        }
    }
    
    Tab 
    {
        id: theCameraTab
        title: "Camera"
        description: "The snapchat camera"
        imageSource: "asset:///images/tabCamera.png"
        
        TheCamera 
        {
            id: theCamera
            tabbedPane: tabbedPane
            feedsTab: feedsTab
            friendsTab: friendsTab
            
            onCreationCompleted: 
            {
                componentCreatorTimer.start();
            }
        } 
        
        function load()
        {
            hideTabs("camera");
        }
        
        attachedObjects: 
        [
            Timer 
            {
                id: componentCreatorTimer
                interval: 500
                repeat: false
                
                onTriggered: 
                {
                    feedsTab.content 			= feedsComponent.createObject();
                    storiesTab.content 			= storiesComponent.createObject();
                    
                    activeTab = storiesTab;
                    activeTab = feedsTab;
                    
                    friendsTab.content 			= friendsComponent.createObject();
                    friendRequestsTab.content 	= friendRequestsComponent.createObject();
                    shoutBoxTab.content 		= shoutboxComponent.createObject();

                    topInitialization();
                }
            },
            Main 
            {
                id: mainSheet
            },
            Invocation 
            {
                id: invokeBrowser
                query.invokeTargetId: "sys.browser"
                query.invokeActionId: "bb.action.OPEN"
                
                onArmed: 
                {
                    invokeBrowser.trigger(query.invokeActionId);
                }
            },
            Timer 
            {
                id: cameraInitializer
                interval: 2000
                repeat: false
                triggeredOnStart: false
                
                onTriggered: 
                {
                    _app.initializeCamera();
                }
            },
            Timer 
            {
                id: announcementsTimer
                interval: 40000
                repeat: false
                triggeredOnStart: false
                
                onTriggered: 
                {
                    var data           = new Object();
                    var params         = new Object();
                    
                    params.endpoint    = "classes/Announcements/" + (_app.purchasedAds ? parseAnnouncementPro : parseAnnouncementLite);
                    params.data        = JSON.stringify(data);
                    
                    selfaceAPI.get(params);
                }
            },
            Timer 
            {
                id: creationCompletedTimer
                
                interval: 1000
                repeat: false
                
                onTriggered: 
                {
                    theCreationCompleted();
                }    
            },
            Timer 
            {
                id: refreshTimer
                interval:_app.getSetting("refreshFeedsEvery", "100000");
                repeat: true
                onTriggered: 
                {
                    if(_app.getSetting("refreshFeeds", "false") == "true")
                    {
                        //_app.loadUpdates();
                        _app.loadStories();
                    }
                }
            },
            Snap2ChatAPISimple 
            {
                id: snap2chatAPI
                onComplete:
                {
                    console.log("HTTP: " + httpcode + ", endpoint: " + endpoint + ", RESPONSE: " + response);
                    
                    if(endpoint == "/bq/updates")
                    {
                        if(httpcode == "200" && !_snap2chatAPIData.isInFriendChooser)
                        { 
                            _snap2chatAPIData.parseUpdatesJSON(response);
                            
                            syncActiveFrame();
                        }
                        
                        _snap2chatAPIData.loading = false;
                    }
                    else if(endpoint == "/bq/stories")
                    {
                        if(httpcode == "200")
                        { 
                            _snap2chatAPIData.parseStoriesJSON(response);
                        }
                        
                        _snap2chatAPIData.loadingStories = false;
                    }
                    else if(endpoint == "/bq/login")
                    {
                        if(httpcode == "200")
                        {
                            var responseJSON = "";
                            
                            try
                            {
                                responseJSON = JSON.parse(response);
                                
                                if(!responseJSON.message)
                                {
                                    _snap2chatAPIData.parseUpdatesJSON(response);
                                    
                                    _app.setSetting("username", 	_snap2chatAPIData.username);
                                    _app.setSetting("auth_token", 	_snap2chatAPIData.auth_token);
                                    
                                    var command = new Object();
                                    command.action = "loadLoginDetails";
                                    
                                    var dataObject = new Object();
                                    dataObject.username 	= _snap2chatAPIData.username;
                                    dataObject.auth_token 	= _snap2chatAPIData.auth_token;
                                    
                                    command.data   = dataObject;
                                    _app.socketSend(JSON.stringify(command));
                                    
                                    var command2 = new Object();
                                    command2.action = "parseUpdatesJSON";
                                    command2.data   = response;
                                    _app.socketSend(JSON.stringify(command2));
                                    
                                    console.log("*** QML PARSE UPDATE: " + JSON.stringify(command2))
                                    
                                    syncActiveFrame();
                                    
                                    Qt.progressDialog.cancel();
                                    Qt.loginSheet.close();
                                    Qt.mainSheet.close(); 
                                }
                                else 
                                {
                                    Qt.app.showDialog("Attention", responseJSON.message);
                                }
                                
                                Qt.app.flurryLogEvent("LOGIN");
                            }
                            catch(err)
                            {
                                console.log("*** QML PARSING ERROR: " + err + ", " + response)
                            }
                        }
                        
                        Qt.progressDialog.cancel();
                    }
                    
                    if(httpcode == "0")
                    {
                        _app.showToast("Looks like you have no internet connection. Please double check and try again.")
                    }
                    else if(httpcode != "200" && httpcode != "204")
                    {
                        Qt.app.flurryLogError("ERROR endpoint: " + endpoint + ", HTTP: " + httpcode + ", RESPONSE: " + response);
                        
                        if(httpcode == "401")
                        {
                            Qt.app.setSetting("username", "");
                            Qt.app.setSetting("auth_token", "");
                            
                            Qt.snap2chatAPIData.clearFeedsLocally();
                            Qt.snap2chatAPIData.resetAll();
                            
                            Qt.mainSheet.open();
                            
                            Qt.app.showDialog("Attention", "Looks like you've logged in from another snapchat app. Please re-sign in :)");
                        }
                    }
                    
                    Qt.progressDialog.cancel();
                }
            }
        ]
    }
    
    Menu.definition: MenuDefinition 
    {
        actions: 
        [
            ActionItem 
            {
                title: "About"
                imageSource: "asset:///images/titleInfo.png"
                onTriggered: 
                {
                    Qt.aboutSheet.open();
                }
            },
            ActionItem 
            {
                title: "Share"
                imageSource: "asset:///images/tabShare.png"
                onTriggered: 
                {
                    theAttachedObjects.invokeShareInteract.trigger("bb.action.SHARE");
                }
            },
            ActionItem  
            {
                title: "Contact"
                imageSource: "asset:///images/menuEmail.png"
                onTriggered: 
                {
                    _app.invokeEmail("snap2chat@gmail.com", "Support : Snap10 ", "")
                }
            },
            ActionItem 
            {
                title: "Rate"
                imageSource: "asset:///images/rate.png"
                enabled: true
                onTriggered:
                {
                    _app.invokeBBWorld("appworld://content/47649895");
                }
            },
            ActionItem 
            {
                id: settingsButton
                title: "Settings"
                imageSource: "asset:///images/settings.png"
                enabled: true
                onTriggered:
                {
                    Qt.settingsSheet.open();
                }
            }
        ]
    }
    
    attachedObjects: 
    [
        ComponentDefinition 
        {
            id: myAttachedObjects
            
            Container 
            {
                id: objects
                
                property alias invokeShareInteract: invokeShare
                property alias aboutSheetInteract: aboutSheet
                property alias loginSheetInteract: loginSheet
                property alias registerSheetInteract: registerSheet
                //property alias mainSheetInteract: mainSheet
                property alias settingsSheetInteract: settingsSheet
                //property alias refreshTimerInteract: refreshTimer
                property alias progressDialogInteract: progressDialog
                property alias shoutSheetInteract: shoutSheet
                property alias uploadingSnapsSheetInteract: uploadingSnapsSheet
                property alias profileSheetInteract : profileSheet
                property alias proSheetInteract : proSheet
                //property alias snap2chatAPIInteract: snap2chatAPI
                property alias dialogInteract : dialog
                
                attachedObjects: 
                [
                    Invocation 
                    {
                        id: invokeShare
                        query.mimeType: "text/plain"
                        query.invokeActionId: "bb.action.SHARE"
                        query.invokerIncluded: true
                        query.data: "Snap2Chat - Native SnapChat Client for BlackBerry 10. Get it at http://appworld.blackberry.com/webstore/content/47649895/"
                    },
                    Profile
                    {
                        id: profileSheet
                    },
                    PROVersion 
                    {
                        id: proSheet
                    },
                    AboutSheet 
                    {
                        id: aboutSheet
                    },
                    UploadingSnaps
                    {
                        id: uploadingSnapsSheet
                    },
                    Login 
                    {
                        id: loginSheet
                        onClosed:
                        {
                            isLoggedIn();
                            initialize(true);
                        }
                    },
                    Register 
                    {
                        id: registerSheet
                    },
                    Settings 
                    {
                        id: settingsSheet
                    },
                    SystemProgressDialog 
                    {
                        id: progressDialog
                        title : "Processing"
                        body: ""
                        cancelButton.enabled: false
                        defaultButton.enabled: false 
                        confirmButton.enabled: false
                    },
                    SystemDialog 
                    {
                        id: dialog
                    },
                    Shout 
                    {
                        id: shoutSheet
                    }
                ]
            }
        },
        SystemDialog 
        {
            id: restartDialog
            title: "Purchase Successful"
            body: "Please restart the Application to complete the process. Thanks. :)"
            cancelButton.label: "Cancel"
            confirmButton.label: "Restart"
            onFinished: 
            {
                if(buttonSelection().label == "Restart")
                {
                    Application.requestExit();
                }
                
                dialog.cancel();
            }
        },
        PaymentManager 
        {
            id: storePaymentManager
            property bool busy: false
            
            onExistingPurchasesFinished: 
            {
                //_app.writeLogToFile(JSON.stringify(reply), "existingPurchaseLOGS.json");
                
                storePaymentManager.busy = false;
                
                if (reply.errorCode == 0) 
                {
                    for (var i = 0; i < reply.purchases.length; ++ i) 
                    {
                        _app.setSetting("purchasedAds", "true");
                        
                        restartDialog.show();
                        
                        console.log("**** onExistingPurchasesFinished RECEIPT: " + reply.purchases[i].receipt["digitalGoodSku"]);
                        console.log("**** onExistingPurchasesFinished SKU: " + reply.purchases[i]["digitalGoodSku"]);
                        
                        _app.flurryLogEvent("PURCHASE EXIST SUCCESS");
                    }
                } 
                else 
                {
                    console.log("**** onExistingPurchasesFinished Error: " + reply.errorText);
                    
                    toastX.body = "Error: " + reply.errorCode + ", " + reply.errorText;
                    toastX.show();
                    
                    _app.flurryLogEvent("PURCHASE EXIST ERROR: " + "Error: " + reply.errorCode + ", " + reply.errorText);
                }
            }
            
            onPurchaseFinished: 
            {
                if (reply.errorCode == 0) 
                {
                    _app.setSetting("purchasedAds", "true");
                    
                    restartDialog.show();
                    
                    console.log("**** onPurchaseFinished Success: " + reply.digitalGoodSku);
                    
                    _app.flurryLogEvent("PURCHASE SUCCESS");
                } 
                else 
                {
                    console.log("**** onPurchaseFinished Error: " + reply.errorText);
                    
                    toastX.body = "Error: " + reply.errorCode + ", " + reply.errorText;
                    toastX.show();
                    
                    _app.flurryLogEvent("PURCHASE ERROR: " + "Error: " + reply.errorCode + ", " + reply.errorText);
                }
            }
        },
        AnnouncementSheet 
        {
            id: announcementSheet
        },
        SelfaceAPI 
        {
            id: selfaceAPI
            
            onComplete: 
            {
                console.log("**** PARSE API endpoint: " + endpoint + ", httpcode: " + httpcode + ", response: " + response);
                
                if(httpcode != 200 && httpcode != 201)
                {
                    _app.flurryLogError(httpcode + " - " + endpoint + " - " + response);
                }
                else 
                {
                    var responseJSON = JSON.parse(response);

                    if(endpoint == ("classes/Announcements/" + parseAnnouncementLite))
                    {
                        if(responseJSON.enabled == "true")
                        {
                            announcementSheet.announcementString = responseJSON.message;
                            announcementSheet.imageURL = responseJSON.image.url;
                            announcementSheet.open();
                            
                            _app.setSetting("lastAnnouncement", responseJSON.message);
                        }
                    }
                    else if(endpoint == ("classes/Announcements/" + parseAnnouncementPro))
                    {
                        if(responseJSON.enabled == "true")
                        {
                            announcementSheet.announcementString = responseJSON.message;
                            announcementSheet.imageURL = responseJSON.image.url;
                            
                            if(_app.getSetting("lastAnnouncement", "") != responseJSON.message)
                            {
                                announcementSheet.open();
                            }
                            
                            _app.setSetting("lastAnnouncement", responseJSON.message);
                        }
                    }
                    else if(endpoint == ("classes/Status/" + parseStatus))
                    {
                        if(responseJSON.enabled == "false")
                        {
                            dialogX.pop(responseJSON.message);
                            announcementSheet.lock = true;
                            announcementSheet.lockMessage = responseJSON.message;
                            announcementSheet.open();
                        }
                    }
                }
            }
        },
        SystemDialog
        {
            id: dialogX
            title: "Attention"
            
            function pop(message)
            {
                dialogX.body = message;
                dialogX.show();
            }
        },
        SystemToast 
        {
            id: toastX
            position: SystemUiPosition.BottomCenter
            
            function pop(message)
            {
                toastX.body = message;
                toastX.show();
            }
        }
    ]
    
    function startRefreshTimer()
    {
        if(_app.getSetting("refreshFeeds", "false") == "true")
        {
            Qt.refreshTimer.start();
        }
    }

    function checkAnnouncements()
    {
        var params = new Object();
        params.url = "http://nemorystudios.com/snapchat/includes/webservices/announcements.php";
        params.endpoint = "checkannouncements";
        Qt.snap2chatAPI.kellyGetRequest(params);
    }
    
    function checkAnnouncementsHub()
    {
        var params = new Object();
        params.url = "http://nemorystudios.com/snapchat/includes/webservices/announcementshub.php";
        params.endpoint = "checkannouncementshub";
        Qt.snap2chatAPI.kellyGetRequest(params);
    }
    
    function loadStories()
    {
        if(!_snap2chatAPIData.loadingStories && isLoggedIn())
        {
            _snap2chatAPIData.loadingStories = true;

            var params 			= new Object();
            params.endpoint		= "/bq/stories";
            params.username 	= Qt.snap2chatAPIData.username;
            params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
            params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
            
            Qt.snap2chatAPI.request(params);
        }
    }
    
    function loadUpdates()
    {
        if(isLoggedIn() && !_snap2chatAPIData.isInFriendChooser)
        {
            _snap2chatAPIData.loading = true;
            
            var params 			= new Object();
            params.endpoint		= "/bq/updates";
            params.username 	= Qt.snap2chatAPIData.username;
            params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
            params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
            
            Qt.snap2chatAPI.request(params);
            
            var command = new Object();
            command.action = "refresh";
            command.data = "data";
            _app.socketSend(JSON.stringify(command));
        }
    }
    
    function isLoggedIn()
    {
        var loggedin = false;
        
        _snap2chatAPIData.username 		= 	_app.getSetting("username", "");
        _snap2chatAPIData.auth_token 	=	_app.getSetting("auth_token", "");
        
        if(_snap2chatAPIData.username != "" && _snap2chatAPIData.auth_token != "")
        {
            loggedin = true;
        }
        
        return loggedin;
    }
    
    function thumbnailed()
    {
        syncActiveFrame();
    }
    
    function awaken()
    {
        _app.clearNotificationEffects();
    }
    
    function syncActiveFrame()
    {
        if(isLoggedIn())
        {
            _activeFrame.setSnap1Visibility(false);
            _activeFrame.setSnap2Visibility(false);
            _activeFrame.setSnap3Visibility(false);
            _activeFrame.setSnap4Visibility(false);
            _activeFrame.setSnap5Visibility(false);
            _activeFrame.setSnap6Visibility(false);
            
            _activeFrame.setListSnapsVisibility(false);
            
            var indexPath = new Array();
            
            if(_snap2chatAPIData.feedsDataModel.size() > 0)
            {
                _activeFrame.setListSnapsVisibility(true);
                
                if(_snap2chatAPIData.feedsDataModel.size() > 0)
                {
                    _activeFrame.setSnap1Visibility(true);
                    
                    indexPath[0] = 0;
                    var snap = _snap2chatAPIData.feedsDataModel.data(indexPath);
                    
                    _activeFrame.setUsername1((snap.sn ? snap.sn : snap.rp));
                    _activeFrame.setStatus1(snap.timeago + snap.statusText);
                    _activeFrame.setImage1(snap.statusImage);
                }
                
                if(_snap2chatAPIData.feedsDataModel.size() > 1)
                {
                    _activeFrame.setSnap2Visibility(true);
                    
                    indexPath[0] = 1;
                    var snap = _snap2chatAPIData.feedsDataModel.data(indexPath);
                    
                    _activeFrame.setUsername2((snap.sn ? snap.sn : snap.rp));
                    _activeFrame.setStatus2(snap.timeago + snap.statusText);
                    _activeFrame.setImage2(snap.statusImage);
                }
                
                if(_snap2chatAPIData.feedsDataModel.size() > 2)
                {
                    _activeFrame.setSnap3Visibility(true);
                    
                    indexPath[0] = 2;
                    var snap = _snap2chatAPIData.feedsDataModel.data(indexPath);
                    
                    _activeFrame.setUsername3((snap.sn ? snap.sn : snap.rp));
                    _activeFrame.setStatus3(snap.timeago + snap.statusText);
                    _activeFrame.setImage3(snap.statusImage);
                }
                
                if(_snap2chatAPIData.feedsDataModel.size() > 3)
                {
                    _activeFrame.setSnap4Visibility(true);
                    
                    indexPath[0] = 3;
                    var snap = _snap2chatAPIData.feedsDataModel.data(indexPath);
                    
                    _activeFrame.setUsername4((snap.sn ? snap.sn : snap.rp));
                    _activeFrame.setStatus4(snap.timeago + snap.statusText);
                    _activeFrame.setImage4(snap.statusImage);
                }
                
                if(_snap2chatAPIData.feedsDataModel.size() > 4)
                {
                    _activeFrame.setSnap5Visibility(true);
                    
                    indexPath[0] = 4;
                    var snap = _snap2chatAPIData.feedsDataModel.data(indexPath);
                    
                    _activeFrame.setUsername5((snap.sn ? snap.sn : snap.rp));
                    _activeFrame.setStatus5(snap.timeago + snap.statusText);
                    _activeFrame.setImage5(snap.statusImage);
                }
                
                if(_snap2chatAPIData.feedsDataModel.size() > 5)
                {
                    _activeFrame.setSnap6Visibility(true);
                    
                    indexPath[0] = 5;
                    var snap = _snap2chatAPIData.feedsDataModel.data(indexPath);
                    
                    _activeFrame.setUsername6((snap.sn ? snap.sn : snap.rp));
                    _activeFrame.setStatus6(snap.timeago + snap.statusText);
                    _activeFrame.setImage6(snap.statusImage);
                }
            }
        }
        else 
        {
            _activeFrame.setSplashImageVisibility(true); 
        }
    }
    
    function clearNotifications()
    {
        _app.clearNotifications();
        
        feedsTab.newContentAvailable = false;
        feedsTab.unreadContentCount = 0;
    }
    
    function redrawTabs()
    {
        tabbedPane.showTabsOnActionBar = (_app.getSetting("showTabsOn", "left") == "left" ? false : true);
    }
    
    function openSettings()
    {
        Qt.settingsSheet.open();
    }
    
    function openAboutSheet()
    {
        Qt.aboutSheet.open();
    }
    
    function openCameraTab(parameters)
    {
        theCamera.parameters 	= parameters;
        tabbedPane.activeTab 	= theCameraTab;
    }
    
    function openLoginSheet()
    {
        Qt.loginSheet.open();
    }

    function hideTabs(currentTab)
    {
        if(currentTab == "feeds")
        {
            tabbedPane.peekEnabled = false;
            tabbedPane.remove(storiesTab);
            tabbedPane.remove(friendRequestsTab);
            tabbedPane.remove(friendsTab);
            tabbedPane.remove(theCameraTab);
            tabbedPane.remove(extendedProfileTab);
            tabbedPane.remove(shoutBoxTab);
        }
        else if(currentTab == "stories")
        {
            tabbedPane.remove(feedsTab);
            //tabbedPane.remove(storiesTab);
            tabbedPane.remove(friendRequestsTab);
            tabbedPane.remove(theCameraTab);
            tabbedPane.remove(friendsTab);
            tabbedPane.remove(extendedProfileTab);
            tabbedPane.remove(shoutBoxTab);
        }
        else if(currentTab == "friends")
        {
            tabbedPane.remove(feedsTab);
            tabbedPane.remove(storiesTab);
            tabbedPane.remove(friendRequestsTab);
            tabbedPane.remove(theCameraTab);
            tabbedPane.remove(extendedProfileTab);
            tabbedPane.remove(shoutBoxTab);
        }
        else if(currentTab == "camera")
        {
            tabbedPane.remove(feedsTab);
            tabbedPane.remove(storiesTab);
            tabbedPane.remove(friendRequestsTab);
            tabbedPane.remove(extendedProfileTab);
            tabbedPane.remove(friendsTab);
            tabbedPane.remove(shoutBoxTab);
        }
    }
    
    function showTabs(currentTab, theTab)
    {
        if(currentTab == "feeds")
        {
            tabbedPane.peekEnabled = true;
            tabbedPane.insert(1, storiesTab);
            tabbedPane.insert(2, friendsTab);
            tabbedPane.insert(3, friendRequestsTab);
            tabbedPane.insert(4, shoutBoxTab);
            tabbedPane.insert(5, extendedProfileTab);
            tabbedPane.insert(6, theCameraTab);
        }
        else if(currentTab == "stories")
        {
            tabbedPane.insert(0, feedsTab);
            //tabbedPane.insert(1, storiesTab);
            tabbedPane.insert(2, friendsTab);
            tabbedPane.insert(4, friendRequestsTab);
            tabbedPane.insert(5, shoutBoxTab);
            tabbedPane.insert(6, extendedProfileTab);
            tabbedPane.insert(7, theCameraTab);
        }
        else if(currentTab == "friends")
        {
            tabbedPane.insert(0, feedsTab);
            tabbedPane.insert(1, storiesTab);
            //tabbedPane.insert(2, friendsTab);
            tabbedPane.insert(4, friendRequestsTab);
            tabbedPane.insert(5, shoutBoxTab);
            tabbedPane.insert(6, extendedProfileTab);
            tabbedPane.insert(7, theCameraTab);
        }
        else if(currentTab == "camera")
        {
            tabbedPane.insert(0, feedsTab);
            tabbedPane.insert(1, storiesTab);
            tabbedPane.insert(2, friendsTab);
            tabbedPane.insert(3, friendRequestsTab);
            tabbedPane.insert(4, shoutBoxTab);
            tabbedPane.insert(5, extendedProfileTab);
            
            if(!theTab)
            {
                tabbedPane.activeTab = feedsTab;
            }
            else 
            {
                tabbedPane.activeTab = theTab;
            }
        }
    } 
}
