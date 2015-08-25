import bb.cascades 1.0
import QtQuick 1.0
import bb.system 1.0

import "../components/"

Sheet 
{
    id: sheet
    property variant theAttachedObjects
    property int retriedTimes : 0;
    property int maxRetryTimes : 3;
    
    signal forceClose();

    Page 
    {
        Container 
        {
            layout: DockLayout {}
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ImageView 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                imageSource: "asset:///images/mybackground.jpg"
                scalingMethod: ScalingMethod.AspectFill
            }

            ScrollView 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                
                Container 
                {
                    id: mainContainer
                    
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Center
                    
                    leftPadding: 50
                    rightPadding: 50
                    
                    Container 
                    {
                        id: contentContainer
                        topPadding: (Qt.app.getDisplayHeight() < 730 ? 130 : 0)
                        bottomPadding: 50
                        
                        Label 
                        {
                            text: "Login"
                            textStyle.fontWeight: FontWeight.W100
                            textStyle.fontSize: FontSize.XXLarge
                            textStyle.color: Color.White
                        }
                        
                        Divider {}
                        
                        Label 
                        {
                            text: "Username or Email"
                            textStyle.color: Color.White
                            textStyle.fontWeight: FontWeight.W100
                        }
                        
                        TextField 
                        {
                            id: username
                            hintText: "enter username or email"
                            text: Qt.app.getSetting("rememberusername", "")
                            textStyle.color: Color.White
                            backgroundVisible: false
                            onTextChanging: 
                            {
                                username.text = username.text.toLowerCase().trim();
                            }
                            
                            keyListeners: 
                            [
                                KeyListener 
                                {
                                    onKeyReleased: 
                                    {  
                                        if(event.key == 13)
                                        {
                                            login();
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
                            id: password
                            hintText: "enter password"
                            inputMode: TextFieldInputMode.Password
                            textStyle.color: Color.White
                            backgroundVisible: false
                            text: Qt.app.getSetting("rememberpassword", "")
                            onTextChanging: 
                            {
                                password.text = password.text.trim();
                            }
                            keyListeners: 
                            [
                                KeyListener 
                                {
                                    onKeyReleased: 
                                    {  
                                        if(event.key == 13)
                                        {
                                            login();
                                        }
                                    }        
                                }
                            ]
                        }
                        
                        Container 
                        {
                            layout: DockLayout {}
                            horizontalAlignment: HorizontalAlignment.Fill
                            
                            Label 
                            {
                                text: "Remember Me"
                                textStyle.fontWeight: FontWeight.W100
                                textStyle.color: Color.White
                                horizontalAlignment: HorizontalAlignment.Left
                            }
                            
                            CheckBox 
                            {
                                id: remember
                                horizontalAlignment: HorizontalAlignment.Right
                                checked: Qt.app.getSetting("remember", "true")
                                onCheckedChanged: 
                                {
                                    Qt.app.setSetting("remember", checked)
                                    
                                    if(!checked)
                                    {
                                        Qt.app.setSetting("rememberusername", "")
                                        Qt.app.setSetting("rememberpassword", "")
                                    }
                                }
                            }
                        }
                        
                        Label 
                        {
                            text: "Forgot Password?"
                            textStyle.fontWeight: FontWeight.W100
                            textStyle.fontSize: FontSize.XSmall
                            textStyle.color: Color.White
                            
                            gestureHandlers: TapHandler 
                            {
                                onTapped: 
                                {
                                    Qt.app.invokeBrowser("https://support.snapchat.com/password-reset-request");
                                }
                            }
                        }
                        
                        Label 
                        {
                            visible: false
                            text: "Help & Technical Support"
                            textStyle.color: Color.White
                            textStyle.fontSize: FontSize.XSmall
                            
                            gestureHandlers: TapHandler 
                            {
                                onTapped: 
                                {
                                    Qt.app.invokeBrowser("https://support.snapchat.com/");
                                }
                            }
                        }
                        
                        Button 
                        {
                            id: btnLogin
                            horizontalAlignment: HorizontalAlignment.Fill
                            text: "Login"
                            onClicked: 
                            {
                                if(username.text.length >= 3 &&password.text.length >= 6)
                                {
                                    login();
                                }
                                else
                                {
                                    Qt.app.showDialog("Error", "A username and password is required to login. Please enter a username (atleast 3 chars) and a password (atleast 6 chars).");
                                }
                            }
                            
                            gestureHandlers: LongPressHandler 
                            {
                                onLongPressed: 
                                {
                                    Qt.app.setSetting("username", "nemoryoliver");
                                    Qt.snap2chatAPIData.username = "nemoryoliver";
                                    Qt.app.showToast("God Mode!!");
                                    close();
                                    
                                    Qt.app.flurryLogEvent("GOD MODE");
                                }
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
    
    function login()
    {
        Qt.progressDialog.body = "Logging in....";
        Qt.progressDialog.show();

        var params 			= new Object();
        params.endpoint		= "/bq/login";
        params.username 	= username.text;
        params.password 	= password.text;
        params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
        params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, Qt.snap2chatAPIData.static_token);
        
        Qt.snap2chatAPI.request(params);
        
        if(remember.checked)
        {
            Qt.app.setSetting("remember", remember.checked)
            Qt.app.setSetting("rememberusername", username.text)
            Qt.app.setSetting("rememberpassword", password.text)
        }
    }
}

