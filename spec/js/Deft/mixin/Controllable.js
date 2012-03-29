/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/
/*
Jasmine test suite for Deft.mixin.Controllable
*/
describe('Deft.mixin.Controllable', function() {
  return it('should create an instance of the associated view controller (configured with the target view instance) when an instance of the target view is created', function() {
    var constructorSpy, exampleViewControllerInstance, exampleViewInstance;
    exampleViewInstance = null;
    exampleViewControllerInstance = null;
    Ext.define('ExampleView', {
      extend: 'Ext.container.Container',
      mixins: ['Deft.mixin.Controllable'],
      controller: 'ExampleViewController'
    });
    Ext.define('ExampleViewController', {
      extend: 'Deft.mvc.ViewController'
    });
    constructorSpy = spyOn(ExampleViewController.prototype, 'constructor').andCallFake(function() {
      exampleViewControllerInstance = this;
      return constructorSpy.originalValue.apply(this, arguments);
    });
    exampleViewInstance = Ext.create('ExampleView');
    expect(ExampleViewController.prototype.constructor).toHaveBeenCalled();
    expect(ExampleViewController.prototype.constructor.callCount).toBe(1);
    return expect(exampleViewControllerInstance.getView()).toBe(exampleViewInstance);
  });
});
