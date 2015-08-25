import bb.cascades 1.0
import bb.system 1.0

Container 
{
    horizontalAlignment: HorizontalAlignment.Fill
    bottomPadding: 5.0
    topPadding: 5.0
    leftPadding: 20
    rightPadding: 20

    background:
    {
        var theColor;
        
        if(Qt.app.getSetting("pureDarkListView", "true") == "false")
        {
            theColor = (root.ListItem.selected ? Color.create("#3BC7FF") : (Qt.app.getSetting("colortheme", "bright") == "bright" ? Color.create("#ffffff") : Color.create("#2B2B2B")));
        }
        else 
        {
            theColor = Color.Transparent;
        }
        
        return theColor;
    }
    
    Container 
    {
        horizontalAlignment: HorizontalAlignment.Fill

        layout: DockLayout{ }

        Label 
        {
            text: ListItemData.sn
            textStyle.fontSize: FontSize.Large
            verticalAlignment: VerticalAlignment.Center
        }

        ImageButton 
        {
            id: addFriendButton
            preferredHeight: 100
            minHeight: 100
            minWidth: 100
            preferredWidth: 100
            defaultImageSource: (ListItemData.confirmed ? "asset:///images/addAsFriendCheck.png" : "asset:///images/addAsFriend.png")
            horizontalAlignment: HorizontalAlignment.Right
            onClicked:
            {
                addFriend();
            }
        }
        
        rightPadding: 29
    }
    
    gestureHandlers:
    [
        DoubleTapHandler 
        {
            onDoubleTapped:
            {
                reply();
            }
        },
        TapHandler 
        {
            onTapped: 
            {
                Qt.profileObject.username 			= ListItemData.sn;
                Qt.profileSheet.open();
            }
        }
    ]
    
    contextActions: 
    [
        ActionSet 
        {
            id: contextActionSet
            title: "Friend Request from " + ListItemData.sn
            
            ActionItem 
            {
                title: "Confirm Friend"
                imageSource: "asset:///images/tabAddFriend.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: 
                {
                    addFriend();
                }
            }
            ActionItem 
            {
                title: "Block"
                imageSource: "asset:///images/tabClose.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: 
                {
                    var item = ListItemData;
                    
                    var params 			= new Object();
                    params.endpoint		= "/bq/friend";
                    params.username 	= Qt.snap2chatAPIData.username;
                    params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
                    params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                    
                    params.action 		= "block";
                    params.friend 		= ListItemData.sn;
                    
                    Qt.snap2chatAPI.request(params);
                    
                    item.type = 2;
                    
                    Qt.snap2chatAPIData.friendRequestsDataModel.updateItem(root.ListItem.indexPath, item);
                }
            }
            ActionItem 
            {
                title: "Send Snap"
                imageSource: "asset:///images/snapchat/aa_snap_preview_send.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: 
                {
                    reply();
                }
            }
        }
    ]
    
    function addFriend()
    {
        var params 			= new Object();
        params.endpoint		= "/bq/friend";
        params.username 	= Qt.snap2chatAPIData.username;
        params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
        params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
        
        params.action 		= "add";
        params.friend 		= ListItemData.sn;
        
        Qt.snap2chatAPI.request(params);
        
        var item = ListItemData;
        item.confirmed = true;
        Qt.snap2chatAPIData.friendRequestsDataModel.updateItem(root.ListItem.indexPath, item);
    }
    
    function reply()
    {
        var parameters 				= new Object();
        parameters.replyMode 		= true;
        parameters.recipient 		= ListItemData.sn;
        parameters.postToShoutBox 	= false;
        Qt.app.openCameraTab(parameters);
    }
}