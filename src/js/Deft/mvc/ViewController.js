/*
 Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
 Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
 */
/**
 A lightweight MVC view controller.

 Used in conjunction with {@link Deft.mixin.Controllable}.
 */
Ext.define('Deft.mvc.ViewController', {
    alternateClassName: ['Deft.ViewController'],
    constructor: function(view) {
        this.view = view;
        return this;
    },
    /**
     Configure the Injector.
     */
    configure: function() {
        Ext.Logger.log('Configuring view controller.');
        if (Ext.isObject(this.control)) {
            Ext.Object.each(this.control, function(selector, config) {
                var components = this.view.query(selector);
                if (components.length > 0) {
                    var component = components[0];
                    if (Ext.isString(config)) {
                        Ext.Logger.log("adding " + config + " component ref");
                        this[config] = component;
                    } else {
                        if (Ext.isString(config.ref)) {
                            Ext.Logger.log("adding " + config.ref + " component ref");
                            this[config.ref] = component;
                        }
                        if (Ext.isObject(config.listeners)) {
                            Ext.Object.each(config.listeners, function(event, handler, obj) {
                                Ext.Logger.log("adding component " + component + " event " + event + " listener to " + handler );
                                component.addListener(event, this[handler], this);
                            }, this);
                        }
                    }
                }
            }, this);
        }
        if (Ext.isFunction(this.setup)) {
            this.setup();
        }
    }
});