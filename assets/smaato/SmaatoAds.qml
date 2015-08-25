import bb.cascades 1.0
import smaatosdk 1.0
import smaatoapi 1.0
import QtQuick 1.0

Container 
{
    id: mainContainer
    maxWidth: 720
    maxHeight: 120
    horizontalAlignment: HorizontalAlignment.Center
    layout: DockLayout {}
    visible: (_app.purchasedAds == false)
    
    property int size : 0;
    
    ImageView 
    {
        imageSource: "asset:///removeAds.png"
        
        gestureHandlers: TapHandler 
        {
            onTapped: 
            {
                btnRemoveAds.clicked();
            }
        }
    }

    SSmaatoAdView 
    {
        id: ads
        preferredWidth: 720
        preferredHeight: 120
        adSpaceId: "65839080"
        publisherId: "923880115"
        viewSize: SSmaatoAdView.AdViewSizeNormal
        format: 1
        coppa: 0
        
        gender: 
        {
            var finalGender = SSmaatoAPI.Female;
            
            var randomNumber = Math.floor((Math.random() * 2) + 1);
            
            if(randomNumber == 2)
            {
                finalGender = SSmaatoAPI.Male;
            }
            
            return finalGender;
        }
        
        onAdUpdated: 
        {
            if (success) 
            {
                ads.autoRefreshPeriod = 0;
            } 
            else 
            {
                ads.autoRefreshPeriod = 30 // by seconds
                
                //console.log("************ SMAATO FAILED ************"); 
            }
        }
    }

    attachedObjects: 
    [
        Timer 
        {
            id: timer
            repeat: false
            interval: 2000
            onTriggered: 
            {
                mainContainer.visible = false;
            }
        }
    ]
    
    ImageButton 
    {
        id: btnRemoveAds
        defaultImageSource: "asset:///xStroked.png"    
        horizontalAlignment: HorizontalAlignment.Right
        verticalAlignment: VerticalAlignment.Top
        
        onClicked: 
        {
            _app.flurryLogEvent("REMOVE ADS");
            
            Qt.proSheet.open(); 
            Qt.toastX.pop("Remove Advertisements and unlock Full Features! Upgrade to PRO Version now for a very low price. :)");    
        }
    }
}
