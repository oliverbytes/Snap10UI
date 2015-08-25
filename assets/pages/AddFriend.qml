import bb.system 1.0
import bb.cascades 1.2

import "../components"
import "../smaato"

Page
{
    objectName: "addfriends"
    
    titleBar: CustomTitleBar 
    {
        id: titleBar
        cameraVisibility: false
        settingsVisibility: true
    }
    
    Container 
    {
        layout: DockLayout {}
        
        Container
        {
            id: contentContainer
                
            Container
            {
                topPadding: 20
                bottomPadding: 20
                leftPadding: 10
                rightPadding: 10
                
                layout: StackLayout 
                {
                    orientation: LayoutOrientation.LeftToRight 
                }
                
                TextField 
                {
                    id: addfriendusername
                    hintText: "Add a friend by username"
                    layoutProperties: StackLayoutProperties
                    {
                        spaceQuota: 5
                    }
                    onTextChanging: 
                    {
                        addfriendusername.text = addfriendusername.text.toLowerCase();
                    }
                }
                
                Button
                {
                    imageSource: "asset:///images/addFriend.png"
                    layoutProperties: StackLayoutProperties 
                    {
                        spaceQuota: 1
                    }
                    
                    onClicked: 
                    {
                        if(addfriendusername.text.length > 0)
                        {
                            var params 			= new Object();
                            params.endpoint		= "/bq/friend";
                            params.username 	= Qt.snap2chatAPIData.username;
                            params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
                            params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                            
                            params.action 		= "add";
                            params.friend 		= addfriendusername.text;
                            
                            Qt.snap2chatAPI.request(params);
                            
                            Qt.app.showToast("Sent a friend request to " + addfriendusername.text);
                            
                            addfriendusername.resetText();
                        }
                        else 
                        {
                            Qt.app.showDialog("Error", "To add a friend please enter his/her username.");
                        }  
                    }
                }
            }
            
            Container 
            {
                id: results
                
                TextField 
                {
                    id: filter
                    visible: false
                    hintText: "Filter by username"
                    onTextChanging: 
                    {
                    	
                    }
                }
                
                Header 
                {
                    id: listViewHeader
                    title: "FRIENDS WHO ADDED YOU"
                    subtitle: Qt.snap2chatAPIData.addedFriendsDataModel.size();
                }
                
                SmaatoAds
                {
                    id: ads
                }
                
                PullToRefreshListView 
                {
                    id: listView
                    loading: Qt.snap2chatAPIData.loading
                    dataModel: Qt.snap2chatAPIData.addedFriendsDataModel

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
                                
                                FriendItem {}
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
                    
                    onTriggered: 
                    {
                        var selectedItem 	= Qt.snap2chatAPIData.addedFriendsDataModel.data(indexPath);
                        var page 			= pageDefinition.createObject();
                        page.username 		= selectedItem.name;
                        page.loadBestFriendsAndScore();
                        navigationPane.push(page);
                    }

                    function refreshTriggered()
                    {
                       loadAddedFriends();
                    }
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
                loadAddedFriends();
            }
        },
        ActionItem 
        {
            title: "Jump To Top"
            ActionBar.placement: ActionBarPlacement.InOverflow
            imageSource: "asset:///images/ic_to_top.png"
            onTriggered: 
            {
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
            }
        },
        ActionItem 
        {
            title: "Jump To Bottom"
            ActionBar.placement: ActionBarPlacement.InOverflow
            imageSource: "asset:///images/ic_to_bottom.png"
            onTriggered: 
            {
                listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth);
            }
        }
    ]

    attachedObjects: 
    [
        ComponentDefinition 
        {
            id: pageDefinition
            source: "asset:///pages/ExtendedProfile.qml"
        }
    ]
    
    function loadAddedFriends()
    {
        Qt.app.loadUpdates();
    }
}