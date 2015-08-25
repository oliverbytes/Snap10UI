import bb.cascades 1.0
import QtQuick 1.0
import bb.cascades.pickers 1.0

import "../sheets"

Page
{
    id: cameraPage
    
    property variant theAttachedObjects
    property bool frontFlashMode : false;
    property int lastRecordedSeconds : 1;
    
    function turnOffVideoFlash()
    {
        _app.setVideoLight(false);
        flash = "off";
    }
    
    function createObjects()
    {
        if (!cameraPage.theAttachedObjects)
        {
            cameraPage.theAttachedObjects = myAttachedObjects.createObject(cameraPage);
        }
    }
    
    function destroyObjects()
    {
        if (cameraPage.theAttachedObjects)
        {
            cameraPage.theAttachedObjects.destroy();
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
                
                property alias recordingTimerInteract: recordingTimer
                property alias frontFlashTimerInteract: frontFlashTimer
                
                attachedObjects: 
                [
                    Timer 
                    {
                        id: recordingTimer
                        repeat: true
                        interval: 1000
                        onTriggered: 
                        {
                            recordedSeconds++;
                            
                            if(recordedSeconds >= maxRecordingSeconds)
                            {
                                stopShoot();
                            }
                        }
                    },
                    Timer 
                    {
                        id: frontFlashTimer
                        repeat: false
                        interval: 300
                        onTriggered: 
                        {
                            _app.capture();
                        }
                    }
                ]
            }
        }
        ,
        EditSnap 
        {
            id: editSnapSheet
            cameraPage: cameraPage
        }
    ]
    
    property variant tabbedPane;
    property variant parameters;
    property string flash : "on";
    property int recordedSeconds : 1;
    property int maxRecordingSeconds : 10;
    property bool firstRun : true;
    property bool firstRunCamera : true;
    
    property variant feedsTab;
    property variant friendsTab;
    
    function startShoot()
    {
        console.log("_app.vfMode: " + _app.vfMode);
        
        if(_app.getSetting("frontFlash", "false") == "true" && _app.cameraUnit == 1 && flash == "on")
        {
            frontFlashMode = true;
        }
        
        if(_app.vfMode == 2)
        {
            if(!_app.capturing)
            {
                _app.capture(); // START VIDEO RECORDING
                theAttachedObjects.recordingTimerInteract.start();
            }   
            else if(_app.capturing)
            {
                _app.capture(); // STOP VIDEO RECORDING
                theAttachedObjects.recordingTimerInteract.stop();
                lastRecordedSeconds = recordedSeconds;
                recordedSeconds = 1;
            }
        }
        else 
        {
            if(frontFlashMode)
            {
                theAttachedObjects.frontFlashTimerInteract.start();
            }
            else 
            {
                _app.capture();
            }
        }
    }
    
    function stopShoot()
    {
        theAttachedObjects.recordingTimerInteract.stop();
        lastRecordedSeconds = recordedSeconds;
        recordedSeconds = 1;
        _app.capture(); // STOP VIDEO RECORDING        
    }
    
    keyListeners: KeyListener 
    {
        onKeyPressed: 
        {
            if(event.key == 32)
            {
                if(_app.capturing && _app.vfMode == 2)
                {
                    stopShoot();
                }
                else 
                {
                    startShoot();
                }
            }
        }
        
        onKeyReleased: 
        {
            if(_app.capturing && _app.vfMode == 2)
            {
                stopShoot();
            }
        }
    }

    Container 
    {
        id: rootContainer
        
        layout: DockLayout {}
        
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        background: Color.Black
        
        gestureHandlers:
        [
            DoubleTapHandler 
            {
                onDoubleTapped: 
                {
                    if(_app.vfMode == 2)
                    {
                        _app.setVfMode(1);
                        
                        if(flash == "on")
                        {
                            _app.setFlashMode(true);
                        }
                        else 
                        {
                            _app.setFlashMode(false);
                        }
                    }
                    else 
                    {
                        _app.setVfMode(2);
                        
                        if(flash == "on")
                        {
                            _app.setVideoLight(true);
                        }
                        else 
                        {
                            _app.setVideoLight(false);
                        }
                    }
                }
            }
        ]
        
        ForeignWindowControl 
        {
            id: vfForeignWindow
            windowId: "vfWindowId"
            objectName: "vfForeignWindow"
            updatedProperties: WindowProperty.Size | WindowProperty.Position | WindowProperty.Visible
            visible: boundToWindow
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            onWindowAttached: 
            {
                _app.windowAttached();
            }
            
            scaleX: 1.1
            scaleY: 1.1
        }

        Container 
        {
            id: advancedCameraSettings
            visible: false
            leftPadding: 50
            rightPadding: 50
            bottomPadding: 50
            topPadding: 50
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.create("#99000000")
            layout: DockLayout {}
            
            Container
            {
                verticalAlignment: VerticalAlignment.Center
                
                Container 
                {
                    layout: DockLayout {}
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    Container 
                    {
                        horizontalAlignment: HorizontalAlignment.Left
                        topPadding: 20
                        
                        Label 
                        {
                            text: "Advanced Camera Settings"
                            textStyle.color: Color.White
                            multiline: true
                        }
                    }
                    
                    ImageButton 
                    {
                        horizontalAlignment: HorizontalAlignment.Right
                        defaultImageSource: "asset:///images/snapchat/aa_snap_preview_x.png"
                        preferredHeight: 100
                        preferredWidth: 100
                        onClicked: 
                        {
                            advancedCameraSettings.visible = false;
                        }
                    }
                }
                
                DropDown 
                {
                    id: aspectRatio
                    title: "Aspect Ratio"
                    selectedIndex: (_app.getDisplayHeight() > 730 ? _app.getSetting("aspectRatio", "2") : _app.getSetting("aspectRatio", "1"));
                    onSelectedIndexChanged: 
                    {
                        _app.setSetting("aspectRatio", selectedIndex);
                    }
                    options: 
                    [
                        Option 
                        {
                            text: "1:1"
                            value: 1/1
                        },
                        Option 
                        {
                            text: "4:3"
                            value: 4/3
                        },
                        Option 
                        {
                            text: "16:9"
                            value: 16/9
                        }
                    ]
                    
                    onSelectedValueChanged: 
                    {
                        _app.setSetting("aspectRatioValue", selectedValue);
                        //_app.selectAspectRatio(camera, selectedValue);
                    }
                }
            }
        }
        
        Container 
        {
            id: controls
            visible: !advancedCameraSettings.visible
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            touchPropagationMode: TouchPropagationMode.PassThrough
            
            background: (frontFlashMode ? Color.create("#ffffff") : Color.Transparent)
            //background: Color.create("#eeffffff")
            
            layout: DockLayout {}
            
            Container 
            {
                id: cancel
                visible: false
                leftPadding: 20
                rightPadding: 20
                bottomPadding: 20
                topPadding: 20
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Top
                
                ImageButton 
                {
                    defaultImageSource: "asset:///images/snapchat/aa_chat_camera_back.png"
                    onClicked: 
                    {
                        close(feedsTab);
                    }
                }
            }
            
            Container 
            {
                id: switchFlash

                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Top

                ImageButton 
                {
                    id: switchFlashButton
                    defaultImageSource: 
                    {
                        if(flash == "off")
                        {
                            return "asset:///images/snapchat/aa_camera_flash_off_visual_button.png";
                        }
                        else 
                        {
                            return "asset:///images/snapchat/aa_camera_flash_on_visual_button.png";
                        }
                    }
                    onClicked: 
                    {
                        if(_app.vfMode == 2)
                        {
                            if(flash == "on")
                            {
                                _app.setVideoLight(false);
                                
                                flash = "off";
                            }
                            else 
                            {
                                _app.setVideoLight(true);
                                
                                flash = "on";
                            }
                        }
                        else 
                        {
                            if(flash == "on")
                            {
                                _app.setFlashMode(false);
                                
                                flash = "off";
                            }
                            else 
                            {
                                _app.setFlashMode(true);
                                
                                flash = "on";
                            }
                        }
                    }
                }
            }
            
            Container 
            {
                id: advancedCamera
                visible: false
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                
                ImageButton 
                {
                    defaultImageSource: "asset:///images/tabOptions.png"
                    onClicked:
                    {
                        advancedCameraSettings.visible = true;
                    }
                }
            }
            
            Container 
            {
                id: switchCamera

                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Top
                
                ImageButton 
                {
                    defaultImageSource: "asset:///images/snapchat/aa_camera_switch_button.png"
                    onClicked: 
                    {
                        if(_app.hasRearCamera && (_app.cameraUnit != 2) && !_app.capturing)
						{
                            _app.setCameraUnit(2);
						}
                        else if(_app.hasFrontCamera && (_app.cameraUnit != 1) && !_app.capturing)
						{
                            _app.setCameraUnit(1);
						}
                        
                        _app.setSetting("cameraUnit", _app.cameraUnit);
                    }
                }
            }
            
            Container 
            {
                id: feeds
                leftPadding: 20
                rightPadding: 20
                bottomPadding: 20
                topPadding: 20
                horizontalAlignment: HorizontalAlignment.Left
                verticalAlignment: VerticalAlignment.Bottom
                
                Container 
                {
                    layout: DockLayout {}
                    
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    
                    ImageButton 
                    {
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        
                        defaultImageSource: 
                        {
                            var image = "";

                            if(_snap2chatAPIData.unopenedSnaps > 0)
                            {
                                image = "asset:///images/snapchat/aa_camera_feed_button_notification.png"
                            }
                            else 
                            {
                                image = "asset:///images/snapchat/aa_camera_feed_empty_button.png"
                            }
                            
                            return image;
                        }
                        
                        onClicked: 
                        {
                            close(feedsTab);
                        }
                    }
                    
                    Container 
                    {
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        visible: (_snap2chatAPIData.unopenedSnaps > 0)
                        touchPropagationMode: TouchPropagationMode.PassThrough
                        
                        Label 
                        {
                            text: (_snap2chatAPIData.unopenedSnaps > 9 ? "+" : _snap2chatAPIData.unopenedSnaps)
                            textStyle.color: Color.White
                            textStyle.textAlign: TextAlign.Center
                            textStyle.fontWeight: FontWeight.Bold
                            textStyle.fontSize: FontSize.Large
                            touchPropagationMode: TouchPropagationMode.PassThrough
                        }
                    }
                }
                
                gestureHandlers: TapHandler 
                {
                    onTapped:
                    {
                        close(feedsTab);
                    }
                }
            }
            
            Container 
            {
                id: videoSlider
                visible: _app.vfMode == 2
                leftPadding: 20
                rightPadding: 20
                bottomPadding: 200
                topPadding: 20
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Bottom
                
                Label 
                {
                    id: recordingCountDownTimer
                    visible: _app.capturing
                    text: recordedSeconds
                    textStyle.color: Color.White
                    horizontalAlignment: HorizontalAlignment.Center
                }
                
                Slider 
                {
                    id: recordingSlider
                    visible: _app.capturing
                    value: recordedSeconds
                    toValue: maxRecordingSeconds
                }
            }
            
            Container 
            {
                id: attach
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Top
                
                ImageButton 
                {
                    defaultImageSource: "asset:///images/snapchat/aa_chat_camera_upload.png"

                    onClicked: 
                    {
                        filePicker.open();
                    }
                    
                    attachedObjects: FilePicker
                    {
                        id: filePicker
                        onFileSelected: 
                        {
                            if(_app.purchasedAds)
                            {
                                var file = selectedFiles[0];
                                
                                if(_app.contains(file, ".jpg") || _app.contains(file, ".jpeg") || _app.contains(file, ".png") || _app.contains(file, ".mp4"))
                                {
                                    var extension = ".jpg";
                                    
                                    if(_app.contains(file, ".mp4"))
                                    {
                                        extension = ".mp4";
                                    }
                                    
                                    _app.tempID = _app.tempID + 1;
                                    
                                    _app.copy(file, _app.getHomePath() + "/files/sent/temporary-" + _app.tempID + extension);
                                    openEditSnapSheet(_app.getHomePath() + "/files/sent/temporary-" + _app.tempID + extension, false, true);
                                }
                                else
                                {
                                    _app.showDialog("Error", "Sorry but this file: " + file + " is not a valid image or video.");
                                }
                            }
                            else 
                            {
                                Qt.toastX.pop("Send snaps from your gallery.\n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                Qt.proSheet.open();
                            }
                        }
                    }
                }
            }
            
            Container 
            {
                id: shoot
                leftPadding: 20
                rightPadding: 20
                bottomPadding: 20
                topPadding: 20
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Bottom
                
                ImageButton 
                {
                    defaultImageSource: (_app.vfMode == 1 ? "asset:///images/snapchat/aa_camera_button.png" : "asset:///images/snapchat/aa_camera_button_video_recording.png")
                    pressedImageSource: (_app.vfMode == 1 ? "asset:///images/snapchat/aa_camera_button_pressed.png" : "asset:///images/snapchat/aa_camera_button_video_recording.png")
                    preferredHeight: 170
                    preferredWidth: preferredHeight
                    onClicked: 
                    {
                        startShoot();
                    }
                    
                    onTouch: 
                    {
                        if(_app.vfMode == 2)
                    	{
                            if(event.touchType == TouchType.Down && !_app.capturing)
                            {
                                startShoot();
                            }   
                            else if(event.touchType == TouchType.Up && _app.capturing)
                            {
                                stopShoot();
                            }
                    	}
                    }
                    
                    gestureHandlers: LongPressHandler 
                    {
	                    onLongPressed: 
	                    {
                            if(_app.vfMode == 1)
                            {
                                _app.showDialog("Attention", "To switch between video and photo mode just double tap the screen. To start the video recording press and hold the red button. :)");
                            }
                        }
                    }
                }
            }
            
            Container 
            {
                id: friends
                leftPadding: 20
                rightPadding: 20
                bottomPadding: 20
                topPadding: 20
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Bottom
                
                Container 
                {
                    layout: DockLayout {}
                    
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    
                    ImageButton 
                    {
                        defaultImageSource:
                        {
                            var image = "";
 
                            if(_snap2chatAPIData.friendRequests > 0)
                            {
                                image = "asset:///images/snapchat/aa_camera_my_friends_new_items.png"
                            }
                            else 
                            {
                                image = "asset:///images/snapchat/aa_camera_my_friends_button.png"
                            }
                            
                            return image;
                        }
                        
                        onClicked: 
                        {
                            close(friendsTab);
                        }
                    }
                    
                    Container 
                    {
                        visible: (_snap2chatAPIData.friendRequests > 0)
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
 
                        Label 
                        {
                            text: (_snap2chatAPIData.friendRequests > 9 ? "+" : _snap2chatAPIData.friendRequests)
                            textStyle.color: Color.White
                            textStyle.textAlign: TextAlign.Center
                            textStyle.fontWeight: FontWeight.Bold
                            textStyle.fontSize: FontSize.Large
                        }
                    }
                }
                
                gestureHandlers: TapHandler 
                {
                    onTapped:
                    {
                        close(friendsTab);
                    }
                }
            }
        }
    }

    onCreationCompleted: 
    {
        createObjects();
        
        _app.openSnapEditorSignal.connect(openEditSnapSheet);
    }

    function close(thetab)
    {
        recordedSeconds 	= 1;
        parameters 			= null;
        
        theAttachedObjects.recordingTimerInteract.stop();
        
        tabbedPane.showTabs("camera", thetab)
    }

    function openEditSnapSheet(fileLocation, mirror, attached)
    {
        turnOffVideoFlash();
        
        frontFlashMode = false;
        
        var valid = false;
        
        if(!_app.contains(fileLocation, ".mp4"))
        {
            _app.preProcess(fileLocation, mirror);
            
            valid = true;
        }
        else 
        {
            editSnapSheet.recordedSeconds = lastRecordedSeconds;
            
            if(_app.validFileSize(fileLocation))
            {
                valid = true;
            }
            else 
            {
                valid = false;
            }
        }
        
        if(parameters)
        {
            editSnapSheet.replyMode 			= parameters.replyMode;
            editSnapSheet.recipient 			= parameters.recipient;
            editSnapSheet.postToShoutBox 		= parameters.postToShoutBox;
        }
        else 
        {
            editSnapSheet.replyMode 			= false;
            editSnapSheet.recipient 			= "";
            editSnapSheet.postToShoutBox 		= false;
        }
        
        editSnapSheet.fileLocation 				= fileLocation;
        
        if(attached)
        {
            if(valid)
            {
                editSnapSheet.open();
            }
            else 
            {
                _app.showDialog("Error", "The file " + fileLocation + " you attached is over the 1MB limit. SnapChat doesn't allow above 1MB snaps to be sent. Or the file you attached isn't valid at all.");
            }
        }
        else 
        {
            editSnapSheet.open();
        }
    }
}