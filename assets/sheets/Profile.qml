import bb.cascades 1.2

import "../pages"

Sheet 
{
    id: sheet
    property variant blankBestFriendsArray : new Array();
    
    onOpened: 
    {
        extendedProfile.profileusername = Qt.profileObject.username;
        extendedProfile.loaded 			= false;
        extendedProfile.friendProfile	= true;
        extendedProfile.load();
    }
    
    onClosed: 
    {
        extendedProfile.profileusername = "";
        extendedProfile.loaded 			= false;
        extendedProfile.friendProfile	= true;
        extendedProfile.load();
    }
    
    ExtendedProfile 
    {
        id: extendedProfile
    }
}