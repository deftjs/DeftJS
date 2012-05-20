###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.mixin.Controllable
###
describe( 'Deft.mixin.Controllable', ->

	it( 'should create an instance of the view controller specified by the target view `controller` property and configure it with a reference to the target view instance when an instance of the target view is created', ->
		exampleViewInstance = null
		exampleViewControllerInstance = null
		
		Ext.define( 'ExampleViewController',
			extend: 'Deft.mvc.ViewController'
		)
		
		Ext.define( 'ExampleView',
			extend: 'Ext.Container'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'ExampleViewController'
		)
		
		constructorSpy = spyOn( ExampleViewController.prototype, 'constructor' ).andCallFake( ->
			exampleViewControllerInstance = @
			return constructorSpy.originalValue.apply( @, arguments )
		)
		
		exampleViewInstance = Ext.create( 'ExampleView' )
		
		expect( ExampleViewController::constructor ).toHaveBeenCalled()
		expect( ExampleViewController::constructor.callCount ).toBe( 1 )
		expect( exampleViewControllerInstance.getView() ).toBe( exampleViewInstance )
		
		return
	)
	
	it( 'should re-throw any error thrown by the view controller during instantiation', ->
		
		Ext.define( 'ExampleErrorThrowingViewController',
			extend: 'Deft.mvc.ViewController'
			
			constructor: ->
				throw new Error( 'Error thrown by \`ExampleErrorThrowingViewController\`.' )
		)
		
		Ext.define( 'ExampleView',
			extend: 'Ext.Container'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'ExampleErrorThrowingViewController'
		)
		
		expect( ->
			Ext.create( 'ExampleView' )
			return
		).toThrow( 'Error thrown by \`ExampleErrorThrowingViewController\`.' )
		
		return
	)
)
