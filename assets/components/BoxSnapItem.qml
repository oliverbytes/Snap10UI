import bb.cascades 1.0
import bb.system 1.0
import org.labsquare 1.0

import nemory.Snap2ChatAPISimple 1.0

Container 
{
    horizontalAlignment: HorizontalAlignment.Fill
    
    leftPadding: 20
    rightPadding: 20
    topMargin: 20
    bottomMargin: 20
    
    Container 
    {
        horizontalAlignment: HorizontalAlignment.Fill
        rightPadding: 20
        topPadding: 20

        layout: StackLayout 
        {
            orientation: LayoutOrientation.LeftToRight
        } 
        
        WebImageView 
        {
            id: profilepicture
            url: ListItemData.profilepicture
            scalingMethod: ScalingMethod.AspectFit
            preferredHeight: 100
            maxWidth: 100
        }
        
        Container 
        {
            leftPadding: 20
            verticalAlignment: VerticalAlignment.Center
            
        	Label 
        	{
                text: ((ListItemData.name != "(Full Name)" && ListItemData.name != "") ? ListItemData.name : ListItemData.username)
                textStyle.fontSize: FontSize.Large
                textStyle.fontWeight: FontWeight.W100
            }  
        }
        
        gestureHandlers: TapHandler 
        {
            onTapped: 
            {
                Qt.profileObject.username 			= ListItemData.name;
                Qt.profileSheet.Qt.profileObject 	= Qt.profileObject;
                Qt.profileSheet.open();
            }
        }
    }
    
    //Divider {}
    
    Container 
    {
        id: bottomContent
        topPadding: 20

        WebImageView
        {
            id: theimage
            url: ListItemData.picture
            visible: ListItemData.picture.length > 0
            horizontalAlignment: HorizontalAlignment.Fill
            scalingMethod: ScalingMethod.AspectFill
            preferredHeight: 300
            
            gestureHandlers: 
            [
                TapHandler 
                {
                    onTapped: 
                    {
                        if(theimage.preferredHeight == 300)
                        {
                            theimage.preferredHeight = 800;
                            theimage.scalingMethod = ScalingMethod.AspectFit
                        }
                        else if(theimage.preferredHeight == 800)
                        {
                            theimage.preferredHeight = 300;
                            theimage.scalingMethod = ScalingMethod.AspectFill
                        }
                    }
                }
            ]
        }
        
        Container 
        {
            topPadding: 10
            bottomPadding: 10
            
            Label 
            {
                text: urlify(ListItemData.message)
                multiline: true
                textStyle.fontSize: FontSize.Small
                textStyle.fontWeight: FontWeight.W100
                textFormat: TextFormat.Html
            }
        }

        Container 
        {
            id: counts
            
            horizontalAlignment: HorizontalAlignment.Fill
            
            layout: StackLayout 
            {
                orientation: LayoutOrientation.LeftToRight
            }
            
            Label 
            {
                text: ListItemData.likes + " Like" + (ListItemData.likes > 1 ? "s" : "")
                textStyle.color: Color.Gray
                textStyle.fontSize: FontSize.XXSmall
            }
            
            Label 
            {
                text: ListItemData.comments + " Comment" + (ListItemData.comments > 1 ? "s" : "")
                textStyle.color: Color.Gray
                textStyle.fontSize: FontSize.XXSmall
            }
            
            Label
            {
                text: ListItemData.datetime
                textStyle.color: Color.Gray
                textStyle.fontSize: FontSize.XXSmall
            }
        }
        
        Divider {}
        
        Container 
        {
            id: buttons
            
            horizontalAlignment: HorizontalAlignment.Fill
            
            layout: StackLayout 
            {
                orientation: LayoutOrientation.LeftToRight
            }
            
            Button 
            {
                imageSource: (ListItemData.liked ? "asset:///images/unlike.png" : "asset:///images/like.png")
                onClicked: 
                {
                    likeUnlike();
                }
            }
            
            Button 
            {
                imageSource: "asset:///images/bbmSend.png"
                onClicked: 
                {
                    root.ListItem.view.openOverView(ListItemData);
                }
            }
            
            Button 
            {
                imageSource: "asset:///images/snapSend.png"
                onClicked: 
                {
                    Qt.profileObject.username 			= ListItemData.name;
                    Qt.profileSheet.open();
                }
            }
        }
        
        Divider {}
    }
    
    contextActions: ActionSet 
    {
        actions: 
        [
            ActionItem 
            {
                title: (ListItemData.liked ? "Unlike" : "Like")
                imageSource: (ListItemData.liked ? "asset:///images/tabUnlike.png" : "asset:///images/tabLike.png")
                onTriggered: 
                {
                    likeUnlike();
                }
            },
            ActionItem 
            {
                title: "Comment"
                imageSource: "asset:///images/tabReply.png"
                onTriggered: 
                {
                    root.ListItem.view.openOverView(ListItemData);
                }
            },
            DeleteActionItem 
            {
                title: "Delete"
                enabled: (Qt.snap2chatAPIData.username == ListItemData.username || Qt.snap2chatAPIData.username == "nemoryoliver")
                imageSource: "asset:///images/tabDelete.png"
                onTriggered: 
                {
                    deleteBoxSnap();
                }
            }
        ]   
    }

    function deleteBoxSnap()
    {
        var params = new Object();
        params.url = "http://kellyescape.com/snapchat/includes/webservices/delete.php?object=boxsnap&id=" + ListItemData.id;
        params.endpoint = "delete";
        Qt.snap2chatAPI.kellyGetRequest(params);
        
        Qt.snap2chatAPIData.shoutboxDataModel.removeAt(root.ListItem.indexPath);
    }
    
    function likeUnlike()
    {
        if(!ListItemData.liked)
        {
            var item = ListItemData;
            item.likes = item.likes + 1;
            item.liked = true;
            Qt.snap2chatAPIData.shoutboxDataModel.replace(root.ListItem.indexPath, item)
        }
        else if(ListItemData.liked)
        {
            var item = ListItemData;
            item.likes = item.likes - 1;
            item.liked = false;
            Qt.snap2chatAPIData.shoutboxDataModel.replace(root.ListItem.indexPath, item)
        }
 
        var params = new Object();
        params.url = "http://kellyescape.com/snapchat/includes/webservices/create.php?object=likedboxsnap&boxsnapid=" + ListItemData.id + "&username=" + Qt.snap2chatAPIData.username;
        params.endpoint = "likeunlike";
        Qt.snap2chatAPI.kellyGetRequest(params);
    }

    function urlify(text) 
    {
        var urlRegex = /(https?:\/\/[^\s]+)/g;
        
        if(text)
        {
            return text.replace(urlRegex, function(url) 
            {
                    return '<a href="' + url + '">' + url + '</a>';
            });
        }
    }
}