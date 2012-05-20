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
		
		Ext.define( 'ExampleView',
			extend: 'Ext.Container'
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
		
		expect( ExampleViewController::constructor ).toHaveBeenCalled()
		expect( ExampleViewController::constructor.callCount ).toBe( 1 )
		expect( exampleViewControllerInstance.getView() ).toBe( exampleViewInstance )
	)
	
	it( 'should throw an error if the target view \`controller\` property is not populated', ->
		
		Ext.define( 'ExampleView',
			extend: 'Ext.Container'
			mixins: [ 'Deft.mixin.Controllable' ]
		)
		
		Ext.define( 'ExampleViewController',
			extend: 'Deft.mvc.ViewController'
		)
		
		expect( ->
			Ext.create( 'ExampleView' )
		).toThrow( 'Error initializing Controllable instance: `controller` was not specified.' )
	)
	
	it( 'should throw an error if the target view \`controller\` property specifies a non-existent class', ->
		
		Ext.define( 'ExampleView',
			extend: 'Ext.Container'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'doesntexist'
		)
		
		expect( ->
			Ext.create( 'ExampleView' )
		).toThrow( 'Error initializing Controllable instance: an error occurred while creating an instance of the specified controller: \'doesntexist\' does not exist.' )
	)
	
	it( 'should re-throw any error thrown by the view controller during instantiation', ->
		
		Ext.define( 'ExampleView',
			extend: 'Ext.Container'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'ExampleBrokenViewController'
		)
		
		Ext.define( 'ExampleBrokenViewController',
			extend: 'Deft.mvc.ViewController'
			
			constructor: ->
				throw new Error( 'Error thrown by \`ExampleBrokenViewController\`.' )
		)
		
		expect( ->
			Ext.create( 'ExampleView' )
		).toThrow( 'Error thrown by \`ExampleBrokenViewController\`.' )
	)
)
