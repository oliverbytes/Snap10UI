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
            if(ListItemData.id)
            {
                if(Qt.app.getSetting("autoLoadSnaps", "false") == "true" && ListItemData.loadable && !ListItemData.loaded)
                {
                    download();
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
                        text: ListItemData.displayname
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
                verticalAlignment: VerticalAlignment.Center
            }
            
            ImageButton 
            {
                preferredWidth: 50
                preferredHeight: 50
                defaultImageSource: "asset:///images/rightarrowthin.png"
                onClicked: 
                {
                    reply();
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
                //console.log("INDEX PATH: " + JSON.parse(root.ListItem.indexPath) + " - " + ListItemData.id + " - " + ListItemData.timerrunning);
                
                if(ListItemData.loaded && ListItemData.recipient == Qt.snap2chatAPIData.username)
                {
                    if(ListItemData.timeleft > 0)
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
                    }
                    
                    if(!snapTimer.running && ListItemData.timeleft > 0)
                    {
                        if(Qt.app.getSetting("replayFeature", "false") == "false")
                        {
                            markAsOpened();
                            
                            if(ListItemData.id == Qt.lastViewedID)
                            {
                                root.ListItem.view.setLabelTimer(ListItemData);
                            }
                            
                            snapTimer.timerStart();
                        }
                        else 
                        {
                            if(!ListItemData.candidateForReplay)
                            {
                                markAsOpened();
                                
                                if(ListItemData.id == Qt.lastViewedID)
                                {
                                    root.ListItem.view.setLabelTimer(ListItemData);
                                }
                                
                                snapTimer.timerStart();
                                
                                var command 	= new Object();
                                command.action 	= "markAsReadBySnapID";
                                command.data 	= ListItemData.id;
                                Qt.app.socketSend(JSON.stringify(command));
                            }
                        }
                    }
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
                if(ListItemData.status == 300)
                {
                    
                }
                else 
                {
                    if(!ListItemData.loaded)
                    {
                        download();
                    }
                    else 
                    {
                        console.log("USERNAME: " + ListItemData.username);
                        
                        root.ListItem.view.loadBestFriends(ListItemData.username);
                    }
                }
            }
        },
        PinchHandler 
        {
            onPinchEnded: 
            {
                markAsScreenshotted();
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
            
            signal timerStop();
            signal timerStart();
            
            onTimerStart: 
            {
                var item 			= ListItemData;
                item.timerrunning 	= true;
                
                if(ListItemData.id)
                {
                    Qt.snap2chatAPIData.feedsDataModel.replace(root.ListItem.indexPath, item);
                }
                
                snapTimer.start();
            }
            
            onTimerStop: 
            {
                var item 			= ListItemData;
                item.timerrunning 	= false;
                
                if(ListItemData.id)
                {
                    Qt.snap2chatAPIData.feedsDataModel.replace(root.ListItem.indexPath, item);
                }
                
                snapTimer.stop();
            }
            
            onTriggered: 
            {
                var item 		= ListItemData;
                item.timeleft 	= item.timeleft - 1;

                if(ListItemData.id)
                {
                    Qt.snap2chatAPIData.feedsDataModel.replace(root.ListItem.indexPath, item);
                }

                if(ListItemData.id == Qt.lastViewedID)
                {
                    root.ListItem.view.setLabelTimer(ListItemData);
                }
                
                if(item.timeleft <= 0)
                { 
                    if(ListItemData.id == Qt.lastViewedID)
                    {
                        root.ListItem.view.setFingerDown(false);
                    }
                    
                    if(ListItemData.media_type == 1 || ListItemData.media_type == 2)
                    {
                        root.ListItem.view.stopVideo();
                    }
                    
                    var item2 				= ListItemData;
                    item2.loading 			= false;
                    item2.statusText 		= " - Opened";
                    item2.status 			= 2;
                    
                    if(Qt.app.getSetting("replayFeature", "false") == "true")
                    {
                        item2.loaded 			= true;
                        item2.actionStatusText 	= " - Press and hold to replay";
                        item2.timeleft 			= 10;
                        item2.candidateForReplay = true;
                        
                        if(ListItemData.media_type == 0)
                        {
                            item2.statusImage = "asset:///images/snapchat/aa_feed_icon_opened_photo_replay.png";
                        }
                        else if(ListItemData.media_type == 1 || ListItemData.media_type == 2 || ListItemData.media_type == 500)
                        {
                            item2.statusImage = "asset:///images/snapchat/aa_feed_icon_opened_video_replay.png";
                        }
                    }
                    else 
                    {
                        item2.loaded 			= false;
                        item2.actionStatusText 	= "";
                        item2.timeleft 			= "";
                        
                        if(ListItemData.media_type == 0)
                        {
                            item2.statusImage = "asset:///images/snapchat/aa_feed_icon_opened_photo.png";
                        }
                        else if(ListItemData.media_type == 1 || ListItemData.media_type == 2 || ListItemData.media_type == 500)
                        {
                            item2.statusImage = "asset:///images/snapchat/aa_feed_icon_opened_video.png";
                        }
                        
                        var extension = "";
                        
                        if(ListItemData.media_type == "0")
                        {
                            extension = ".jpg";
                        }
                        else if(ListItemData.media_type == "1" || ListItemData.media_type == "2")
                        {
                            extension = ".mp4";
                        }
                        else if(ListItemData.media_type == "500")
                        {
                            extension = ".zip";
                        }
                        
                        var fileLocation = "data/files/blobs/" + ListItemData.id + extension;
                        
                        Qt.app.deletePhoto(fileLocation);
                    }
                    
                    if(ListItemData.id && ListItemData.timerrunning)
                    {
                        //console.log("INDEX PATH: " + JSON.parse(root.ListItem.indexPath) + " - " + ListItemData.id + " - " + ListItemData.timerrunning);
                        
                        
                        Qt.snap2chatAPIData.feedsDataModel.replace(root.ListItem.indexPath, item2);
                    }
                    
                    if(ListItemData.id == Qt.lastViewedID)
                    {
                        root.ListItem.view.setLabelTimer(ListItemData);
                    }
                    
                    snapTimer.timerStop();
                }
            }
        },
        Snap2ChatAPISimple 
        {
            id: snap2chatAPISimple
            onCompleteSnap: 
            {
                var fileLocation 	= resultObject.passedParams.fileLocation;
                var endpoint		= resultObject.passedParams.endpoint;
                var httpcode		= resultObject.httpcode;
                var response		= resultObject.response;
                
                if(httpcode == "200")
                {
                    if(Qt.app.getFileSize(fileLocation) > 100)
                    {
                        if(!resultObject.passedParams.done)
                        {
                            Qt.app.decrypt(fileLocation, fileLocation, "ECB", Qt.app.getEncryptionKey(), "");
                            
                            if(ListItemData.media_type == 500) // ZIPPED
                            {
                                Qt.app.extractZippedVideo(ListItemData.id);
                            }
                        }
                        
                        var item 				= ListItemData;
                        item.loading 			= false;
                        item.loaded 			= true;
                        item.load 				= false;
                        item.statusText 		= "";
                        item.actionStatusText 	= " - Press and hold to view";
                        
                        if(ListItemData.id)
                        {
                            //console.log("INDEX PATH: " + JSON.parse(root.ListItem.indexPath) + " - " + ListItemData.id + " - " + ListItemData.timerrunning);
                            Qt.snap2chatAPIData.feedsDataModel.replace(root.ListItem.indexPath, item);
                        }
                    }
                    else
                    {
                        Qt.app.flurryLogError("ERROR DECRYPTING SNAP: " + httpcode + ", " + response);
                        
                        var item 		= ListItemData;
                        item.loading 	= false;
                        item.loaded 	= false;
                        item.uploadNow 	= false;
                        item.status 	= 300;
                        item.statusText 		= " - Failed";
                        item.actionStatusText 	= " - Tap to retry";
                        
                        if(ListItemData.id)
                        {
                            //console.log("INDEX PATH: " + JSON.parse(root.ListItem.indexPath) + " - " + ListItemData.id + " - " + ListItemData.timerrunning);
                            Qt.snap2chatAPIData.feedsDataModel.replace(root.ListItem.indexPath, item);
                        }
                    }
                }
                else 
                {
                    Qt.app.flurryLogError("ERROR DOWNLOAD SNAP: " + httpcode + ", " + response);
                    
                    var item 		= ListItemData;
                    item.loading 	= false;
                    item.loaded 	= false;
                    item.uploadNow 	= false;
                    item.status 	= 300;
                    item.statusText 		= " - Failed";
                    item.actionStatusText 	= " - Tap to retry";

                    if(ListItemData.id)
                    {
                        //console.log("INDEX PATH: " + JSON.parse(root.ListItem.indexPath) + " - " + ListItemData.id + " - " + ListItemData.timerrunning);
                        Qt.snap2chatAPIData.feedsDataModel.replace(root.ListItem.indexPath, item);
                    }
                }
            }
        }
    ]
    
    function reply()
    {
        if(ListItemData.sender == Qt.snap2chatAPIData.username)
        {
            var parameters 				= new Object();
            parameters.replyMode 		= true;
            parameters.recipient 		= ListItemData.recipient;
            parameters.postToShoutBox 	= false;
            Qt.app.openCameraTab(parameters);
        }
        else 
        {
            var parameters 				= new Object();
            parameters.replyMode 		= true;
            parameters.recipient 		= ListItemData.sender;
            parameters.postToShoutBox 	= false;
            Qt.app.openCameraTab(parameters);
        }
    }
    
    function download()
    {
        Qt.app.flurryLogEvent("DOWNLOAD SNAP");
        
        var item = ListItemData;
        item.load = false;
        item.loading = true;
        item.statusText = " - Loading...";
        item.actionStatusText = "";

        if(ListItemData.id)
        {
            //console.log("INDEX PATH: " + JSON.parse(root.ListItem.indexPath) + " - " + ListItemData.id + " - " + ListItemData.timerrunning);
            Qt.snap2chatAPIData.feedsDataModel.replace(root.ListItem.indexPath, item);
        }
        
        var params 			= new Object();
        params.endpoint		= "/ph/blob";
        params.username 	= Qt.snap2chatAPIData.username;
        params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
        params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
        
        params.id 			= ListItemData.id;
        
        var extension = "";
        
        if(ListItemData.media_type == "0")
        {
        	extension = ".jpg";
        }
        else if(ListItemData.media_type == "1" || ListItemData.media_type == "2")
        {
        	extension = ".mp4";
        }
        else if(ListItemData.media_type == "500")
        {
        	extension = ".zip";
        }

        params.fileLocation = "data/files/blobs/" + params.id + extension;
       
        snap2chatAPISimple.download(params);
    }
    
    function markAsOpened()
    {
        //console.log("MARK AS OPENED");
        
        var timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
        var req_token 	= Qt.snap2chatAPIData.generateRequestToken(timestamp, Qt.snap2chatAPIData.auth_token);
        
        // --------------------------- JSON OBJECT ------------------------------------ //
        
        var jsonObject = new Object();
        
        var cObject = new Object();
        cObject["t"] = parseInt(timestamp / 1000);
        jsonObject[ListItemData.id] = cObject;
        
        var jsonString = JSON.stringify(jsonObject);
        
        // --------------------------- EVENTS ARRAY ------------------------------------ //
        
        var eventObject = new Object();
        eventObject["eventName"] = "SNAP_VIEW";
        eventObject["ts"] = Qt.snap2chatAPIData.getCurrentTimestamp() - 1;
        
        var eventParams = new Object();
        eventParams["id"] = ListItemData.id;
        eventObject["params"] = eventParams;
        
        // ---------------
        
        var eventObject2 = new Object();
        eventObject2["eventName"] = "SNAP_EXPIRED";
        eventObject2["ts"] = Qt.snap2chatAPIData.getCurrentTimestamp();
        
        var eventParams2 = new Object();
        eventParams2["id"] = ListItemData.id;
        eventObject2["params"] = eventParams2;
        
        // ---------------
        
        var eventsArray = new Array();
        eventsArray[0] = eventObject;
        eventsArray[1] = eventObject2;
        
        var eventsString = JSON.stringify(eventsArray);
        
        var params 			= new Object();
        params.endpoint		= "/bq/update_snaps";
        params.username 	= Qt.snap2chatAPIData.username;
        params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
        params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
        
        params.events		= eventsString;
        params.json			= jsonString;
        params.added_friends_timestamp	= Qt.snap2chatAPIData.addedFriendsTimestamp;
        
        snap2chatAPISimple.request(params);
    }
    
    function markAsScreenshotted()
    {
        var item 	= ListItemData;
        item.status = 3;
        
        if(ListItemData.media_type == 0)
        {
            item.statusImage = "asset:///images/snapchat/aa_feed_icon_screenshotted_photo.png";
        }
        else if(ListItemData.media_type == 1 || ListItemData.media_type == 2 || ListItemData.media_type == 500)
        {
            item.statusImage = "asset:///images/snapchat/aa_feed_icon_screenshotted_video.png";
        }
        
        item.statusText 		= " - Screenshotted";
        item.actionStatusText 	= "";
        
        if(ListItemData.id)
        {
            //console.log("INDEX PATH: " + JSON.parse(root.ListItem.indexPath) + " - " + ListItemData.id + " - " + ListItemData.timerrunning);
            Qt.snap2chatAPIData.feedsDataModel.replace(root.ListItem.indexPath, item);
        }
        
        var timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
        var req_token 	= Qt.snap2chatAPIData.generateRequestToken(timestamp, Qt.snap2chatAPIData.auth_token);
        
        // --------------------------- JSON OBJECT ------------------------------------ //
        
        var jsonObject = new Object();
        
        var cObject = new Object();
        cObject["t"] = parseInt(timestamp / 1000);
        cObject["c"] = 3;
        jsonObject[ListItemData.id] = cObject;
        
        var jsonString = JSON.stringify(jsonObject);
        
        // --------------------------- EVENTS ARRAY ------------------------------------ //
        
        var eventObject = new Object();
        eventObject["eventName"] = "SNAP_SCREENSHOT";
        eventObject["ts"] = Qt.snap2chatAPIData.getCurrentTimestamp() - 1;
        
        var eventParams = new Object();
        eventParams["id"] = ListItemData.id;
        eventObject["params"] = eventParams;
        
        var eventsArray = new Array();
        eventsArray[0] = eventObject;
        
        var eventsString = JSON.stringify(eventsArray);
        
        var params 			= new Object();
        params.endpoint		= "/bq/update_snaps";
        params.username 	= Qt.snap2chatAPIData.username;
        params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
        params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
        
        params.events		= eventsString;
        params.json			= jsonString;
        params.added_friends_timestamp	= Qt.snap2chatAPIData.addedFriendsTimestamp;
        
        snap2chatAPISimple.request(params);
    }
}