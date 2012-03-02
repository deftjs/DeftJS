/*
 Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
 Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
 */
/**
 A mixin that attaches a view to a view controller.

 Used in conjunction with {@link Deft.mvc.ViewController}.
 */
Ext.define('Deft.mixin.Controllable', {
    requires: ['Deft.mvc.ViewControllerManager'],
    /**
     @private
     */
    onClassMixedIn: function(targetClass) {
        targetClass.prototype.constructor = Ext.Function.createInterceptor(targetClass.prototype.constructor, function() {
            return Deft.mvc.ViewControllerManager.attach(this.controller, this);
        });
    }
});
