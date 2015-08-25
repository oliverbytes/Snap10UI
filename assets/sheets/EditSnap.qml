import bb.cascades 1.2
import bb.system 1.0
import bb.cascades.pickers 1.0
import QtQuick 1.0
import nemory.PictureEditor 1.0
import nemory.VideoEditor 1.0

import "../components"
import "../emoticons"
import "../emoji"

Sheet 
{
    id: sheet
    peekEnabled: false;
    
    property string fileLocation
    property bool screenShotMode : false
    property bool replyMode : false;
    property bool postToShoutBox : false;
    property string recipient : "";
    property variant cameraPage;
    property int captionLastPositionY : 350;
    property int recordedSeconds: 0;
    property bool firstRunCaption : true;
    property bool addToStory : false;
    property bool isPainting : false;
    property bool isPaintingEnabled : false;
    
    function isPhoto()
    {
        var isphoto = false;
        
        if(_app.contains(fileLocation, ".jpg") || _app.contains(fileLocation, ".png"))
        {
            isphoto = true;
        }
        
        return isphoto;
    }
    
    onOpened: 
    {
        firstRunCaption = true;
        
        if(!isPhoto())
        {
            videoPlayerContainer.stopVideo();
            videoPlayerContainer.playVideo("file://" + fileLocation);

            timerDropDown.selectedIndex = recordedSeconds - 1;
        }
        else 
        {
            theimage.imageSource = "file://" + fileLocation
        }
    }
    
    onClosed: 
    {
        theimage.imageSource = "";
        
        videoPlayerContainer.stopVideo();
        
        canvasWebView.reload();
        
        recordedSeconds = 0;
        fileLocation = "";
        replyMode = false;
        postToShoutBox = false;
        recipient = "";
        captionLastPositionY = 350;
        addToStory = false;
        
        captionText.resetText();
        caption.resetScale();
        caption.resetTranslation();
        caption.resetRotationZ();
        caption.translationY = 350;
        
        theimage.resetScale();
        theimage.resetTranslation();
        theimage.resetRotationZ();
    }
    
    Page 
    {
        Container 
        {
            layout: DockLayout {}
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            background: Color.Black

            Container 
            {
                id: controls
                //visible: !painter.visible
                layout: DockLayout {}
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                ////background: Color.Red
                touchPropagationMode: TouchPropagationMode.PassThrough
    
                gestureHandlers:
                [
                    DoubleTapHandler
                    {
                        onDoubleTapped:
                        {
                            caption.translationY = event.y;
                        }
                    }
                ]
                
                Container 
                {
                    id: videoPlayerContainer
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    property string lastVideoSource : "";
                    
                    attachedObjects: ComponentDefinition 
                    {
                        id: videoPlayerComponent
                        source: "asset:///components/VideoPlayer.qml"
                    }
                    
                    function playVideo(videoSource)
                    {
                        lastVideoSource = videoSource;
                        
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
                }
                
                ImageView 
                {
                    id: theimage
                    visible: (fileLocation.length > 0) && isPhoto()
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    scalingMethod: ScalingMethod.AspectFit
                    
                    property bool pinchHappening: false
                    property double initialScale: 1.0
                    property double scaleFactor: 1.25
                    property double initialRotationZ: 0.0
                    property double rotationFactor: 1.5
                    property bool dragHappening: false
                    property double initialWindowX
                    property double initialWindowY
                    property double dragFactor: 1.25
                    
                    onTouch: 
                    {
                        theimage.requestFocus();
                        
                        emojiInput.visible = false;
                        
                        if (pinchHappening) 
                        {
                            dragHappening = false
                        } 
                        else
                        {
                            if (event.isDown()) 
                            {
                                dragHappening = true
                                
                                if(_app.getSetting("lockImagePosition", "true") == "false")
                                {
                                    initialWindowX = event.windowX
                                    initialWindowY = event.windowY
                                }
                            } 
                            else if (dragHappening && event.isMove()) 
                            {
                                if(_app.getSetting("lockImagePosition", "true") == "false")
                                {
                                    translationX += (event.windowX - initialWindowX) * dragFactor
                                    translationY += (event.windowY - initialWindowY) * dragFactor
                                    initialWindowX = event.windowX
                                    initialWindowY = event.windowY
                                }
                            } 
                            else 
                            {
                                dragHappening = false
                            }
                        }
                    }
                    
                    gestureHandlers: 
                    [
                        PinchHandler 
                        {
                            onPinchStarted: 
                            {
                                theimage.initialScale = theimage.scaleX
                                theimage.initialRotationZ = theimage.rotationZ
                                theimage.pinchHappening = true
                            }
                            onPinchUpdated: 
                            {
                                theimage.scaleX = theimage.initialScale + ((event.pinchRatio - 1) * theimage.scaleFactor)
                                theimage.scaleY = theimage.initialScale + ((event.pinchRatio - 1) * theimage.scaleFactor)
                                theimage.rotationZ = theimage.initialRotationZ + ((event.rotation) * theimage.rotationFactor)
                            }
                            onPinchEnded: 
                            {
                                theimage.pinchHappening = false
                            }
                        }
                    ]
                }
                
                WebView 
                {
                    id: canvasWebView
                    touchPropagationMode: (isPaintingEnabled ? TouchPropagationMode.Full : TouchPropagationMode.None)
                    settings.background: Color.Transparent
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    preferredHeight: _app.getDisplayHeight();
                    preferredWidth: _app.getDisplayWidth();
                    url: "local:///assets/html/canvas.html"
                    
                    onLoadingChanged:
                    {
                        var messageJSON = "{ \"brushSize\":\"" + brushSize.value + "\", \"brushOpacity\":\"" + brushOpacity.value + "\", \"brushColor\":\"" + colorpickerWebView.brushColor + "\" }";
                        canvasWebView.postMessage(messageJSON);
                    }
                    
                    onMessageReceived: 
                    {
                        if(message.data == "up")
                        {
                            isPainting = false;
                        }
                        else if(message.data == "move")
                        {
                            isPainting = true;
                        }
                    }
                    
                    onTouch: 
                    {
                        emojiInput.visible = false;
                        
                        if(event.touchType == TouchType.Up || event.touchType == TouchType.Cancel)
                        {
                            isPainting = false;
                            controls.visible = true;
                        }
                    }
                } 
                
                Container 
                {
                    id: captionDraggingContainer
                    visible: caption.visible && isPhoto()
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    touchPropagationMode: (dragHappening ? TouchPropagationMode.Full : TouchPropagationMode.None)

                    property bool dragHappening: false;
                    
                    property double initialScale: 1.0
                    property double scaleFactor: 1.25
                    property double initialRotationZ: 0.0
                    property double rotationFactor: 1.5
                    property double initialWindowX
                    property double initialWindowY
                    property double dragFactor: 1.25
                    
                    onTouch: 
                    {
                        if(!isPaintingEnabled)
                        {
                            if (caption.pinchHappening) 
                            {
                                dragHappening = false
                            } 
                            else
                            {
                                if (event.isDown()) 
                                {
                                    dragHappening = true
                                    
//                                    if(_app.getSetting("lockCaptionVertically", "true") == "false")
//                                    {
//                                        initialWindowX = event.windowX
//                                    }
//                                    
//                                    initialWindowY = event.windowY
                                } 
                                else if (dragHappening && event.isMove()) 
                                {
                                    caption.translationY += (event.windowY - initialWindowY) * dragFactor
                                    initialWindowY = event.windowY
                                    
                                    if(_app.getSetting("lockCaptionVertically", "true") == "false")
                                    {
                                        caption.translationX += (event.windowX - initialWindowX) * dragFactor
                                        initialWindowX = event.windowX
                                    }
                                } 
                                else 
                                {
                                    dragHappening = false
                                }
                            }
                        }
                        
                        if(event.isCancel())
                        {
                            dragHappening = false
                        }
                    }
                }
                
                Container 
                {
                    id: caption
                    visible: isPhoto() && !isPainting && !isPaintingEnabled
                    translationY: 350
                    //translationY: (theEmoticonsContainer.visible ? 350 : captionLastPositionY)
                    horizontalAlignment: HorizontalAlignment.Fill
                    background: Color.create("#99000000");
                    
                    touchPropagationMode: (captionDraggingContainer.dragHappening ? TouchPropagationMode.None : TouchPropagationMode.Full)

                    layout: StackLayout 
                    {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    property bool pinchHappening: false
                    
                    TextArea 
                    {
                        id: captionText
                        enabled: !captionDraggingContainer.dragHappening
                        touchPropagationMode: (captionDraggingContainer.dragHappening ? TouchPropagationMode.None : TouchPropagationMode.Full)
                        hintText: "Enter Caption Here :)"
                        backgroundVisible: false;
                        textStyle.color: Color.White
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.textAlign: TextAlign.Center
                        inputMode: TextAreaInputMode.Chat
                        input.submitKey: SubmitKey.Send

                        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.Emoticons
                        focusRetentionPolicyFlags: FocusRetentionPolicy.LoseToFocusable
                        implicitLayoutAnimationsEnabled: false
                        
                        input.onSubmitted: 
                        {
                            if (captionText.text.length == 0)
                            {
                                captionBackground.requestFocus();
                            }
                        }
                        
                        gestureHandlers: 
                        [
                            TapHandler 
                            {
                                onTapped: 
                                {
                                    captionText.requestFocus();
                                }
                            }
                        ]
                    }
                    
                    onTouch: 
                    {
                        if (event.isMove() && !caption.pinchHappening) 
	                    {
                            captionDraggingContainer.dragHappening = true;
	                    }
                        
                        if(!isPaintingEnabled)
                        {
                            if (!caption.pinchHappening) 
                            {
                                if (event.isDown()) 
                                {
                                    if(_app.getSetting("lockCaptionVertically", "true") == "false")
                                    {
                                        captionDraggingContainer.initialWindowX = event.windowX
                                    }
                                    
                                    captionDraggingContainer.initialWindowY = event.windowY
                                }
                            }
                        }
                    }

                    gestureHandlers: 
                    [
                        PinchHandler 
                        {
                            onPinchStarted: 
                            {
                                if(!isPaintingEnabled)
                                {
                                    captionDraggingContainer.initialScale = caption.scaleX
                                    captionDraggingContainer.initialRotationZ = caption.rotationZ
                                    caption.pinchHappening = true
                                }
                            }
                            onPinchUpdated: 
                            {
                                if(!isPaintingEnabled)
                                {
                                    caption.scaleX = captionDraggingContainer.initialScale + ((event.pinchRatio - 1) * captionDraggingContainer.scaleFactor)
                                    caption.scaleY = captionDraggingContainer.initialScale + ((event.pinchRatio - 1) * captionDraggingContainer.scaleFactor)
                                    caption.rotationZ = captionDraggingContainer.initialRotationZ + ((event.rotation) * captionDraggingContainer.rotationFactor)
                                }
                            }
                            onPinchEnded: 
                            {
                                caption.pinchHappening = false;
                            }
                        },
                        TapHandler 
                        {
                            onTapped: 
                            {
                                captionText.requestFocus();
                                emojiInput.visible = false;
                            }
                        }
                    ]
                }
                
                Container 
                {
                    id: deletePhoto
                    visible: !screenShotMode && !isPainting

                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Top

                    ImageButton 
                    {
                        defaultImageSource: "asset:///images/snapchat/aa_snap_preview_x.png"

                        onClicked: 
                        {
                            deletePrompt.show();
                        }
                        
                        attachedObjects: SystemDialog
                        {
                            id: deletePrompt
                            title: "Attention"
                            body: "Are you sure you want to delete this snapsterpiece?"
                            modality: SystemUiModality.Application
                            confirmButton.label: "Delete"
                            confirmButton.enabled: true
                            dismissAutomatically: true
                            cancelButton.label: "Cancel"
                            onFinished: 
                            {
                                if(buttonSelection().label == "Delete")
                                {
                                    videoPlayerContainer.stopVideo();
                                    
                                    _app.deletePhoto(fileLocation);
                                    
                                    if(friendChooserSheet.fileLocation.length > 0)
                                    {
                                        _app.deletePhoto(friendChooserSheet.fileLocation);
                                    }
                                    
                                    close();
                                }
                            }
                        }
                    }
                }
                
                Container 
                {
                    rightPadding: 20
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Top
                    visible: !screenShotMode && isPhoto()
                    
                	layout: StackLayout 
                	{
                    	orientation: LayoutOrientation.LeftToRight
                    }  
                	
                    Container 
                    {
                        id: colorPickerUndo
                        visible: isPaintingEnabled
                        layout: DockLayout {}
                        
                        ImageButton 
                        {
                            defaultImageSource: "asset:///images/snapchat/aa_snap_preview_undo.png"

                            onClicked:
                            {
                                canvasWebView.reload();
                            }
                        }
                    }
                	
                    Container 
                    {
                        id: verticalStack
                        
                        Container 
                        {
                            id: colorPicker
                            layout: DockLayout {}
                            
                            Container 
                            {
                                id: colorPickerBackground
                                visible: isPaintingEnabled
                                preferredHeight: 70
                                preferredWidth: 70
                                background: Color.Green
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                            }
                            
                            ImageButton 
                            {
                                defaultImageSource: (isPaintingEnabled ? "asset:///images/snapchat/aa_snap_preview_color_picker_button_pressed.png" : "asset:///images/snapchat/aa_snap_preview_color_picker_button.png")
                                pressedImageSource: "asset:///images/snapchat/aa_snap_preview_color_picker_button_pressed.png"

                                onClicked: 
                                {
                                    isPaintingEnabled = !isPaintingEnabled;
                                }
                            }
                        }
                        
                        Container 
                        {
                            id: colorPickerSelect
                            visible: isPaintingEnabled
                            layout: DockLayout {}
                            
                            ImageButton
                            {
                                defaultImageSource: "asset:///images/colorpickerbutton.png"
                                preferredHeight: 120
                                preferredWidth: 120
                                onClicked: 
                                {
                                   brushDialog.open();
                                }
                            }
                        }
                    }
                }
                
                Container 
                {
                    id: advancedOptionButton
                    visible: !screenShotMode && !isPainting
                    topPadding: 26
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Top
                    
                    ImageButton 
                    {
                        defaultImageSource: "asset:///images/snapchat/aa_action_bar_settings_icon_white.png"
                        
                        onClicked: 
                        {
                            advancedOptionsDialog.open();
                        }
                    }
                }

                Container 
                {
                    visible: !screenShotMode && !isPainting
                    verticalAlignment: VerticalAlignment.Bottom

                    layout: StackLayout 
                    {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    Container 
                    {
                        id: timerPickerButton
                        layout: DockLayout {}
                        
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                    
	                    ImageButton 
	                    {
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
	                        defaultImageSource: "asset:///images/snapchat/aa_snap_preview_timer.png"
	                        
	                        onClicked: 
	                        {
                                timerPickerDialog.open();
	                        }
	                    }
	                    
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Center
                            verticalAlignment: VerticalAlignment.Center
                            topPadding: 7
                            touchPropagationMode: TouchPropagationMode.PassThrough

                            Label 
                            {
                                horizontalAlignment: HorizontalAlignment.Center
                                verticalAlignment: VerticalAlignment.Center
                                text: timerDropDown.selectedValue
                                textStyle.color: Color.White
                                textStyle.fontSize: FontSize.XSmall
                                touchPropagationMode: TouchPropagationMode.PassThrough
                            }
                        }
                        
                        gestureHandlers: TapHandler 
                        {
                            onTapped:
                            {
                                timerPickerDialog.open();
                            }
                        }
                    }
                    
                    ImageButton 
                    {
                        defaultImageSource: "asset:///images/snapchat/aa_snap_preview_save.png"

                        onClicked: 
                        {
                            filePickerSaver.open();
                        }
                        
                        attachedObjects: FilePicker 
                        {
                            id: filePickerSaver
                            type: FileType.Picture
                            title : "Save To Location"
                            defaultType: FileType.Picture
                            mode: FilePickerMode.SaverMultiple
                            viewMode: FilePickerViewMode.ListView
                            onFileSelected :
                            {
                                if(_app.purchasedAds)
                                {
                                    var folder = selectedFiles[0];
                                    var dateToday = new Date();
                                    
                                    if(isPhoto())
                                    {
                                        _app.copy(fileLocation, folder + "/snap2chat-" + dateToday.getTime() + ".jpg")
                                    }
                                    else 
                                    {
                                        _app.copy(fileLocation, folder + "/snap2chat-" + dateToday.getTime() + ".mp4")
                                    }
                                }
                                else 
                                {
                                    Qt.toastX.pop("Be able to save snaps to your phone. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                        }
                    }
                    
                    ImageButton 
                    {
                        defaultImageSource:  "asset:///images/snapchat/aa_snap_preview_post_story.png"

                        onClicked:
                        {
                            addToStoryPrompt.show();
                        }
                        
                        attachedObjects: SystemDialog
                        {
                            id: addToStoryPrompt
                            title: "Add To Your Story?"
                            body: "Adding a Snap to your Story allows your followers to view your Snap an unlimited number of times for 24 hours. Would you like to add this to Snap to your Story?"
                            modality: SystemUiModality.Application
                            confirmButton.label: "Add To Story"
                            confirmButton.enabled: true
                            dismissAutomatically: true
                            cancelButton.label: "Don't Add"
                            onFinished: 
                            {
                                if(buttonSelection().label == "Add To Story")
                                {
                                    addToStory = true;
                                    //_app.showToast("This snap will be added to your story once sent.");
                                }
                                else if(buttonSelection().label == "Don't Add")
                                {
                                    addToStory = false;
                                    //_app.showToast("Will no longer be added to your story when sent.");
                                }
                            }
                        }
                    }
                    
                    ImageButton 
                    {
                        visible: !screenShotMode && isPhoto()
                        defaultImageSource: "asset:///images/snapchat/quick_snap_front.png"
                        
                        onClicked: 
                        {
                            emojiInput.visible = true;
                        }
                    }
                }

                Container 
                {
                    id: send
                    visible: !screenShotMode && !isPainting
                    leftPadding: 20
                    rightPadding: 20
                    bottomPadding: 20
                    topPadding: 20
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Bottom

                    ImageButton 
                    {
                        defaultImageSource: "asset:///images/snapchat/send_to_icon_enabled.png"
      
                        onClicked: 
                        {
                            screenShotMode = true;
                            //theEmoticonsContainer.visible = false;
                            
                            if(captionText.text.length == 0 || captionText.text == "")
                            {
                                caption.visible = false;
                            }
                            
                            screenshotTimer.start();
                        }
                        
                        attachedObjects:
                        [
                            FriendChooser 
                            {
                                id: friendChooserSheet
                                editSnapSheet: sheet
                                onPlayVideo: 
                                {
                                    videoPlayerContainer.playVideo(videoPlayerContainer.lastVideoSource);
                                }
                            },
                            Timer 
                            {
                                id: screenshotTimer
                                interval: 200
                                onTriggered: 
                                {
                                    if(isPhoto())
                                    {
                                        _app.captureScreen(OrientationSupport.orientation);
                                    }
                                    else 
                                    {
                                        videoPlayerContainer.stopVideo();
                                    }

                                    screenShotMode = false;

                                    caption.visible = true;
 
                                    if(!postToShoutBox)
                                    {
                                        friendChooserSheet.snapTimer 				= timerDropDown.selectedValue;
                                        friendChooserSheet.replyMode 				= replyMode;
                                        friendChooserSheet.recipient 				= recipient;
                                        friendChooserSheet.fileLocation 			= fileLocation;
                                        friendChooserSheet.addToStory 				= addToStory;
                                        friendChooserSheet.open();
                                    }
                                    else
                                    {
                                        close();
                                        cameraPage.close();
                                        _app.setSetting("shoutBoxImage", fileLocation);
                                    }
                                }
                            }
                        ]
                    }
                }
            }
            
            EmojiKeyboard 
            { 
                id: emojiInput
                //visible: true
                visible: false && !screenShotMode && isPhoto() && !firstRunCaption && !isPainting
                
                property int lastKeyboardY;
                
                onEmojiTapped: 
                {
                    if(_app.purchasedAds)
                    {
                        captionText.editor.insertPlainText(getUnicodeCharacter('0x'+chars));
                    }
                    else 
                    {
                        Qt.toastX.pop("Insert Emojis and BBM Emoticons \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                        Qt.proSheet.open();
                    }
                }
                
                onBbmEmoticonTapped: 
                {
                    if(_app.purchasedAds)
                    {
                        captionText.editor.insertPlainText(data);
                    }
                    else 
                    {
                        Qt.toastX.pop("Insert Emojis and BBM Emoticons \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                        Qt.proSheet.open();
                    }
                }
                
                onKeyboardShown1: 
                {
                    lastKeyboardY = caption.translationY;
                    caption.translationY = 100;
                }
                
                onKeyboardHidden1: 
                {
                    caption.translationY = lastKeyboardY;
                }
            }
        }
    }
    
    attachedObjects: 
    [
        Dialog 
        {
            id: timerPickerDialog
            
            Container 
            {
                id: timerPickerContainer
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
                    
                    Label 
                    {
                        text: "Time limit to be viewed in seconds."
                        textStyle.color: Color.White
                        multiline: true
                    }
                    
                    DropDown 
                    {
                        id: timerDropDown
                        title: "Timer"
                        selectedIndex: _app.getSetting("timerDropDown", "5");
                        
                        onSelectedIndexChanged: 
                        {
                            _app.setSetting("timerDropDown", selectedIndex);
                            
                            timerPickerDialog.close();
                        }
                        
                        options: 
                        [
                            Option 
                            {
                                text: "1 seconds"
                                value: 1
                            },
                            Option 
                            {
                                text: "2 seconds"
                                value: 2
                            },
                            Option 
                            {
                                text: "3 seconds"
                                value: 3
                            },
                            Option 
                            {
                                text: "4 seconds"
                                value: 4
                            },
                            Option 
                            {
                                text: "5 seconds"
                                value: 5
                            },
                            Option 
                            {
                                text: "6 seconds"
                                value: 6
                            },
                            Option 
                            {
                                text: "7 seconds"
                                value: 7
                            },
                            Option 
                            {
                                text: "8 seconds"
                                value: 8
                            },
                            Option 
                            {
                                text: "9 seconds"
                                value: 9
                            },
                            Option 
                            {
                                text: "10 seconds"
                                value: 10
                            }
                        ]
                    }
                }
                
                ImageButton 
                {
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Top
                    defaultImageSource: "asset:///images/snapchat/aa_snap_preview_x.png"

                    onClicked: 
                    {
                        timerPickerDialog.close();
                    }
                }
            }
        }
        ,Dialog 
        {
            id: advancedOptionsDialog
            
            Container 
            {
                id: advancedOptionsContainer
                leftPadding: 50
                rightPadding: 50
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                background: Color.create("#DD000000")
                
                ImageButton 
                {
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Top
                    defaultImageSource: "asset:///images/snapchat/aa_snap_preview_x.png"

                    onClicked: 
                    {
                        advancedOptionsDialog.close();
                    }
                }
                
                ScrollView 
                {
                    Container 
                    {
                        id: scrollViewContainer
                        
                        Label 
                        {
                            text: "Advanced Options"
                            textStyle.color: Color.White
                            multiline: true
                        }
                        
                        Button 
                        {
                            text: "Edit in Advanced Media Editor"
                            horizontalAlignment: HorizontalAlignment.Fill
                            onClicked: 
                            {
                                if(isPhoto())
                                {
                                    pictureEditor.invokePictureEditor("file://" + fileLocation);
                                }
                                else
                                {
                                    _app.showDialog("Attention", "Using this editor may / may not bump the video size more than 1M. If more than 1MB your video will fail to send.");
                                    videoPlayerContainer.stopVideo();
                                    videoEditor.invokeVideoEditor(fileLocation);
                                }
                            }
                            
                            attachedObjects:
                            [
                                PictureEditor
                                {
                                    id: pictureEditor
                                    onComplete: 
                                    {
                                        if(imageSource.length > 0 && imageSource != "")
                                        {
                                            if(_app.purchasedAds)
                                            {
                                                var newImageSource = _app.getHomePath() + "/files/sent/temporary-" + _app.tempID + ".jpg";
                                                _app.copyAndRemove(imageSource, newImageSource);
                                                theimage.imageSource = "";
                                                theimage.imageSource = "file://" + newImageSource;
                                                fileLocation = newImageSource;
                                            }
                                            else 
                                            {
                                                Qt.toastX.pop("Like the last edited photo? Want to save snaps on your phone? You can when you're on the pro version. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                                Qt.proSheet.open();
                                            }
                                        }
                                    }
                                },
                                VideoEditor
                                {
                                    id: videoEditor
                                    onComplete: 
                                    {
                                        if(videoSource.length > 0 && videoSource != "")
                                        {
                                            if(_app.purchasedAds)
                                            {
                                                fileLocation = videoSource;
                                                videoPlayerContainer.playVideo("file://" + videoSource);
                                            }
                                            else 
                                            {
                                                Qt.toastX.pop("Be able to edit Videos before you send them. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                                Qt.proSheet.open();
                                            }
                                        }
                                    }
                                    onCanceled: 
                                    {
                                        videoPlayer.playVideo(videoPlayerContainer.lastVideoSource);
                                    }
                                }
                            ]
                        }
                        
                        DropDown 
                        {
                            id: captionFont
                            selectedIndex: _app.getSetting("captionFontIndex", "5")
                            title: "Font Face"
                            options:
                            [
                                Option 
                                {
                                    text: "Default"
                                    value: ""
                                },
                                Option 
                                {
                                    text: "Helvetica"
                                    value: text
                                },
                                Option 
                                {
                                    text: "Arial Black"
                                    value: text
                                },
                                Option 
                                {
                                    text: "Impact"
                                    value: text
                                },
                                Option 
                                {
                                    text: "Tahoma"
                                    value: text
                                },
                                Option 
                                {
                                    text: "Instagram Font"
                                    value: "InstagramFont"
                                }
                            ]
                            onSelectedIndexChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    _app.setSetting("captionFontIndex", selectedIndex);
                                }
                            }
                            onSelectedValueChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    if(selectedValue == "InstagramFont")
                                    {
                                        captionText.textStyle.base = instagramTextStyle.style;
                                        captionText.textStyle.fontFamily = "InstagramFont, sans-serif";
                                    }
                                    else 
                                    {
                                        captionText.textStyle.base = SystemDefaults.TextStyles.BodyText;
                                        captionText.textStyle.fontFamily = selectedValue;
                                    }
                                    
                                    _app.setSetting("captionFont", selectedValue);
                                }
                                else 
                                {
                                    Qt.toastX.pop("Be able to customize fonts like the beautiful Instagram font. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                            
                            attachedObjects: 
                            [
                                TextStyleDefinition 
                                {
                                    id: instagramTextStyle
                                    base: SystemDefaults.TextStyles.BodyText
                                    fontFamily: "InstagramFont, sans-serif"
                                    // 10.2
                                    rules: 
                                    [
                                        FontFaceRule 
                                        {
                                            source: "asset:///fonts/billabong.ttf"
                                            fontFamily: "InstagramFont"
                                        }
                                    ]
                                }
                            ]
                        }
                        
                        DropDown 
                        {
                            id: fontSize
                            selectedIndex: _app.getSetting("fontSizeIndex", "6")
                            title: "Font Size"
                            options:
                            [
                                Option 
                                {
                                    text: "Default"
                                    value: FontSize.Default
                                },
                                Option 
                                {
                                    text: "XXSmall"
                                    value: FontSize.XXSmall
                                },
                                Option 
                                {
                                    text: "XSmall"
                                    value: FontSize.XSmall
                                },
                                Option 
                                {
                                    text: "Small"
                                    value: FontSize.Small
                                },
                                Option 
                                {
                                    text: "Medium"
                                    value: FontSize.Medium
                                },
                                Option 
                                {
                                    text: "Large"
                                    value: FontSize.Large
                                },
                                Option 
                                {
                                    text: "XLarge"
                                    value: FontSize.XLarge
                                },
                                Option 
                                {
                                    text: "XXLarge"
                                    value: FontSize.XXLarge
                                }
                            ]
                            onSelectedIndexChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    _app.setSetting("fontSizeIndex", selectedIndex);
                                }
                            }
                            onSelectedValueChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    captionText.textStyle.fontSize = selectedValue;
                                    _app.setSetting("fontSize", selectedValue);
                                }
                                else 
                                {
                                    Qt.toastX.pop("Customize the Font Size. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                        }
                        
                        DropDown 
                        {
                            id: fontColor
                            selectedIndex: _app.getSetting("fontColorIndex", "0")
                            title: "Font Color"
                            options:
                            [
                                Option 
                                {
                                    text: "Default"
                                    value: Color.White
                                },
                                Option 
                                {
                                    text: "Black"
                                    value: Color.Black
                                },
                                Option 
                                {
                                    text: "Blue"
                                    value: Color.Blue
                                },
                                Option 
                                {
                                    text: "Cyan"
                                    value: Color.Cyan
                                },
                                Option 
                                {
                                    text: "Dark Blue"
                                    value: Color.DarkBlue
                                },
                                Option 
                                {
                                    text: "Dark Cyan"
                                    value: Color.DarkCyan
                                },
                                Option 
                                {
                                    text: "Dark Gray"
                                    value: Color.DarkGray
                                },
                                Option 
                                {
                                    text: "Dark Green"
                                    value: Color.DarkGreen
                                },
                                Option 
                                {
                                    text: "Dark Magenta"
                                    value: Color.DarkMagenta
                                },
                                Option 
                                {
                                    text: "Dark Red"
                                    value: Color.DarkRed
                                },
                                Option 
                                {
                                    text: "Dark Yellow"
                                    value: Color.DarkYellow
                                },
                                Option 
                                {
                                    text: "Gray"
                                    value: Color.Gray
                                },
                                Option 
                                {
                                    text: "Green"
                                    value: Color.Green
                                },
                                Option 
                                {
                                    text: "Light Gray"
                                    value: Color.LightGray
                                },
                                Option 
                                {
                                    text: "Magenta"
                                    value: Color.Magenta
                                },
                                Option 
                                {
                                    text: "Red"
                                    value: Color.Red
                                },
                                Option 
                                {
                                    text: "Yellow"
                                    value: Color.Yellow
                                }
                            ]
                            onSelectedIndexChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    _app.setSetting("fontColorIndex", selectedIndex);
                                }
                            }
                            onSelectedValueChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    captionText.textStyle.color = selectedValue;
                                    _app.setSetting("fontColor", selectedValue);
                                }
                                else 
                                {
                                    Qt.toastX.pop("Customize the Font Color. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                        }
                        
                        DropDown 
                        {
                            id: fontWeight
                            selectedIndex: _app.getSetting("fontWeightIndex", "0")
                            title: "Font Weight"
                            options:
                            [
                                Option 
                                {
                                    text: "Default"
                                    value: FontWeight.Default
                                },
                                Option 
                                {
                                    text: "Bold"
                                    value: FontWeight.Bold
                                },
                                Option 
                                {
                                    text: "Normal"
                                    value:FontWeight.Normal
                                },
                                Option 
                                {
                                    text: "Thin"
                                    value: FontWeight.W100
                                },
                                Option 
                                {
                                    text: "Super Bold"
                                    value: FontWeight.W900
                                }
                            ]
                            onSelectedIndexChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    _app.setSetting("fontWeightIndex", selectedIndex);
                                }
                            }
                            onSelectedValueChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    captionText.textStyle.fontWeight = selectedValue;
                                    _app.setSetting("fontWeight", selectedValue);
                                }
                                else 
                                {
                                    Qt.toastX.pop("Customize the font weight. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                        }
                        
                        DropDown 
                        {
                            id: fontStyle
                            selectedIndex: _app.getSetting("fontStyleIndex", "0")
                            title: "Font Style"
                            options:
                            [
                                Option 
                                {
                                    text: "Default"
                                    value: FontStyle.Default
                                },
                                Option 
                                {
                                    text: "Italic"
                                    value: FontStyle.Italic
                                },
                                Option 
                                {
                                    text: "Normal"
                                    value: FontStyle.Normal
                                }
                            ]
                            onSelectedIndexChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    _app.setSetting("fontStyleIndex", selectedIndex);
                                }
                            }
                            onSelectedValueChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    captionText.textStyle.fontStyle = selectedValue;
                                    _app.setSetting("fontStyle", selectedValue);
                                }
                                else 
                                {
                                    Qt.toastX.pop("Customize the Font Style \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                        }
                        
                        DropDown 
                        {
                            id: fontAlignment
                            selectedIndex: _app.getSetting("textAlignmentIndex", "0")
                            title: "Text Alignment"
                            options:
                            [
                                Option 
                                {
                                    text: "Center"
                                    value: TextAlign.Center
                                },
                                Option 
                                {
                                    text: "Left"
                                    value: TextAlign.Left
                                },
                                Option 
                                {
                                    text: "Right"
                                    value: TextAlign.Right
                                },
                                Option 
                                {
                                    text: "Justify"
                                    value: TextAlign.Justify
                                }
                            ]
                            onSelectedIndexChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    _app.setSetting("textAlignmentIndex", selectedIndex);
                                }
                            }
                            onSelectedValueChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    captionText.textStyle.textAlign = selectedValue;
                                    _app.setSetting("textAlignment", selectedValue);
                                }
                                else 
                                {
                                    Qt.toastX.pop("Customize the Text Alignment. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                        }
                        
                        DropDown 
                        {
                            id: captionBackground
                            selectedIndex: _app.getSetting("captionBackgroundIndex", "0")
                            title: "Caption Background"
                            options:
                            [
                                Option 
                                {
                                    text: "Default"
                                    value: Color.create("#99000000")
                                },
                                Option 
                                {
                                    text: "Transparent"
                                    value: Color.Transparent
                                },
                                //                                Option 
                                //                                {
                                //                                    text: "CrackBerry Orange"
                                //                                    value: Color.create("#f75e11");
                                //                                },
                                Option 
                                {
                                    text: "Black"
                                    value: Color.Black
                                },
                                Option 
                                {
                                    text: "Blue"
                                    value: Color.Blue
                                },
                                Option 
                                {
                                    text: "Cyan"
                                    value: Color.Cyan
                                },
                                Option 
                                {
                                    text: "Dark Blue"
                                    value: Color.DarkBlue
                                },
                                Option 
                                {
                                    text: "Dark Cyan"
                                    value: Color.DarkCyan
                                },
                                Option 
                                {
                                    text: "Dark Gray"
                                    value: Color.DarkGray
                                },
                                Option 
                                {
                                    text: "Dark Green"
                                    value: Color.DarkGreen
                                },
                                Option 
                                {
                                    text: "Dark Magenta"
                                    value: Color.DarkMagenta
                                },
                                Option 
                                {
                                    text: "Dark Red"
                                    value: Color.DarkRed
                                },
                                Option 
                                {
                                    text: "Dark Yellow"
                                    value: Color.DarkYellow
                                },
                                Option 
                                {
                                    text: "Gray"
                                    value: Color.Gray
                                },
                                Option 
                                {
                                    text: "Green"
                                    value: Color.Green
                                },
                                Option 
                                {
                                    text: "Light Gray"
                                    value: Color.LightGray
                                },
                                Option 
                                {
                                    text: "Magenta"
                                    value: Color.Magenta
                                },
                                Option 
                                {
                                    text: "Red"
                                    value: Color.Red
                                },
                                Option 
                                {
                                    text: "Yellow"
                                    value: Color.Yellow
                                }
                            ]
                            onSelectedIndexChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    _app.setSetting("captionBackgroundIndex", selectedIndex);
                                }
                            }
                            onSelectedValueChanged: 
                            {
                                if(_app.purchasedAds)
                                {
                                    caption.background = selectedValue;
                                    _app.setSetting("captionBackground", selectedValue);
                                }
                                else 
                                {
                                    Qt.toastX.pop("Set a custom Text Background Color \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                        }
                        
                        Button 
                        {
                            text: "Reset to Original Photo"
                            horizontalAlignment: HorizontalAlignment.Fill
                            
                            onClicked:
                            {
                                if(_app.purchasedAds)
                                {
                                    captionText.resetText();
                                    caption.resetScale();
                                    caption.resetTranslation();
                                    caption.resetRotationZ();
                                    
                                    theimage.resetScale();
                                    theimage.resetTranslation();
                                    theimage.resetRotationZ();
                                }
                                else 
                                {
                                    Qt.toastX.pop("Reset all changes in one click. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                    Qt.proSheet.open();
                                }
                            }
                        }
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Lock Captions Vertically"  
                                textStyle.color: Color.White
                            }
                            
                            ToggleButton 
                            {
                                id: lockCaptionVertically
                                checked: _app.getSetting("lockCaptionVertically", "true");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged:
                                {
                                    _app.setSetting("lockCaptionVertically", checked);
                                }
                            }
                        }
                        
                        Divider {}
                        
                        Container 
                        {
                            horizontalAlignment: HorizontalAlignment.Fill  
                            
                            layout: DockLayout {}
                            
                            Label
                            {
                                text: "Lock Image Position"  
                                textStyle.color: Color.White
                            }
                            
                            ToggleButton 
                            {
                                id: lockImagePosition
                                checked: _app.getSetting("lockImagePosition", "true");
                                horizontalAlignment: HorizontalAlignment.Right
                                onCheckedChanged:
                                {
                                    _app.setSetting("lockImagePosition", checked);
                                }
                            }
                        }
                    }
                }
            }
        },
        Dialog 
        {
            id: brushDialog
            
            Container 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                background: Color.create("#eeffffff")
                leftPadding: 20.0
                rightPadding: 20.0
                topPadding: 50.0
                bottomPadding: 50.0
                
                Label 
                {
                    text: "Brush Color"
                }
                
                WebView 
                {
                    id: colorpickerWebView
                    property string brushColor : "#2DED4A" // green
                    settings.background: Color.Transparent
                    url: "local:///assets/html/colorpicker.html"
                    settings.webInspectorEnabled: true
                    
                    onMessageReceived:
                    {
                        var colorJSON = JSON.parse(message.data);
                        brushColor = colorJSON.brushColorHEX;
                    }
                }
                
                Label 
                {
                    text: "Brush Size"
                }
                
                Slider 
                {
                    id: brushSize
                    value: 10
                    fromValue: 1
                    toValue: 150
                }
                
                Label 
                {
                    visible: false
                    text: "Brush Opacity"
                }
                
                Slider
                {
                    id: brushOpacity
                    visible: false
                    value: 1
                    fromValue: 0.1
                    toValue: 1
                }
                
                Container 
                {
                    layout: StackLayout 
                    {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    Button 
                    {
                        horizontalAlignment: HorizontalAlignment.Fill
                        text: "Set"
                        onClicked: 
                        {
                            if(_app.purchasedAds)
                            {
                                colorPickerBackground.background = Color.create(colorpickerWebView.brushColor);
                                
                                var messageJSON = "{ \"brushSize\":\"" + brushSize.value + "\", \"brushOpacity\":\"" + brushOpacity.value + "\", \"brushColor\":\"" + colorpickerWebView.brushColor + "\" }";
                                
                                canvasWebView.postMessage(messageJSON);
                                brushDialog.close(); 
                            }
                            else 
                            {
                                Qt.toastX.pop("Set a Brush Color. \n\nRemove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");
                                Qt.proSheet.open();
                            }
                        }
                    }
                    
                    Button 
                    {
                        horizontalAlignment: HorizontalAlignment.Fill
                        text: "Cancel"
                        onClicked: 
                        {
                            brushDialog.close(); 
                        }
                    }
                }
            }
        }
    ]
    
    function resetAll()
    {
        canvasWebView.reload();
        
        fileLocation = "";
        screenShotMode = false
        replyMode = false;
        postToShoutBox = false;
        recipient = "";
        captionLastPositionY = 350;
        firstRunCaption : true;
        addToStory = false;
        isPainting = false;
        isPaintingEnabled = false;
    }
}