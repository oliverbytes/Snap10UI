import bb.cascades 1.0

ListView 
{
    id: refreshableListView
    leadingVisualSnapThreshold: 0
    property bool loading: false;
    snapMode: SnapMode.LeadingEdge
    bufferedScrollingEnabled: true
    
    signal refreshTriggered()
    
    leadingVisual: RefreshHeader 
    {
        id: refreshHeaderComponent
        onRefreshTriggered:
        {
            refreshableListView.refreshTriggered();
        }
    }
    
    onTouch: 
    {
        refreshHeaderComponent.onListViewTouch(event);
    }
    
    onLoadingChanged: 
    {
        refreshHeaderComponent.refreshing = refreshableListView.loading;

        if(!refreshHeaderComponent.refreshing) 
        {
            refreshHeaderComponent.doneRefreshing();
            scroll();
        }
    }

    function scroll()
    {
        scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
    }
    
    function refreshHeader()
    {
        refreshTriggered();
        refreshHeaderComponent.refreshTriggered();
    }
}
