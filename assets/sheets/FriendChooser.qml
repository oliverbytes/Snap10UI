import bb.cascades 1.2

import "../components/"
import "../smaato"
import QtQuick 1.0

Sheet
{
    id: sheet
    
    property string fileLocation : "";
    property string selectedName : "";
    property bool replyMode : false;
    property string recipient : "";
    property bool addFriend : false;
    property string therecipients : "";
    property int snapTimer : 3;
    property variant editSnapSheet;
    property bool addToStory : false;
    
    signal playVideo();
    
    onOpened: 
    {
        selectRecipient();
        
        _snap2chatAPIData.isInFriendChooser = true;
    }
    
    onClosed: 
    {
        selectedName = "";
        listView.clearSelection();
        selectAll.title = "Select All";
        listView.multiSelectHandler.active = false;
        
        replyMode = false;
        recipient = "";
        
        listView.multiSelectHandler.active = false;
        listView.multiSelectHandler.status = "None selected";
        page.actionBarVisibility = ChromeVisibility.Visible;
        
        _snap2chatAPIData.isInFriendChooser = false;
    }
    
    Page
    {
        id: page
        
        titleBar: CustomTitleBar 
        {
            closeVisibility: true
            addFriendVisibility: true
            
            onCloseButtonClicked: 
            {
                playVideo();
                close();
            }
            
            onAddFriendButtonClicked: 
            {
                var page = addFriendPage.createObject();
                navigationPane.push(page);
            }
        }
        
        Container 
        {
            layout: DockLayout {}
            
            Container 
            {
                id: results

                Header 
                {
                    id: listViewHeader
                    title: "Friends"
                    subtitle: _snap2chatAPIData.friendsDataModel.size();
                }
                
                SmaatoAds
                {
                    id: ads
                }
                
                ListView 
                {
                    id: listView
                    dataModel: _snap2chatAPIData.friendsDataModel

                    listItemComponents: 
                    [
                        ListItemComponent 
                        {
                            type: "header"
                            
                            Header 
                            {
                                title:
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
                                    showMyStory: true
                                }
                            }
                        }
                    ]
                    
                    onTriggered: 
                    {
                        clearSelection();
                        
                        select(indexPath, true);
 
                        var selectedItem = _snap2chatAPIData.friendsDataModel.data(indexPath);
                        therecipients = selectedItem.name;
                        
                        multiSelectHandler.active = true;
                    }

                    multiSelectHandler 
                    {
                        status: "None Selected"
                        actions: 
                        [
                            ActionItem 
                            {
                                title: "Send to Selected"
                                imageSource: "asset:///images/snapchat/send_to_icon_enabled.png"
                                onTriggered: 
                                {
                                    sendSnap(therecipients);
                                    listView.multiSelectHandler.active = false;
                                    listView.multiSelectHandler.status = "None selected";
                                }
                            }
                        ]
                    }
                    
                    attachedObjects: 
                    [
                        ListScrollStateHandler 
                        {
                            id: scrollStateHandler
                        }
                    ]
                    
                    onSelectionChanged: 
                    {
                        if (selectionList().length > 1) 
                        {
                            multiSelectHandler.status = selectionList().length +" friends selected";
                        } 
                        else if (selectionList().length == 1) 
                        {
                            multiSelectHandler.status = "1 friend selected";
                        } 
                        else 
                        {
                            multiSelectHandler.active = false;
                            multiSelectHandler.status = "None selected";
                        }
                        
                        therecipients = "";
                        
                        for(var i = 0; i < selectionList().length; i++)
                        {
                            if(i == 0)
                            {
                                therecipients += dataModel.data(selectionList()[i]).name + "";
                            }
                            else
                            {
                            	therecipients += "," + dataModel.data(selectionList()[i]).name;
                            }
                        }
                    }
                }
            }
            
            Container 
            {
                id: loadingBox
                visible: _snap2chatAPIData.loading
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
                imageSource: "asset:///images/snapchat/aa_action_bar_stories_refresh.png"
                onTriggered: 
                {
                    _app.loadUpdates();
                }
            },
            MultiSelectActionItem 
            {
                title: "Select Multiple"
                ActionBar.placement: ActionBarPlacement.OnBar
                multiSelectHandler: listView.multiSelectHandler
            },
            ActionItem 
            {
                id: selectAll
                title: "Select All"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/ic_select_all.png"
                onTriggered: 
                {
                    if(_app.purchasedAds)
                    {
                        if(title == "Select All")
                        {
                            selectedName = "";
                            listView.selectAll();
                            title = "Deselect All";
                            listView.multiSelectHandler.active = true;
                        }
                        else 
                        {
                            selectedName = "";
                            listView.clearSelection();
                            title = "Select All";
                            listView.multiSelectHandler.active = false;
                        }
                    }
                    else 
                    {
                        Qt.toastX.pop("Send to all friends in one click. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                        Qt.proSheet.open();
                    }
                }
            }
        ]
    }

    function sendSnap(thisrecipients)
    {
        var snap = new Object();
        
        var storyOnly 			= false;
        
        if(Qt.app.contains(thisrecipients, "My Story"))
        {
            addToStory = true;
            
            if(thisrecipients == "My Story")
            {
                storyOnly 	= true;
            }
        }
        
        snap.storyOnly 		= storyOnly;
        snap.addToStory 	= addToStory;
        
        if(snap.addToStory)
        {
            snap.statusImage 		= "asset:///images/snapchat/story.png";
        }
        else 
        {
            snap.statusImage 		= (isPhoto() ? "asset:///images/snapchat/aa_feed_icon_sent_photo.png" : "asset:///images/snapchat/aa_feed_icon_sent_video.png");
        }
        
        thisrecipients = thisrecipients.replace("undefined,", "");
        thisrecipients = thisrecipients.replace(",undefined", "");
        thisrecipients = thisrecipients.replace("undefined", "");
        
        thisrecipients = thisrecipients.replace(",My Story", "");
        thisrecipients = thisrecipients.replace("My Story,", "");
        thisrecipients = thisrecipients.replace("My Story", "");
        
        thisrecipients = thisrecipients.replace(",,", ",");
        
        var recipientsArray = thisrecipients.split(",");
        
        if(recipientsArray.length > 200)
        {
            recipientsArray = recipientsArray.slice(0, 200);    
        }
        
        var uniqueArray = recipientsArray.filter(function(elem, pos) 
        {
                return recipientsArray.indexOf(elem) == pos;
        }); 
        
        thisrecipients = uniqueArray.join();
        
        thisrecipients = thisrecipients.replace("undefined,", "");
        thisrecipients = thisrecipients.replace(",undefined", "");
        thisrecipients = thisrecipients.replace("undefined", "");
        
        thisrecipients = thisrecipients.replace(",,", ",");
        
        console.log("THIS RECIPIENTS: " + JSON.stringify(thisrecipients));
        
        Qt.app.writeLogToFile(thisrecipients);
        
        Qt.app.encrypt(fileLocation, fileLocation);
        
        snap.id 				= "temporary-" + _app.tempID;
        snap.media_id 			= 0;
        snap.media_type 		= (isPhoto() ? "0" : "1");
        snap.time 				= snapTimer;
        snap.sender 			= _snap2chatAPIData.username;
        snap.recipient 			= thisrecipients;
        snap.rp 				= thisrecipients;
        snap.status 			= 100;
        snap.screenshot_count 	= 0;
        snap.sent 				= 0;
        snap.opened 			= 0;
        snap.loaded 			= false;
        snap.timeleft 			= 0;
        snap.timeago 			= "Moments ago";
        snap.statusText 		= (addToStory ? " - Sending & Posting..." : " - Sending...");
        snap.actionStatusText 	= "";
        snap.displayname 		= snap.recipient;
        snap.uploadNow 			= true;
        snap.loading 			= true;
        snap.zipped 			= 0;
        snap.fileLocation 		= fileLocation;

        _snap2chatAPIData.addToSendQueue(snap);
        
        editSnapSheet.resetAll();
        editSnapSheet.cameraPage.close();
        editSnapSheet.close();
        close();
        
        Qt.uploadingSnapsSheet.open();
        closeTimer.start();
    }
    
    function isPhoto()
    {
        var isphoto = false;
        
        if(_app.contains(fileLocation, ".jpg") || _app.contains(fileLocation, ".png"))
        {
            isphoto = true;
        }
        
        return isphoto;
    }
    
    function selectRecipient()
    {
        for (var i = 0; i < _snap2chatAPIData.friendsDataModel.size(); i++)
        {
            var indexPath = new Array();
            indexPath[0] = i; // 2nd List Item Component
            
            var listItem = _snap2chatAPIData.friendsDataModel.data(indexPath);
            
            var recipientFound = false;
            
            if(listItem)
            {
                if(replyMode && recipient.length > 0)
                {
                    if(listItem.name == recipient)
                    {
                        recipientFound = true;
                        therecipients = listItem.name;
                        
                        listView.clearSelection();
                        listView.select(indexPath, true);
                        listView.scrollToItem(indexPath, ScrollAnimation.Smooth);
                        listView.multiSelectHandler.active = true;
                    }
                }
            }
            
            if(replyMode && !recipientFound)
            {
                addFriend = true;
                listView.multiSelectHandler.active = true;
                listView.multiSelectHandler.status = recipient;
                therecipients = recipient;
            }
        }
    }
    
    attachedObjects: 
    [
        ComponentDefinition 
        {
            id: addFriendPage
            source: "asset:///pages/AddFriend.qml"
        },
        Timer
        {
            id: closeTimer
            repeat: false
            interval: 20
            onTriggered:
            {
                Qt.uploadingSnapsSheet.close();
            }
        }
    ]
}