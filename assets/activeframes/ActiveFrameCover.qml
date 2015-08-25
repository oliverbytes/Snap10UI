import bb.cascades 1.0

Container 
{   
    horizontalAlignment: HorizontalAlignment.Fill
    property int bottomPaddingForSnaps : 10

    background:
    {
        if(Application.themeSupport.theme.colorTheme.style == VisualStyle.Bright)
        {
            return Color.White;
        } 
        else 
        {
            return Color.Black;
        }
    }
    
    ImageView 
    {
        id: splashScreenImage
        visible: false
        objectName: "splashScreenImage"
        imageSource: "asset:///images/activeframe.jpg"
    }
    
    Container 
    {   
        visible: !splashScreenImage.visible
        horizontalAlignment: HorizontalAlignment.Fill
        layout: DockLayout {}

        Container 
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Bottom
            
            Container
            {
            	bottomMargin: 5
                bottomPadding: 5
                leftPadding: 10
            	topPadding: 5
                background: Color.create("#1F1F1F");
                horizontalAlignment: HorizontalAlignment.Fill
                
                Label 
                {
                    text: "Recent Snaps"
                    textStyle.color: Color.White
                }
            }
            
            Container 
            {
                visible: !listSnaps.visible
                horizontalAlignment: HorizontalAlignment.Fill
                leftPadding: 50
                topMargin: 50
                
                Label 
                {
                    text: "No Recent Snaps"
                    textStyle.fontSize: FontSize.XSmall
                }
            }
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                id: listSnaps
                objectName: "listSnaps"
                
                Container 
                {
                    objectName: "snap1"
                    bottomPadding: bottomPaddingForSnaps
                    
                    layout: StackLayout 
                    {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    ImageView
                    {
                        objectName: "theimage1"
                        verticalAlignment: VerticalAlignment.Center
                        imageSource: "asset:///images/snapchat/aa_feed_icon_unopened_broadcast.png";
                        preferredHeight: 50
                        minHeight: preferredHeight
                        minWidth: preferredHeight
                        scalingMethod: ScalingMethod.AspectFit
                    }
                    
                    Container 
                    {
                        horizontalAlignment: HorizontalAlignment.Fill

                        Container 
                        {
                            Label 
                            {
                                objectName: "theusername1"
                                textStyle.fontSize: FontSize.Small
                                text: "loading...."
                            }
                        }
                        
                        Container 
                        {
                            Label 
                            {
                                objectName: "thestatus1"
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.color: Color.Gray
                                text:"loading..."
                            }
                        }
                    }
                }

                Container 
                {
                    objectName: "snap2"
                    bottomPadding: bottomPaddingForSnaps
                    
                    layout: StackLayout 
                    {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    ImageView
                    {
                        objectName: "theimage2"
                        verticalAlignment: VerticalAlignment.Center
                        imageSource: "asset:///images/snapchat/aa_feed_icon_unopened_photo.png";
                        preferredHeight: 50
                        minHeight: preferredHeight
                        minWidth: preferredHeight
                        scalingMethod: ScalingMethod.AspectFit
                    }
                    
                    Container 
                    {
                        Container 
                        {
                            Label 
                            {
                                objectName: "theusername2"
                                textStyle.fontSize: FontSize.Small
                                text: "loading...."
                            }
                        }
                        
                        Container 
                        {
                            Label 
                            {
                                objectName: "thestatus2"
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.color: Color.Gray
                                text:"loading..."
                            }
                        }
                    }
                }

                Container 
                {
                    objectName: "snap3"
                    bottomPadding: bottomPaddingForSnaps
                    
                    layout: StackLayout 
                    {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    ImageView
                    {
                        objectName: "theimage3"
                        verticalAlignment: VerticalAlignment.Center
                        imageSource: "asset:///images/snapchat/aa_feed_icon_unopened_video.png";
                        preferredHeight: 50
                        minHeight: preferredHeight
                        minWidth: preferredHeight
                        scalingMethod: ScalingMethod.AspectFit
                    }
                    
                    Container 
                    {
                        Container 
                        {
                            Label 
                            {
                                objectName: "theusername3"
                                textStyle.fontSize: FontSize.Small
                                text: "loading...."
                            }
                        }
                        
                        Container 
                        {
                            Label 
                            {
                                objectName: "thestatus3"
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.color: Color.Gray
                                text:"loading..."
                            }
                        }
                    }
                }
                
                Container 
                {
                    objectName: "snap4"
                    bottomPadding: bottomPaddingForSnaps
                    
                    layout: StackLayout 
                    {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    ImageView
                    {
                        objectName: "theimage4"
                        verticalAlignment: VerticalAlignment.Center
                        imageSource: "asset:///images/snapchat/aa_feed_icon_opened_broadcast.png";
                        preferredHeight: 50
                        minHeight: preferredHeight
                        minWidth: preferredHeight
                        scalingMethod: ScalingMethod.AspectFit
                    }
                    
                    Container 
                    {
                        Container 
                        {
                            Label 
                            {
                                objectName: "theusername4"
                                textStyle.fontSize: FontSize.Small
                                text: "loading...."
                            }
                        }
                        
                        Container 
                        {
                            Label 
                            {
                                objectName: "thestatus4"
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.color: Color.Gray
                                text:"loading..."
                            }
                        }
                    }
                }
                
                Container 
                {
                    objectName: "snap5"
                    bottomPadding: bottomPaddingForSnaps
                    
                    layout: StackLayout 
                    {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    ImageView
                    {
                        objectName: "theimage5"
                        verticalAlignment: VerticalAlignment.Center
                        imageSource: "asset:///images/snapchat/aa_feed_icon_unopened_video.png";
                        preferredHeight: 50
                        minHeight: preferredHeight
                        minWidth: preferredHeight
                        scalingMethod: ScalingMethod.AspectFit
                    }
                    
                    Container 
                    {
                        Container 
                        {
                            Label 
                            {
                                objectName: "theusername5"
                                textStyle.fontSize: FontSize.Small
                                text: "loading...."
                            }
                        }
                        
                        Container 
                        {
                            Label 
                            {
                                objectName: "thestatus5"
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.color: Color.Gray
                                text:"loading..."
                            }
                        }
                    }
                }
                
                Container 
                {
                    objectName: "snap6"
                    bottomPadding: bottomPaddingForSnaps
                    
                    layout: StackLayout 
                    {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    ImageView
                    {
                        objectName: "theimage6"
                        verticalAlignment: VerticalAlignment.Center
                        imageSource: "asset:///images/snapchat/aa_feed_icon_unopened_broadcast.png";
                        preferredHeight: 50
                        minHeight: preferredHeight
                        minWidth: preferredHeight
                        scalingMethod: ScalingMethod.AspectFit
                    }
                    
                    Container 
                    {
                        Container 
                        {
                            Label 
                            {
                                objectName: "theusername6"
                                textStyle.fontSize: FontSize.Small
                                text: "loading...."
                            }
                        }
                        
                        Container 
                        {
                            Label 
                            {
                                objectName: "thestatus6"
                                textStyle.fontSize: FontSize.XXSmall
                                textStyle.color: Color.Gray
                                text:"loading..."
                            }
                        }
                    }
                }
            }
        }
    }
}