/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/
/**
A mixin that creates and attaches the specified view controller(s) to the target view.

Used in conjunction with {@link Deft.mvc.ViewController}.
*/
Ext.define('Deft.mixin.Controllable', {
  requires: ['Deft.mvc.ViewController'],
  /**
  	@private
  */
  onClassMixedIn: function(targetClass) {
    targetClass.prototype.constructor = Ext.Function.createSequence(targetClass.prototype.constructor, function() {
      var controller, controllerClass, controllers, _i, _len;
      if (!(this.controller != null)) {
        Ext.Error.raise('Error initializing Controllable instance: \`controller\` is null.');
      }
      controllers = Ext.isArray(this.controller) ? this.controller : [this.controller];
      for (_i = 0, _len = controllers.length; _i < _len; _i++) {
        controllerClass = controllers[_i];
        controller = Ext.create(controllerClass, {
          view: this
        });
      }
    });
  }
});
