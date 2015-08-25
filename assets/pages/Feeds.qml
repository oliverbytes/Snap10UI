import bb.system 1.0
import bb.cascades 1.2

import "../components"
import "../sheets"
import "../smaato"
import "../dialogs"

NavigationPane 
{
    id: navigationPane
    property variant theAttachedObjects
    property string therecipient : "";
    property bool isPhoto : false;
    property bool isVideoWithCaption : false;
    
    onCreationCompleted:
    {
        createObjects();
    }
    
    function loadFeeds()
    {
        Qt.app.loadUpdates();
    }
    
    function createObjects()
    {
        if (!navigationPane.theAttachedObjects)
        {
            navigationPane.theAttachedObjects = myAttachedObjects.createObject(navigationPane);
        }
    }
    
    function destroyObjects()
    {
        if (navigationPane.theAttachedObjects)
        {
            navigationPane.theAttachedObjects.destroy();
        }
    }
    
    attachedObjects: 
    [
        ComponentDefinition 
        {
            id: myAttachedObjects
            
            Container 
            {
                id: objects
                
                property alias viewingDialogInteract: viewingDialog
                property alias optionsDialogInteract: optionsDialog
                property alias clearFeedsPromptInteract: clearFeedsPrompt
                
                attachedObjects: 
                [
                    Dialog 
                    {
                        id: viewingDialog
                        
                        property alias videoCaptionInteract : videoCaption
                        property alias backgroundImageInteract : backgroundImage
                        property alias labelTimerInteract : labelTimer
                        
                        function playVideo(videoSource)
                        {
                            var videoPlayerComponentControl = videoPlayerComponent.createObject();
                            videoPlayerComponentControl.videoSource = videoSource;
                            videoPlayerComponentControl.replay = true;
                            videoPlayerComponentControl.playVideo();
                            videoPlayerContainer.add(videoPlayerComponentControl);
                        }
                        
                        function stopVideo()
                        {
                            var videoPlayerComponentControl = videoPlayerContainer.at(0);
                            
                            if(videoPlayerComponentControl)
                            {
                                videoPlayerComponentControl.replay = false;
                                videoPlayerComponentControl.stopVideo();
                                videoPlayerContainer.remove(videoPlayerComponentControl);
                                videoPlayerComponentControl.destroy();
                            }
                        }
                        
                        onOpened: 
                        {
                            Qt.app.flurryLogEvent("VIEW SNAP");
                        }
                        
                        onClosed: 
                        {
                            stopVideo();
                        }
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            background: Color.Black
                            
                            layout: DockLayout {}
                            
                            onTouch: 
                            {
                                if(event.touchType == TouchType.Cancel || event.touchType == TouchType.Up)
                                {
                                    viewingDialog.close();
                                }
                            }
                            
                            Container 
                            {
                                id: videoPlayerContainer
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                
                                attachedObjects: ComponentDefinition 
                                {
                                    id: videoPlayerComponent
                                    source: "asset:///components/VideoPlayer.qml"
                                }
                            }
                            
                            ImageView
                            {
                                id: backgroundImage
                                visible: isPhoto
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                scalingMethod: snapViewingAspect.selectedValue
                            }
                            
                            ImageView
                            {
                                id: videoCaption
                                visible: !isPhoto && isVideoWithCaption
                                horizontalAlignment: HorizontalAlignment.Fill
                                verticalAlignment: VerticalAlignment.Fill
                                scalingMethod: snapViewingAspect.selectedValue
                            }
                            
                            Container 
                            {
                                visible: labelTimer.text.length > 0
                                leftPadding: 10
                                rightPadding: 10
                                topPadding: 10
                                bottomPadding: 10
                                background: Color.create("#000000")
                                opacity: 0.7
                                horizontalAlignment: HorizontalAlignment.Right
                                verticalAlignment: VerticalAlignment.Top
                                
                                Label 
                                {
                                    id: labelTimer
                                    text: ""
                                    textStyle.color: Color.create("#ffffff")
                                }
                            }
                        }
                    },
                    Dialog 
                    {
                        id: optionsDialog
                        
                        Container 
                        {
                            id: mainDialogContainer
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            background: Color.create("#dd000000");
                            
                            layout: DockLayout {}
                            
                            Container 
                            {
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                leftPadding: 100
                                rightPadding: 100
                                
                                Label 
                                {
                                    text: "Filter Options"
                                    textStyle.color: Color.White;
                                }
                                
                                DropDown 
                                {
                                    id: feedsshowonly
                                    title: "Show Only"
                                    selectedIndex: Qt.app.getSetting("showOnlyMediaTypeIndex", "0")
                                    options: 
                                    [
                                        Option 
                                        {
                                            text: "All Snaps"
                                            value: "all"
                                        },
                                        Option 
                                        {
                                            text: "Photo Snaps"
                                            value: "photo"
                                        },
                                        Option 
                                        {
                                            text: "Video Snaps"
                                            value: "video"
                                        }
                                    ]
                                    onSelectedValueChanged: 
                                    {
                                        Qt.app.setSetting("showOnlyMediaType", selectedValue);
                                    }
                                    onSelectedIndexChanged: 
                                    {
                                        Qt.app.setSetting("showOnlyMediaTypeIndex", selectedIndex);
                                    }
                                }
                                
                                DropDown 
                                {
                                    id: feedssortby
                                    visible: false
                                    title: "Show Only"
                                    selectedIndex: Qt.app.getSetting("showOnlyStatusIndex", "0")
                                    options: 
                                    [
                                        Option 
                                        {
                                            text: "All"
                                            value: "all"
                                        },
                                        Option 
                                        {
                                            text: "Unopened"
                                            value: "unopened"
                                        },
                                        Option 
                                        {
                                            text: "Opened"
                                            value: "opened"
                                        },
                                        Option 
                                        {
                                            text: "Screenshots"
                                            value: "screenshots"
                                        }
                                    ]
                                    onSelectedValueChanged: 
                                    {
                                        Qt.app.setSetting("showOnlyStatus", selectedValue);
                                    }
                                    onSelectedIndexChanged: 
                                    {
                                        Qt.app.setSetting("showOnlyStatusIndex", selectedIndex);
                                    }
                                }
                                
                                Label 
                                {
                                    text: "Maximum Feeds To Show"
                                    textStyle.color: Color.White;
                                    visible: false
                                }
                                
                                DropDown 
                                {
                                    id: feedsmaxtoshow
                                    visible: false
                                    title: "Show Up To"
                                    selectedIndex: Qt.app.getSetting("maxToShowIndex", "0")
                                    options: 
                                    [
                                        Option 
                                        {
                                            text: "Unlimited Snaps"
                                            value: "unlimited"
                                        },
                                        Option 
                                        {
                                            text: "10 Latest Snaps"
                                            value: "10"
                                        },
                                        Option
                                        {
                                            text: "20 Latest Snaps"
                                            value: "20"
                                        },
                                        Option 
                                        {
                                            text: "30 Latest Snaps"
                                            value: "30"
                                        },
                                        Option 
                                        {
                                            text: "40 Latest Snaps"
                                            value: "40"
                                        },
                                        Option 
                                        {
                                            text: "50 Latest Snaps"
                                            value: "50"
                                        },
                                        Option 
                                        {
                                            text: "100 Latest Snaps"
                                            value: "100"
                                        }
                                    ]
                                    onSelectedValueChanged: 
                                    {
                                        Qt.app.setSetting("maxToShow", selectedValue);
                                    }
                                    onSelectedIndexChanged: 
                                    {
                                        Qt.app.setSetting("maxToShowIndex", selectedIndex);
                                    }
                                }
                                
                                Label 
                                {
                                    text: "Photo Snaps Viewing Aspect"
                                    textStyle.color: Color.White;
                                }
                                
                                DropDown 
                                {
                                    id: snapViewingAspect
                                    title: "Viewing Aspect"
                                    selectedIndex: Qt.app.getSetting("snapViewingAspectIndex", "0")
                                    options: 
                                    [
                                        Option 
                                        {
                                            text: "Fit to Screen"
                                            value: ScalingMethod.AspectFit
                                        },
                                        Option
                                        {
                                            text: "Fill / Full Screen"
                                            value: ScalingMethod.AspectFill
                                        }
                                    ]
                                    onSelectedValueChanged: 
                                    {
                                        Qt.app.setSetting("snapViewingAspect", selectedValue);
                                    }
                                    onSelectedIndexChanged: 
                                    {
                                        Qt.app.setSetting("snapViewingAspectIndex", selectedIndex);
                                    }
                                }
                            }
                            
                            Container 
                            {
                                id: closeOptions
                                leftPadding: 20
                                rightPadding: 20
                                bottomPadding: 20
                                topPadding: 20
                                horizontalAlignment: HorizontalAlignment.Right
                                verticalAlignment: VerticalAlignment.Top
                                
                                ImageButton 
                                {
                                    defaultImageSource: "asset:///images/snapchat/aa_snap_preview_x.png"
                                    preferredHeight: 100
                                    preferredWidth: 100
                                    onClicked: 
                                    {
                                       theAttachedObjects.optionsDialogInteract.close();
                                    }
                                }
                            }
                        }
                    },
                    SystemDialog
                    {
                        id: clearFeedsPrompt
                        title: "Are you sure?"
                        body: "Clearing Feeds will delete all your received and sent snaps and the action cannot be undone."
                        modality: SystemUiModality.Application
                        confirmButton.label: "Clear Feeds"
                        confirmButton.enabled: true
                        dismissAutomatically: true
                        cancelButton.label: "Cancel"
                        onFinished: 
                        {
                            if(buttonSelection().label == "Clear Feeds")
                            {
                                Qt.snap2chatAPIData.clearFeedsLocally();
                                
                                Qt.app.showToast("Successfully Cleared Your Feeds :)");

                                var params 			= new Object();
                                params.endpoint		= "/loq/clear_feed";
                                params.username 	= Qt.snap2chatAPIData.username;
                                params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
                                params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.auth_token);
                                
                                Qt.snap2chatAPI.request(params);
                            }
                        }
                    }
                ]
            }
        }
    ]

    Page
    {
        id: page
        
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: CustomTitleBar 
        {
            id: titleBar
            cameraVisibility: true
            settingsVisibility: true
        }
        
        Container 
        {
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Fill

            onTouch: 
            {
                if(event.isUp())
                {
                    theAttachedObjects.viewingDialogInteract.close();
                }
            }

            Container 
            {
                id: results
                horizontalAlignment: HorizontalAlignment.Fill
                
                Container
                {
                    Header
                    {
                        id: listViewHeader
                        title: "FEEDS"
                        subtitle: Qt.snap2chatAPIData.feedsDataModel.size();
                    }
                }
    
                UploadingFakeItem 
                {
                    visible: (Qt.snap2chatAPIData.uploadingSize > 0)
                    onVisibleChanged: 
                    {
                        if(visible)
                        {
                            startAnimations();
                        }
                        else 
                        {
                            stopAnimations();
                        }
                    }
                }
                
                SmaatoAds
                {
                    id: ads
                }
                
                PullToRefreshListView 
                {
                    id: listView
                    loading: Qt.snap2chatAPIData.loading
                    dataModel: Qt.snap2chatAPIData.feedsDataModel
                    horizontalAlignment: HorizontalAlignment.Fill

                    property string lastViewedID : "";
                    
                    onCreationCompleted: 
                    {
                        Qt.lastViewedID = lastViewedID;
                    }

                    listItemComponents: 
                    [
                        ListItemComponent 
                        {
                            content: FeedItem 
                            {
                                id: root
                            }
                        }
                    ]
                    
                    attachedObjects: 
                    [
                        ListScrollStateHandler 
                        {
                            id: scrollStateHandler
                        },
                        UserInfo 
                        {
                            id: bestFriendsDialog
                        }
                    ]
                    
                    function loadBestFriends(username)
                    {
                        bestFriendsDialog.username = username;
                        bestFriendsDialog.open();
                    }
                    
                    function isScrolling()
                    {
                        return scrollStateHandler.scrolling && Qt.app.getSetting("floatingButtons", "true") == "true";
                    }
                    
                    function playVideo(ListItemData)
                    {
                        Qt.lastViewedID = ListItemData.id;
                        
                        isPhoto = false;
                        isVideoWithCaption = false;
                        
                        var videoSource = "";

                        if(ListItemData.media_type == 500)
                        {
                            isVideoWithCaption = true;
                            videoSource = "file://" + Qt.app.getHomePath() + "/files/blobs/" + ListItemData.id + "/media.mp4";
                            theAttachedObjects.viewingDialogInteract.videoCaptionInteract.imageSource = "file://" + Qt.app.getHomePath() + "/files/blobs/" + ListItemData.id + "/overlay.png";
                        }
                        else 
                        {
                            videoSource = "file://" + Qt.app.getHomePath() + "/files/blobs/" + ListItemData.id + ".mp4";
                        }
                        
                        console.log("VIDEO SOURCE: " + videoSource)
                        
                        if(Qt.app.getSetting("videoPlayer", "snap2chatVideoPlayer") == "snap2chatVideoPlayer")
                        {
                            theAttachedObjects.viewingDialogInteract.playVideo(videoSource);
                        }
                        else 
                        {
                            Qt.app.invokeOpenWithMediaPlayer(videoSource);
                        }
                    }
                    
                    function stopVideo()
                    {
                        isVideoWithCaption = false;
                        
                        theAttachedObjects.viewingDialogInteract.stopVideo();
                    }
                    
                    function setImageSource(ListItemData)
                    {
                        Qt.lastViewedID = ListItemData.id;
                        
                        isPhoto = true;
                        isVideoWithCaption = false;
                        
                        theAttachedObjects.viewingDialogInteract.backgroundImageInteract.imageSource = "file://" + Qt.app.getHomePath() + "/files/blobs/" + ListItemData.id + ".jpg";
                    }
                    
                    function setLabelTimer(ListItemData)
                    {
                        if(ListItemData.candidateForReplay)
                        {
                            theAttachedObjects.viewingDialogInteract.labelTimerInteract.text = "";
                        }
                        else 
                        {
                            if(Qt.lastViewedID == ListItemData.id)
                            {
                                theAttachedObjects.viewingDialogInteract.labelTimerInteract.text = ListItemData.timeleft;
                            }
                        }
                    }
                    
                    function setFingerDown(value)
                    {
                        if(value == true)
                        {
                            theAttachedObjects.viewingDialogInteract.open();
                        }
                        else 
                        {
                            theAttachedObjects.viewingDialogInteract.labelTimerInteract.text = "";
                            
                            theAttachedObjects.viewingDialogInteract.close();
                        }
                    }
 
                    function refreshTriggered()
                    {
                        loadFeeds();
                    }
                }
            }
            
            Container 
            {
                visible: (!Qt.snap2chatAPIData.loading && listViewHeader.subtitle == 0)
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                
                Label 
                {
                    text: (Qt.snap2chatAPIData.loading ? "Loading..." : "No entries to show. :(")
                    textStyle.fontSize: FontSize.Small
                }
            }
            
            Container 
            {
                id: loadingBox
                visible: Qt.snap2chatAPIData.loading
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                touchPropagationMode: TouchPropagationMode.None
                layout: DockLayout {}
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Bottom
                    leftPadding: 20
                    bottomPadding: 20
                    
                    Label 
                    {
                        text: "Loading..."
                        visible: false
                        textStyle.fontSize: FontSize.Small
                    }
                }
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Bottom
                    rightPadding: 20
                    bottomPadding: 10
                    
                    ActivityIndicator 
                    {
                        visible: true
                        running: visible
                        preferredHeight: 60
                    }
                }
            } 
            
            Container 
            {
                id: jumpButtons
                opacity: 0.5
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                rightPadding: 20
                visible: scrollStateHandler.scrolling && Qt.app.getSetting("floatingButtons", "true") == "true"
                
                ImageButton
                {
                    defaultImageSource: "asset:///images/jumpToTop.png" 
                    verticalAlignment: VerticalAlignment.Center
                    onClicked: 
                    {
                        listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth)
                    }
                }
                
                ImageButton
                {
                    defaultImageSource: "asset:///images/jumpToBottom.png" 
                    verticalAlignment: VerticalAlignment.Center
                    onClicked: 
                    {
                        listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth)
                    }
                }
            }
        }
        
        actions: 
        [
            ActionItem 
            {
                title: "Refresh"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/refresh.png"
                onTriggered: 
                {
                    loadFeeds();
                }
            },
            ActionItem 
            {
                title: "Options"
                ActionBar.placement: ActionBarPlacement.InOverflow
                imageSource: "asset:///images/tabAutomation.png"
                onTriggered: 
                {
                    theAttachedObjects.optionsDialogInteract.open();
                }
            },
            ActionItem 
            {
                title: Qt.snap2chatAPIData.uploadingSize + " Uploading Snaps "
                ActionBar.placement: ActionBarPlacement.InOverflow
                imageSource: "asset:///images/tabUploadingSnaps.png"
                onTriggered: 
                {
                    Qt.uploadingSnapsSheet.open();
                }
            },
            ActionItem 
            {
                title: "Jump To Top"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/ic_to_top.png"
                onTriggered: 
                {
                    listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                }
            },
            ActionItem 
            {
                title: "Jump To Bottom"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/ic_to_bottom.png"
                onTriggered: 
                {
                    listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth);
                }
            },
            ActionItem 
            {
                title: "Clear Feeds"
                ActionBar.placement: ActionBarPlacement.InOverflow
                imageSource: "asset:///images/tabDelete.png"
                onTriggered: 
                {
                    theAttachedObjects.clearFeedsPromptInteract.show();
                }
            }
        ]
    }
    
    function setOrientation()
    {
        var orientation = Qt.app.getSetting("orientation", 0);
        
        if(orientation == 0)
        {
            OrientationSupport.supportedDisplayOrientation = 
            SupportedDisplayOrientation.All;  
        }
        else if(orientation == 1)
        {
            OrientationSupport.supportedDisplayOrientation = 
            SupportedDisplayOrientation.DisplayPortrait;  
        }
        else if(orientation == 2)
        {
            OrientationSupport.supportedDisplayOrientation = 
            SupportedDisplayOrientation.DisplayLandscape;  
        }
    }
}