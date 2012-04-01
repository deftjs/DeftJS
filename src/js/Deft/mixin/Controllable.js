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
      var controllerClass, controllers, _i, _len;
      if (!(this.controller != null)) {
        Ext.Error.raise({
          msg: 'Error initializing Controllable instance: \`controller\` was not specified.'
        });
      }
      controllers = Ext.isArray(this.controller) ? this.controller : [this.controller];
      for (_i = 0, _len = controllers.length; _i < _len; _i++) {
        controllerClass = controllers[_i];
        try {
          Ext.create(controllerClass, {
            view: this
          });
        } catch (error) {
          Ext.Error.raise({
            msg: "Error initializing Controllable instance: an error occurred while creating an instance of the specified controller: '" + this.controller + "'."
          });
        }
      }
    });
  }
});
