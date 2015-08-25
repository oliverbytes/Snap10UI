import bb.cascades 1.0

Container {
	id:root
	
    property alias text: _lbl.text
    property int index: -1
    signal firstPanelVisible(bool value)
    
    layout: DockLayout {}
    
	Label {
	    id: _lbl
	    text: ":)"
	    textStyle.fontSize: FontSize.PointValue
        textStyle.fontSizeValue: 15
	    content.flags: TextContentFlag.Emoticons
        horizontalAlignment: HorizontalAlignment.Center
        verticalAlignment: VerticalAlignment.Center
	    
	}
	attachedObjects: [
		LayoutUpdateHandler {
	        onLayoutFrameChanged: {
	            
	        	if (index == 36) { // Arbitrary middle point, we have 72 emoticons
	            	//console.log("Layout Frame: [" + layoutFrame.x + ", " + layoutFrame.y + ", " + layoutFrame.width + ", " + layoutFrame.height + "]");
	            	
	            	//The middle point is 360 (=720/2) in the portrait mode, and 640 (=1280/2) in the landscape mode
	            	firstPanelVisible(layoutFrame.x > (OrientationSupport.orientation == UIOrientation.Portrait ? 360 : 640));
	            }
	        }
	    }
    ]
    
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
}