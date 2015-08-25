import bb.system 1.0
import bb.cascades 1.2
import nemory.Snap2ChatAPISimple 1.0
import QtQuick 1.0
import org.labsquare 1.0

CustomListItem
{
    highlightAppearance: HighlightAppearance.Full
    
    property int downloadedStories : 0;
    
    ListItem.onInitializedChanged: 
    {
        if(initialized)
        {
            if(Qt.app.getSetting("autoLoadStories", "false") == "true" && !ListItemData.loaded)
            {
                download();
            }
        }
    }

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
                        id: storyImage
                        defaultImage: "asset:///images/snapchat/storyloading.png"
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
                        text:ListItemData.username
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
                        text: ListItemData.timeago + ListItemData.statusText + ListItemData.actionStatusText
                    }
                }
            }
        }
        
        Container 
        {
            horizontalAlignment: HorizontalAlignment.Right
            verticalAlignment: VerticalAlignment.Center
            
            layout: StackLayout 
            {
                orientation: LayoutOrientation.LeftToRight
            }
            
            ActivityIndicator 
            {
                id: imageLoading
                visible: ListItemData.loading
                running: ListItemData.loading
                preferredHeight: 50
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
            }
            
            Container 
            {
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                
                ImageButton 
                {
                    preferredWidth: 50
                    preferredHeight: 50
                    defaultImageSource: "asset:///images/rightarrowthin.png"
                    onClicked: 
                    {
                        if(ListItemData.loaded)
                        {
                            root.ListItem.view.openStoryOverview(ListItemData);
                        }
                        else
                        {
                            Qt.app.showToast("Please let the story load first :)");
                        }
                    }
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
                if(ListItemData.loaded)
                {
                    root.ListItem.view.openStoryOverview(ListItemData);
                }
            }
        },
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
                if(!ListItemData.loaded)
                {
                    download();
                }
                else 
                {
                    root.ListItem.view.openStoryOverview(ListItemData);
                }
            }
        }
    ]
    
    attachedObjects: 
    [
        Snap2ChatAPISimple
        {
            id: snap2chatAPI
            
            onCompleteStory:
            {
                var fileLocation 	= resultObject.passedParams.fileLocation;
                var id				= resultObject.passedParams.id;
                var media_key		= resultObject.passedParams.media_key;
                var media_iv		= resultObject.passedParams.media_iv;
                var media_type		= resultObject.passedParams.media_type;
                var endpoint		= resultObject.passedParams.endpoint;
                var time			= resultObject.passedParams.time;
                
                Qt.app.writeLogToFile("resultObject.json", JSON.stringify(resultObject));
                
                if(resultObject.httpcode == "200")
                {
                    downloadedStories++;
                    
                    if(!resultObject.passedParams.done)
                    {
                        Qt.app.decrypt(fileLocation, fileLocation, "CBC", media_key, media_iv);
                        
                        if(media_type == 500) // ZIPPED
                        {
                            Qt.app.extractZippedVideo(id);
                        }
                    }
                    
                    var storiesLength = 0;
                    
                    if(ListItemData.stories)
                    {
                        storiesLength = ListItemData.stories.length;
                    }
                    
                    if(downloadedStories == storiesLength)
                    {
                        var item 				= ListItemData;
                        item.loading 			= false;
                        item.loaded 			= true;
                        item.load 				= false;
                        item.statusText 		= "";
                        item.actionStatusText 	= " - Tap to expand " + storiesLength + " " + (storiesLength > 1 ? "stories" : "story");
                        Qt.snap2chatAPIData.storiesDataModel.updateItem(root.ListItem.indexPath, item);
                        
                        storyImage.imageSource = getImageInStories();;
                    }
                }
                else 
                {
                    Qt.app.flurryLogError("ERROR DOWNLOAD STORY: " + resultObject.httpcode + ", " + resultObject.response);
                    
                    var item 		= ListItemData;
                    item.loading 	= false;
                    item.loaded 	= false;
                    item.load 		= true;
                    item.statusText 		= "Failed";
                    item.actionStatusText 	= " - Tap to retry";
                    Qt.snap2chatAPIData.storiesDataModel.updateItem(root.ListItem.indexPath, item);
                }
            }
        }
    ]
    
    function reply()
    {
        var parameters 				= new Object();
        parameters.replyMode 		= true;
        parameters.recipient 		= ListItemData.username;
        parameters.postToShoutBox 	= false;
        Qt.app.openCameraTab(parameters);
    }
    
    function download()
    {
        Qt.app.flurryLogEvent("DOWNLOAD STORY");
        
        downloadedStories = 0;
        
        var item 				= ListItemData;
        item.load 				= false;
        item.loading 			= true;
        item.statusText 		= " - Loading...";
        item.actionStatusText 	= "";
        Qt.snap2chatAPIData.storiesDataModel.updateItem(root.ListItem.indexPath, item);

        for(var i = 0; i < ListItemData.stories.length; i++)
        {
            var story = ListItemData.stories[i].story;
            
            var params 			= new Object();
            params.endpoint		= "/bq/story_blob";
            params.username 	= Qt.snap2chatAPIData.username;
            params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
            params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
            
            params.id 			= story.media_id;
            params.media_iv 	= story.media_iv;
            params.media_key 	= story.media_key;
            params.media_type 	= story.media_type;
            params.time 		= story.time;
            
            var extension = "";
            
            if(story.media_type == "0")
            {
                extension = ".jpg";
            }
            else if(story.media_type == "1" || story.media_type == "2")
            {
                extension = ".mp4";
            }
            else if(story.media_type == "500")
            {
                extension = ".zip";
            }
            
            params.fileLocation = "data/files/blobs/" + params.id + extension;
            
            snap2chatAPI.downloadStory(params);
        }
    }
    
    function getImageInStories()
    {
        var image = "asset:///images/snapchat/storyloading.png";
        
        for(var i = 0; i < ListItemData.stories.length; i++)
        {
            var story = ListItemData.stories[i].story;
            
            if(story.media_type == 0)
            {
                image = "file:///" + Qt.app.getHomePath() + "/files/blobs/" + story.media_id + ".jpg";
            }
        }
        
        return image;
    }
}