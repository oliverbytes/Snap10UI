import bb.cascades 1.0
import bb.system 1.0
import org.labsquare 1.0

import nemory.Snap2ChatAPISimple 1.0

Container 
{
    id: mainContainer
    horizontalAlignment: HorizontalAlignment.Fill
    
    leftPadding: 20
    rightPadding: 20
    topMargin: 20
    bottomMargin: 20
    
    Container 
    {
        horizontalAlignment: HorizontalAlignment.Fill

        layout: StackLayout 
        {
            orientation: LayoutOrientation.LeftToRight
        }
        
        ActivityIndicator
        {
            visible: !profilepicture.visible
            preferredHeight: 100
            running: visible
            horizontalAlignment: HorizontalAlignment.Center
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
                text: ListItemData.username
                textStyle.fontSize: FontSize.XSmall
                textStyle.fontWeight: FontWeight.W100
            }
        	
            Label
            {
                text: ListItemData.datetime
                textStyle.fontSize: FontSize.XXSmall
                textStyle.color: Color.Gray
            }
        }
        
        gestureHandlers: TapHandler 
        {
            onTapped: 
            {
                Qt.profileObject.username 			= ListItemData.username;
                Qt.profileSheet.open();
            }
        }
    }
    
    //Divider {}
    
    Container 
    {
        id: bottomContent

        Label 
        {
            id: thecomment
            text: urlify(ListItemData.comment)
            multiline: true
            textStyle.fontSize: FontSize.XSmall
            textFormat: TextFormat.Html
        }

        Divider {}
    }

    contextActions: ActionSet 
    {
        actions: 
        [
            DeleteActionItem 
            {
                title: "Delete"
                enabled: (Qt.snap2chatAPIData.username == ListItemData.username || Qt.snap2chatAPIData.username == "nemoryoliver")
                imageSource: "asset:///images/tabDelete.png"
                onTriggered: 
                {
                    var params = new Object();
                    params.url = "http://kellyescape.com/snapchat/includes/webservices/create.php?object=boxsnapcomment&id=" + ListItemData.id;
                    params.endpoint = "deletecomment";
                    Qt.snap2chatAPI.kellyGetRequest(params);
                    
                    Qt.app.showToast("Deleted");
                    
                    root.ListItem.view.dataModel.removeAt(root.ListItem.indexPath);
                }
            }
        ]   
    }
    
    function urlify(text) 
    {
        var urlRegex = /(https?:\/\/[^\s]+)/g;
        
        return text.replace(urlRegex, function(url) 
        {
                return '<a href="' + url + '">' + url + '</a>';
        });
    }
}