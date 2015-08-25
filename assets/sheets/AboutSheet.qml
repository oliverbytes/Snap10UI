import bb.cascades 1.0

import "../components/"
import "../smaato"

Sheet 
{
    id: sheet
    
    property bool uiHeadlessConnected : false;
    
    signal connected();
    
    onConnected: 
    {
        uiHeadlessConnected = true;
    }
    
    onOpened: 
    {
//        var videoPlayerComponentControl = videoPlayerComponent.createObject();
//        videoPlayerComponentControl.videoSource = "asset:///media/SmallSplashScreen.mp4";
//        videoPlayerComponentControl.replay = true;
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
        titleBar: CustomTitleBar
        {
            closeVisibility: true
            onCloseButtonClicked: 
            {
                sheet.close();
            }
        }
        
        ScrollView 
        {
            Container 
            {
                Label 
                {
                    text: "Snap10 v" + _packageInfo.version;
                    horizontalAlignment: HorizontalAlignment.Center
                }
                
                Header 
                {
                    title: "DEVELOPED BY:"
                    bottomMargin: 50
                }
                
                ImageView 
                {
                    preferredWidth: 300
                    scalingMethod: ScalingMethod.AspectFit
                    imageSource: "asset:///images/nemory.png"
                    horizontalAlignment: HorizontalAlignment.Fill
                }
                
                Label 
                {
                    text: "Oliver Martinez"
                    horizontalAlignment: HorizontalAlignment.Center
                    textStyle.fontWeight: FontWeight.W100
                    textStyle.fontSize: FontSize.Large
                }
                
                Label 
                {
                    text: "of Nemory Development Studios"
                    horizontalAlignment: HorizontalAlignment.Center
                    textStyle.fontWeight: FontWeight.W100
                }
                
                SmaatoAds
                {
                    id: ads
                }
            }
        }
    }
}