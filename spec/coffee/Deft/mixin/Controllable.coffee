###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.mixin.Controllable
###
describe( 'Deft.mixin.Controllable', ->
	
	it( 'should create an instance of the associated view controller (configured with the target view instance) when an instance of the target view is created', ->
		exampleViewInstance = null
		exampleViewControllerInstance = null
		
		Ext.define( 'ExampleView',
			extend: 'Ext.container.Container'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'ExampleViewController'
		)
		
		Ext.define( 'ExampleViewController',
			extend: 'Deft.mvc.ViewController'
		)
		
		constructorSpy = spyOn( ExampleViewController.prototype, 'constructor' ).andCallFake( ->
			exampleViewControllerInstance = @
			return constructorSpy.originalValue.apply( @, arguments )
		)
		
		exampleViewInstance = Ext.create( 'ExampleView' )
		
		expect( ExampleViewController.prototype.constructor ).toHaveBeenCalled()
		expect( ExampleViewController.prototype.constructor.callCount ).toBe( 1 )
		expect( exampleViewControllerInstance.getView() ).toBe( exampleViewInstance )
	)
)