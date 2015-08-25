import bb.cascades 1.0
import nemory.Snap2ChatAPISimple 1.0
import bb.system 1.0

Sheet 
{
    id: sheet
    peekEnabled: false
    
    signal forceClose();
    
    property string emailUsername : "";
    property string authToken: "";
    
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
                property alias registerAddNumberSheetInteract: registerAddNumberSheet
                
                attachedObjects: 
                [
                    Snap2ChatAPISimple 
                    {
                        id: snap2chatAPI
                        onComplete:
                        {
                            Qt.progressDialog.cancel();
                            
                            var responseJSON = JSON.parse(response);
                            
                            if(responseJSON.logged)
                            {
                                Qt.snap2chatAPIData.parseUpdatesJSON(response);
                                
                                _app.setSetting("username", 	Qt.snap2chatAPIData.username);
                                _app.setSetting("auth_token", 	Qt.snap2chatAPIData.auth_token);
                                
                                var command = new Object();
                                command.action = "loadLoginDetails";
                                
                                var dataObject = new Object();
                                dataObject.username 	= Qt.snap2chatAPIData.username;
                                dataObject.auth_token 	= Qt.snap2chatAPIData.auth_token;
                                
                                command.data   = dataObject;
                                _app.socketSend(JSON.stringify(command));
                                
                                var command2 = new Object();
                                command2.action = "parseUpdatesJSON";
                                command2.data   = response;
                                Qt.app.socketSend(JSON.stringify(command2));
                                
                                console.log("*** QML PARSE UPDATE: " + JSON.stringify(command2))

                                syncActiveFrame();

                                sheet.close();
                                sheet.forceClose();
                                Qt.mainSheet.close();
                                
                                Qt.app.flurryLogEvent("REGISTERED");
                            }
                            else 
                            {
                                Qt.app.showDialog("Attention", responseJSON.message);
                            }
                        }
                    }
                    ,
                    RegisterAddNumber 
                    {
                        id: registerAddNumberSheet
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
                            text: "Choose a Username"
                            textStyle.fontWeight: FontWeight.W100
                            textStyle.fontSize: FontSize.XXLarge
                            textStyle.color: Color.White
                        }
                        
                        Divider {}
                        
                        Label 
                        {
                            text: "Username"
                            textStyle.color: Color.White
                            textStyle.fontWeight: FontWeight.W100
                        }
                        
                        TextField 
                        {
                            id: theusername
                            hintText: "chosen username"
                            textStyle.color: Color.White
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
        if(theusername.text.length >= 3)
        {
            Qt.progressDialog.body = "Registering Username...";
        	Qt.progressDialog.show();
            
            var params 			= new Object();
            params.endpoint		= "/loq/register_username";
            params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
            params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, sheet.authToken);
            
            params.selected_username 	= theusername.text;
            params.username 			= sheet.emailUsername;
            
            theAttachedObjects.snap2chatAPIInteract.request(params);
        }
        else
        {
            Qt.app.showDialog("Error", "Username must be atleast 3 characters and all low capital letters.");
        }
    }
}