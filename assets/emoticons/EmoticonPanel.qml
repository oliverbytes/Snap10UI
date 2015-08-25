import bb.cascades 1.0

Container {
	signal emoticonSelected(string value);
	
	property bool first_selected : true

    id: root
    onCreationCompleted: { Qt.root = root; }
        
	background: Color.create("#333333")
	layout: DockLayout {}
    
	Container {
        topPadding: 5
        bottomPadding: 5
        
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
		
	    Container { // Pane indicator
	        layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
        	}
		    horizontalAlignment: HorizontalAlignment.Center
		    verticalAlignment: VerticalAlignment.Fill
	        
	        preferredHeight: 20
	        
	        ImageView {
	            id: first
	            preferredWidth: 10
	            preferredHeight: 10
	            rightPadding: 5
	            imageSource: first_selected ? "asset:///emoticons/panel_index_selected.png" : "asset:///emoticons/panel_index.png";
	        }
	        ImageView {
	            id: second
	            preferredWidth: 10
	            preferredHeight: 10
	            imageSource: first_selected ? "asset:///emoticons/panel_index.png" : "asset:///emoticons/panel_index_selected.png";        
	        }
	    }
	    
	    ListView {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            snapMode: SnapMode.LeadingEdge
	        scrollIndicatorMode: ScrollIndicatorMode.None

            rightPadding: OrientationSupport.orientation == UIOrientation.Portrait ? 0 : 10
            leftPadding: OrientationSupport.orientation == UIOrientation.Portrait ? 0 : 10
	        
	        layout: GridListLayout {
	            orientation: LayoutOrientation.LeftToRight
	            columnCount: _UILayoutManager.emoticonPanelNumRows

                horizontalCellSpacing: 0
	            verticalCellSpacing: 0
	            cellAspectRatio: 96/89
	        }
	
	        dataModel: ArrayDataModel {
	        	id: dm
	        }
	        
	        onCreationCompleted: {
        	    dm.append([":)", ";)", ":D", "=D", "=))", "({})", "\\=D/", "<=-P", ":p", ";;)", "<3<3", ":*", ":|", 
        	        "/:)", ":>", "3-|", ":]x", ">:/", "8-|", ":]Y", ":s", ":&", ":]xx", ":(", ":'(", ">:O", ":$", 
        	        "#:-s", ":/", ":O", "X_X", "(=|", ":x", "O:)", ">=)", "*nerd*", "B-)", "=)]", "=]min", "=-c", 
        	        "~o)", "*beer*", "*wine*", "*dine*", "@>--", "*gift*", "*bday*", "(*)", "*fly*", "=]()", "*music*", 
        	        "=-?", "*...*", "(y)", "(n)", "<3", "</3", "|:o|", "\\m/", "|-)", "!-)", "8-}", ":G", 
        	        "x-o", "~:-)", ";-shh", ":E>", "*snow*", "*sun*", "*rain*", "*storm*", "*pic*", "*idea*", "*run*"]);
	        }
	     
	        onTriggered: {
	            var text = dataModel.data(indexPath);
	            emoticonSelected(text);
	        }

	        listItemComponents: [
	            ListItemComponent {
	                Emoticon {
	               		text: ListItemData.toString()
	               		index: ListItem.indexPath[0]
	               		onFirstPanelVisible: {
	               			Qt.root.first_selected = value;
	               		}
	               	}
	            }
	        ]
	    }
    }
    
	ImageView {
        imageSource: "asset:///images/title_bar/core_titlebar_dropdown_shadow_top.png"
		horizontalAlignment: HorizontalAlignment.Fill
		verticalAlignment: VerticalAlignment.Top
    }
}