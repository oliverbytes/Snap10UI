import bb.system 1.0
import bb.cascades 1.2
import nemory.Snap2ChatAPISimple 1.0
import QtQuick 1.0
import org.labsquare 1.0

CustomListItem
{
    id: main
    highlightAppearance: HighlightAppearance.Full
    
    Container 
    {
        id: mainContainer
        
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        leftPadding: 20
        rightPadding: leftPadding
        topPadding: 50
        bottomPadding: 50
        
        preferredHeight: 160
        minHeight: preferredHeight
        
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
            
            Container 
            {
                rightPadding: 20
                
                Container 
                {
                    id: circlePhotoContainer
                    layout: DockLayout {}
                    preferredHeight: 130
                    preferredWidth: preferredHeight
                    minWidth: preferredHeight
                    minHeight: preferredHeight
                    maxWidth: preferredHeight
                    maxHeight: preferredHeight
                    
                    layoutProperties: StackLayoutProperties 
                    {
                        spaceQuota: 1
                    }
                    
                    WebImageView 
                    {
                        imageSource: ( ListItemData.story.media_type != 0 ? "asset:///images/snapchat/storyloading.png" : "file:///" + Qt.app.getHomePath() + "/files/blobs/" + ListItemData.story.media_id + ".jpg")
                        preferredHeight: 130
                        preferredWidth: preferredHeight
                        minWidth: preferredHeight
                        minHeight: preferredHeight
                        maxWidth: preferredHeight
                        maxHeight: preferredHeight
                        scalingMethod: ScalingMethod.AspectFill
                    }
                    
                    ImageView 
                    {
                        imageSource: "asset:///images/circle_cover.png"
                        preferredHeight: 130
                        preferredWidth: preferredHeight
                        minWidth: preferredHeight
                        minHeight: preferredHeight
                        maxWidth: preferredHeight
                        maxHeight: preferredHeight
                        scalingMethod: ScalingMethod.AspectFit
                    }
                }
            }
            
            Container 
            {
                verticalAlignment: VerticalAlignment.Center
                
                Container 
                {
                    Label 
                    {
                        id: theusername
                        verticalAlignment: VerticalAlignment.Center  
                        textStyle.fontSize: FontSize.Large
                        text:ListItemData.story.username
                        textStyle.fontWeight: FontWeight.W100
                    }
                }
                
                Container 
                {
                    Label 
                    {
                        id: thestatus
                        verticalAlignment: VerticalAlignment.Center
                        textStyle.fontSize: FontSize.XXSmall
                        textStyle.color: Color.Gray
                        text: 
                        {
                            var statusText = "";
                            
                            if(ListItemData.story)
                            {
                                if(Qt.snap2chatAPIData.username == ListItemData.story.username)
                                {
                                    statusText = ListItemData.story.timeago + ListItemData.story.statusText + ListItemData.story.actionStatusText + ", " + ListItemData.story_extras.view_count + " views" + ", " + ListItemData.story_extras.screenshot_count + " shots"
                                }
                                else 
                                {
                                    statusText = ListItemData.story.timeago + ListItemData.story.statusText + ListItemData.story.actionStatusText
                                }
                            }
                            
                            return statusText;
                        }
                    }
                }
            }
        }
        
        Container 
        {
            visible: 
            {
                var visibility = false;
                
                if(ListItemData.story)
                {
                    if(Qt.snap2chatAPIData.username == ListItemData.story.username)
                    {
                        visibility = true;
                    }
                }
                
                return visibility;
            }
            horizontalAlignment: HorizontalAlignment.Right
            verticalAlignment: VerticalAlignment.Center
            
            layout: StackLayout
            {
                orientation: LayoutOrientation.LeftToRight
            }
 
            ImageButton 
            {
                preferredWidth: 50
                preferredHeight: 50
                defaultImageSource: "asset:///images/delete.png"
                onClicked: 
                {
                    deletePrompt.show();
                }
            }
        }
    }
    
    gestureHandlers:
    [
        LongPressHandler 
        {
            onLongPressed: 
            {
                if(ListItemData.story.media_type == 1 || ListItemData.story.media_type == 2 || ListItemData.story.media_type == 500)
                {
                    root.ListItem.view.setFingerDown(true);
                    root.ListItem.view.playVideo(ListItemData.story);
                }
                else if(ListItemData.story.media_type == 0)
                {
                    root.ListItem.view.setFingerDown(true);
                    root.ListItem.view.setImageSource(ListItemData.story);
                }
            }
        },
        DoubleTapHandler 
        {
            onDoubleTapped: 
            {
                reply()
            }
        },
        TapHandler 
        {
            onTapped: 
            {
                if(ListItemData.story.username == Qt.snap2chatAPIData.username)
                {
                    root.ListItem.view.openViewersScreenshotters(ListItemData);
                }
            }
        }
    ]
    
    attachedObjects: 
    [
        Timer
        {
            id: storyTimer
            interval: 1000
            repeat: true
            onTriggered: 
            {
                
            }
        },
        SystemDialog
        {
            id: deletePrompt
            title: "Delete this story?"
            body: "Note: This cannot be undone."
            modality: SystemUiModality.Application
            confirmButton.label: "Delete"
            confirmButton.enabled: true
            dismissAutomatically: true
            cancelButton.label: "Cancel"
            onFinished: 
            {
                if(buttonSelection().label == "Delete")
                {
                    var params 			= new Object();
                    params.endpoint		= "/bq/delete_story";
                    params.username 	= Qt.snap2chatAPIData.username;
                    params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
                    params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                    
                    params.story_id		= ListItemData.story.id;
                    
                    Qt.snap2chatAPI.request(params);

                    Qt.snap2chatAPIData.currentStoriesOverViewModel.removeAt(root.ListItem.indexPath);
                }
            }
        }
    ]
    
    function reply()
    {
        var parameters 				= new Object();
        parameters.replyMode 		= true;
        parameters.recipient 		= ListItemData.story.username;
        parameters.postToShoutBox 	= false;
        Qt.app.openCameraTab(parameters);
    }
}