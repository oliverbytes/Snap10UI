import bb.cascades 1.2
import com.knobtviker.Helpers 1.0

Container 
{ 
    id: rootEmojiKeyboard

    signal bbmEmoticonTapped(string data);
    signal emojiTapped(string chars); 
    
    signal keyboardShown1();
    signal keyboardHidden1();
    
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Bottom
    preferredHeight: 400
    background: Color.create("#ff323232")
    bottomPadding: 6
    
    onVisibleChanged: 
    {
        if(visible)
        {
            keyboard.setVisibility(false);
        }
    }

    Container 
    {
        background: Color.create("#ff676f73")
        horizontalAlignment: HorizontalAlignment.Fill
        minHeight: 9
        preferredHeight: 9
    }
    
    EmojiGrid 
    {
        id: emojiGrid
        
        onEmojiTapped: 
        {
            rootEmojiKeyboard.emojiTapped(chars)
        }
        
        onBbmTapped1: 
        {
            bbmEmoticonTapped(data);
        }
    }
    
    Container 
    {
        background: Color.create("#ff676f73")
        horizontalAlignment: HorizontalAlignment.Fill
        minHeight: 9
        preferredHeight: 9
    }
    
    EmojiTabsContainer 
    {
        onEmojiTabClicked: 
        {
            emojiGrid.fillListView(tabName, tabOrder)
        }
        
        onBbmEmoticonsClicked1: 
        {
            emojiGrid.showBBMEmoticons();
        }
    }
    
    attachedObjects: 
    [
        VirtualKeyboardHandler 
        {
            id: keyboard
            
            onKeyboardShown: 
            {
                console.log("SHOWN");
                
                rootEmojiKeyboard.visible = false;
                
                keyboardShown1();
            }
            
            onKeyboardHidden: 
            {
                console.log("HIDDEN"); 
                
                keyboardHidden1();
            }
        }
    ]
    
    function getUnicodeCharacter(cp) 
    {
        if (cp >= 0 && cp <= 0xD7FF || cp >= 0xE000 && cp <= 0xFFFF) 
        {
            return String.fromCharCode(cp);
        } 
        else if (cp >= 0x10000 && cp <= 0x10FFFF) 
        {
            cp -= 0x10000;
            var first = ((0xffc00 & cp) >> 10) + 0xD800
            var second = (0x3ff & cp) + 0xDC00;
            return String.fromCharCode(first) + String.fromCharCode(second);
        }
    }
}
