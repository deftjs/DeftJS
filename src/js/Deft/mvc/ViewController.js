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
        this.components = {view: view};
        return this;
    },
    /**
     Configure the ViewController.
     */
    configure: function() {
        Ext.Logger.log('Configuring view controller.');

        var view = this.getView();

        if (Ext.isObject(this.control)) {
            Ext.Object.each(this.control, function(key, config) {
                var isView = key == "view";
                var selector = Ext.isString(config) ? config : Ext.isString(config.selector) ? config.selector : "#" + key;
                var component = isView ? view : view.query( selector )[0];
                var getterName = "get" + Ext.String.capitalize(key);

                if (!this[getterName]) {
                    this[getterName] = Ext.Function.pass(this.getElement, [key], this);
                }

                this.components[key] = component;

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

        view.removeListener('initialize', this.configure, this);
        view.addListener('beforedestroy', this.destroy, this);
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

                var getterName = "get" + Ext.String.capitalize(key);
                this[getterName] = null;

            }, this);
        }

        this.view.removeListener('beforedestroy', this.destroy, this);
        this.components = null;

        return true;
    },

    getComponent: function( key ) {
        return this.components[ key];
    },

    getView: function() {
        return this.components.view;
    }

});