import bb.cascades 1.0
import org.labsquare 1.0

import "../smaato"

Sheet 
{
    id: sheet
    
    property string announcementString : "";
    property string imageURL : "";
    property string lockMessage : "";
    property bool lock : false;
    
    onOpened: 
    {
        labelObject.text = urlify(announcementString);
        image.url        = imageURL;
    }
    
    Page 
    {
        id: page
        
        titleBar: TitleBar 
        {
            title: "Announcements"
            branded: TriBool.False
        }
        
        ScrollView 
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                layout: DockLayout {}
                
                Container 
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    topPadding: 20
                    bottomPadding: 20
                    leftPadding: 20
                    rightPadding: 20
                    
                    WebImageView 
                    {
                        id: image
                        horizontalAlignment: HorizontalAlignment.Center
                        maxWidth: 720
                        minWidth: 720
                        scalingMethod: ScalingMethod.AspectFill
                        defaultImage: "asset:///images/loading.png"
                        imageSource: "asset:///images/loading.png"
                    }
                    
                    Button 
                    {
                        visible: !_app.purchasedAds
                        text: "Upgrade to PRO"
                        horizontalAlignment: HorizontalAlignment.Center
                        
                        onClicked: 
                        {
                            Qt.proSheet.open();
                        }
                    }
                    
                    TextArea 
                    {
                        id: labelObject
                        text: "Loading..."
                        backgroundVisible: false
                        editable: false
                        input.flags: TextInputFlag.SpellCheckOff
                        inputMode: TextAreaInputMode.Chat
                        textFormat: TextFormat.Html
                        textStyle.fontWeight: FontWeight.W100
                        textStyle.fontSize: FontSize.Small
                    }
                    
                    SmaatoAds
                    {
                        id: ads
                    }
                }
            }
        }
        
        actions: 
        [
            ActionItem 
            {
                title: "Close"
                imageSource: "asset:///images/tabBack.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: 
                {
                    if(!lock)
                    {
                        sheet.close();
                    }
                    else 
                    {
                        Qt.dialogX.pop(lockMessage);
                    }
                }
            }
        ]
    }
    
    function urlify(text) 
    {
        return text.replace(/(https?:\/\/[^\s]+)/g, function(url)
        {
            return '<a style="font-weight: 500; color:#00779e;" href="' + url + '">' + url + '</a>';
        });
    }
}