import bb.cascades 1.0

Dialog 
{
    Container 
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        background: Color.create("#ccffffff")
        leftPadding: 20.0
        rightPadding: 20.0
        topPadding: 50.0
        bottomPadding: 50.0
        
        Label 
        {
            text: "Brush Color"
        }
        
        WebView 
        {
            id: colorpicker
            settings.background: Color.Transparent
            url: "local:///assets/html/colorpicker.html"
            settings.webInspectorEnabled: true
            onMessageReceived: 
            {
                console.log("JSON: " + message.data);
                
                var colorJSON = JSON.parse(message.data);
                colorPickerBackground.background = Color.create(colorJSON.brushColorHEX);
            }
        }
        
        Label 
        {
            text: "Brush Size"
        }
        
        Slider 
        {
            id: brushSize
            value: 10
            fromValue: 1
            toValue: 150
        }
        
        Label 
        {
            text: "Brush Opacity"
        }
        
        Slider
        {
            id: brushOpacity
            value: 1
            fromValue: 0.1
            toValue: 1
        }
        
        Container 
        {
            layout: StackLayout 
            {
                orientation: LayoutOrientation.LeftToRight
            }
            
            Button 
            {
                id: muffinbutton
                horizontalAlignment: HorizontalAlignment.Fill
                text: "Set"
                onClicked: 
                {
                    var messageJSON = "{ \"size\":\"" + brushSize.value + "\", \"opacity\":\"" + brushOpacity.value + "\" }";
                    webView.postMessage(messageJSON);
                    
                    brushDialog.close(); 
                }
            }
            
            Button 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                text: "Cancel"
                onClicked: 
                {
                    brushDialog.close(); 
                }
            }
        }
    }
}