// Generated by CoffeeScript 1.3.3
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
A mixin that creates and attaches the specified view controller(s) to the target view.

Used in conjunction with {@link Deft.mvc.ViewController}.
*/

Ext.define('Deft.mixin.Controllable', {});

Ext.Class.registerPreprocessor('controller', function(Class, data, hooks, callback) {
  var controllerClass, parameters, self;
  if (arguments.length === 3) {
    parameters = Ext.toArray(arguments);
    hooks = parameters[1];
    callback = parameters[2];
  }
  if ((data.mixins != null) && ((Ext.isArray(data.mixins) && Ext.Array.contains(data.mixins, Ext.ClassManager.get('Deft.mixin.Controllable'))) || (Ext.isObject(data.mixins) && Ext.Array.contains(Ext.Object.getValues(data.mixins), Ext.ClassManager.get('Deft.mixin.Controllable'))))) {
    controllerClass = data.controller;
    delete data.controller;
    if (controllerClass != null) {
      Class.prototype.constructor = Ext.Function.createSequence(Class.prototype.constructor, function() {
        var controller;
        try {
          controller = Ext.create(controllerClass, Ext.Object.merge({}, this.controllerConfig || {}, {
            view: this
          }));
        } catch (error) {
          Deft.Logger.warn("Error initializing Controllable instance: an error occurred while creating an instance of the specified controller: '" + controllerClass + "'.");
          throw error;
        }
        if (!(this.getController != null)) {
          this.getController = function() {
            return controller;
          };
          Class.prototype.destroy = Ext.Function.createSequence(Class.prototype.destroy, function() {
            delete this.getController;
          });
        }
      });
      self = this;
      Ext.require([controllerClass], function() {
        if (callback != null) {
          callback.call(self, Class, data, hooks);
        }
      });
      return false;
    }
  }
});

Ext.Class.setDefaultPreprocessorPosition('controller', 'before', 'mixins');
