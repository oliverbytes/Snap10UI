import bb.cascades 1.0
import QtQuick 1.0
import bb.system 1.0

import "../components/"

Sheet 
{
    id: sheet
    property variant theAttachedObjects
    peekEnabled: false
    signal forceClose();
    
    onOpened: 
    {
        var command     = new Object();
        command.action  = "connect";
        command.data    = "data";
        _app.socketSend(JSON.stringify(command));
        
//        var videoPlayerComponentControl         = videoPlayerComponent.createObject();
//        videoPlayerComponentControl.videoSource = (Qt.app.getDisplayHeight() > 730 ? "asset:///media/BigSplashScreen.mp4" : "asset:///media/SmallSplashScreen.mp4");
//        videoPlayerComponentControl.replay      = true;
//        videoPlayerComponentControl.playVideo();
//        videoPlayerContainer.add(videoPlayerComponentControl);
    }
    
    onClosed: 
    {
//        var videoPlayerComponentControl = videoPlayerContainer.at(0);
//        
//        if(videoPlayerComponentControl)
//        {
//            videoPlayerComponentControl.replay = false;
//            videoPlayerComponentControl.stopVideo();
//            videoPlayerContainer.remove(videoPlayerComponentControl);
//            videoPlayerComponentControl.destroy();
//        }
    }
    
    Page 
    {
        Container 
        {
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            background: Color.create("#ff2d71")
            
            ImageView 
            {
                imageSource: "asset:///images/icon%20480.png"
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                scalingMethod: ScalingMethod.AspectFit
            }
            
//            Container 
//            {
//                id: videoPlayerContainer
//                horizontalAlignment: HorizontalAlignment.Fill
//                verticalAlignment: VerticalAlignment.Fill
//                
//                attachedObjects: ComponentDefinition 
//                {
//                    id: videoPlayerComponent
//                    source: "asset:///components/VideoPlayer.qml"
//                }
//            }

			Container 
			{
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Bottom
                
                Container 
                {
                    id: registrationMessage
                    topPadding: 50
                    bottomPadding: 50
                    bottomMargin: 20
                    rightMargin: 20
                    leftMargin: 20
                    background: Color.White
                    visible: false

                    Label 
                    {
                        multiline: true
                        textStyle.fontSize: FontSize.Small
                        textFormat: TextFormat.Html
                        text: "Registration is currently not working at the moment. Please bear with us as we're still working on the issue.\n\nBut there's an alternative way to register please visit: Frequently Asked Questions: <a href='http://goo.gl/OV6Jt8'>http://goo.gl/OV6Jt8</a>"
                    }
                }
                
                Container 
                {
                    bottomPadding: 5
                    
                    layout: StackLayout 
                    {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    Button 
                    {
                        text: "Login"
                        onClicked: 
                        {
                            Qt.loginSheet.open();
                        }
                    }
                    
                    Button 
                    {
                        text: "Register"
                        
                        onClicked:
                        {
                            registrationMessage.visible = !registrationMessage.visible;
                        }
                        
                        attachedObjects: SystemToast 
                        {
                            id: toast
                        
                        }
                    }
                }
			}
        }
    }
}

