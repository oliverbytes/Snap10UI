import bb.cascades 1.0
import nemory.Snap2ChatAPISimple 1.0
import bb.cascades.pickers 1.0
import org.labsquare 1.0

import "../components"
import "../smaato"

Sheet 
{
    id: sheet
    property string newImage;
    
    onOpened: 
    {
        title.subtitle 		= Qt.profileObject.username;
        theimage.url 		= Qt.profileObject.picture;
        thename.text 		= Qt.profileObject.name;
        about.text 			= Qt.profileObject.about;
        age.text 			= Qt.profileObject.age;
        
        var index = 0;
        
        if(Qt.profileObject.gender == "Male")
        {
            index = 0;
        }
        else if(Qt.profileObject.gender == "Female")
        {
            index = 1;
        }
        else if(Qt.profileObject.gender == "Unspecified")
        {
            index = 2;
        }
        
        gender.selectedIndex = index;
    }

    Page 
    {    
        titleBar: CustomTitleBar 
        {
            id: titleBar
            closeVisibility: true
            settingsVisibility: true
            onCloseButtonClicked: 
            {
                sheet.close();
            }
        }
        
        ScrollView 
        { 
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                layout: DockLayout {}
                
                Container 
                {
                    id: content
                    
                    leftPadding: 20
                    rightPadding: 20
                    topPadding: 20
                    bottomPadding: 20
                    
                    Header
                    {
                        id: title
                        title: "EDIT EXTENDED PROFILE"
                    }
                    
                    Container 
                    {
                        topPadding: 20
                        
                        layout: StackLayout 
                        {
                            orientation: LayoutOrientation.LeftToRight
                        }

                        WebImageView 
                        {
                            id: theimage
                            preferredHeight: 300
                            preferredWidth: 300
                            scalingMethod: ScalingMethod.AspectFit
                        }
                        
                        Button 
                        {
                            text: "Change Profile Picture"
                            verticalAlignment: VerticalAlignment.Center
                            onClicked:
                            {
                                filePicker.open();
                            }
                        }
                    }
                    
                    Label 
                    {
                        text: "Full Name"
                    }
                    
                    TextField 
                    {
                        id: thename
                    }
                    
                    Label 
                    {
                        text: "About"
                    }
                    
                    SmaatoAds
                    {
                        id: ads
                    }
                    
                    TextArea
                    {
                        id: about
                        preferredHeight: 300
                        inputMode: TextAreaInputMode.Chat
                    }
                    
                    Label 
                    {
                        text: "Age"
                    }
                    
                    TextField 
                    {
                        id: age
                        inputMode: TextFieldInputMode.PhoneNumber
                    }
                    
                    Label 
                    {
                        text: "Gender"
                    }
                    
                    DropDown
                    {
                        id: gender
                        title: "Gender"
                        options:
                        [
                            Option 
                            {
                                text: "Male"
                            },
                            Option 
                            {
                                text: "Female"
                            },
                            Option 
                            {
                                text: "Unspecified"
                            }
                        ]
                    }
                }
            }
        }
        
        actions: 
        [
            ActionItem 
            {
                id: save
                title: (enabled ? "Save" : "Saving...")
                imageSource: "asset:///images/tabSave.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: 
                {
                    save.enabled = false;

                    var params 			= new Object();
                    params.endpoint 	= "updateprofile";
                    params.url 			= "http://kellyescape.com/snapchat/includes/webservices/update.php?object=extendedprofile&id=" + Qt.profileObject.id;
                    params.fileLocation	= newImage;
                    params.age			= age.text;
                    params.about		= about.text;
                    params.username 	= Qt.profileObject.username;
                    params.name			= Qt.profileObject.name;
                    params.gender		= gender.selectedOption.text;
                    params.id			= Qt.profileObject.id;
                    
                    snap2chatAPI.kellyUploadProfile(params);
                    
                    console.log(JSON.stringify(params));
                }
            }
        ]
    }    
    
    attachedObjects: 
    [
        FilePicker 
        {
            id: filePicker
            type: FileType.Picture
            title : "Select a Profile Picture"
            onFileSelected :
            {
                var oldImagePath = selectedFiles[0];
                var newImagePath = Qt.app.getTempPath() + "/PROFILE.jpg";
                
                Qt.app.copy(oldImagePath, newImagePath);
                Qt.app.preProcess(newImagePath, false);
                
                newImage = newImagePath;
                theimage.imageSource = "file://" + newImage;
            }
        },
        Snap2ChatAPISimple 
        {
            id: snap2chatAPI
            onComplete: 
            {
                console.log("RESPONSE: " + response)
                
            	if(endpoint == "updateprofile")
            	{
            	    sheet.close();
            	    
            	    _app.showToast("Successfully Updated! :)");
            	}
            	
                save.enabled = true;
            }
        }
    ]
}