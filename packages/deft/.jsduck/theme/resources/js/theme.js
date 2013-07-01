Ext.define('Docs.view.CustomViewport', {
	override: 'Docs.view.Viewport',
	
	initComponent: function () {
		this.callParent();
		
		// Resize the north region and header.
		var northRegion = Ext.getCmp('north-region');
		northRegion.setHeight(80);
		northRegion.child('container').setHeight(52);
	}
});