import bb.cascades 1.0
import bb.data 1.0
import nemory.Snap2ChatAPISimple 1.0
import org.labsquare 1.0

import "../components"

Page 
{    
    property variant boxsnapObject;
    property bool liked : boxsnapObject.liked;
    property int likes : boxsnapObject.likes;
    property int comments : boxsnapObject.comments;
    
    property bool dataSourceLoading : false;
    property string dataSourceURL : "http://kellyescape.com/snapchat/includes/webservices/get.php?object=boxsnapcomment&boxsnapid="+boxsnapObject.id+"&username=" + Qt.snap2chatAPIData.username;
    
    titleBar: CustomTitleBar 
    {
        closeVisibility: true
        onCloseButtonClicked: 
        {
        	navigationPane.pop();
        }
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
                id: content
                
                leftPadding: 20
                rightPadding: 20
                topPadding: 20
                bottomPadding: 20
                
                Header
                {
                    title: "SHOUT OVERVIEW"
                }
                
                Container 
                {
                    id: bottomContent
                    topPadding: 20
                    
                    Container 
                    {
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        layout: StackLayout 
                        {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        WebImageView 
                        {
                            id: profilepicture
                            url: boxsnapObject.profilepicture
                            scalingMethod: ScalingMethod.AspectFit
                            preferredHeight: 100
                            maxWidth: 100
                        }
                        
                        Label 
                        {
                            text: boxsnapObject.username
                            textStyle.fontSize: FontSize.Small
                            textStyle.fontWeight: FontWeight.W100
                            verticalAlignment: VerticalAlignment.Center
                        }
                        
                        gestureHandlers: TapHandler 
                        {
                            onTapped: 
                            {
                                Qt.profileObject.username 		= boxsnapObject.username;
                                Qt.profileSheet.friendProfile	= true;
                                Qt.profileSheet.open();
                            }
                        }
                    }
                    
                    Divider {}
                    
                    WebImageView
                    {
                        id: theimage
                        visible: boxsnapObject.picture.length > 0
                        url: boxsnapObject.picture
                        horizontalAlignment: HorizontalAlignment.Fill
                        scalingMethod: ScalingMethod.AspectFit
                        preferredHeight: 800

                        gestureHandlers: 
                        [
                            LongPressHandler 
                            {
                                onLongPressed: 
                                {
                                    invokePictureViewer2.trigger("bb.action.VIEW");
                                }
                                
                                attachedObjects: Invocation 
                                {
                                    id: invokePictureViewer2
                                    query.invokeTargetId: "sys.pictures.card.previewer"
                                    query.invokeActionId: "bb.action.VIEW"
                                    query.mimeType: "image/jpeg"
                                    query.uri: theimage.imageSource
                                }
                            },
                            TapHandler 
                            {
                                onTapped: 
                                {
                                    if(theimage.preferredHeight == 300)
                                    {
                                        theimage.preferredHeight = 800;
                                        theimage.scalingMethod = ScalingMethod.AspectFit
                                    }
                                    else if(theimage.preferredHeight == 800)
                                    {
                                        theimage.preferredHeight = 300;
                                        theimage.scalingMethod = ScalingMethod.AspectFill
                                    }
                                }
                            }
                        ]
                    }
                    
                    Label 
                    {
                        text: urlify(boxsnapObject.message);
                        multiline: true
                        textStyle.fontSize: FontSize.XSmall
                        textFormat: TextFormat.Html
                    }
                    
                    Container 
                    {
                        id: counts
                        
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        layout: StackLayout 
                        {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        Label 
                        {
                            text: likes + " Like" + (likes > 1 ? "s" : "")
                            textStyle.color: Color.Gray
                            textStyle.fontSize: FontSize.XXSmall
                        }
                        
                        Label 
                        {
                            text: comments + " Comment" + (comments > 1 ? "s" : "")
                            textStyle.color: Color.Gray
                            textStyle.fontSize: FontSize.XXSmall
                        }
                    }
                    
                    Divider {}
                    
                    Container 
                    {
                        id: commentsContainer
                        //visible: false
                    
                        Header
                        {
                            id: listViewHeader
                            title: "COMMENTS"
                            bottomMargin: 20
                        }
                        
                        ActivityIndicator 
                        {
                            preferredHeight: 150
                            visible: dataSourceLoading
                            running: visible
                            horizontalAlignment: HorizontalAlignment.Fill
                        }
                        
                        Label 
                        {
                            id: noCommentsYet
                            visible: false
                            text: "No comments yet. :("
                            textStyle.textAlign: TextAlign.Center
                            horizontalAlignment: HorizontalAlignment.Fill
                            textStyle.fontSize: FontSize.XXSmall
                        }
                        
                        PullToRefreshListView 
                        {
                            id: listView
                            visible: !dataSourceLoading && !noCommentsYet.visible
                            dataModel: dataModel
                            preferredHeight:
                            {
                                var height = 0;
                                
                                if(listViewHeader.subtitle > 0)
                                {
                                    height = 200; 
                                }
                                
                                if(listViewHeader.subtitle > 1)
                                {
                                    height = 400; 
                                }
                                
                                if(listViewHeader.subtitle > 2)
                                {
                                    height = 600; 
                                }
                                
                                return height;
                            }
                            horizontalAlignment: HorizontalAlignment.Fill
                            
                            listItemComponents: 
                            [
                                ListItemComponent 
                                {
                                    BoxSnapCommentItem 
                                    {
                                        id: root
                                    }
                                }
                            ]
                            
                            attachedObjects: 
                            [
                                ArrayDataModel
                                {
                                    id: dataModel
                                },
                                DataSource 
                                {
                                    id: dataSource
                                    source: dataSourceURL
                                    type: DataSourceType.Json
                                    remote: true
                                    onDataLoaded: 
                                    {   
                                        dataSourceLoading = false;               
                                        
                                        if(data != null)
                                        {
                                            listViewHeader.subtitle = data.length;
                                            
                                            listView.listItemComponents[0] = null;
                                            
                                            dataModel.clear();
                                            dataModel.ListItem.destroy();
                                            dataModel = null;
                                            dataModel.insert(0, data);
                                            
                                            comments = data.length;
                                            
                                            if(data.length == 0)
                                            {
                                                noCommentsYet.visible = true;
                                            }
                                            else 
                                            {
                                                noCommentsYet.visible = false;
                                            }
                                            
                                            listView.scroll();
                                        }
                                        else 
                                        {
                                            loadComments();
                                        }
                                    }
                                    onError: 
                                    {
                                        Qt.app.showToast("Retrying...");
                                        dataSourceLoading = false;
                                        source = "";
                                        source = dataSourceURL; 
                                        listView.scroll();
                                    }
                                }
                            ]

                            function refreshTriggered()
                            {
                                if(!dataSourceLoading)
                                {
                                    dataSourceLoading = true;
                                    dataSource.load();
                                }
                            }  
                        }
                    }
                    
                    Container
                    {
                        topMargin: 20
                        bottomPadding: 50
                        enabled: !loadingComments.visible
                        layout: StackLayout 
                        {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        TextArea 
                        {
                            id: thecomment
                            hintText: "Your Comment Here"
                            preferredHeight: 200
                            layoutProperties: StackLayoutProperties 
                            {
                                spaceQuota: 5
                            }
                        }
                        
                        Container 
                        {
                            layoutProperties: StackLayoutProperties 
                            {
                                spaceQuota: 1
                            }
                            
                            Button 
                            {
                                imageSource: "asset:///images/bbmSend.png"

                                onClicked: 
                                {
                                    var params = new Object();
                                    params.url = "http://kellyescape.com/snapchat/includes/webservices/create.php?object=boxsnapcomment&boxsnapid=" + boxsnapObject.id + "&username=" + Qt.snap2chatAPIData.username + "&comment=" + thecomment.text;
                                    params.endpoint = "likeunlike";
                                    Qt.snap2chatAPI.kellyGetRequest(params);
                                    
                                    var commentObject 		= new Object();
                                    commentObject.username 	= Qt.snap2chatAPIData.username;
                                    commentObject.comment	= thecomment.text;
                                    dataModel.insert(0, commentObject);
                                    
                                    //loadComments();
                                }
                            }
                            
                            ActivityIndicator 
                            {
                                id: loadingComments
                                visible: false
                                preferredHeight: 80
                                horizontalAlignment: HorizontalAlignment.Fill
                                running: visible
                            }
                        }
                    }
                }
            }
            
            Container 
            {
                id: loadingBox
                visible: false
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                background: Color.create("#99000000")
                
                layout: DockLayout {}
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    rightPadding: 20
                    bottomPadding: 20
                    
                    ActivityIndicator 
                    {
                        id: loadingIndicator
                        visible: loadingBox.visible
                        running: visible
                        preferredHeight: 200
                    }
                }
                
                Container 
                {
                    verticalAlignment: VerticalAlignment.Center
                    horizontalAlignment: HorizontalAlignment.Center
                    topPadding: 250
                    
                    Label 
                    {
                        id: loadingText
                        text: "Posting your comment..."
                        textStyle.fontStyle: FontStyle.Italic
                        verticalAlignment: VerticalAlignment.Center
                        horizontalAlignment: HorizontalAlignment.Center
                        textStyle.fontSize: FontSize.XSmall
                        textStyle.color: Color.White
                    }
                }
            }
        }
    }
    
    actions: 
    [
        ActionItem 
        {
            id: like
            title: (liked ? "Unlike" : "Like")
            imageSource: (liked ? "asset:///images/tabUnlike.png" : "asset:///images/tabLike.png")
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: 
            {
                if(!liked)
                {
                    likes = likes + 1;
                    liked = true;
                }
                else if(liked)
                {
                    likes = likes - 1;
                    liked = false;
                }
 
                var params = new Object();
                params.url = "http://kellyescape.com/snapchat/includes/webservices/create.php?object=likedboxsnap&boxsnapid=" + boxsnapObject.id + "&username=" + Qt.snap2chatAPIData.username;
                params.endpoint = "likeunlike";
                Qt.snap2chatAPI.kellyGetRequest(params);
            }
        },
        ActionItem 
        {
            id: comment
            title: "Comment"
            imageSource: "asset:///images/tabBBMSend.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: 
            {
                thecomment.requestFocus();
            }
        },
        ActionItem 
        {
            id: refresh
            title: "Refresh"
            imageSource: "asset:///images/refresh.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: 
            {
            	loadComments();
            }
        }
    ]

    function loadComments()
    {
        listView.refreshHeader();
    }
    
    function urlify(text) 
    {
        var urlRegex = /(https?:\/\/[^\s]+)/g;
        
        return text.replace(urlRegex, function(url) 
        {
            return '<a href="' + url + '">' + url + '</a>';
        });
    }
}