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
  config: {
    /**
    		View controlled by this ViewController.
    */
    view: null
  },
  constructor: function(config) {
    var initializationEvent;
    this.initConfig(config);
    if (!getView() instanceof Ext.ClassManager.get('Ext.Component')) {
      Ext.Error.raise('Error constructing ViewController: the \'view\' is not an Ext.Component.');
    }
    this.registeredComponents = {};
    initializationEvent = view.events.initialize != null ? 'initialize' : 'beforeRender';
    view.on(initializationEvent, this.onInitialize, this, {
      single: true
    });
    view.on('beforedestroy', this.onBeforeDestroy, this);
    view.on('destroy', this.onDestroy, this, {
      single: true
    });
    return this;
  },
  /**
  	Initialize the ViewController
  */
  init: function() {},
  /**
  	Destroy the ViewController
  */
  destroy: function() {
    return true;
  },
  /**
  	@private
  */
  onInitialize: function() {
    var component, config, id, listeners, _ref;
    _ref = this.control;
    for (id in _ref) {
      config = _ref[id];
      component = this.locateComponent(id, config);
      listeners = Ext.isObject(config.listeners) ? config.listeners : config;
      this.registerComponent(id, component, listeners);
    }
    this.init();
  },
  /**
  	@private
  */
  onBeforeDestroy: function() {
    if (this.destroy()) {
      getView().un('onBeforeDestroy', this.onBeforeDestroy, this);
      return true;
    }
    return false;
  },
  /**
  	@private
  */
  onDestroy: function() {
    var id;
    for (id in this.registeredComponents) {
      this.unregisterComponent(id);
    }
  },
  /**
  	@private
  */
  getComponent: function(id) {
    return this.registeredComponents[id].component;
  },
  /**
  	@private
  */
  registerComponent: function(id, component, listeners) {
    var event, existingComponent, getterName, handler;
    Ext.log("Registering '" + id + "' component.");
    existingComponent = this.getComponent(id);
    if (existingComponent != null) {
      Ext.Error.raise("Error registering component: an existing component already registered as '" + id + "'.");
    }
    this.registeredComponents[id] = {
      component: component,
      listeners: listeners
    };
    if (id !== view) {
      getterName = 'get' + Ext.String.capitalize(id);
      if (!this[getterName]) {
        this[getterName] = Ext.Function.pass(this.getComponent, [id], this);
      }
    }
    if (Ext.isObject(listeners)) {
      for (event in listeners) {
        handler = listeners[event];
        Ext.log("Adding '" + event + "' listener to '" + id + "'.");
        component.on(event, this[handler], this);
      }
    }
  },
  /**
  	@private
  */
  unregisterComponent: function(id) {
    var component, event, existingComponent, getterName, handler, listeners, _ref;
    Ext.log("Unregistering '" + id + "' component.");
    existingComponent = this.getComponent(id);
    if (!(existingComponent != null)) {
      Ext.Error.raise("Error unregistering component: no component is registered as '" + id + "'.");
    }
    _ref = this.registeredComponents[id], component = _ref.component, listeners = _ref.listeners;
    if (Ext.isObject(listeners)) {
      for (event in listeners) {
        handler = listeners[event];
        Ext.log("Removing '" + event + "' listener from '" + id + "'.");
        component.un(event, this[handler], this);
      }
    }
    if (id !== 'view') {
      getterName = 'get' + Ext.String.capitalize(id);
      this[getterName] = null;
    }
    this.registeredComponents[id] = null;
  },
  /**
  	@private
  */
  locateComponent: function(id, config) {
    var matches, view;
    view = getView();
    if (id === 'view') return view;
    if (Ext.isString(config)) {
      matches = view.query(config);
      if (matches.length === 0) {
        Ext.Error.raise("Error locating component: no component found matching '" + config + "'.");
      }
      if (matches.length > 1) {
        Ext.Error.raise("Error locating component: multiple components found matching '" + config + "'.");
      }
      return matches[0];
    } else if (Ext.isString(config.selector)) {
      matches = view.query(config.selector);
      if (matches.length === 0) {
        Ext.Error.raise("Error locating component: no component found matching '" + config.selector + "'.");
      }
      if (matches.length > 1) {
        Ext.Error.raise("Error locating component: multiple components found matching '" + config.selector + "'.");
      }
      return matches[0];
    } else {
      matches = view.query('#' + id);
      if (matches.length === 0) {
        Ext.Error.raise("Error locating component: no component found with an itemId of '" + id + "'.");
      }
      if (matches.length > 1) {
        Ext.Error.raise("Error locating component: multiple components found with an itemId of '" + id + "'.");
      }
      return matches[0];
    }
  }
});
