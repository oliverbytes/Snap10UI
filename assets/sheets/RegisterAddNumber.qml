import bb.cascades 1.0
import nemory.Snap2ChatAPISimple 1.0
import bb.system 1.0

Sheet 
{
    id: sheet
    peekEnabled: false
    
    signal forceClose();
    
    property string captchaID : "";
    property string emailUsername : "";
    property string authToken: "";
    property string prompt: "";
    
    property variant theAttachedObjects

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
        createObjects();    
    }
    
    onClosed: 
    {
        destroyObjects();
    }
    
    attachedObjects: 
    [
        ComponentDefinition 
        {
            id: myAttachedObjects
            
            Container 
            {
                id: objects
                
                property alias snap2chatAPIInteract: snap2chatAPI
                
                attachedObjects: 
                [
                    Snap2ChatAPISimple 
                    {
                        id: snap2chatAPI
                        onComplete:
                        {
                            Qt.progressDialog.cancel();
                            
                            console.log("ADD NUMBER: " + response);
                            
                            var responseJSON = JSON.parse(response);
                        
                            if(responseJSON.logged)
                            {
                                
                            }
                            else 
                            {
                                Qt.app.showDialog("Attention", responseJSON.message);
                            }
                        }
                    }
                ]
            }
        }
    ]
    
    Page 
    {
        Container 
        {
            layout: DockLayout {}
            
            ImageView 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                imageSource: "asset:///images/mybackground.jpg"
                scalingMethod: ScalingMethod.AspectFill
            }
            
            ScrollView 
            {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                
                Container 
                {
                    id: mainContentContainer
                    
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    leftPadding: 50
                    rightPadding: 50
                    
                    Container 
                    {
                        verticalAlignment: VerticalAlignment.Center
                        topPadding: (Qt.app.getDisplayHeight() < 730 ? 130 : 0)
                        bottomPadding: 50
                        
                        Label 
                        {
                            text: "Add a Phone Number"
                            textStyle.fontWeight: FontWeight.W100
                            textStyle.fontSize: FontSize.XXLarge
                            textStyle.color: Color.White
                        }
                        
                        Divider {}
                        
                        Label 
                        {
                            text: "Phone Number"
                            textStyle.color: Color.White
                            textStyle.fontWeight: FontWeight.W100
                        }
                        
                        DropDown 
                        {
                            id: countryCode
                            title: "Country Code"
                            
                            attachedObjects: 
                            [
                                ComponentDefinition 
                                {
                                    id: optionControlDefinition
                                    Option {}
                                }
                            ]
                            
                            onCreationCompleted: 
                            {
//                                var countryCodesJSONString = Globals.countryCodes;
//                                
//                                var countryCodesJSON = JSON.parse(countryCodesJSONString);
//                                
//                                for (var i = 0; i < countryCodesJSON.length; i ++) 
//                                {
//                                    var option 		= optionControlDefinition.createObject();
//                                    option.text 	= countryCodesJSON[i].name;
//                                    option.value 	= countryCodesJSON[i].alpha2;
//                                    countryCode.add(option);
//                                }
                            }
                        }
                        
                        TextField 
                        {
                            id: theusername
                            hintText: "phone number"
                            textStyle.color: Color.White
                            inputMode: TextFieldInputMode.PhoneNumber
                            backgroundVisible: false
                            onTextChanging: 
                            {
                                theusername.text = theusername.text.toLowerCase().trim();
                            }
                            keyListeners: 
                            [
                                KeyListener 
                                {
                                    onKeyReleased: 
                                    {  
                                        if(event.key == 13)
                                        {
                                            done();
                                        }
                                    }        
                                }
                            ]
                        }
                        
                        Button 
                        {
                            text: "Done"
                            horizontalAlignment: HorizontalAlignment.Fill
                            onClicked: 
                            {
                                done();
                            }
                        }
                        
                        Divider {}
                        
                        Label 
                        {
                            text: "Verify Mobile #"
                            textStyle.color: Color.White
                            textStyle.fontWeight: FontWeight.W100
                        }
                        
                        Container 
                        {
                            layout: StackLayout 
                            {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            
                            TextField 
                            {
                                id: verificationCode
                                backgroundVisible: false
                                hintText: "4 Digit Verification Code"
                                inputMode: TextFieldInputMode.PhoneNumber
                                
                                layoutProperties: StackLayoutProperties 
                                {
                                    spaceQuota: 3
                                }
                            }
                            
                            Button 
                            {
                                text: "Verify"
                                horizontalAlignment: HorizontalAlignment.Fill
                                onClicked: 
                                {
                                    if(verificationCode.text.length > 3)
                                    {
                                        Qt.progressDialog.body = "Verifying mobile number...";
                                        Qt.progressDialog.show();
                                        
                                        var timestamp = Qt.snap2chatAPIData.getCurrentTimestamp();
                                        var req_token 	= Qt.snap2chatAPIData.generateRequestToken(timestamp, Qt.snap2chatAPIData.auth_token);
                                        
                                        theAttachedObjects.snap2chatAPIInteract.verifyPhoneNumber(verificationCode.text, timestamp, req_token);
                                    } 
                                    else 
                                    {
                                        Qt.app.showDialog("Attention", "Please enter the 4 Digit Code");
                                    }
                                }
                                
                                layoutProperties: StackLayoutProperties 
                                {
                                    spaceQuota: 1
                                }
                            }
                        }
                        
                        Divider {}
                        
                        Button 
                        {
                            text: "Skip this step"
                            horizontalAlignment: HorizontalAlignment.Fill
                            
                            onClicked: 
                            {
                                sheet.close();
                                sheet.forceClose();
                                
                                Qt.app.showToast("Successfully Registered and Logged In :)");
                            }
                        }
                    }
                }
            }
            
            Container 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Top
                background: Color.create("#1a000000")
                
                topPadding: 30
                bottomPadding: 20
                
                ImageView 
                {
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    imageSource: "asset:///images/title_bar_logo.png"
                    preferredHeight: 70
                    scalingMethod: ScalingMethod.AspectFit
                }
            }
            
            Container 
            {
                verticalAlignment: VerticalAlignment.Top
                topPadding: 20
                leftPadding: 10
                
                ImageButton 
                {
                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Top
                    defaultImageSource: "asset:///images/Back.png"
                    onClicked: 
                    {
                        sheet.close();
                    }
                }
            }
            
            Container 
            {
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Top
                topPadding: 20
                rightPadding: 30
                
                ImageButton 
                {
                    defaultImageSource: "asset:///images/titleInfo.png"
                    onClicked: 
                    {
                        Qt.aboutSheet.open();
                    }
                }
            }
        }
    }
    
    function done()
    {
        
    }
}