import bb.cascades 1.0

import "../smaato"

Sheet 
{
    id: sheet
    
    onOpened: 
    {
        _app.flurryLogEvent("PRO VERSION");
    }
    
    onClosed: 
    {
//        if(_app.isCard() && Qt.app.getSetting("purchasedAds", "false") == "false")
//        {
//            Application.requestExit();
//        }
    }

    Page 
    {
        titleBar: TitleBar 
        {
            title: "Upgrade to PRO"
            dismissAction: ActionItem 
            {
                title: "Close"
                onTriggered: 
                {
                    sheet.close();
                }
            }
        }
        
        Container 
        {
            layout: DockLayout {}
            
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center

            ScrollView 
            {
                verticalAlignment: VerticalAlignment.Center
                horizontalAlignment: HorizontalAlignment.Center
                
                Container 
                {
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    
                    leftPadding: 20
                    rightPadding: 20
                    
                    ImageView 
                    {
                        scalingMethod: ScalingMethod.AspectFit
                        imageSource: "asset:///images/new480.png"    
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        preferredHeight: 300
                    }
                    
                    Label 
                    {
                        text: "Upgrade to Snap10 Pro"
                        multiline: true
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.textAlign: TextAlign.Center
                        textStyle.fontWeight: FontWeight.W100
                        textStyle.fontSize: FontSize.XLarge
                    }
                    
                    Divider { }
                    
                    Label 
                    {
                        text: "No Advertisements, No Limits, All the features Twittly offers will be covered. To view all the features Twittly offers, please click the button below.";
                        textStyle.fontSize: FontSize.XXSmall
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.textAlign: TextAlign.Center
                        textStyle.color: Color.Gray
                        multiline: true
                    }

					Button 
					{
						text: "Upgrade to Pro NOW"
						horizontalAlignment: HorizontalAlignment.Center
						onClicked: 
						{
                            _app.flurryLogEvent("PRO BUTTON");
							
                            Qt.storePaymentManager.requestPurchase("", "snapnowads", "", "", "");
						}
					}
					
                    Button 
                    {
                        text: "View Full Features of Snap10 Pro"
                        horizontalAlignment: HorizontalAlignment.Center
                        
                        onClicked: 
                        {
                            _app.flurryLogEvent("FULL FEATURES");
                            
                            Qt.invokeBrowser.query.uri = "http://nemorystudios.blogspot.com/2014/11/snap10-pro-features.html";
                            Qt.invokeBrowser.query.updateQuery();
                        }
                    }
                    
                    Label 
                    {
                        text: "If you already purchased before, please click the button below.";
                        textStyle.fontSize: FontSize.XXSmall
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.textAlign: TextAlign.Center
                        textStyle.color: Color.Gray
                        multiline: true
                    }
                    
                    Button 
                    {
                        text: "Request Existing Purchase"
                        horizontalAlignment: HorizontalAlignment.Center
                        onClicked: 
                        {
                            Qt.storePaymentManager.requestExistingPurchases(true);
                            
                            Qt.toast.pop("Checking for existing purchase...");
                        }
                    }
					
                    SmaatoAds
                    {
                        id: ads
                    }
                }
            }
        }
    }
}