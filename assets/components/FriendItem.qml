import bb.cascades 1.0
import bb.system 1.0
import QtQuick 1.0

Container 
{
    property bool showMyStory : false;
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    layout: DockLayout { }
    
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
        verticalAlignment: VerticalAlignment.Center
        
        layout: StackLayout
        {
            orientation: LayoutOrientation.LeftToRight
        }
        
        ImageView 
        {
            verticalAlignment: VerticalAlignment.Center
            visible: (ListItemData.type == "mystory")
            preferredHeight: 70
            scalingMethod: ScalingMethod.AspectFit
            imageSource: "asset:///images/storyicon.png"
        }
        
        ImageView 
        {
            verticalAlignment: VerticalAlignment.Center
            visible: (ListItemData.type == "recentfriend")
            preferredHeight: 70
            scalingMethod: ScalingMethod.AspectFit
            imageSource: "asset:///images/recentfriend.png"
        }
        
        ImageView 
        {
            verticalAlignment: VerticalAlignment.Center
            visible: (ListItemData.type == "bestfriend")
            preferredHeight: 70
            scalingMethod: ScalingMethod.AspectFit
            imageSource: "asset:///images/bestfriendicon.png"
        }
        
        ImageView
        {
            visible: ListItemData.type != "bestfriend" && ListItemData.type != "recentfriend"
            verticalAlignment: VerticalAlignment.Center
            imageSource: getFriendshipStatusImage();
            preferredHeight: 70
            scalingMethod: ScalingMethod.AspectFit
        }
        
        Container 
        {
            Container 
            {
                Label 
                {
                    id: mainName
                    text:
                    {
                        var thenametodisplay = "";
                        
                        if(ListItemData.display)
                        {
                            if(ListItemData.display.length > 0)
                            {
                                thenametodisplay = ListItemData.display;
                            }
                            else 
                            {
                                thenametodisplay = ListItemData.name;
                            }
                        }
                        else 
                        {
                            thenametodisplay = ListItemData.name;
                        }
                        
                        if(ListItemData.name == Qt.snap2chatAPIData.username)
                        {
                            thenametodisplay = thenametodisplay + " (me)";
                        }
                        
                        return thenametodisplay;
                    }
                    
                    textStyle.fontSize: FontSize.Large
                    textStyle.color: (root.ListItem.selected ? Color.White : (Qt.app.getSetting("colortheme", "bright") == "bright" ? Color.Black : Color.White))
                    textStyle.fontWeight: FontWeight.W100
                }
            }
            
            Container 
            {
                Label 
                {
                    id: theUsername
                    textStyle.fontSize: FontSize.XXSmall
                    textStyle.color: Color.Gray
                    text: ListItemData.name
                }
            }
        }
    }
    
    Container 
    {
        visible: (ListItemData.type != "mystory")
        horizontalAlignment: HorizontalAlignment.Right
        verticalAlignment: VerticalAlignment.Center
        rightPadding: 20
        
        ImageButton 
        {
            preferredWidth: 50
            preferredHeight: 50
            defaultImageSource: "asset:///images/rightarrowthin.png"
            onClicked:
            {
                if(ListItemData.type != "mystory")
                {
                    reply();
                }
            }
        }
    }
    
    gestureHandlers:
    [
        DoubleTapHandler 
        {
            onDoubleTapped:
            {
                reply();
            }
        }
    ]
    
    contextActions: 
    [
        ActionSet 
        {
            id: contextActionSet
            title: "My Friend " + ListItemData.name
            
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
            ActionItem 
            {
                title: "Unblock"
                imageSource: "asset:///images/tabSave.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: 
                {
                    var params 			= new Object();
                    params.endpoint		= "/bq/friend";
                    params.username 	= Qt.snap2chatAPIData.username;
                    params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
                    params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                    
                    params.action 		= "unblock";
                    params.friend 		= ListItemData.name;
                    
                    Qt.snap2chatAPI.request(params);
                    
                    var item = ListItemData;
                    item.type = 0;
                    Qt.snap2chatAPIData.friendsDataModel.updateItem(root.ListItem.indexPath, item);
                }
            }
            ActionItem 
            {
                title: "Block"
                imageSource: "asset:///images/tabClose.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: 
                {
                    var params 			= new Object();
                    params.endpoint		= "/bq/friend";
                    params.username 	= Qt.snap2chatAPIData.username;
                    params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
                    params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                    
                    params.action 		= "block";
                    params.friend 		= ListItemData.name;
                    
                    Qt.snap2chatAPI.request(params);
                    
                    var item = ListItemData;
                    item.type = 2;
                    Qt.snap2chatAPIData.friendsDataModel.updateItem(root.ListItem.indexPath, item);
                }
            }
            DeleteActionItem 
            {
                title: "Delete"
                enabled: getFriendshipStatusText() != "Deleted"
                imageSource: "asset:///images/tabDelete.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: 
                {
                    var params 			= new Object();
                    params.endpoint		= "/bq/friend";
                    params.username 	= Qt.snap2chatAPIData.username;
                    params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
                    params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                    
                    params.action 		= "delete";
                    params.friend 		= ListItemData.name;
                    
                    Qt.snap2chatAPI.request(params);
                    
                    var item = ListItemData;
                    item.type = 3;
                    Qt.snap2chatAPIData.friendsDataModel.updateItem(root.ListItem.indexPath, item);
                }
            }
        }
    ]
    
    attachedObjects: 
    [
        SystemPrompt 
        {
            id: setDisplayNamePrompt
            title: "Set Display Name"
            modality: SystemUiModality.Application
            inputField.emptyText: "Display Name"
            confirmButton.label: "Set"
            confirmButton.enabled: true
            dismissAutomatically: false
            cancelButton.label: "Cancel"
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
                        params.username 	= Qt.snap2chatAPIData.username;
                        params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
                        params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                        
                        params.action 		= "display";
                        params.friend 		= ListItemData.name;
                        params.display 		= inputFieldTextEntry();
                        
                        Qt.snap2chatAPI.request(params);
                        
                        setDisplayNamePrompt.cancel();
                        
                        var item = ListItemData;
                        item.display = inputFieldTextEntry();
                        Qt.snap2chatAPIData.friendsDataModel.updateItem(root.ListItem.indexPath, item);
                    }
                    else if(inputFieldTextEntry() == "")
                    {
                        Qt.app.showDialog("Error", "Please enter a display name or cancel if you changed your mind.");
                    }
                }
            }
        }
    ]
    
    function reply()
    {
        var parameters 				= new Object();
        parameters.replyMode 		= true;
        parameters.recipient 		= ListItemData.name;
        parameters.postToShoutBox 	= false;
        Qt.app.openCameraTab(parameters);
    }
        
    function getFriendshipStatusImage()
    {
        var image = "";
        
        if(ListItemData.type == 0)
        {
            image = (ListItemData.name == Qt.snap2chatAPIData.username ? "asset:///images/youicon.png" : "asset:///images/friendIcon.png");
        }
        else if(ListItemData.type == 1)
        {
            image = "asset:///images/clock.png";
        }
        else if(ListItemData.type == 2)
        {
            image = "asset:///images/stop.png";
        }
        else if(ListItemData.type == 3)
        {
            image = "asset:///images/delete.png";
        }
        
        return image;
    }
    
    function getFriendshipStatusText()
    {
        var text = "";
        
        if(ListItemData.type == 0)
        {
            text = "Friend";
        }
        else if(ListItemData.type == 1)
        {
            text = "Unconfirmed";
        }
        else if(ListItemData.type == 2)
        {
            text = "Blocked";
        }
        else if(ListItemData.type == 3)
        {
            text = "Deleted";
        }
        else if(ListItemData.type == "bestfriend")
        {
            text = "Best Friend";
        }
        else if(ListItemData.type == "recentfriend")
        {
            text = "Recent Friend";
        }
        
        return text;
    }
}