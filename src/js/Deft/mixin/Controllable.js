/*
 Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
 Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
 */
/**
 A mixin that attaches a view to a view controller.

 Used in conjunction with {@link Deft.mvc.ViewController}.
 */
Ext.define('Deft.mixin.Controllable', {
    requires: ['Deft.mvc.ViewController'],
    /**
     @private
     */
    onClassMixedIn: function(targetClass) {
        targetClass.prototype.constructor = Ext.Function.createInterceptor(targetClass.prototype.constructor, function() {
            var controllers = Ext.isArray(this.controller) ? this.controller : [ this.controller ];
            Ext.each(controllers, function(controllerClass) {
                Ext.create(controllerClass, this);
            }, this);
        });
    }
});
