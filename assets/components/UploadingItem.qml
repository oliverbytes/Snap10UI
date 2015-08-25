import bb.system 1.0
import QtQuick 1.0
import bb.cascades 1.2
import nemory.Snap2ChatAPISimple 1.0

CustomListItem
{
    highlightAppearance: HighlightAppearance.Full

    ListItem.onInitializedChanged:
    {
        if(initialized)
        {
            if(ListItemData)
            {
                if(ListItemData.uploadNow)
                {
                    upload();
                }
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
                id: statImage
                rightPadding: 20
                layout: DockLayout {}
                verticalAlignment: VerticalAlignment.Center
                
                ImageView
                {
                    id: theimage
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    imageSource: ListItemData.statusImage;
                    preferredHeight: 70
                    minHeight: preferredHeight
                    minWidth: preferredHeight
                    scalingMethod: ScalingMethod.AspectFit
                    
                    animations: 
                    [
                        FadeTransition 
                        {
                            id: fadeAnimation
                            duration: 1000
                            repeatCount: 99999999
                            toOpacity: 1.0
                            fromOpacity: 0.3
                            easingCurve: StockCurve.Linear
                            
                            onStopped: 
                            {
                                theimage.resetOpacity();
                            }
                        },
                        ScaleTransition 
                        {
                            id: scaleAnimation
                            duration: 1000
                            repeatCount: 99999999
                            toX: 1.0
                            toY: 1.0
                            fromX: 0.7
                            fromY: 0.7
                            easingCurve: StockCurve.BounceInOut
                            
                            onStopped: 
                            {
                                theimage.resetScale();
                            }
                        }
                    ]
                }
                
                Label 
                {
                    visible: snapTimer.running
                    text: ListItemData.timeleft
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    textStyle.color: Color.White
                    textStyle.fontSize: FontSize.Medium
                }
            }
            
            Container 
            {
                Container 
                {
                    Label 
                    {
                        id: theusername
                        verticalAlignment: VerticalAlignment.Center  
                        textStyle.fontSize: FontSize.Large
                        text: ListItemData.recipient
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
                verticalAlignment: VerticalAlignment.Center
            }
            
            ImageButton 
            {
                preferredWidth: 50
                preferredHeight: 50
                defaultImageSource: "asset:///images/delete.png"
                onClicked: 
                {
                    if(ListItemData.status != 200)
                    {
                        deletePrompt.show();
                    }
                    else 
                    {
                        deleteSentPrompt.show();
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
                if(ListItemData.media_type == 0)
                {
                    root.ListItem.view.setImageSource(ListItemData);
                    root.ListItem.view.setFingerDown(true);
                }
                else
                {
                    root.ListItem.view.playVideo(ListItemData);
                    root.ListItem.view.setFingerDown(true);
                }
                
                if(!snapTimer.running && ListItemData.timeleft > 0)
                {
                    if(Qt.app.getSetting("replayFeature", "false") == "false")
                    {
                        setLabelTimer(ListItemData.timeleft);
                        snapTimer.start();
                    }
                    else 
                    {
                        if(ListItemData.maxreplayresee <= 1)
                        {
                            setLabelTimer(ListItemData.timeleft);
                            snapTimer.start();
                        }
                        else 
                        {
                            var item = ListItemData;
                            item.maxreplayresee = ListItemData.maxreplayresee - 1;
                            root.ListItem.view.dataModel.replace(root.ListItem.indexPath, item);
                        }
                    }
                }
            }
        },
        TapHandler 
        {
            onTapped: 
            {
                if(ListItemData.status == 300)
                {
                    upload();
                }
            }
        }
    ]
    
    attachedObjects: 
    [
        Timer 
        {
            id: snapTimer
            interval: 1000
            repeat: true
            onTriggered: 
            {
                setLabelTimer(ListItemData.timeleft - 1);
                
                if((ListItemData.timeleft - 1) <= 0)
                { 
                    root.ListItem.view.setFingerDown(false);
                    
                    if(ListItemData.media_type == 1 || ListItemData.media_type == 2)
                    {
                        root.ListItem.view.stopVideo();
                    }
                    
                    var item 			= ListItemData;
                    item.beingviewed 	= false;
                    item.loaded 		= false;
                    item.loading 		= false;
                    Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);
                    
                    setStatus(2); // OPENED
                    
                    snapTimer.stop();
                }
                
                var item = ListItemData;
                item.timeleft = ListItemData.timeleft - 1;
                Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);
            }
        },
        Snap2ChatAPISimple 
        {
            id: snap2chatAPISimple

            onComplete: 
            {
                if(endpoint == "/ph/send")
                {
                    if(httpcode == "200")
                    {
                        var item 				= ListItemData;
                        item.sentSnap			= true;
                        Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);
                        
                        if(ListItemData.addToStory || ListItemData.storyOnly)
                        {
                            if(ListItemData.postedStory)
                            {
                                var item 				= ListItemData;
                                item.loading 			= false;
                                item.statusText 		= " - Posted & Sent";
                                item.statusImage 		= "asset:///images/snapchat/feedStorySent.png";
                                item.actionStatusText 	= " - Press and hold to preview";
                                item.status				= 200;
                                Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);    
          
                                var item2 				= ListItemData;
                                item2.loading 			= false;
                                item2.statusText 		= " - Posted & Sent";
                                item2.actionStatusText 	= "";
                                item2.status			= 200;
                                Qt.snap2chatAPIData.addToSendQueueFeeds(item2);
                                
                                Qt.app.decrypt(ListItemData.fileLocation, ListItemData.fileLocation, "ECB", Qt.app.getEncryptionKey(), "");
                                
                                fadeAnimation.stop();
                                scaleAnimation.stop();
                                
                                Qt.snap2chatAPIData.uploadingSize = Qt.snap2chatAPIData.uploadingSize - 1;
                            }
                        }
                        else 
                        {
                            var item 				= ListItemData;
                            item.loading 			= false;
                            item.statusText 		= " - Sent";
                            item.actionStatusText 	= " - Press and hold to preview";
                            item.status				= 200;
                            Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);
                            
                            var item2 				= ListItemData;
                            item2.loading 			= false;
                            item2.statusText 		= " - Sent";
                            item2.actionStatusText 	= "";
                            item2.status			= 200;
                            Qt.snap2chatAPIData.addToSendQueueFeeds(item2);
                            
                            Qt.app.decrypt(ListItemData.fileLocation, ListItemData.fileLocation, "ECB", Qt.app.getEncryptionKey(), "");
                            
                            fadeAnimation.stop();
                            scaleAnimation.stop();
                            
                            Qt.snap2chatAPIData.uploadingSize = Qt.snap2chatAPIData.uploadingSize - 1;
                        }
                    }
                    else 
                    {
                        Qt.app.flurryLogError("ERROR SEND SNAP: " + httpcode + ", " + response);
                        
                        var item = ListItemData;
                        item.loading = false;
                        item.loaded = false;
                        item.uploadNow = false;
                        item.status = 300;
                        item.statusText 		= " - Failed";
                        item.actionStatusText 	= " - Tap to retry";
                        Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);
                        
                        fadeAnimation.stop();
                        scaleAnimation.stop();
                        
                        console.log("ERROR SEND SNAP: " + httpcode + ", " + response);
                    }
                }
                if(endpoint == "/bq/post_story")
                {
                    if(httpcode == "202")
                    {
                        var item 				= ListItemData;
                        item.postedStory		= true;
                        Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);
                        
                        if(ListItemData.storyOnly)
                        {
                            var item 				= ListItemData;
                            item.loading 			= false;
                            item.statusText 		= " - Posted & Sent";
                            item.statusImage 		= "asset:///images/snapchat/feedStorySent.png";
                            item.actionStatusText 	= " - Press and hold to preview";
                            item.status				= 200;
                            Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);
                            
                            var item2 				= ListItemData;
                            item2.loading 			= false;
                            item2.statusText 		= " - Posted & Sent";
                            item2.statusImage 		= "asset:///images/snapchat/feedStorySent.png";
                            item2.actionStatusText 	= "";
                            item2.status			= 200;
                            Qt.snap2chatAPIData.addToSendQueueFeeds(item2);
                            
                            Qt.app.decrypt(ListItemData.fileLocation, ListItemData.fileLocation, "ECB", Qt.app.getEncryptionKey(), "");
                            
                            fadeAnimation.stop();
                            scaleAnimation.stop();
                            
                            Qt.snap2chatAPIData.uploadingSize = Qt.snap2chatAPIData.uploadingSize - 1;
                        }
                        else 
                        {
                            if(ListItemData.sentSnap)
                            {
                                var item 				= ListItemData;
                                item.loading 			= false;
                                item.statusText 		= " - Posted & Sent";
                                item.statusImage 		= "asset:///images/snapchat/feedStorySent.png";
                                item.actionStatusText 	= " - Press and hold to preview";
                                item.status				= 200;
                                Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);
                                
                                var item2 				= ListItemData;
                                item2.loading 			= false;
                                item2.statusText 		= " - Posted & Sent";
                                item2.statusImage 		= "asset:///images/snapchat/feedStorySent.png";
                                item2.actionStatusText 	= "";
                                item2.status			= 200;
                                Qt.snap2chatAPIData.addToSendQueueFeeds(item2);
                                
                                Qt.app.decrypt(ListItemData.fileLocation, ListItemData.fileLocation, "ECB", Qt.app.getEncryptionKey(), "");
                                
                                fadeAnimation.stop();
                                scaleAnimation.stop();
                                
                                Qt.snap2chatAPIData.uploadingSize = Qt.snap2chatAPIData.uploadingSize - 1;
                            }
                        }
                    }
                    else 
                    {
                        Qt.app.flurryLogError("ERROR POST STORY: " + httpcode + ", " + response);
                        
                        var item = ListItemData;
                        item.loading = false;
                        item.loaded = false;
                        item.uploadNow = false;
                        item.status = 300;
                        item.statusText 		= " - Failed";
                        item.actionStatusText 	= " - Tap to retry";
                        Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);
                        
                        fadeAnimation.stop();
                        scaleAnimation.stop();
                        
                        console.log("ERROR POST STORY: " + httpcode + ", " + response);
                    }
                }
                else if(endpoint == "/ph/upload")
                {
                    if(httpcode == "200")
                    {
                        if(ListItemData.storyOnly)
                        {
                            postUploadedStory();
                        }
                        else 
                        {
                            sendUploadedSnap();
                            
                            if(ListItemData.addToStory || ListItemData.storyOnly)
                            {
                                postUploadedStory(); 
                            }
                        }
                    }
                    else 
                    {
                        Qt.app.flurryLogError("ERROR UPLOAD SNAP: " + httpcode + ", " + response);
                        
                        var item = ListItemData;
                        item.loading = false;
                        item.loaded = false;
                        item.uploadNow = false;
                        item.status = 300;
                        item.statusText 		= " - Failed";
                        item.actionStatusText 	= " - Tap to retry";
                        Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);
                        
                        fadeAnimation.stop();
                        scaleAnimation.stop();
                        
                        console.log("ERROR UPLOAD SNAP: " + httpcode + ", " + response);
                    }
                }
                
                if(httpcode != "200" && httpcode != "202")
                {
                    Qt.app.flurryLogError("GENERAL ERROR UPLOADING ITEM: " + httpcode + ", " + response);
                    
                    fadeAnimation.stop();
                    scaleAnimation.stop();
                    
                    Qt.snap2chatAPIData.uploadingSize = Qt.snap2chatAPIData.uploadingSize - 1;
                }
            }
        },
        SystemDialog
        {
            id: deletePrompt
            title: "Cancel this uploading snap?"
            body: "Note: This cannot be undone."
            modality: SystemUiModality.Application
            confirmButton.label: "No"
            confirmButton.enabled: true
            dismissAutomatically: true
            cancelButton.label: "Cancel"
            onFinished: 
            {
                if(buttonSelection().label == "Cancel")
                {
                    Qt.snap2chatAPIData.uploadingDataModel.removeAt(root.ListItem.indexPath);
                    Qt.snap2chatAPIData.uploadingSize = Qt.snap2chatAPIData.uploadingSize - 1;
                }
            }
        },
        SystemDialog
        {
            id: deleteSentPrompt
            title: "Remove this sent snap?"
            body: "Don't worry, it's already sent, this will not delete the actual snap you sent to the recipient."
            modality: SystemUiModality.Application
            confirmButton.label: "Remove"
            confirmButton.enabled: true
            dismissAutomatically: true
            cancelButton.label: "Cancel"
            onFinished: 
            {
                if(buttonSelection().label == "Remove")
                {
                    Qt.snap2chatAPIData.uploadingDataModel.removeAt(root.ListItem.indexPath);
                    Qt.app.deletePhoto(ListItemData.fileLocation);
                }
            }
        }
    ]

    function setLabelTimer(timeleft)
    {
        if(ListItemData.beingviewed)
        {
            root.ListItem.view.setLabelTimer(timeleft); 
        }
    }
    
    function sendUploadedSnap()
    {
        Qt.app.flurryLogEvent("SEND SNAP");
        
        var params 			= new Object();
        params.endpoint		= "/ph/send";
        params.username 	= Qt.snap2chatAPIData.username;
        params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
        params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
        
        params.recipient 	= ListItemData.recipient;
        params.media_id 	= ListItemData.upload_media_id;
        params.time 		= ListItemData.time;
        params.zipped 		= ListItemData.zipped;
        
        snap2chatAPISimple.request(params);
    }
    
    function postUploadedStory()
    {
        Qt.app.flurryLogEvent("POST STORY");
        
        var params 			= new Object();
        params.endpoint		= "/bq/post_story";
        params.username 	= Qt.snap2chatAPIData.username;
        params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
        params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
        
        params.media_id 	= ListItemData.upload_media_id;
        params.client_id 	= params.media_id;
        params.time 		= ListItemData.time;
        params.zipped 		= ListItemData.zipped;
        params.type 		= ListItemData.media_type;
        
        snap2chatAPISimple.request(params);
    }
    
    function upload()
    {
        console.log("UPLOAD: ADD TO STORY: " + ListItemData.addToStory + ", STORY ONLY: " + ListItemData.storyOnly)
        
        Qt.app.flurryLogEvent("UPLOAD SNAP");
        
        fadeAnimation.play();
        scaleAnimation.play();
        
        setStatus(100); // SENDING
        
        var item 		= ListItemData;
        item.loading 	= true;
        item.send 		= false;
        item.uploadNow 	= false;
        item.statusText = (item.addToStory ? " - Sending & Posting..." : " - Sending...");
        item.actionStatusText = "";
        Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);

        var item 				= ListItemData;
        item.upload_media_id 	= Qt.snap2chatAPIData.username.toUpperCase() + "~" + Qt.snap2chatAPIData.generateUUID().replace("{", "").replace("}", "").toUpperCase();
        Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);

        var params 			= new Object();
        params.endpoint		= "/ph/upload";
        params.username 	= Qt.snap2chatAPIData.username;
        params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
        params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
        
        params.type 		= ListItemData.media_type;
        params.media_id 	= ListItemData.upload_media_id;
        params.fileLocation = ListItemData.fileLocation;
        
        snap2chatAPISimple.upload(params);
    }

    function setStatus(status)
    {
        var item = ListItemData;
        item.status = status;
        
        if(status == 2)
        {
            if(ListItemData.media_type == 0)
            {
                item.statusImage = "asset:///images/snapchat/aa_feed_icon_opened_photo.png";
            }
            else if(ListItemData.media_type == 1 || ListItemData.media_type == 2 || ListItemData.media_type == 500)
            {
                item.statusImage = "asset:///images/snapchat/aa_feed_icon_opened_video.png";
            }
            
            item.statusText 		= " - Opened";
            item.actionStatusText 	= "";
        }

        Qt.snap2chatAPIData.uploadingDataModel.replace(root.ListItem.indexPath, item);
    }
}