import bb.cascades 1.0
import bb.system 1.0
import QtQuick 1.0

Container 
{
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    layout: DockLayout { }
    
    Container 
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        leftPadding: 10
        
        layout: StackLayout
        {
            orientation: LayoutOrientation.LeftToRight
        }
        
        ImageView 
        {
            verticalAlignment: VerticalAlignment.Center
            preferredHeight: 70
            scalingMethod: ScalingMethod.AspectFit
            imageSource: (ListItemData.screenshotted ? "asset:///images/snapchat/story_screenshot.png" : "asset:///images/snapchat/story_view.png")
        }
        
        Container 
        {
            Container 
            {
                Label 
                {
                    id: mainName
                    text:ListItemData.viewer
                    textStyle.fontSize: FontSize.Large
                }
            }
            
            Container 
            {
                Label 
                {
                    id: timestamp
                    textStyle.fontSize: FontSize.XXSmall
                    textStyle.color: Color.Gray
                    text: Qt.snap2chatAPIData.timeSince(ListItemData.timestamp);
                }
            }
        }
    }
    
    Container 
    {
        horizontalAlignment: HorizontalAlignment.Right
        verticalAlignment: VerticalAlignment.Center
        rightPadding: 20
        
        ImageButton 
        {
            preferredWidth: 50
            preferredHeight: 50
            defaultImageSource: "asset:///images/rightarrowthin.png"
            onClicked:
            {
                var profileObject 				= new Object();
                profileObject.username 			= ListItemData.viewer;
                Qt.profileSheet.profileObject 	= profileObject;
                Qt.profileSheet.open();
            }
        }
    }
    
    gestureHandlers:
    [
        DoubleTapHandler 
        {
            onDoubleTapped:
            {
                reply();
            }
        },
        TapHandler 
        {
            onTapped: 
            {
                var profileObject 				= new Object();
                profileObject.username 			= ListItemData.viewer;
                Qt.profileSheet.profileObject 	= profileObject;
                Qt.profileSheet.open();
            }
        }
    ]
    
    function reply()
    {
        var parameters 				= new Object();
        parameters.replyMode 		= true;
        parameters.recipient 		= ListItemData.viewer;
        parameters.postToShoutBox 	= false;
        Qt.app.openCameraTab(parameters);
    }
}