import bb.cascades 1.2
import bb.system 1.0

import "../components/"
import "../smaato"

Sheet
{
    id: sheet

    property bool isPhoto : false;
    property bool isVideoWithCaption : false;
    property variant theAttachedObjects;
    
    function createObjects()
    {
        if (!sheet.theAttachedObjects)
        {
            sheet.theAttachedObjects = myAttachedObjects.createObject(sheet);
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
                property alias optionsDialogInteract: optionsDialog
                
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
                                        optionsDialog.close();
                                    }
                                }
                            }
                        }
                    }
                ]
            }
        },
        SystemDialog
        {
            id: deletePrompt
            title: "Cancel all uploading snap?"
            body: "Note: This cannot be undone."
            modality: SystemUiModality.Application
            confirmButton.label: "Cancel"
            confirmButton.enabled: true
            dismissAutomatically: true
            cancelButton.label: "No"
            onFinished: 
            {
                if(buttonSelection().label == "Cancel")
                {
                    var blobsFolder = Qt.app.getHomePath() + "/files/sent/"
                    Qt.app.wipeFolderContents(blobsFolder);
                    
                    Qt.snap2chatAPIData.uploadingDataModel.clear();
                    Qt.snap2chatAPIData.uploadingSize = 0;
                }
            }
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
                    title: "UPLOADING SNAPS"
                    subtitle: Qt.snap2chatAPIData.uploadingSize;
                }
                
                SmaatoAds
                {
                    id: ads
                }
                
                ListView 
                {
                    id: listView
                    dataModel: Qt.snap2chatAPIData.uploadingDataModel

                    listItemComponents: 
                    [
                        ListItemComponent 
                        {
                            id: theListItemComponent
                            
                            content: UploadingItem 
                            {
                                id: root
                            }
                        }
                    ]

                    function playVideo(ListItemData)
                    {
                        if(_app.purchasedAds)
                        {
                            isPhoto = false;
                            isVideoWithCaption = false;
                            
                            var videoSource = "";
                            
                            if(ListItemData.media_type == 500)
                            {
                                isVideoWithCaption = true;
                                videoSource = "file://" + ListItemData.fileLocation;
                                theAttachedObjects.viewingDialogInteract.videoCaptionInteract.imageSource = "file://" + ListItemData.fileLocationOverlay;
                            }
                            else 
                            {
                                videoSource = "file://" + ListItemData.fileLocation;
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
                        else 
                        {
                            Qt.toastX.pop("Preview your sent snap. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                            Qt.proSheet.open();
                        }
                    }
                    
                    function stopVideo()
                    {
                        isVideoWithCaption = false;
                        
                        theAttachedObjects.viewingDialogInteract.stopVideo();
                    }
                    
                    function setImageSource(ListItemData)
                    {
                        if(_app.purchasedAds)
                        {
                            isPhoto = true;
                            isVideoWithCaption = false;
                            
                            var imageSource = "file://" + ListItemData.fileLocation;
                            theAttachedObjects.viewingDialogInteract.backgroundImageInteract.imageSource = imageSource;
                        }
                        else 
                        {
                            Qt.toastX.pop("Preview your sent snap. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                            Qt.proSheet.open();
                        }
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
            ActionItem 
            {
                title: "Cancel All"
                enabled: (Qt.snap2chatAPIData.uploadingSize > 0)
                imageSource: "asset:///images/titleCancel.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: 
                {
                    if(_app.purchasedAds)
                    {
                        deletePrompt.show();
                    }
                    else 
                    {
                        Qt.toastX.pop("Cancel all uploading snaps in one click. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                        Qt.proSheet.open();
                    }
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