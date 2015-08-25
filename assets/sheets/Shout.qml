import bb.cascades 1.0
import nemory.Snap2ChatAPISimple 1.0
import bb.cascades.pickers 1.0

import "../components/"

Sheet 
{
    id: sheet
    
    property variant theAttachedObjects

    property string shoutImageLocation : "";
    
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
    
    onOpened: 
    {
        shoutText.text = "";
        
        loadingBox.visible = false;
    }
    
    attachedObjects: 
    [
        ComponentDefinition 
        {
            id: myAttachedObjects
            
            Container 
            {
                id: objects
                
                property alias filePickerInteract: filePicker
                property alias snap2chatAPIInteract: snap2chatAPI
                
                attachedObjects: 
                [
                    FilePicker 
                    {
                        id: filePicker
                        type: FileType.Picture
                        title : "Select a Picture"
                        onFileSelected :
                        {
                            var oldImagePath = selectedFiles[0];
                            var newImagePath = Qt.app.getTempPath() + "/SHOUT.jpg";
                            
                            Qt.app.copy(oldImagePath, newImagePath);
                            Qt.app.rotateCorrectly(newImagePath);
                            
                            shoutImageLocation = newImagePath;
                            shoutImage.imageSource = "file://" + shoutImageLocation;
                        }
                    },
                    Snap2ChatAPISimple 
                    {
                        id: snap2chatAPI
                        onComplete: 
                        {
                            console.log("RESPONSE: " + response)
                            
                            if(endpoint == "shout")
                            {
                                _app.showToast("Successfully Shouted! :)");
                                
                                sheet.close();
                                
                                Qt.shoutBoxTab.load();
                            }
                            
                            loadingBox.visible = false;
                        }
                    }
                ]
            }
        }
    ]

    Page 
    {
        titleBar: CustomTitleBar
        {
            closeVisibility: true
            onCloseButtonClicked: 
            {
                sheet.close();
            }
        }
        
        Container 
        {
            layout: DockLayout {}
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ScrollView 
            {
                horizontalAlignment: HorizontalAlignment.Fill

                Container 
                {
                    id: mainContainer
                    
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    bottomPadding: 20
                    topPadding: 50
                    leftPadding: 20
                    rightPadding: 20
                    
                    Label 
                    {
                        text: "Shout it out!"
                        textStyle.fontSize: FontSize.XXLarge
                    }
                    
                    Label 
                    {
                        text: "Tell the world you need a snapchat friend."
                    }
                    
                    TextArea 
                    {
                        id: shoutText
                        preferredHeight: 300
                        hintText: "Your Message Here."
                    }
                    
                    ImageView 
                    {
                        id: shoutImage
                        horizontalAlignment: HorizontalAlignment.Fill
                        scalingMethod: ScalingMethod.AspectFit 
                        preferredHeight: 200
                    }
                }
            }
            
            Container 
            {
                id: loadingBox
                visible: false
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                background: Color.create("#99000000")
                
                layout: DockLayout {}
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    rightPadding: 20
                    bottomPadding: 20
                    
                    ActivityIndicator 
                    {
                        id: loadingIndicator
                        visible: loadingBox.visible
                        running: visible
                        preferredHeight: 200
                    }
                }
                
                Container 
                {
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    topPadding: 250
                    
                    Label 
                    {
                        id: loadingText
                        text: "Posting your shout. Please wait... :)"
                        textStyle.fontStyle: FontStyle.Italic
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.fontSize: FontSize.XSmall
                        textStyle.color: Color.White
                    }
                }
            }
        }
        
        actions:
        [
            ActionItem 
            {
                title: "Post Shout"
                enabled: (!loadingBox.visible)
                imageSource: "asset:///images/snapchat/aa_snap_preview_send.png"
            	ActionBar.placement: ActionBarPlacement.OnBar  
            	onTriggered: 
            	{
                    if(shoutText.text.length > 0 && shoutImageLocation.length > 0)
            	    {
                        Qt.app.flurryLogEvent("SHOUTED");
                        
                        loadingBox.visible = true;
                        loadingText.text = "Posting your shout. Please wait... :)";
                        
                        var params 			= new Object();
                        params.url 			= "http://kellyescape.com/snapchat/includes/webservices/create.php?object=boxsnap";
                        params.username		= Qt.snap2chatAPIData.username;
                        params.message		= shoutText.text;
                        params.fileLocation	= shoutImageLocation;
                        params.endpoint		= "shout";
                        
                        theAttachedObjects.snap2chatAPIInteract.kellyUploadShout(params);
            	    }
                    else
                    {
                    	Qt.app.showToast("Sorry, You can't shout without a message and an image. Please add one.");
                    }
                }
            },
            ActionItem
            {
                title: "Add Photo"
                enabled: (!loadingBox.visible)
                imageSource: "asset:///images/titleCamera.png"
                ActionBar.placement: ActionBarPlacement.OnBar  
                onTriggered:
                {
                    theAttachedObjects.filePickerInteract.open();
                }
            }
        ]
    }
}
