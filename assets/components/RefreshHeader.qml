import bb.cascades 1.0
import QtQuick 1.0

Container 
{
    property bool readyForRefresh: false;
    property bool refreshing: false;
    property string refreshedAt: "";
    property int refresh_threshold: 150;
    
    signal refreshTriggered
    id: refreshContainer
    horizontalAlignment: HorizontalAlignment.Fill
    layout: DockLayout {}

    Container 
    {
        id: refreshStatusContainer
        visible: !refreshing
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Top
        bottomPadding: 30.0
        
        ImageView 
        {
            id: refreshImage
            imageSource: "asset:///images/snapchat/stretchableRefresh.png"
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
            preferredHeight: getImageHeight();
        }
    }
    
    Container 
    {
        id: refreshingContainer
        verticalAlignment: VerticalAlignment.Center
        visible: refreshing
        horizontalAlignment: HorizontalAlignment.Fill
        preferredHeight: 100
        topPadding: 10
        
        ImageView 
        {
            id: sprite
            imageSource: "asset:///images/snapchat/sprites/ghost_1.png"
            verticalAlignment: VerticalAlignment.Center
            horizontalAlignment: HorizontalAlignment.Center
            preferredHeight: 80
            scalingMethod: ScalingMethod.AspectFit
        }
    }
    
    Divider 
    {
        opacity: 0.0
    }
    
    onRefreshingChanged: 
    {
        if (refreshing) 
        {
            refreshStatusContainer.visible = false;
            refreshingTimer.start();
        } 
        else 
        {
            refreshingTimer.stop();
        }
    }
    
    attachedObjects: 
    [
        LayoutUpdateHandler 
        {
            id: refreshHandler
            
            onLayoutFrameChanged: 
            {
                if (refreshing) 
                {
                    return;
                }
                
                readyForRefresh = false;

                if (layoutFrame.y >= 0) 
                {
                    if (layoutFrame.y >= refresh_threshold) 
                    {
                        if (!refreshing) 
                        {
                            readyForRefresh = true;
                        }
                    }
                } 
                else if (layoutFrame.y >= -100) 
                {
                   // not yet ready
                } 
            }
        },
        Timer
        {
            id: refreshingTimer
            interval: 80
            repeat: true
            property int spriteIndex : 1
            onTriggered:
            {
                spriteIndex++;
                if(spriteIndex > 20){ spriteIndex = 1; }
                sprite.imageSource = "asset:///images/snapchat/sprites/ghost_" + spriteIndex + ".png";
                
                if(spriteIndex % 3 == 0)
                {
                    var colors = new Array("#FF3690", "#BC36FF", "#36A1FF", "#D6D020", "#FF992B", "#1EE3C9");
                    var randomNumber = Math.floor(Math.random() * colors.length);
                    refreshingContainer.background = Color.create(colors[randomNumber]);
                }
            }
        }
    ]
    
    function released() 
    {
        if (readyForRefresh) 
        {
            readyForRefresh = false;
            refreshing = true;
            refreshTriggered();
        }
        else 
        {
            refreshContainer.setPreferredHeight(0);
        }
    }

    function doneRefreshing()
    {
        readyForRefresh = false;
        refreshing = false;
        
        refreshContainer.setPreferredHeight(0);
        refreshStatusContainer.visible = true;
    }

    function onListViewTouch(event) 
    {
        refreshContainer.resetPreferredHeight();
        
        if (event.touchType == TouchType.Up) 
        {
            released();
        }
    }
    
    function getImageHeight()
    {
        var height = 0;
        
        if(refreshHandler.layoutFrame.y > 0)
        {
            height = refreshHandler.layoutFrame.y;
        }
        else 
        {
            height = 5;
        }
        
        return height;
    }
}
