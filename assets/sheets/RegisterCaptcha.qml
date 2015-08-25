import bb.cascades 1.0
import nemory.Snap2ChatAPISimple 1.0
import bb.system 1.0

Sheet 
{
    id: sheet
    peekEnabled: false
    
    signal forceClose();
    
    property string captchaID : "";
    property string emailUsername : "";
    property string authToken: "";
    property string prompt: "";
    
    property variant theAttachedObjects

    function createObjects()
    {
        if (!sheet.theAttachedObjects)
        {
            sheet.theAttachedObjects = myAttachedObjects.createObject(sheet);
        }
    }
    
    function destroyObjects()
    {
        if (sheet.theAttachedObjects)
        {
            sheet.theAttachedObjects.destroy();
        }
    }
    
    onCreationCompleted: 
    {
        createObjects();
    }
    
    onOpened: 
    {
        createObjects();
        
        resetSelectedImages();
        resetImages();
    }
    
    onClosed: 
    {
        destroyObjects();
    }
    
    function resetSelectedImages()
    {
        var captchaImages = new Array(row1col1, row1col2, row1col3, row2col1, row2col2, row2col3, row3col1, row3col2, row3col3);
        
        var captchaSolution = "";
        var atleast1Selected = false;
        
        for(var i = 0; i < captchaImages.length; i++)
        {
            var captchaImage = captchaImages[i];
            captchaImage.selected = false;
        }
    }
    
    function resetImages()
    {
        var homePath = Qt.app.getHomePath();


        row1col1Image.resetImageSource();
        row1col1Image.setImageSource("asset:///images/tabView.png");
        row1col1Image.setImageSource("file://" + homePath + "/files/captcha/" + captchaID + "/image0.png");
        
        row1col2Image.resetImageSource();
        row1col2Image.setImageSource("asset:///images/tabView.png");
        row1col2Image.setImageSource("file://" + homePath + "/files/captcha/" + captchaID + "/image1.png");
        
        row1col3Image.resetImageSource();
        row1col3Image.setImageSource("asset:///images/tabView.png");
        row1col3Image.setImageSource("file://" + homePath + "/files/captcha/" + captchaID + "/image2.png");
        
        // ------------------------------------------------------------------------------------------- //
        row2col1Image.resetImageSource();
        row2col1Image.setImageSource("asset:///images/tabView.png");
        row2col1Image.setImageSource("file://" + homePath + "/files/captcha/" + captchaID + "/image3.png");
        
        row2col2Image.resetImageSource();
        row2col2Image.setImageSource("asset:///images/tabView.png");
        row2col2Image.setImageSource("file://" + homePath + "/files/captcha/" + captchaID + "/image4.png");
        
        row2col3Image.resetImageSource();
        row2col3Image.setImageSource("asset:///images/tabView.png");
        row2col3Image.setImageSource("file://" + homePath + "/files/captcha/" + captchaID + "/image5.png");
        
        // ------------------------------------------------------------------------------------------- //
        
        row3col1Image.resetImageSource();
        row3col1Image.setImageSource("asset:///images/tabView.png");
        row3col1Image.setImageSource("file://" + homePath + "/files/captcha/" + captchaID + "/image6.png");
        
        row3col2Image.resetImageSource();
        row3col2Image.setImageSource("asset:///images/tabView.png");
        row3col2Image.setImageSource("file://" + homePath + "/files/captcha/" + captchaID + "/image7.png");
        
        row3col3Image.resetImageSource();
        row3col3Image.setImageSource("asset:///images/tabView.png");
        row3col3Image.setImageSource("file://" + homePath + "/files/captcha/" + captchaID + "/image8.png");
    }
    
    attachedObjects: 
    [
        ComponentDefinition 
        {
            id: myAttachedObjects
            
            Container 
            {
                id: objects
                
                property alias snap2chatAPIInteract: snap2chatAPICaptchaRegister
                property alias registerUsernameSheetInteract: registerUsernameSheet
                
                attachedObjects: 
                [
                    Snap2ChatAPISimple 
                    {
                        id: snap2chatAPICaptchaRegister
                        onComplete:
                        {
                            Qt.progressDialog.cancel();
                            
                            console.log("REGISTER CAPTCHA: " + response);
 
                            if(response == 200)
                            {
                                registerUsernameSheet.emailUsername = sheet.emailUsername;
                                registerUsernameSheet.authToken = sheet.authToken;
                                registerUsernameSheet.open();
                            }
                            else if(response > 200)
                            {
                                grid.visible = false;
                                
                                resetImages();
                                resetSelectedImages();

                                // ---------------- LOAD NEW CAPTCHAS --------------------------
                                
                                var params 			= new Object();
                                params.endpoint		= "/bq/get_captcha";
                                params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
                                params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, sheet.authToken);
                                
                                params.username 	= sheet.emailUsername;
                                
                                captchaDownloader2.downloadCaptcha(params);
                                
                                Qt.progressDialog.body = "Wrong answers. Loading new captchas... " + prompt;
                                Qt.progressDialog.show();
                            }
                        }
                    },
                    Snap2ChatAPISimple 
                    {
                        id: captchaDownloader2
                        onDownloadDone: 
                        {
                            var re = new RegExp("attachment;filename=(.*).zip");
                            var newRealFileName = re.exec(realFileName)[1];
                            
                            captchaID = newRealFileName;
                            
                            Qt.app.unzip("data/files/captcha/captcha.zip", "data/files/captcha/" + captchaID + "/");
                            
                            Qt.progressDialog.cancel();
                            
                            grid.visible = true;
                            
                            resetSelectedImages();
                            resetImages();
                        }
                    },
                    RegisterUsername 
                    {
                        id: registerUsernameSheet
                        
                        onForceClose: 
                        {
                            sheet.close();
                            sheet.forceClose();
                        }
                    }
                ]
            }
        }
    ]
    
    Page 
    {
        Container 
        {
            layout: DockLayout {}
            
            ImageView 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                imageSource: "asset:///images/mybackground.jpg"
                scalingMethod: ScalingMethod.AspectFill
            }
            
            ScrollView 
            {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                
                Container 
                {
                    id: mainContentContainer
                    
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    leftPadding: 50
                    rightPadding: 50
                    
                    Container 
                    {
                        verticalAlignment: VerticalAlignment.Center
                        topPadding: (Qt.app.getDisplayHeight() < 730 ? 130 : 0)
                        bottomPadding: 20
                        
                        Label 
                        {
                            text: "Robot Checkpoint"
                            textStyle.fontWeight: FontWeight.W100
                            textStyle.fontSize: FontSize.XXLarge
                            textStyle.color: Color.White
                        }
                        
                        Divider {}
                        
                        Label 
                        {
                            text: prompt
                            textStyle.color: Color.White
                            textStyle.fontWeight: FontWeight.W100
                            horizontalAlignment: HorizontalAlignment.Center
                        }
                        
                        Container 
                        {
                            id: grid
                            property int imageRatio : (Qt.app.getDisplayHeight() < 730 ? 100 : 200)
                            property variant selectedBackground : Color.create("#aaFFFFFF");
                            property int selectedBackgroundPadding : 10;
                            
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            
                            layout: StackLayout 
                            {
                                orientation: LayoutOrientation.TopToBottom
                            }
                            
                            Container 
                            {
                                id: row1
                                
                                horizontalAlignment: HorizontalAlignment.Center
                                
                                layout: StackLayout 
                                {
                                    orientation: LayoutOrientation.LeftToRight
                                }
                                
                                Container 
                                {
                                    id: row1col1
                                    property bool selected : false;
                                    background: (selected ? grid.selectedBackground : Color.Transparent)
                                    topPadding: grid.selectedBackgroundPadding
                                    bottomPadding: topPadding
                                    leftPadding: topPadding
                                    rightPadding: topPadding
                                    
                                    gestureHandlers: TapHandler 
                                    {
                                        onTapped: 
                                        {
                                            row1col1.selected = !row1col1.selected;
                                        }
                                    }
                                    
                                    ImageView 
                                    {
                                        id: row1col1Image
                                        preferredHeight: grid.imageRatio
                                        preferredWidth: grid.imageRatio
                                    }
                                }
                                
                                Container 
                                {
                                    id: row1col2
                                    property bool selected : false;
                                    background: (selected ? grid.selectedBackground : Color.Transparent)
                                    topPadding: grid.selectedBackgroundPadding
                                    bottomPadding: topPadding
                                    leftPadding: topPadding
                                    rightPadding: topPadding
                                    
                                    gestureHandlers: TapHandler 
                                    {
                                        onTapped: 
                                        {
                                            row1col2.selected = !row1col2.selected;
                                        }
                                    }
                                    
                                    ImageView 
                                    {
                                        id: row1col2Image
                                        preferredHeight: grid.imageRatio
                                        preferredWidth: grid.imageRatio
                                    }
                                }
                                
                                Container 
                                {
                                    id: row1col3
                                    property bool selected : false;
                                    background: (selected ? grid.selectedBackground : Color.Transparent)
                                    topPadding: grid.selectedBackgroundPadding
                                    bottomPadding: topPadding
                                    leftPadding: topPadding
                                    rightPadding: topPadding
                                    
                                    gestureHandlers: TapHandler 
                                    {
                                        onTapped: 
                                        {
                                            row1col3.selected = !row1col3.selected;
                                        }
                                    }
                                    
                                    ImageView 
                                    {
                                        id: row1col3Image
                                        preferredHeight: grid.imageRatio
                                        preferredWidth: grid.imageRatio
                                    }
                                }
                            }
                            
                            Container 
                            {
                                id: row2
                                
                                horizontalAlignment: HorizontalAlignment.Center
                                
                                layout: StackLayout 
                                {
                                    orientation: LayoutOrientation.LeftToRight
                                }
                                
                                Container 
                                {
                                    id: row2col1
                                    property bool selected : false;
                                    background: (selected ? grid.selectedBackground : Color.Transparent)
                                    topPadding: grid.selectedBackgroundPadding
                                    bottomPadding: topPadding
                                    leftPadding: topPadding
                                    rightPadding: topPadding
                                    
                                    gestureHandlers: TapHandler 
                                    {
                                        onTapped: 
                                        {
                                            row2col1.selected = !row2col1.selected;
                                        }
                                    }
                                    
                                    ImageView 
                                    {
                                        id: row2col1Image
                                        preferredHeight: grid.imageRatio
                                        preferredWidth: grid.imageRatio
                                    }
                                }
                                
                                Container 
                                {
                                    id: row2col2
                                    property bool selected : false;
                                    background: (selected ? grid.selectedBackground : Color.Transparent)
                                    topPadding: grid.selectedBackgroundPadding
                                    bottomPadding: topPadding
                                    leftPadding: topPadding
                                    rightPadding: topPadding
                                    
                                    gestureHandlers: TapHandler 
                                    {
                                        onTapped: 
                                        {
                                            row2col2.selected = !row2col2.selected;
                                        }
                                    }
                                    
                                    ImageView 
                                    {
                                        id: row2col2Image
                                        preferredHeight: grid.imageRatio
                                        preferredWidth: grid.imageRatio
                                    }
                                }
                                
                                Container 
                                {
                                    id: row2col3
                                    property bool selected : false;
                                    background: (selected ? grid.selectedBackground : Color.Transparent)
                                    topPadding: grid.selectedBackgroundPadding
                                    bottomPadding: topPadding
                                    leftPadding: topPadding
                                    rightPadding: topPadding
                                    
                                    gestureHandlers: TapHandler 
                                    {
                                        onTapped: 
                                        {
                                            row2col3.selected = !row2col3.selected;
                                        }
                                    }
                                    
                                    ImageView 
                                    {
                                        id: row2col3Image
                                        preferredHeight: grid.imageRatio
                                        preferredWidth: grid.imageRatio
                                    }
                                }
                            }
                            
                            Container 
                            {
                                id: row3
                                
                                horizontalAlignment: HorizontalAlignment.Center
                                
                                layout: StackLayout 
                                {
                                    orientation: LayoutOrientation.LeftToRight
                                }
                                
                                Container 
                                {
                                    id: row3col1
                                    property bool selected : false;
                                    background: (selected ? grid.selectedBackground : Color.Transparent)
                                    topPadding: grid.selectedBackgroundPadding
                                    bottomPadding: topPadding
                                    leftPadding: topPadding
                                    rightPadding: topPadding
                                    
                                    gestureHandlers: TapHandler 
                                    {
                                        onTapped: 
                                        {
                                            row3col1.selected = !row3col1.selected;
                                        }
                                    }
                                    
                                    ImageView 
                                    {
                                        id: row3col1Image
                                        preferredHeight: grid.imageRatio
                                        preferredWidth: grid.imageRatio
                                    }
                                }
                                
                                Container 
                                {
                                    id: row3col2
                                    property bool selected : false;
                                    background: (selected ? grid.selectedBackground : Color.Transparent)
                                    topPadding: grid.selectedBackgroundPadding
                                    bottomPadding: topPadding
                                    leftPadding: topPadding
                                    rightPadding: topPadding
                                    
                                    gestureHandlers: TapHandler 
                                    {
                                        onTapped: 
                                        {
                                            row3col2.selected = !row3col2.selected;
                                        }
                                    }
                                    
                                    ImageView 
                                    {
                                        id: row3col2Image
                                        preferredHeight: grid.imageRatio
                                        preferredWidth: grid.imageRatio
                                    }
                                }
                                
                                Container 
                                {
                                    id: row3col3
                                    property bool selected : false;
                                    background: (selected ? grid.selectedBackground : Color.Transparent)
                                    topPadding: grid.selectedBackgroundPadding
                                    bottomPadding: topPadding
                                    leftPadding: topPadding
                                    rightPadding: topPadding
                                    
                                    gestureHandlers: TapHandler 
                                    {
                                        onTapped: 
                                        {
                                            row3col3.selected = !row3col3.selected;
                                        }
                                    }
                                    
                                    ImageView 
                                    {
                                        id: row3col3Image
                                        preferredHeight: grid.imageRatio
                                        preferredWidth: grid.imageRatio
                                    }
                                }
                            }
                        }
                        
                        Button 
                        {
                            text: "Done"
                            horizontalAlignment: HorizontalAlignment.Center
                            onClicked: 
                            {
                                done();
                            }
                        }
                    }
                }
            }
            
            Container 
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Top
                background: Color.create("#1a000000")
                
                topPadding: 30
                bottomPadding: 20
                
                ImageView 
                {
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    imageSource: "asset:///images/title_bar_logo.png"
                    preferredHeight: 70
                    scalingMethod: ScalingMethod.AspectFit
                }
            }
            
            Container 
            {
                verticalAlignment: VerticalAlignment.Top
                topPadding: 20
                leftPadding: 10
                
                ImageButton 
                {
                    horizontalAlignment: HorizontalAlignment.Left
                    verticalAlignment: VerticalAlignment.Top
                    defaultImageSource: "asset:///images/Back.png"
                    onClicked: 
                    {
                        sheet.close();
                    }
                }
            }
            
            Container 
            {
                horizontalAlignment: HorizontalAlignment.Right
                verticalAlignment: VerticalAlignment.Top
                topPadding: 20
                rightPadding: 30
                
                ImageButton 
                {
                    defaultImageSource: "asset:///images/titleInfo.png"
                    onClicked: 
                    {
                        Qt.aboutSheet.open();
                    }
                }
            }
        }
    }
    
    function done()
    {
        var captchaImages = new Array(row1col1, row1col2, row1col3, row2col1, row2col2, row2col3, row3col1, row3col2, row3col3);
        
        var captchaSolution = "";
        var atleast1Selected = false;
        
        for(var i = 0; i < captchaImages.length; i++)
        {
            var captchaImage = captchaImages[i];
            
            if(captchaImage.selected)
            {
                captchaSolution += "" + 1;
                
                atleast1Selected = true;
            }
            else 
            {
                captchaSolution += "" + 0;
            }
        }
        
        if(atleast1Selected)
        {
            Qt.progressDialog.body = "Solving captcha... " + prompt;
            Qt.progressDialog.show();
            
            var params 			= new Object();
            params.endpoint		= "/bq/solve_captcha";
            params.timestamp 	= Qt.snap2chatAPIData.getCurrentTimestamp();
            params.req_token 	= Qt.snap2chatAPIData.generateRequestToken(params.timestamp, sheet.authToken);
            
            params.captcha_solution 	= captchaSolution;
            params.captcha_id 			= sheet.captchaID;
            params.username 			= sheet.emailUsername;
            
            theAttachedObjects.snap2chatAPIInteract.request(params);

            //theAttachedObjects.snap2chatAPIInteract.solveCaptcha(captchaSolution, sheet.captchaID, sheet.emailUsername, timestamp, req_token);
        }
        else 
        {
            Qt.app.showDialog("Attention", "Please select at least one image with a ghost.");
        }
    }
}