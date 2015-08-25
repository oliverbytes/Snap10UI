import bb.cascades 1.0
import nemory.Snap2ChatAPISimple 1.0

import "../smaato"

Dialog
{
    id: dialog
    property string username;
    
    onOpened: 
    {
        load();
    }
    
    function load()
    {
        loading.visible = true;
        bestFriendsDataModel.clear();
    
        var params 			= new Object();
        params.endpoint		= "/bq/bests";
        params.username 	= _snap2chatAPIData.username;
        params.timestamp 	= _snap2chatAPIData.getCurrentTimestamp();
        params.req_token 	= _snap2chatAPIData.generateRequestToken(params.timestamp, _snap2chatAPIData.auth_token);
        
        var friendUsernamesArray = new Array();
        friendUsernamesArray.push(username);
        params.friend_usernames = JSON.stringify(friendUsernamesArray);
        
        snap2chatAPI.request(params);
    }
    
    Container 
    {
        layout: DockLayout {}
        
        background: Color.create("#dd000000");
        
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
            
            Label 
            {
                id: score
                text: "Score: "
                textStyle.fontSize: FontSize.XXLarge
                textStyle.fontWeight: FontWeight.W100
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                textStyle.color: Color.create("#ffffff")
            }
            
            SmaatoAds
            {
                id: ads
            }
            
            ListView 
            {
                id: listview
                preferredHeight: 500
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
                            horizontalAlignment: HorizontalAlignment.Center
                            
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
                                textStyle.color: Color.create("#ffffff")
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
        
        ImageButton 
        {
            defaultImageSource: "asset:///images/snapchat/aa_snap_preview_x.png"
            preferredHeight: 100
            preferredWidth: 100
            horizontalAlignment: HorizontalAlignment.Right
            verticalAlignment: VerticalAlignment.Top
            
            onClicked: 
            {
                dialog.username = "";
                loading.visible = true;
                dialog.close();
            }
        }
    }
    
    attachedObjects: 
    [
        Snap2ChatAPISimple
        {
            id: snap2chatAPI
            
            onComplete: 
            {
                console.log("RESPONSE: " + response);
                
                if(endpoint == "/bq/bests" && response != "0" && response != "{}")
                {
                    var responseJSON 	= JSON.parse(response);
                    score.text 			= "Score: " + responseJSON[username].score;
                    var best_friends 	= responseJSON[username].best_friends;
                    
                    console.log("BEST FRIENDS" + best_friends);
                    
                    bestFriendsDataModel.append(best_friends);
                }
                
                loading.visible = false;
            }
        }
    ]
}