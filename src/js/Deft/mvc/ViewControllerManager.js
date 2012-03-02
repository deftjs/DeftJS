/*
 Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
 Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
 */
/**
 A lightweight MVC view controller.

 Used in conjunction with {@link Deft.mixin.Controllable}.
 */
Ext.define('Deft.mvc.ViewControllerManager', {
    requires: ['Deft.mvc.ViewController'],
    singleton: true,
    constructor: function() {
        return this;
    },
    /**
     Create view controller instance and attach it to target view.
     */
    attach: function(controllerClass, targetView) {
        var controller = Ext.create(controllerClass, targetView);
        targetView.addListener('show', controller.configure, controller);
        return controller;
    }
});