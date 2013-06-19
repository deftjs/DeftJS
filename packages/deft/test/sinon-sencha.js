// Tweak Sinon's "pretty print" logic to make it aware of Sencha classes.
var format = sinon.format
sinon.format = function (value) {
	if (value instanceof Ext.ClassManager.get('Ext.Base')) {
		return Ext.ClassManager.getName(value);
	}
	return format.apply(this, arguments);
}
