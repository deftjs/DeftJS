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
     Configure the ViewController.
     */
    configure: function() {
        Ext.Logger.log('Configuring view controller.');

        if (Ext.isObject(this.control)) {
            Ext.Object.each(this.control, function(key, config) {
                var isView = key == "view";
                var selector = Ext.isString(config) ? config : Ext.isString(config.selector) ? config.selector : "#" + key;
                var component = isView ? this.view : this.view.query( selector )[0];
                this[key] = component;
                if (Ext.isObject(config)) {
                    var listeners = Ext.isObject(config.listeners) ? config.listeners : config;
                    Ext.Object.each(listeners, function(event, handler, obj) {
                        Ext.Logger.log("adding component " + component + " event " + event + " listener to " + handler );
                        component.addListener(event, this[handler], this);
                    }, this);
                }
            }, this);
        }

        if (Ext.isFunction(this.setup)) {
            this.setup();
        }

        this.view.removeListener('initialize', this.configure, this);
        this.view.addListener('beforedestroy', this.destroy, this);
    },

    /**
     * Destroy the ViewController.
     */
    destroy: function(e) {
        if (Ext.isFunction(this.tearDown)) {
            if (this.tearDown() == false)
                return false; // cancel view destroy
        }

        if (Ext.isObject(this.control)) {
            Ext.Object.each(this.control, function(key, config) {
                var component = this[key];
                if (Ext.isObject(config)) {
                    var listeners = Ext.isObject(config.listeners) ? config.listeners : config;
                    Ext.Object.each(listeners, function(event, handler, obj) {
                        Ext.Logger.log("removing component " + component + " event " + event + " listener to " + handler );
                        component.removeListener(event, this[handler], this);
                    }, this);
                }
                this[key] = null;
            }, this);
        }

        this.view.removeListener('beforedestroy', this.destroy, this);

        return true;
    }

});