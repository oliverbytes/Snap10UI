import bb.cascades 1.2

import "../sheets"
import "../components"
import "../smaato"

NavigationPane 
{
    id: navigationPane

    function load()
    {
        if(!Qt.snap2chatAPIData.loadingShoutbox)
        {
            Qt.snap2chatAPIData.loadingShoutbox = true;
            
            var params = new Object();
            params.url = "http://kellyescape.com/snapchat/includes/webservices/get.php?object=boxsnap&username=" + Qt.snap2chatAPIData.username;
            params.endpoint = "shoutbox";
            Qt.snap2chatAPI.kellyGetRequest(params);
        }
    }
    
    attachedObjects: 
    [
        ComponentDefinition 
        {
            id: boxsnapOverViewDefinition
            source: "asset:///pages/BoxSnapOverView.qml"
        }
    ]
    
    onCreationCompleted: 
    {
        load();
    }
    
    Page
    {
        id: page
        titleBar: CustomTitleBar 
        {
            id: titleBar
            cameraVisibility: true
            settingsVisibility: true
        }
        
        Container 
        {
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Fill
            
            Container 
            {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                
                Label 
                {
                    text: "Coming Back Soon :)"
                    horizontalAlignment: HorizontalAlignment.Center
                }
                
                SmaatoAds 
                {
                    id: ads
                }
            }

            Container 
            {
                id: results
                horizontalAlignment: HorizontalAlignment.Fill
                topPadding: 10
                
//                SegmentedControl 
//                {
//                    visible: false
//                    options: 
//                    [
//                        Option
//                        {
//                        	text: "Latest"
//                        },
//                        Option
//                        {
//                            text: "Top"
//                        },
//                        Option
//                        {
//                            text: "Stickies"
//                        },
//                        Option
//                        {
//                            text: "My"
//                        }
//                    ]
//                    
//                    onSelectedOptionChanged:
//                    {
//                        load()
//                    }
//                }
                
//                Header
//                {
//                    id: listViewHeader
//                    title: "SHOUTBOX"
//                }
//                 

                PullToRefreshListView 
                {
                    id: listView
                    snapMode: SnapMode.Default
                    loading: Qt.snap2chatAPIData.loadingShoutbox
                    dataModel: Qt.snap2chatAPIData.shoutboxDataModel
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    listItemComponents: 
                    [
                        ListItemComponent
                        {
                            BoxSnapItem
                            {
                            	id: root
                            }
                        }
                    ]
                    
                    attachedObjects: 
                    [
                        ListScrollStateHandler 
                        {
                            id: scrollStateHandler
                        }
                    ]
                    
                    function openOverView(boxsnapObject)
                    {
                        var page 				= boxsnapOverViewDefinition.createObject();
                        page.boxsnapObject 		= boxsnapObject;
                        page.loadComments();
                        navigationPane.push(page);
                    }
                    
                    function refreshTriggered()
                    {
                        load();
                    }
                }
            }
            
            Container 
            {
                visible: Qt.snap2chatAPIData.loadingShoutbox
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Bottom
                
                bottomPadding: 20
                rightPadding: 20
                
                ActivityIndicator 
                {
                    visible: true
                    running: visible
                    preferredHeight: 60
                }
            }
            
            Container 
            {
                id: jumpButtons
                opacity: 0.5
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Center
                rightPadding: 20
                visible: scrollStateHandler.scrolling && Qt.app.getSetting("floatingButtons", "true") == "true"
                
                ImageButton
                {
                    defaultImageSource: "asset:///images/jumpToTop.png" 
                    verticalAlignment: VerticalAlignment.Center
                    onClicked: 
                    {
                        listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth)
                    }
                }
                
                ImageButton
                {
                    defaultImageSource: "asset:///images/jumpToBottom.png" 
                    verticalAlignment: VerticalAlignment.Center
                    onClicked: 
                    {
                        listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth)
                    }
                }
            }
        }
        
//        actions:
//        [
//            ActionItem 
//            {
//                title: "Shout"
//                ActionBar.placement: ActionBarPlacement.OnBar
//                imageSource: "asset:///images/shout.png"
//                onTriggered: 
//                {
//                    Qt.shoutSheet.open();
//                }
//            },
//            ActionItem 
//            {
//                title: "Refresh"
//                enabled: !Qt.snap2chatAPIData.loadingShoutbox
//                ActionBar.placement: ActionBarPlacement.OnBar
//                imageSource: "asset:///images/refresh.png"
//                onTriggered: 
//                {
//                    load();
//                }
//            },
//            ActionItem 
//            {
//                title: "Jump To Top"
//                ActionBar.placement: ActionBarPlacement.OnBar
//                imageSource: "asset:///images/ic_to_top.png"
//                onTriggered: 
//                {
//                    listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
//                }
//            },
//            ActionItem 
//            {
//                title: "Jump To Bottom"
//                ActionBar.placement: ActionBarPlacement.OnBar
//                imageSource: "asset:///images/ic_to_bottom.png"
//                onTriggered: 
//                {
//                    listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth);
//                }
//            }
//        ]
    }
}