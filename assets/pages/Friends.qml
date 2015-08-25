import bb.system 1.0
import nemory.MyContactPicker 1.0
import bb.cascades 1.2
import nemory.Snap2ChatAPISimple 1.0

import "../components"
import "../dialogs"
import "../smaato"

NavigationPane 
{
    id: navigationPane
    property string therecipient : "";
    
    property variant theAttachedObjects
    
    function createObjects()
    {
        if (!navigationPane.theAttachedObjects)
        {
            navigationPane.theAttachedObjects = myAttachedObjects.createObject(navigationPane);
        }
    }
    
    function destroyObjects()
    {
        if (navigationPane.theAttachedObjects)
        {
            navigationPane.theAttachedObjects.destroy();
        }
    }
    
    onCreationCompleted: 
    {
        createObjects();
    }
    
    attachedObjects: 
    [
        ComponentDefinition 
        {
            id: myAttachedObjects
            
            Container 
            {
                id: objects
                
                property alias friendOptionsDialogInteract: friendOptionsDialog
                property alias invokeSocialInvitesInteract: invokeSocialInvites
                property alias contactPickerInteract: contactPicker
                property alias proceedPromptInteract: proceedPrompt
                property alias snap2chatAPIInteract: snap2chatAPISimple
                property alias findFriendsDialogInteract: findFriendsDialog
                
                attachedObjects: 
                [
                    Dialog 
                    {
                        id: friendOptionsDialog
                        
                        Container 
                        {
                            id: friendOptions
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            background: Color.create("#dd000000");
                            layout: DockLayout {}
                            
                            Container 
                            {
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                leftPadding: 50
                                rightPadding: 50
                                
                                Label 
                                {
                                    text: "Hide Blocked and Deleted Friends"
                                    textStyle.color: Color.White;
                                }
                                
                                DropDown
                                {
                                    title: "Show / Hide"
                                    selectedIndex: Qt.app.getSetting("hideBlockedDeletedFriendsIndex", "1")
                                    options: 
                                    [
                                        Option 
                                        {
                                            text: "Hide"
                                            value: "hide"
                                        },
                                        Option 
                                        {
                                            text: "Show"
                                            value: "show"
                                        }
                                    ]
                                    
                                    onSelectedValueChanged: 
                                    {
                                        Qt.app.setSetting("hideBlockedDeletedFriends", selectedValue);
                                    }
                                    
                                    onSelectedIndexChanged: 
                                    {
                                        Qt.app.setSetting("hideBlockedDeletedFriendsIndex", selectedIndex);
                                    }
                                }
                            }
                            
                            Container 
                            {
                                id: closeFriendOptions
                                leftPadding: 20
                                rightPadding: 20
                                bottomPadding: 20
                                topPadding: 20
                                horizontalAlignment: HorizontalAlignment.Right
                                verticalAlignment: VerticalAlignment.Top
                                
                                ImageButton 
                                {
                                    defaultImageSource: "asset:///images/snapchat/aa_snap_preview_x.png"
                                    preferredHeight: 100
                                    preferredWidth: 100
                                    onClicked: 
                                    {
                                        friendOptionsDialog.close();
                                    }
                                }
                            }
                        }
                    },
                    Invocation 
                    {
                        id: invokeSocialInvites
                        query.mimeType: "text/plain"
                        query.invokeActionId: "bb.action.SHARE"
                        query.invokerIncluded: true
                        query.data: 
                        {
                            var message = "Add me on Snapchat! Username: " + Qt.snap2chatAPIData.username + " via #snap2chat";
                            return message;
                        }
                    },
                    MyContactPicker 
                    {
                        id: contactPicker
                        onComplete: 
                        {
                            for(var i = 0; i < contactIds.length; i++)
                            {
                                var message = "Add me on Snapchat! Username: " + Qt.snap2chatAPIData.username + ", for BlackBerry 10 http://appworld.blackberry.com/webstore/content/47649895, for iOS and Android: http://snapchat.com/download?ref=a";
                                var phoneNumber = Qt.app.getContactPhoneNumber(contactIds[i]);
                                
                                if(phoneNumber.length > 0)
                                {
                                    Qt.app.sendSMS(phoneNumber, message);
                                }
                            }
                        }
                    },
                    SystemDialog
                    {
                        id: proceedPrompt
                        title: "Attention"
                        body: "Note: this will automatically send SMS to the contacts that you will be selecting. It will populate your BlackBerry Hub but they will be automatically deleted in the hub once they're sent."
                        modality: SystemUiModality.Application
                        confirmButton.label: "Proceed"
                        confirmButton.enabled: true
                        dismissAutomatically: true
                        cancelButton.label: "Cancel"
                        onFinished: 
                        {
                            if(buttonSelection().label == "Proceed")
                            {
                                contactPicker.open();
                            }
                        }
                    },
                    Snap2ChatAPISimple 
                    {
                        id: snap2chatAPISimple
                        onComplete: 
                        {
                            console.log("RESPONSE:" + response);
                            
                            Qt.progressDialog.cancel();
                            
                            if(response != "error")
                            {
                                var responseJSON = JSON.parse(response);
                                
                                Qt.app.showToast(responseJSON.message);
                            }
                            else 
                            {
                                Qt.app.showDialog("Attention", "Sorry we had problems connecting you. Please try again later.");
                            }
                        }
                    },
                    Dialog 
                    {
                        id: findFriendsDialog
                        
                        Container 
                        {
                            id: findFriends
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            background: Color.create("#dd000000");
                            layout: DockLayout {}
                            
                            Container 
                            {
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                leftPadding: 50
                                rightPadding: 50
                                
                                Label 
                                {
                                    text: "Country Code"
                                    textStyle.color: Color.White;
                                }
                                
                                DropDown 
                                {
                                    id: countryCode
                                    title: "Country Code"
                                    
                                    attachedObjects: 
                                    [
                                        ComponentDefinition 
                                        {
                                            id: optionControlDefinition
                                            Option {}
                                        }
                                    ]
                                    
                                    onCreationCompleted: 
                                    {
//                                        var countryCodesJSONString = Globals.countryCodes;
//                                        
//                                        var countryCodesJSON = JSON.parse(countryCodesJSONString);
//                                        
//                                        for (var i = 0; i < countryCodesJSON.length; i ++) 
//                                        {
//                                            var option 		= optionControlDefinition.createObject();
//                                            option.text 	= countryCodesJSON[i].name;
//                                            option.value 	= countryCodesJSON[i].alpha2;
//                                            countryCode.add(option);
//                                        }
                                    }
                                }
                                
                                Label 
                                {
                                    text: "Scan Contact Phone Numbers"
                                    textStyle.color: Color.White;
                                }
                                
                                DropDown
                                {
                                    id: scanUpTo
                                    title: "Scan up to"
                                    selectedIndex: 0
                                    options: 
                                    [
                                        Option 
                                        {
                                            text: "All"
                                            value: 99999
                                        },
                                        Option 
                                        {
                                            text: "10"
                                            value: 10
                                        },
                                        Option 
                                        {
                                            text: "30"
                                            value: 30
                                        },
                                        Option 
                                        {
                                            text: "60"
                                            value: 60
                                        },
                                        Option 
                                        {
                                            text: "120"
                                            value: 120
                                        },
                                        Option 
                                        {
                                            text: "300"
                                            value: 300
                                        },
                                        Option 
                                        {
                                            text: "500"
                                            value: 500
                                        }
                                    ]
                                    
                                    onSelectedValueChanged: 
                                    {
                                        Qt.app.setSetting("friendVisibility", selectedValue);
                                    }
                                    
                                    onSelectedIndexChanged: 
                                    {
                                        Qt.app.setSetting("friendVisibilityIndex", selectedIndex);
                                    }
                                }
                                
                                Divider {}
                                
                                Button 
                                {
                                    text: "Find Friends"
                                    horizontalAlignment: HorizontalAlignment.Fill
                                    onClicked: 
                                    {
                                        if(Qt.snap2chatAPIData.mobileNumber != "")
                                        {
                                            Qt.app.flurryLogEvent("FIND FRIENDS");
                                            
                                            Qt.progressDialog.body = "We're scanning your contacts. This may take long depending on the size of your contacts. Please wait....";
                                            Qt.progressDialog.show();
                                            
                                            var contactsJSON = Qt.app.getContacts(scanUpTo.selectedValue);
                                            
                                            Qt.progressDialog.cancel();
                                            
                                            if(contactsJSON != "")
                                            {
                                                Qt.progressDialog.body = "We're now contacting the server to check if your contacts are snapchatters. Please wait.....";
                                                Qt.progressDialog.show();
                                                
                                                var timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
                                                var req_token 	= Qt.snap2chatAPIData.generateRequestToken(timestamp, Qt.snap2chatAPIData.auth_token);
                                                
                                                snap2chatAPI.findFriends(contactsJSON, countryCode.selectedValue, timestamp, req_token);
                                            }
                                            else 
                                            {
                                                Qt.app.flurryLogEvent("FIND FRIENDS NO CONTACTS");
                                                
                                                Qt.app.showDialog("Attention", "We have not found any contacts in your device. Or maybe your permission to access contacts are disallowed.");
                                            }
                                        }
                                        else 
                                        {
                                            Qt.app.flurryLogEvent("FIND FRIENDS UNVERIFIED");
                                            
                                            Qt.app.showDialog("Attention", "Before you can find friends you need to verify your phone number first.");
                                        }
                                    }
                                }
                                
                                Divider {}
                                
                                Label 
                                {
                                    text: "Note: your phone number must be verified in order you can find friends."
                                    multiline: true
                                    textStyle.color: Color.LightGray
                                    textStyle.fontSize: FontSize.Small
                                }
                            }
                            
                            Container 
                            {
                                id: closeFindFriends
                                leftPadding: 20
                                rightPadding: 20
                                bottomPadding: 20
                                topPadding: 20
                                horizontalAlignment: HorizontalAlignment.Right
                                verticalAlignment: VerticalAlignment.Top
                                
                                ImageButton 
                                {
                                    defaultImageSource: "asset:///images/snapchat/aa_snap_preview_x.png"
                                    preferredHeight: 100
                                    preferredWidth: 100
                                    onClicked: 
                                    {
                                        findFriendsDialog.close();
                                    }
                                }
                            }
                        }
                    }
                ]
            }
        },
        ComponentDefinition 
        {
            id: addFriendPage
            source: "asset:///pages/AddFriend.qml"
            
            function open()
            {
                var page = addFriendPage.createObject();
                navigationPane.push(page);
            }
        },
        ComponentDefinition 
        {
            id: pageDefinition
            source: "asset:///pages/ExtendedProfile.qml"
        }
    ]

    Page
    {
        id: page
        titleBar: CustomTitleBar 
        {
            id: titleBar
            cameraVisibility: true
            addFriendVisibility: true
            
            onAddFriendButtonClicked: 
            {
                addFriendPage.open();
            }
        }
        
        Container 
        {
            layout: DockLayout {}
            
            ImageView 
            {
                visible: false
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                imageSource: "asset:///images/mybackground.jpg"
                opacity: 0.5
                scalingMethod: ScalingMethod.AspectFill
            }

            Container 
            {
                id: results

                Header
                {
                    id: listViewHeader
                    title: "FRIENDS"
                    subtitle: Qt.snap2chatAPIData.friendsDataModel.size();
                }
                
                SmaatoAds
                {
                    id: ads
                }

                TextField 
                {
                    id: filter
                    visible: false
                    hintText: "Filter by Username"
                    onTextChanging: 
                    {
                        
                    }
                }

                PullToRefreshListView 
                {
                    id: listView
                    loading: Qt.snap2chatAPIData.loading
                    dataModel: Qt.snap2chatAPIData.friendsDataModel
                    
                    listItemComponents: 
                    [
                        ListItemComponent 
                        {
                            type: "header"
                            
                            Container 
                            {
                                topPadding: 5
                                bottomPadding: topPadding
                                horizontalAlignment: HorizontalAlignment.Fill
                                
                                Label 
                                {
                                    text: 
                                    {
                                        var friendTypeText = "";
                                        
                                        if(ListItemData == "0")
                                        {
                                            friendTypeText = "My Story";
                                        }
                                        else if(ListItemData == "1")
                                        {
                                            friendTypeText = "Best Friends";
                                        }
                                        else if(ListItemData == "2")
                                        {
                                            friendTypeText = "Recent Friends";
                                        }
                                        else if(ListItemData == "3")
                                        {
                                            friendTypeText = "Friends";
                                        }
                                        else 
                                        {
                                            friendTypeText = ListItemData;
                                        }
                                        
                                        return friendTypeText;
                                    }    
                                    
                                    horizontalAlignment: HorizontalAlignment.Center
                                    textStyle.fontSize: FontSize.Default
                                    textStyle.color: Color.create("#0f9f9a")
                                    textStyle.fontWeight: FontWeight.W100
                                }
                                
                                Divider {}
                            }
                        },
                        ListItemComponent 
                        {
                            type: "item"
                            
                            CustomListItem 
                            {
                                id: root
                                highlightAppearance: HighlightAppearance.Full
                                
                                FriendItem 
                                {
                                    showMyStory: false
                                }
                            }
                        }
                    ]
                    
                    onTriggered: 
                    {
                        var item = dataModel.data(indexPath);
                        bestFriendsDialog.username = item.name;
                        bestFriendsDialog.open();
                    }
                    
                    attachedObjects: 
                    [
                        ListScrollStateHandler 
                        {
                            id: scrollStateHandler
                        },
                        UserInfo 
                        {
                            id: bestFriendsDialog    
                        }
                    ]
                    
                    function loadBestFriends(username)
                    {
                        bestFriendsDialog.username = username;
                        bestFriendsDialog.open();
                    }

                    function refreshTriggered()
                    {
                       loadFriends();
                    }
                }
            }
            
            Container 
            {
                visible: (!Qt.snap2chatAPIData.loading && listViewHeader.subtitle == 0)
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                
                Label 
                {
                    text: (Qt.snap2chatAPIData.loading ? "Loading..." : "No entries to show. :(")
                    textStyle.fontSize: FontSize.Small
                }
            }
            
            Container 
            {
                id: loadingBox
                visible: Qt.snap2chatAPIData.loading
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                touchPropagationMode: TouchPropagationMode.None
                layout: DockLayout {}
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Bottom
                    leftPadding: 20
                    bottomPadding: 20
                    
                    Label 
                    {
                        text: "Loading..."
                        visible: false
                        textStyle.fontSize: FontSize.Small
                    }
                }
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Bottom
                    rightPadding: 20
                    bottomPadding: 10
                    
                    ActivityIndicator 
                    {
                        visible: true
                        running: visible
                        preferredHeight: 60
                    }
                }
            }
            
            Container 
            {
                id: jumpButtons
                opacity: 0.5
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                rightPadding: 20
                visible: scrollStateHandler.scrolling && Qt.app.getSetting("floatingButtons", "true") == "true"
                
                ImageButton
                {
                    defaultImageSource: "asset:///images/jumpToTop.png" 
                    verticalAlignment: VerticalAlignment.Center
                    onClicked: 
                    {
                        listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth)
                    }
                }
                
                ImageButton
                {
                    defaultImageSource: "asset:///images/jumpToBottom.png" 
                    verticalAlignment: VerticalAlignment.Center
                    onClicked: 
                    {
                        listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth)
                    }
                }
            }
        }
        
        actions: 
        [
            ActionItem 
            {
                title: "Refresh"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/refresh.png"
                onTriggered: 
                {
                    loadFriends();
                }
            },
            ActionItem 
            {
                title: "Add Friends"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/titleAddFriend.png"
                onTriggered: 
                {
                    addFriendPage.open();
                }
            },
//            ActionItem 
//            {
//                title: "Find Friends"
//                ActionBar.placement: ActionBarPlacement.OnBar
//                imageSource: "asset:///images/tabSearch.png"
//                onTriggered: 
//                {
//                    theAttachedObjects.findFriendsDialogInteract.open();
//                }
//            },
            ActionItem 
            {
                title: "Invite via Social"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/tabFacebook.png"
                onTriggered:
                {
                    theAttachedObjects.invokeSocialInvitesInteract.query.data = "Add me on Snapchat! Username: " + _snap2chatAPIData.username + " via #snap2chat http://appworld.blackberry.com/webstore/content/47649895/";
                    theAttachedObjects.invokeSocialInvitesInteract.query.updateQuery();
                    theAttachedObjects.invokeSocialInvitesInteract.trigger("bb.action.SHARE");
                }
            },
//            ActionItem 
//            {
//                title: "Invite via SMS"
//                ActionBar.placement: ActionBarPlacement.OnBar
//                imageSource: "asset:///images/tabBBMSend.png"
//                onTriggered: 
//                {
//                   theAttachedObjects.proceedPromptInteract.show();
//                }
//            },
            ActionItem 
            {
                title: "Options"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/tabAutomation.png"
                onTriggered:
                {
                   theAttachedObjects.friendOptionsDialogInteract.open();
                }
            },
            ActionItem 
            {
                title: "Jump To Top"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/ic_to_top.png"
                onTriggered: 
                {
                    listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                }
            },
            ActionItem 
            {
                title: "Jump To Bottom"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/ic_to_bottom.png"
                onTriggered: 
                {
                    listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth);
                }
            }
        ]
    }

    function loadFriends()
    {
        Qt.app.loadUpdates();
    }
}