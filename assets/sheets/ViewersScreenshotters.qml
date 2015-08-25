import bb.cascades 1.2

import "../components/"
import "../smaato"

Sheet
{
    id: sheet
    
    property variant storyNotes;
    
    function load()
    {
        Qt.snap2chatAPIData.currentStoryNotesDataModel.clear();
        Qt.snap2chatAPIData.currentStoryNotesDataModel.insert(0, storyNotes);
    }
    
    Page
    {
        id: page
        
        titleBar: CustomTitleBar 
        {
            closeVisibility: true
            onCloseButtonClicked:
            {
                close();
            }
        }
        
        Container 
        {
            id: results
            
            Header
            {
                id: listViewHeader
                title: "Viewers and Screenshotters: "
                subtitle: Qt.snap2chatAPIData.currentStoryNotesDataModel.size();
            }
            
            SmaatoAds
            {
                id: ads
            }
            
            ListView 
            {
                id: listView
                dataModel: Qt.snap2chatAPIData.currentStoryNotesDataModel
                
                listItemComponents: 
                [
                    ListItemComponent 
                    {
                        content: CustomListItem 
                        {
                            highlightAppearance: HighlightAppearance.Full
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            
                            ViewerScreenshotterItem 
                            {
                                id: root
                            }
                        }
                    }
                ]
            }
        }
        
        actions: 
        [
            ActionItem 
            {
                title: "Jump To Top"
                imageSource: "asset:///images/ic_to_top.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: 
                {
                    listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                }
            },
            ActionItem 
            {
                title: "Jump To Bottom"
                imageSource: "asset:///images/ic_to_bottom.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: 
                {
                    listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth);
                }
            }
        ]
    }
}