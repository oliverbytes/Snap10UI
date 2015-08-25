import bb.cascades 1.2

import "../sheets"

Container
{
    id: mainContainer
    
    signal startAnimations();
    signal stopAnimations();
    
    onStartAnimations: 
    {
        fadeAnimation.play();
        scaleAnimation.play();
    }
    
    onStopAnimations: 
    {
        fadeAnimation.stop();
        scaleAnimation.stop();
    }
    
    topPadding: 10
    bottomPadding: 10
    
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    layout: DockLayout {}
    leftPadding: 20
    rightPadding: leftPadding
    
    background:
    {
        var theColor;
        
        if(Qt.app.getSetting("pureDarkListView", "true") == "false")
        {
            theColor = (root.ListItem.selected ? Color.create("#3BC7FF") : (Qt.app.getSetting("colortheme", "bright") == "bright" ? Color.create("#ffffff") : Color.create("#2B2B2B")));
        }
        else 
        {
            theColor = Color.Transparent;
        }
        
        return theColor;
    }
    
    Container
    {
        verticalAlignment: VerticalAlignment.Center
        
        layout: StackLayout
        {
            orientation: LayoutOrientation.LeftToRight
        }
        
        Container 
        {
            id: statImage
            rightPadding: 20
            layout: DockLayout {}
            verticalAlignment: VerticalAlignment.Center
            
            ImageView
            {
                id: theimage
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                imageSource: "asset:///images/snapchat/uploading.png"
                preferredHeight: 70
                minHeight: preferredHeight
                minWidth: preferredHeight
                scalingMethod: ScalingMethod.AspectFit
                
                animations: 
                [
                    FadeTransition 
                    {
                        id: fadeAnimation
                        duration: 1000
                        repeatCount: 99999999
                        toOpacity: 1.0
                        fromOpacity: 0.3
                        easingCurve: StockCurve.Linear
                        
                        onStopped: 
                        {
                            theimage.resetOpacity();
                        }
                    },
                    ScaleTransition 
                    {
                        id: scaleAnimation
                        duration: 1000
                        repeatCount: 99999999
                        toX: 1.0
                        toY: 1.0
                        fromX: 0.7
                        fromY: 0.7
                        easingCurve: StockCurve.BounceInOut
                        
                        onStopped: 
                        {
                            theimage.resetScale();
                        }
                    }
                ]
            }
        }
        
        Container 
        {
            Container 
            {
                Label 
                {
                    id: theusername
                    verticalAlignment: VerticalAlignment.Center  
                    textStyle.fontSize: FontSize.Large
                    text: "Uploading " + Qt.snap2chatAPIData.uploadingSize + " snaps...";
                }
            }
            
            Container 
            {
                Label 
                {
                    id: thestatus
                    verticalAlignment: VerticalAlignment.Center
                    textStyle.fontSize: FontSize.XXSmall
                    textStyle.color: Color.Gray
                    text: "Tap to expand " + Qt.snap2chatAPIData.uploadingSize + " uploading snap" + (Qt.snap2chatAPIData.uploadingSize > 0 ? "s" : "");
                }
            }
        }
    }
    
    Container 
    {
        horizontalAlignment: HorizontalAlignment.Right
        verticalAlignment: VerticalAlignment.Center
        
        layout: StackLayout 
        {
            orientation: LayoutOrientation.LeftToRight
        }
        
        ActivityIndicator 
        {
            id: imageLoading
            visible: true
            running: true
            preferredHeight: 50
            verticalAlignment: VerticalAlignment.Center
        }
        
        ImageButton 
        {
            preferredWidth: 50
            preferredHeight: 50
            defaultImageSource: "asset:///images/rightarrowthin.png"
            onClicked: 
            {
                Qt.uploadingSnapsSheet.open();
            }
        }
    }
    
    Divider {}
}
