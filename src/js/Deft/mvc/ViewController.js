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
        view.on('initialize', this.configure, this);
        return this;
    },
    /**
     Configure the ViewController.
     */
    configure: function() {
        Ext.Logger.log('Configuring view controller.');

        var view = this.getView();

        view.un('initialize', this.configure, this);
        view.on('beforedestroy', this.destroy, this);

        if (Ext.isObject(this.control)) {
            Ext.Object.each(this.control, function(key, config) {
                var component = this.locateComponent(key, config);

                this.setComponent(key, component);

                if (Ext.isObject(config)) {
                    var listeners = Ext.isObject(config.listeners) ? config.listeners : config;

                    Ext.Object.each(listeners, function(event, handler, obj) {
                        Ext.Logger.log('adding component ' + component + ' event ' + event + ' listener to ' + handler );

                        component.on(event, this[handler], this);
                    }, this);
                }
            }, this);
        }

        if (Ext.isFunction(this.setup)) {
            this.setup();
        }
    },

    /**
     * Destroy the ViewController.
     */
    destroy: function(e) {
        Ext.Logger.log('Destroying view controller.');

        var view = this.getView();
        view.un('beforedestroy', this.destroy, this);

        if (Ext.isFunction(this.tearDown) && this.tearDown() == false)
            return false;

        if (Ext.isObject(this.control)) {
            Ext.Object.each(this.control, function(key, config) {
                var component = this.getComponent( key );

                if (Ext.isObject(config)) {
                    var listeners = Ext.isObject(config.listeners) ? config.listeners : config;

                    Ext.Object.each(listeners, function(event, handler, obj) {
                        Ext.Logger.log('removing component ' + component + ' event ' + event + ' listener to ' + handler);

                        component.un(event, this[handler], this);
                    }, this);
                }

                var getterName = 'get' + Ext.String.capitalize(key);
                this[getterName] = null;

            }, this);
        }

        this.components = null;

        return true;
    },

    locateComponent: function(key, config) {
        var view = this.getView();

        if (key == 'view')
            return view;

        if (Ext.isString(config))
            return view.query(config)[0];

        if (Ext.isString(config.selector))
            return view.query(config.selector)[0];

        return view.query('#' + key)[0];
    },

    getComponent: function(key) {
        return this.components[key];
    },

    setComponent: function(key, value) {
        var getterName = 'get' + Ext.String.capitalize(key);

        // create getter method
        if (!this[getterName])
            this[getterName] = Ext.Function.pass(this.getElement, [key], this);

        this.components[key] = value;
    },

    getView: function() {
        return this.components.view;
    }

});