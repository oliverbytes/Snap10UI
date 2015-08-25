import bb.cascades 1.2

import "../components"
import "../sheets"
import "../smaato"

NavigationPane 
{
    id: navigationPane
    property string therecipient : "";
    property bool isPhoto : false;
    property bool isVideoWithCaption : false;
    property variant theAttachedObjects
    
    function createObjects()
    {
        if (!navigationPane.theAttachedObjects)
        {
            navigationPane.theAttachedObjects = myAttachedObjects.createObject(navigationPane);
        }
    }
    
    function destroyObjects()
    {
        if (navigationPane.theAttachedObjects)
        {
            navigationPane.theAttachedObjects.destroy();
        }
    }
    
    onCreationCompleted: 
    {
        createObjects();
    }
    
    attachedObjects: 
    [
        ComponentDefinition 
        {
            id: myAttachedObjects
            
            Container 
            {
                id: objects
                
                property alias storyOverviewSheetInteract : storyOverviewSheet
                
                attachedObjects: 
                [
                    StoryOverview
                    {
                        id: storyOverviewSheet
                    }
                ]
            }
        },
        ComponentDefinition 
        {
            id: extendedProfileComponent
            source: "asset:///pages/ExtendedProfile.qml"
        }
    ]

    function loadStories()
    {
        Qt.app.loadStories();
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
                id: results
                horizontalAlignment: HorizontalAlignment.Fill
                
                Header
                {
                    id: listViewHeader
                    title: "STORIES"
                    subtitle: Qt.snap2chatAPIData.storiesDataModel.size();
                }
                
                SmaatoAds
                {
                    id: ads
                }
                
                PullToRefreshListView 
                {
                    id: listView
                    loading: Qt.snap2chatAPIData.loadingStories
                    dataModel: Qt.snap2chatAPIData.storiesDataModel
                    horizontalAlignment: HorizontalAlignment.Fill

                    listItemComponents: 
                    [
                        ListItemComponent 
                        {
                            type: "header"
                            
                            Container 
                            {
                                topPadding: 5
                                bottomPadding: topPadding
                                horizontalAlignment: HorizontalAlignment.Fill
                                
                                Label 
                                {
                                    text: ListItemData
                                    horizontalAlignment: HorizontalAlignment.Center
                                    textStyle.fontSize: FontSize.Small
                                    textStyle.color: Color.create("#0f9f9a")
                                }
                                
                                Divider {}
                            }
                        },
                        ListItemComponent 
                        {
                            type: "item"
                            
                            content: StoryItem 
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
                    
                    function openStoryOverview(ListItemData)
                    {
                        theAttachedObjects.storyOverviewSheetInteract.userStory = ListItemData;
                        theAttachedObjects.storyOverviewSheetInteract.load();
                        theAttachedObjects.storyOverviewSheetInteract.open();
                    }
                    
                    function refreshTriggered()
                    {
                        loadStories();
                    }
                }
            }

            Container 
            {
                visible: (!Qt.snap2chatAPIData.loadingStories && listViewHeader.subtitle == 0)
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                
                Label 
                {
                    text: (Qt.snap2chatAPIData.loadingStories ? "Loading..." : "No entries to show. :(")
                    textStyle.fontSize: FontSize.Small
                }
            }
            
            Container 
            {
                id: loadingBox
                visible: Qt.snap2chatAPIData.loadingStories
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                touchPropagationMode: TouchPropagationMode.None
                layout: DockLayout {}
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Bottom
                    leftPadding: 20
                    bottomPadding: 20
                    
                    Label 
                    {
                        text: "Loading..."
                        visible: false
                        textStyle.fontSize: FontSize.Small
                    }
                }
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Bottom
                    rightPadding: 20
                    bottomPadding: 10
                    
                    ActivityIndicator 
                    {
                        visible: true
                        running: visible
                        preferredHeight: 60
                    }
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
        
        actions: 
        [
            ActionItem 
            {
                title: "Refresh"
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "asset:///images/refresh.png"
                onTriggered: 
                {
                    loadStories();
                }
            },
            ActionItem 
            {
                title: "Jump To Top"
                ActionBar.placement: ActionBarPlacement.InOverflow
                imageSource: "asset:///images/ic_to_top.png"
                onTriggered: 
                {
                    listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                }
            },
            ActionItem 
            {
                title: "Jump To Bottom"
                ActionBar.placement: ActionBarPlacement.InOverflow
                imageSource: "asset:///images/ic_to_bottom.png"
                onTriggered: 
                {
                    listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth);
                }
            }
        ]
    }

    function setOrientation()
    {
        var orientation = Qt.app.getSetting("orientation", 0);
        
        if(orientation == 0)
        {
            OrientationSupport.supportedDisplayOrientation = 
            SupportedDisplayOrientation.All;  
        }
        else if(orientation == 1)
        {
            OrientationSupport.supportedDisplayOrientation = 
            SupportedDisplayOrientation.DisplayPortrait;  
        }
        else if(orientation == 2)
        {
            OrientationSupport.supportedDisplayOrientation = 
            SupportedDisplayOrientation.DisplayLandscape;  
        }
    }
}