import bb.cascades 1.2

import "../emoticons"

Container 
{ 
    id: rootEmojiGrid
    
    signal bbmTapped1(string data);
    
    function fillListView(path, order) 
    {
        emojiListView.visible = true;
        bbmEmoticons.visible = false;
        
        rootEmojiGrid.hasButtons = false
        emojiDataModel.clear()
        for (var i=0; i<order.length;i++) {
            emojiDataModel.append(path+order[i])
        }
        rootEmojiGrid.hasButtons = true
    }
    
    function showBBMEmoticons()
    {
        emojiListView.visible = false;
        bbmEmoticons.visible = true;
        
        rootEmojiGrid.hasButtons = false
        emojiDataModel.clear()

        rootEmojiGrid.hasButtons = true
    }
    
    signal emojiTapped(string chars)
    
    property bool hasButtons: false

    implicitLayoutAnimationsEnabled: false
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    topPadding: 6
    bottomPadding: 6
    leftPadding: 6
    rightPadding: 6

    ActivityIndicator {
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1.0
        }
        visible: !rootEmojiGrid.hasButtons
        running: !rootEmojiGrid.hasButtons
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
        preferredWidth:  256 
        preferredHeight: 256 
    }

    ListView 
    {  
        id: emojiListView
        
        signal tapped(string chars)
        
        onTapped: 
        {
            rootEmojiGrid.emojiTapped(chars)
        }
        
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        scrollIndicatorMode: ScrollIndicatorMode.None
        snapMode: SnapMode.LeadingEdge
        visible: rootEmojiGrid.hasButtons
        flickMode: FlickMode.SingleItem
        
        layoutProperties: StackLayoutProperties 
        {
            spaceQuota: 1.0
        }
        
        layout: GridListLayout 
        {
            orientation: LayoutOrientation.LeftToRight
            headerMode: ListHeaderMode.None
        }
        
        dataModel: ArrayDataModel 
        {
            id: emojiDataModel
        }
        
        listItemComponents: 
        [
            ListItemComponent 
            {
                EmojiButton 
                {
                    imageSource: ListItemData.toString()
                }
            }
        ]
    }
    
    ListView 
    {
        id: bbmEmoticons
        visible: false
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        snapMode: SnapMode.LeadingEdge
        scrollIndicatorMode: ScrollIndicatorMode.None
        
        rightPadding: OrientationSupport.orientation == UIOrientation.Portrait ? 0 : 10
        leftPadding: OrientationSupport.orientation == UIOrientation.Portrait ? 0 : 10
        
        layout: GridListLayout 
        {
            orientation: LayoutOrientation.LeftToRight
            
            horizontalCellSpacing: 0
            verticalCellSpacing: 0
            cellAspectRatio: 96/89
        }
        
        dataModel: ArrayDataModel 
        {
            id: emoticonsModel
        }
        
        onCreationCompleted: 
        {
            emoticonsModel.append(
            [
                ":)", ";)", ":D", "=D", "=))", "({})", "\\=D/", "<=-P", ":p", ";;)", "<3<3", ":*", ":|", 
                "/:)", ":>", "3-|", ":]x", ">:/", "8-|", ":]Y", ":s", ":&", ":]xx", ":(", ":'(", ">:O", ":$", 
                "#:-s", ":/", ":O", "X_X", "(=|", ":x", "O:)", ">=)", "*nerd*", "B-)", "=)]", "=]min", "=-c", 
                "~o)", "*beer*", "*wine*", "*dine*", "@>--", "*gift*", "*bday*", "(*)", "*fly*", "=]()", "*music*", 
                "=-?", "*...*", "(y)", "(n)", "<3", "</3", "|:o|", "\\m/", "|-)", "!-)", "8-}", ":G", 
                "x-o", "~:-)", ";-shh", ":E>", "*snow*", "*sun*", "*rain*", "*storm*", "*pic*", "*idea*", "*run*", 
                "*fist*", "*rainbow*", "*moon*", "*thinking*","*coffee*", "*nerd*", "*eyesrolling*", "*yawn*", 
                "*callme*", "*onthephone*", "*BDRIVE*", "=]MIN", "*BMIN*", 
            ]);
        }
        
        onTriggered: 
        {
            var text = emoticonsModel.data(indexPath);
            bbmTapped1(text);
        }
        
        listItemComponents: 
        [
            ListItemComponent 
            {
                Emoticon 
                {
                    text: ListItemData.toString()
                    index: ListItem.indexPath[0]
                }
            }
        ]
    }
}
