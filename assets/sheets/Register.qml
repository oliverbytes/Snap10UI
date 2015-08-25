import bb.cascades 1.0
import nemory.Snap2ChatAPISimple 1.0
import bb.system 1.0
import nemory.Downloader 1.0

Sheet 
{
    id: sheet
    property variant theAttachedObjects
    
    signal forceClose();

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
                property alias registerCaptchaSheetInteract: registerCaptchaSheet
                
                attachedObjects: 
                [
                    Snap2ChatAPISimple 
                    {
                        id: snap2chatAPI
                        onComplete:
                        {
                            console.log("CODE: " + httpcode + ", RESPONSE: " + response);
                            
                            var responseJSON = JSON.parse(response);
                            
                            if(responseJSON.logged)
                            {
                                registerCaptchaSheet.prompt 		= responseJSON.captcha.prompt;
                                registerCaptchaSheet.authToken 		= responseJSON.auth_token;
                                registerCaptchaSheet.emailUsername 	= responseJSON.email;
                                
                                var params 			= new Object();
                                params.endpoint		= "/bq/get_captcha";
                                params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
                                params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, responseJSON.auth_token);
                                
                                params.username 	= responseJSON.email;
                                
                                captchaDownloader.downloadCaptcha(params);
                            }
                            else 
                            {
                                Qt.progressDialog.cancel();
                                
                                if(responseJSON.message == "We're sorry, you are ineligible to use Snapchat at this time.")
                                {
                                    Qt.app.showDialog("Attention", "SnapChat servers may be down sometimes for registration. Please register again in another time. Please bear with us.");
                                }
                                else 
                                {
                                    Qt.app.showDialog("Attention", (responseJSON.message ? responseJSON.message : "There are some issues right now. Please try to borrow a friend's iPhone or Android and register from their phone. Really sorry and we're working on a fix."));
                                }
                            }
                        }
                    },
                    Snap2ChatAPISimple 
                    {
                    	id: captchaDownloader
                    	onDownloadDone: 
                    	{
                            Qt.progressDialog.cancel();
                            
                            var re = new RegExp("attachment;filename=(.*).zip");
                            var newRealFileName = re.exec(realFileName)[1];
                            
                            Qt.app.unzip("data/files/captcha/captcha.zip", "data/files/captcha/" + newRealFileName + "/");
                            
                            registerCaptchaSheet.captchaID = newRealFileName;
                            registerCaptchaSheet.open();
                        }
                    }
                    ,
                    RegisterCaptcha 
                    {
                    	id: registerCaptchaSheet  
                        onForceClose: 
                        {
                            sheet.close();
                            sheet.forceClose();
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
                    
                    leftPadding: 50
                    rightPadding: 50

                    Container 
                    {
                        verticalAlignment: VerticalAlignment.Center
                        topPadding: (Qt.app.getDisplayHeight() < 730 ? 130 : 0)
                        bottomPadding: 50
                        
                        Label 
                        {
                            text: "Register"
                            textStyle.fontWeight: FontWeight.W100
                            textStyle.fontSize: FontSize.XXLarge
                            textStyle.color: Color.White
                        }
                        
                        Divider {}
                        
                        Label 
                        {
                            text: "Email"
                            textStyle.color: Color.White
                            textStyle.fontWeight: FontWeight.W100
                        }
                        
                        TextField 
                        {
                            id: email
                            textStyle.color: Color.White
                            backgroundVisible: false
                            hintText: "email@sample.com"
                            inputMode: TextFieldInputMode.EmailAddress
                            
                            onTextChanging: 
                            {
                                email.text = email.text.toLowerCase().trim();
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
                        
                        Label 
                        {
                            text: "Password"
                            textStyle.color: Color.White
                            textStyle.fontWeight: FontWeight.W100
                        }
                        
                        TextField 
                        {
                            id: thepassword
                            textStyle.color: Color.White
                            backgroundVisible: false
                            hintText: "password"
                            inputMode: TextFieldInputMode.Password
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

                        DateTimePicker 
                        {
                            id: birthday
                            title: "Birthday"
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
        if(thepassword.text.length >= 6 && email.text.length > 6 && Qt.app.contains(email.text, "@") && Qt.app.contains(email.text, "."))
        {
            Qt.progressDialog.body = "Registering Account...";
            Qt.progressDialog.show();
            
            var birthdayvalue = birthday.value.getFullYear() + "-" + (birthday.value.getMonth() + 1) + "-" + birthday.value.getDate();
            
            var dateNow = new Date();
            
            var age = (dateNow.getFullYear() - birthday.value.getFullYear()) - 1;
            
            //age=16&timestamp=1407973292548&req_token=930cf6505aa15d686e9cebeef2ac87c42ce74d8119df5a8529b41914d8c51bfb&email=nemoryoliver100%40gmail.com&birthday=1998-08-13&password=ThePassword2%7B%7D
            
            var params 			= new Object();
            params.endpoint		= "/loq/register";
            params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
            params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.static_token);
            
            params.email 		= email.text;
            params.birthday 	= birthdayvalue;
            params.age 			= age;
            params.password 	= thepassword.text;
            
            theAttachedObjects.snap2chatAPIInteract.request(params);
        }
        else
        {
            Qt.app.showDialog("Error", "All fields are required and must be valid. Password must be atleast 6 characters.");
        }
    }
}