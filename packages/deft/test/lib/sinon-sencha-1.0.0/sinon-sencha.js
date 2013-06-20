/*
 * [sinon-sencha](http://github.com/CodeCatalyst/sinon-sencha) v1.0.0
 * Copyright (c) 2013 [CodeCatalyst, LLC](http://www.codecatalyst.com/).
 * Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
 */
(function(){
	"use strict";
	
	// Tweak Sinon's "pretty print" logic to make it aware of Sencha classes.
	var format = sinon.format;
	sinon.format = function (value) {
		if (value instanceof Ext.ClassManager.get('Ext.Base')) {
			return Ext.ClassManager.getName(value);
		}
		return format.apply(this, arguments);
	}
})();
