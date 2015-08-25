import bb.cascades 1.0
import bb.system 1.0
import QtQuick 1.0
import org.labsquare 1.0
import nemory.Snap2ChatAPISimple 1.0

import "../components"
import "../smaato"
import "../sheets"

Page
{
    id: page
    
    signal load();
    
    onLoad: 
    {
        loading.visible = true;
        
        var params 			= new Object();
        params.endpoint		= "/bq/bests";
        params.username 	= _snap2chatAPIData.username;
        params.timestamp 	= _snap2chatAPIData.getCurrentTimestamp();
        params.req_token 	= _snap2chatAPIData.generateRequestToken(params.timestamp, _snap2chatAPIData.auth_token);
        
        var friendUsernamesArray = new Array();
        friendUsernamesArray.push(_snap2chatAPIData.username);
        params.friend_usernames = JSON.stringify(friendUsernamesArray);
        
        snap2chatAPI.request(params);    
    }
    
    titleBar: CustomTitleBar 
    {
        id: titleBar
        settingsVisibility: true
        cameraVisibility: true
    }
    
    ScrollView 
    {
        Container 
        {
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                leftPadding: 20
                rightPadding: 20
                
                Container 
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    leftPadding: 20
                    rightPadding: 20
                    topPadding: 20
                    bottomPadding: 20
                    
                    Label 
                    {
                        text: _snap2chatAPIData.username
                        textStyle.fontWeight: FontWeight.W100
                        textStyle.fontSize: FontSize.XXLarge
                        horizontalAlignment: HorizontalAlignment.Center
                    }
                    
                    Container 
                    {
                        horizontalAlignment: HorizontalAlignment.Center
                        
                        Label 
                        {
                            id: sentSnapsCount
                            textStyle.fontWeight: FontWeight.W100
                            text: "Sent Snaps: " + _snap2chatAPIData.sentSnapsCount
                            textStyle.color: Color.DarkGray
                        }
                    }
                    
                    Container 
                    {
                        horizontalAlignment: HorizontalAlignment.Center
                        
                        Label 
                        {
                            id: receievedSnapsCount
                            textStyle.fontWeight: FontWeight.W100
                            text: "Received Snaps: " + _snap2chatAPIData.receivedSnapsCount
                            textStyle.color: Color.DarkGray
                        }
                    }
                    
                    SmaatoAds
                    {
                        id: ads
                    }
                    
                    Container 
                    {
                        horizontalAlignment: HorizontalAlignment.Center
                        
                        Label 
                        {
                            id: friendsCount
                            textStyle.fontWeight: FontWeight.W100
                            text: "Friends: " + _snap2chatAPIData.friendsDataModel.size();
                            textStyle.color: Color.DarkGray
                        }
                    }
                    
                    Container 
                    {
                        horizontalAlignment: HorizontalAlignment.Center
                        
                        Label 
                        {
                            id: score
                            textStyle.fontWeight: FontWeight.W100
                            text: "Friends: " + _snap2chatAPIData.friendsDataModel.size();
                            textStyle.color: Color.DarkGray
                        }
                    }
                    
                    Container 
                    {
                        layout: DockLayout {}
                        
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
                        leftPadding: 40
                        rightPadding: leftPadding
                        topPadding: leftPadding
                        bottomPadding: leftPadding
                        
                        Container 
                        {
                            visible: !loading.visible
                            
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            
                            Divider {}
                            
                            Label 
                            {
                                id: bestFriendsCount
                                text: "Best Friends" 
                                textStyle.fontWeight: FontWeight.W100
                                textStyle.fontSize: FontSize.XXLarge
                                horizontalAlignment: HorizontalAlignment.Center
                            }

                            ListView 
                            {
                                id: listview
                                preferredHeight: 200
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                
                                dataModel: ArrayDataModel 
                                {
                                    id: bestFriendsDataModel
                                }
                                
                                listItemComponents: 
                                [
                                    ListItemComponent 
                                    {
                                        content: Container 
                                        {
                                            layout: StackLayout 
                                            {
                                                orientation: LayoutOrientation.LeftToRight
                                            }
                                            
                                            ImageView 
                                            {
                                                imageSource: "asset:///images/snapchat/best_friend_star.png"
                                                preferredHeight: 60
                                                preferredWidth: preferredHeight
                                                verticalAlignment: VerticalAlignment.Center    
                                            }
                                            
                                            Label 
                                            {
                                                text: ListItemData
                                                verticalAlignment: VerticalAlignment.Center
                                                textStyle.color: Color.DarkGray
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                        
                        ActivityIndicator 
                        {
                            id: loading
                            visible: true
                            running: visible
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
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
            title: "Set Display Name"
            imageSource: "asset:///images/tabPencil.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: 
            {
                setDisplayNamePrompt.show();
            }
        }
    ]
    
    attachedObjects: 
    [
        SystemPrompt 
        {
            id: setDisplayNamePrompt
            title: "Set Display Name of " + _snap2chatAPIData.username
            modality: SystemUiModality.Application
            inputField.emptyText: "Display Name"
            confirmButton.label: "Set"
            confirmButton.enabled: true
            dismissAutomatically: false
            cancelButton.enabled: true
            onFinished: 
            {
                if(buttonSelection().label == "Cancel")
                {
                    setDisplayNamePrompt.cancel();
                }
                else 
                {
                    if(inputFieldTextEntry() != "")
                    {
                        var params 			= new Object();
                        params.endpoint		= "/bq/friend";
                        params.username 	= _snap2chatAPIData.username;
                        params.timestamp 	= _snap2chatAPIData.getCurrentTimestamp();
                        params.req_token 	= _snap2chatAPIData.generateRequestToken(params.timestamp, _snap2chatAPIData.auth_token);
                        
                        params.action 		= "display";
                        params.friend 		= _snap2chatAPIData.username;
                        params.display 		= inputFieldTextEntry();
                        
                        Qt.snap2chatAPI.request(params);
                        
                        _app.showToast("Successfully set " + _snap2chatAPIData.username + "'s display name to " + inputFieldTextEntry() + " :)");
                        
                        setDisplayNamePrompt.cancel();
                    }
                    else if(inputFieldTextEntry() == "")
                    {
                        _app.showDialog("Error", "Please enter a display name or cancel if you changed your mind.");
                    }
                }
            }
        },
        Snap2ChatAPISimple
        {
            id: snap2chatAPI
            
            onComplete: 
            {
                if(endpoint == "/bq/bests" && response != "0" && response != "{}")
                {
                    var responseJSON 	    = JSON.parse(response);
                    var best_friends 		= responseJSON[_snap2chatAPIData.username].best_friends;
                    bestFriendsCount.text   = "Best Friends: " + best_friends.length;
                    score.text 			    = "Score: " + responseJSON[_snap2chatAPIData.username].score
                    
                    bestFriendsDataModel.append(best_friends);
                }
                
                loading.visible = false;
            }
        }
    ]
    
    function urlify(text) 
    {
        var urlRegex = /(https?:\/\/[^\s]+)/g;
        
        return text.replace(urlRegex, function(url) 
        {
                return '<a href="' + url + '">' + url + '</a>';
        });
    }
}
