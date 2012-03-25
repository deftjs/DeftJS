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
    if (!this.getView() instanceof Ext.ClassManager.get('Ext.Component')) {
      Ext.Error.raise('Error constructing ViewController: the \'view\' is not an Ext.Component.');
    }
    this.registeredComponents = {};
    initializationEvent = view.events.initialize ? 'initialize' : 'beforerender';
    view.on(initializationEvent, this.onViewInitialize, this, {
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
  onViewInitialize: function() {
    var component, config, id, listeners, _ref;
    view.on('beforedestroy', this.onViewBeforeDestroy, this);
    view.on('destroy', this.onViewDestroy, this, {
      single: true
    });
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
  onViewBeforeDestroy: function() {
    if (this.destroy()) {
      this.getView().un('beforedestroy', this.onBeforeDestroy, this);
      return true;
    }
    return false;
  },
  /**
  	@private
  */
  onViewDestroy: function() {
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
    var event, existingComponent, getterName, listener;
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
        listener = listeners[event];
        Ext.log("Adding '" + event + "' listener to '" + id + "'.");
        if (Ext.isFunction(this[listener])) {
          component.on(event, this[listener], this);
        } else {
          Ext.Error.raise("Error adding '" + event + "' listener: the specified handler '" + listener + "' is not a Function or does not exist.");
        }
      }
    }
  },
  /**
  	@private
  */
  unregisterComponent: function(id) {
    var component, event, existingComponent, getterName, listener, listeners, _ref;
    Ext.log("Unregistering '" + id + "' component.");
    existingComponent = this.getComponent(id);
    if (!(existingComponent != null)) {
      Ext.Error.raise("Error unregistering component: no component is registered as '" + id + "'.");
    }
    _ref = this.registeredComponents[id], component = _ref.component, listeners = _ref.listeners;
    if (Ext.isObject(listeners)) {
      for (event in listeners) {
        listener = listeners[event];
        Ext.log("Removing '" + event + "' listener from '" + id + "'.");
        if (Ext.isFunction(this[listener])) {
          component.un(event, this[listener], this);
        } else {
          Ext.Error.raise("Error removing '" + event + "' listener: the specified handler '" + listener + "' is not a Function or does not exist.");
        }
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
    view = this.getView();
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
