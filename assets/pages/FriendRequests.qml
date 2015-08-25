import bb.cascades 1.0
import bb.system 1.0
import nemory.MyContactPicker 1.0

import "../components"
import "../smaato"
import bb.cascades 1.2

NavigationPane 
{
    id: navigationPane
    
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
                
                property alias invokeSocialInvitesInteract: invokeSocialInvites
                property alias contactPickerInteract: contactPicker
                property alias proceedPromptInteract: proceedPrompt
                
                attachedObjects: 
                [
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
                                    
                                    Qt.app.flurryLogEvent("INVITED VIA SMS");
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
            addFriendVisibility: true
            cameraVisibility: true
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
                    title: "FRIEND REQUESTS"
                    subtitle: Qt.snap2chatAPIData.friendRequestsDataModel.size();
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
                    dataModel: Qt.snap2chatAPIData.friendRequestsDataModel
                    
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
                                    text: ListItemData
                                    horizontalAlignment: HorizontalAlignment.Center
                                    textStyle.fontSize: FontSize.Small
                                    textStyle.color: Color.create("#0f9f9a")
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
                                
                                FriendRequestItem {}
                            }
                        }
                    ]
                    
                    attachedObjects: 
                    [
                        ListScrollStateHandler 
                        {
                            id: scrollStateHandler
                        }
                    ]
                    
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
                title: "Add Friend"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/titleAddFriend.png"
                onTriggered: 
                {
                    addFriendPage.open();
                }
            },
            ActionItem 
            {
                title: "Invite via Social"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/titleAddFriend.png"
                onTriggered:
                {
                    theAttachedObjects.invokeSocialInvitesInteract.trigger("bb.action.SHARE");
                    
                    Qt.app.flurryLogEvent("INVITED VIA SOCIAL");
                }
            },
            ActionItem 
            {
                title: "Invite via SMS"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/titleAddFriend.png"
                onTriggered: 
                {
                    theAttachedObjects.proceedPromptInteract.show();
                }
            }
			,
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