###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.mixin.Controllable
###
describe( 'Deft.mixin.Controllable', ->
	
	it( 'should (when specified within a mixins Array) create an instance of the view controller specified by the target view `controller` property and configure it with a reference to the target view instance when an instance of the target view is created', ->
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
	
	it( 'should (when specified within a mixins Object) create an instance of the view controller specified by the target view `controller` property and configure it with a reference to the target view instance when an instance of the target view is created', ->
		exampleViewInstance = null
		exampleViewControllerInstance = null
		
		Ext.define( 'ExampleViewController',
			extend: 'Deft.mvc.ViewController'
		)
		
		Ext.define( 'ExampleView',
			extend: 'Ext.Container'
			mixins:
				controllable: 'Deft.mixin.Controllable'
			controller: 'ExampleViewController'
			
			constructor: ( config ) ->
				@callParent( arguments )
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
	
	it( 'should pass the configuration object defined in the target view\'s `controllerConfig` config to the view controller\'s constructor', ->
		exampleViewInstance = null
		exampleViewControllerInstance = null
		
		Ext.define( 'ExampleViewController',
			extend: 'Deft.mvc.ViewController'
			
			config:
				value: null
		)
		
		Ext.define( 'ExampleView',
			extend: 'Ext.Container'
			alias: 'widget.ExampleView'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'ExampleViewController'
			controllerConfig:
				value: 'expected value'
		)
		
		constructorSpy = spyOn( ExampleViewController.prototype, 'constructor' ).andCallFake( ->
			exampleViewControllerInstance = @
			return constructorSpy.originalValue.apply( @, arguments )
		)
		
		exampleViewInstance = Ext.create( 'ExampleView' )
		
		expect( ExampleViewController::constructor ).toHaveBeenCalledWith( { value: 'expected value' } )
		expect( ExampleViewController::constructor.callCount ).toBe( 1 )
		expect( exampleViewControllerInstance.getView() ).toBe( exampleViewInstance )
		expect( exampleViewControllerInstance.getValue() ).toBe( 'expected value' )
		
		return
	)
	
	it( 'should pass the configuration object passed to the target view\'s `controllerConfig` config to the view controller\'s constructor', ->
		exampleViewInstance = null
		exampleViewControllerInstance = null
		
		Ext.define( 'ExampleViewController',
			extend: 'Deft.mvc.ViewController'
			
			config:
				value: null
		)
		
		Ext.define( 'ExampleView',
			extend: 'Ext.Container'
			alias: 'widget.ExampleView'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'ExampleViewController'
		)
		
		constructorSpy = spyOn( ExampleViewController.prototype, 'constructor' ).andCallFake( ->
			exampleViewControllerInstance = @
			return constructorSpy.originalValue.apply( @, arguments )
		)
		
		exampleViewInstance = Ext.create( 'ExampleView',
			controllerConfig:
				value: 'expected value'
		)
		
		expect( ExampleViewController::constructor ).toHaveBeenCalledWith( { value: 'expected value' } )
		expect( ExampleViewController::constructor.callCount ).toBe( 1 )
		expect( exampleViewControllerInstance.getView() ).toBe( exampleViewInstance )
		expect( exampleViewControllerInstance.getValue() ).toBe( 'expected value' )
		
		return
	)
	
	it( 'should automatically add a getController() accessor method to the target view that returns the associated the view controller instance', ->
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
		
		expect( exampleViewInstance.getController() ).toBe( exampleViewControllerInstance )
		
		return
	)
	
	it( 'should only create and attach the most specific controller (i.e. the controller specified for the subclass) in an inheritance tree where multiple controllers are specified', ->
		baseViewInstance = null
		baseViewControllerInstance = null
		extendedViewInstance = null
		extendedViewControllerInstance = null
		
		Ext.define( 'BaseViewController',
			extend: 'Deft.mvc.ViewController'
			
			constructor: ->
				@callParent( arguments )
		)
		
		Ext.define( 'ExtendedViewController',
			extend: 'BaseViewController'
			
			constructor: ->
				@callParent( arguments )
		)
		
		Ext.define( 'BaseView',
			extend: 'Ext.Container'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'BaseViewController'
			
			constructor: ->
				@callParent( arguments )
		)
		
		Ext.define( 'ExtendedView',
			extend: 'BaseView'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'ExtendedViewController'
			
			constructor: ->
				expect( @getController() ).toBe( extendedViewControllerInstance )
				@callParent( arguments )
		)
		
		baseViewControllerConstructorSpy = spyOn( BaseViewController.prototype, 'constructor' ).andCallFake( ->
			baseViewControllerInstance = @
			return baseViewControllerConstructorSpy.originalValue.apply( @, arguments )
		)
		extendedViewControllerConstructorSpy = spyOn( ExtendedViewController.prototype, 'constructor' ).andCallFake( ->
			extendedViewControllerInstance = @
			return extendedViewControllerConstructorSpy.originalValue.apply( @, arguments )
		)
		
		baseViewInstance = Ext.create( 'BaseView' )
		
		expect( baseViewControllerConstructorSpy ).toHaveBeenCalled()
		expect( baseViewControllerConstructorSpy.callCount ).toBe( 1 )
		expect( extendedViewControllerConstructorSpy ).not.toHaveBeenCalled()
		expect( baseViewControllerInstance ).not.toBe( null )
		expect( extendedViewControllerInstance ).toBe( null )
		expect( baseViewInstance.getController() ).toBe( baseViewControllerInstance )
		
		baseViewControllerConstructorSpy.reset()
		extendedViewControllerConstructorSpy.reset()
		baseViewControllerInstance = null
		extendedViewControllerInstance = null
		
		extendedViewInstance = Ext.create( 'ExtendedView' )
		
		expect( baseViewControllerConstructorSpy ).toHaveBeenCalled() # by @callParent()
		expect( baseViewControllerConstructorSpy.callCount ).toBe( 1 )
		expect( extendedViewControllerConstructorSpy ).toHaveBeenCalled()
		expect( extendedViewControllerConstructorSpy.callCount ).toBe( 1 )
		expect( baseViewControllerInstance ).not.toBe( null )
		expect( extendedViewControllerInstance ).not.toBe( null )
		expect( extendedViewControllerInstance ).toBe( baseViewControllerInstance )
		expect( extendedViewInstance.getController() ).toBe( extendedViewControllerInstance )
		
		return
	)
	
	it( 'should only create and attach the most specific controller (i.e. the controller specified for the subclass) in an inheritance tree where multiple controllers are specified (and the leaf class does not define a constructor)', ->
		baseViewInstance = null
		baseViewControllerInstance = null
		extendedViewInstance = null
		extendedViewControllerInstance = null
		
		Ext.define( 'BaseViewController',
			extend: 'Deft.mvc.ViewController'
			
			constructor: ->
				@callParent( arguments )
		)
		
		Ext.define( 'ExtendedViewController',
			extend: 'BaseViewController'
			
			constructor: ->
				@callParent( arguments )
		)
		
		Ext.define( 'BaseView',
			extend: 'Ext.Container'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'BaseViewController'
			
			constructor: ->
				@callParent( arguments )
		)
		
		Ext.define( 'ExtendedView',
			extend: 'BaseView'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'ExtendedViewController'
		)
		
		baseViewControllerConstructorSpy = spyOn( BaseViewController.prototype, 'constructor' ).andCallFake( ->
			baseViewControllerInstance = @
			return baseViewControllerConstructorSpy.originalValue.apply( @, arguments )
		)
		extendedViewControllerConstructorSpy = spyOn( ExtendedViewController.prototype, 'constructor' ).andCallFake( ->
			extendedViewControllerInstance = @
			return extendedViewControllerConstructorSpy.originalValue.apply( @, arguments )
		)
		
		baseViewInstance = Ext.create( 'BaseView' )
		
		expect( baseViewControllerConstructorSpy ).toHaveBeenCalled()
		expect( baseViewControllerConstructorSpy.callCount ).toBe( 1 )
		expect( extendedViewControllerConstructorSpy ).not.toHaveBeenCalled()
		expect( baseViewControllerInstance ).not.toBe( null )
		expect( extendedViewControllerInstance ).toBe( null )
		expect( baseViewInstance.getController() ).toBe( baseViewControllerInstance )
		
		baseViewControllerConstructorSpy.reset()
		extendedViewControllerConstructorSpy.reset()
		baseViewControllerInstance = null
		extendedViewControllerInstance = null
		
		extendedViewInstance = Ext.create( 'ExtendedView' )
		
		expect( baseViewControllerConstructorSpy ).toHaveBeenCalled() # by @callParent()
		expect( baseViewControllerConstructorSpy.callCount ).toBe( 1 )
		expect( extendedViewControllerConstructorSpy ).toHaveBeenCalled()
		expect( extendedViewControllerConstructorSpy.callCount ).toBe( 1 )
		expect( baseViewControllerInstance ).not.toBe( null )
		expect( extendedViewControllerInstance ).not.toBe( null )
		expect( extendedViewControllerInstance ).toBe( baseViewControllerInstance )
		expect( extendedViewInstance.getController() ).toBe( extendedViewControllerInstance )
		
		return
	)
	
	it( 'should only create and attach the most specific controller (i.e. the controller specified for the subclass) in an inheritance tree where multiple controllers are specified (and the root class does not define a constructor)', ->
		baseViewInstance = null
		baseViewControllerInstance = null
		extendedViewInstance = null
		extendedViewControllerInstance = null
		
		Ext.define( 'BaseViewController',
			extend: 'Deft.mvc.ViewController'
			
			constructor: ->
				@callParent( arguments )
		)
		
		Ext.define( 'ExtendedViewController',
			extend: 'BaseViewController'
			
			constructor: ->
				@callParent( arguments )
		)
		
		Ext.define( 'BaseView',
			extend: 'Ext.Container'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'BaseViewController'
		)
		
		Ext.define( 'ExtendedView',
			extend: 'BaseView'
			mixins: [ 'Deft.mixin.Controllable' ]
			controller: 'ExtendedViewController'
			
			constructor: ->
				@callParent( arguments )
		)
		
		baseViewControllerConstructorSpy = spyOn( BaseViewController.prototype, 'constructor' ).andCallFake( ->
			baseViewControllerInstance = @
			return baseViewControllerConstructorSpy.originalValue.apply( @, arguments )
		)
		extendedViewControllerConstructorSpy = spyOn( ExtendedViewController.prototype, 'constructor' ).andCallFake( ->
			extendedViewControllerInstance = @
			return extendedViewControllerConstructorSpy.originalValue.apply( @, arguments )
		)
		
		baseViewInstance = Ext.create( 'BaseView' )
		
		expect( baseViewControllerConstructorSpy ).toHaveBeenCalled()
		expect( baseViewControllerConstructorSpy.callCount ).toBe( 1 )
		expect( extendedViewControllerConstructorSpy ).not.toHaveBeenCalled()
		expect( baseViewControllerInstance ).not.toBe( null )
		expect( extendedViewControllerInstance ).toBe( null )
		expect( baseViewInstance.getController() ).toBe( baseViewControllerInstance )
		
		baseViewControllerConstructorSpy.reset()
		extendedViewControllerConstructorSpy.reset()
		baseViewControllerInstance = null
		extendedViewControllerInstance = null
		
		extendedViewInstance = Ext.create( 'ExtendedView' )
		
		expect( baseViewControllerConstructorSpy ).toHaveBeenCalled() # by @callParent()
		expect( baseViewControllerConstructorSpy.callCount ).toBe( 1 )
		expect( extendedViewControllerConstructorSpy ).toHaveBeenCalled()
		expect( extendedViewControllerConstructorSpy.callCount ).toBe( 1 )
		expect( baseViewControllerInstance ).not.toBe( null )
		expect( extendedViewControllerInstance ).not.toBe( null )
		expect( extendedViewControllerInstance ).toBe( baseViewControllerInstance )
		expect( extendedViewInstance.getController() ).toBe( extendedViewControllerInstance )
		
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
	
	return
)
