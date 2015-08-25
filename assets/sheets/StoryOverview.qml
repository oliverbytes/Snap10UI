import bb.cascades 1.2

import "../components/"
import "../smaato"

Sheet
{
    id: sheet
    
    property variant userStory : Object();
    
    function load()
    {
        Qt.snap2chatAPIData.currentStoriesOverViewModel.clear();
        Qt.snap2chatAPIData.currentStoriesOverViewModel.insert(0, userStory.stories);
    }
    
    property bool isPhoto : false;
    property bool isVideoWithCaption : false;
    property variant theAttachedObjects
    
    function createObjects()
    {
        if (!sheet.theAttachedObjects)
        {
            sheet.theAttachedObjects = myAttachedObjects.createObject(navigationPane);
        }
    }
    
    function destroyObjects()
    {
        if (sheet.theAttachedObjects)
        {
            sheet.theAttachedObjects.destroy();
        }
    }
    
    onCreationCompleted: 
    {
        createObjects();
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
                property alias storiesOptionDialogInteract: storiesOptionDialog
                property alias viewersScreenshottersSheetInteract: viewersScreenshottersSheet
                
                attachedObjects: 
                [
                    ViewersScreenshotters 
                    {
                        id: viewersScreenshottersSheet
                    },
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
                        id: storiesOptionDialog

                        Container 
                        {
                            id: theoptions
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
                                        storiesOptionDialog.close();
                                    }
                                }
                            }
                        }
                    }
                ]
            }
        },
        ComponentDefinition 
        {
            id: extendedProfileComponent
            source: "asset:///pages/ExtendedProfile.qml"
        }
    ]
    
    Page
    {
        id: page
        
        titleBar: CustomTitleBar 
        {
            closeVisibility: true
            onCloseButtonClicked:
            {
                close();
            }
        }
        
        Container 
        {
            layout: DockLayout {}
            
            Container 
            {
                id: results
                
                Header
                {
                    id: listViewHeader
                    title: "Stories of " + ( userStory ? userStory.username : "")
                    subtitle: ( userStory ? (userStory.stories ? userStory.stories.length : "") : "");
                }
                
                SmaatoAds
                {
                    id: ads
                }
                
                ListView 
                {
                    id: listView
                    dataModel: Qt.snap2chatAPIData.currentStoriesOverViewModel

                    listItemComponents: 
                    [
                        ListItemComponent 
                        {
                            content: StoryOverViewItem 
                            {
                                id: root
                            }
                        }
                    ]
                    
                    function openViewersScreenshotters(ListItemData)
                    {
                        theAttachedObjects.viewersScreenshottersSheetInteract.storyNotes = ListItemData.story_notes;
                        theAttachedObjects.viewersScreenshottersSheetInteract.load();
                        theAttachedObjects.viewersScreenshottersSheetInteract.open();
                    }
                    
                    function playVideo(story)
                    {
                        isPhoto = false;
                        isVideoWithCaption = false;
                        
                        var videoSource = "";
                        
                        if(story.media_type == 500)
                        {
                            isVideoWithCaption = true;
                            videoSource = "file://" + Qt.app.getHomePath() + "/files/blobs/" + story.media_id + "/media.mp4";
                            theAttachedObjects.viewingDialogInteract.videoCaptionInteract.imageSource = "file://" + Qt.app.getHomePath() + "/files/blobs/" + story.media_id + "/overlay.png";
                        }
                        else 
                        {
                            videoSource = "file://" + Qt.app.getHomePath() + "/files/blobs/" + story.media_id + ".mp4";
                        }
                        
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
                    
                    function setImageSource(story)
                    {
                        isPhoto = true;
                        isVideoWithCaption = false;
                        
                        var imageSource = "file://" + Qt.app.getHomePath() + "/files/blobs/" + story.media_id + ".jpg";
                        theAttachedObjects.viewingDialogInteract.backgroundImageInteract.imageSource = imageSource;
                    }
                    
                    function setLabelTimer(timeLeft)
                    {
                        theAttachedObjects.viewingDialogInteract.labelTimerInteract.text = timeLeft;
                    }
                    
                    function setFingerDown(value)
                    {
                        if(value == true)
                        {
                            theAttachedObjects.viewingDialogInteract.open();
                        }
                        else 
                        {
                            theAttachedObjects.viewingDialogInteract.close();
                        }
                    }
                }
            }
        }
        
        actions: 
        [
//            ActionItem 
//            {
//                title: "Play Slide Show"
//                imageSource: "asset:///images/tabPlay.png"
//                ActionBar.placement: ActionBarPlacement.OnBar
//                onTriggered: 
//                {
//                    console.log("STORIES: " + JSON.stringify(userStory.stories));
//                }
//            },
            ActionItem 
            {
                title: "Options"
                ActionBar.placement: ActionBarPlacement.InOverflow
                imageSource: "asset:///images/tabAutomation.png"
                onTriggered: 
                {
                    theAttachedObjects.storiesOptionDialogInteract.open();
                }
            },
            ActionItem 
            {
                title: "Jump To Top"
                ActionBar.placement: ActionBarPlacement.InOverflow
                imageSource: "asset:///images/ic_to_top.png"
                onTriggered: 
                {
                    listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                }
            },
            ActionItem 
            {
                title: "Jump To Bottom"
                ActionBar.placement: ActionBarPlacement.InOverflow
                imageSource: "asset:///images/ic_to_bottom.png"
                onTriggered: 
                {
                    listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth);
                }
            }
        ]
    }
}