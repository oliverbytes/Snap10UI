import bb.cascades 1.0

TitleBar 
{
    property string page
    property string titleText
    property bool logoVisibility : true;
    property bool cameraVisibility
    property bool addFriendVisibility
    property bool closeVisibility
    property bool settingsVisibility
    
    signal closeButtonClicked();
    signal addFriendButtonClicked();

	appearance: TitleBarAppearance.Plain
    scrollBehavior: TitleBarScrollBehavior.Sticky
	kind: TitleBarKind.FreeForm
	
	kindProperties: FreeFormTitleBarKindProperties 
	{
	    content: 
		Container 
		{
		    id: titleBackground
            background: Color.create(_snap2chatAPIData.titleBarColor)
		    layout: DockLayout {}
		    
            horizontalAlignment: HorizontalAlignment.Fill
		    preferredHeight: 124

			Container 
			{
			    layout: DockLayout {}
		
		        horizontalAlignment: HorizontalAlignment.Fill
		        verticalAlignment: VerticalAlignment.Fill
		        
		        leftPadding: 20
		        rightPadding: leftPadding
		        
		        Container 
		        {
                    visible: logoVisibility
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    
                    ImageView 
                    {
                        visible: logoVisibility
                        verticalAlignment: VerticalAlignment.Center
                        imageSource: "asset:///images/title_bar_logo.png"
                        preferredHeight: 70
                        scalingMethod: ScalingMethod.AspectFit
                    }
                }
		        
				Container 
				{
					id: leftButtons
					visible: (cameraVisibility || closeVisibility)
                    horizontalAlignment: HorizontalAlignment.Left   
					verticalAlignment: VerticalAlignment.Center
					
                    ImageButton 
                    {
                        id: cameraButton
                        visible: cameraVisibility
                        defaultImageSource: "asset:///images/titleCamera.png"
                        onClicked: 
                        {
                            var parameters 				= new Object();
                            parameters.replyMode 		= false;
                            parameters.postToShoutBox 	= false;
                            parameters.recipient 		= "";
                            _app.openCameraTab(parameters);
                        }
                    }
                    
                    ImageButton 
                    {
                        id: closeButton
                        visible: closeVisibility
                        preferredHeight: 70
                        preferredWidth: 70
                        defaultImageSource: "asset:///images/Back.png"
                        onClicked: 
                        {
                            closeButtonClicked();
                        }
                    }
				}

		        Container 
		        {
		            id: rightButtons
		            
                    visible: (settingsVisibility || addFriendVisibility)
                    horizontalAlignment: HorizontalAlignment.Right
                    verticalAlignment: VerticalAlignment.Center
            
                    ImageButton 
                    {
                        visible: settingsVisibility
                        preferredHeight: 70
                        preferredWidth: 70
                        defaultImageSource: "asset:///images/titleSettings.png"
                        onClicked: 
                        {
                            Qt.settingsSheet.open();
                        }
                    }
                    
                    ImageButton 
                    {
                        visible: addFriendVisibility
                        defaultImageSource: "asset:///images/titleAddFriend.png"
                        onClicked: 
                        {
							addFriendButtonClicked();
                        }
                    }
              	}
		    }
		}
	}
}