###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

describe( 'Deft.mixin.Controllable', ->
	
	describe( "when a Component or Container specifies the 'controller' class annotation", ->
		
		specify( 'creates an instance of the view controller specified by the target view `controller` class annotation and configures it with a reference to the target view instance when an instance of the target view is created', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
			)
			
			Ext.define( 'ExampleView',
				extend: 'Ext.Container'
				controller: 'ExampleViewController'
			)
			
			constructorSpy = sinon.spy( ExampleViewController.prototype, 'constructor' )
			
			exampleViewInstance = Ext.create( 'ExampleView' )
			
			expect( constructorSpy ).to.be.calledOnce
			exampleViewControllerInstance = constructorSpy.lastCall.thisValue
			expect( exampleViewControllerInstance.getView() ).to.equal( exampleViewInstance )

			delete ExampleViewController
			delete ExampleView

			return
		)
		
		specify( 'creates an instance of the view controller specified by the target view `controller` class annotation and configures it with a reference to the target view instance when an instance of the target view is created', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
			)
			
			Ext.define( 'ExampleView',
				extend: 'Ext.Container'
				controller: 'ExampleViewController'
				
				constructor: ( config ) ->
					@callParent( arguments )
			)
			
			constructorSpy = sinon.spy( ExampleViewController.prototype, 'constructor' )
			
			exampleViewInstance = Ext.create( 'ExampleView' )
			
			expect( constructorSpy ).to.be.calledOnce
			exampleViewControllerInstance = constructorSpy.lastCall.thisValue
			expect( exampleViewControllerInstance.getView() ).to.equal( exampleViewInstance )

			delete ExampleViewController
			delete ExampleView

			return
		)
		
		specify( 'passes the configuration object passed to the target view\'s `controllerConfig` config to the view controller\'s constructor', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					value: null
			)
			
			Ext.define( 'ExampleView',
				extend: 'Ext.Container'
				alias: 'widget.ExampleView'
				controller: 'ExampleViewController'
			)
			
			constructorSpy = sinon.spy( ExampleViewController.prototype, 'constructor' )
			
			exampleViewInstance = Ext.create( 'ExampleView',
				controllerConfig:
					value: 'expected value'
			)
			
			expect( constructorSpy ).to.be.calledOnce.and.calledWith( { value: 'expected value' } )
			exampleViewControllerInstance = constructorSpy.lastCall.thisValue
			expect( exampleViewControllerInstance.getView() ).to.equal( exampleViewInstance )
			expect( exampleViewControllerInstance.getValue() ).to.equal( 'expected value' )

			delete ExampleViewController
			delete ExampleView

			return
		)
		
		specify( 'automatically adds a getController() accessor method to the target view that returns the associated the view controller instance', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
			)
			
			Ext.define( 'ExampleView',
				extend: 'Ext.Container'
				controller: 'ExampleViewController'
			)
			
			constructorSpy = sinon.spy( ExampleViewController.prototype, 'constructor' )
			
			exampleViewInstance = Ext.create( 'ExampleView' )
			
			expect( constructorSpy ).to.be.calledOnce
			exampleViewControllerInstance = constructorSpy.lastCall.thisValue
			expect( exampleViewInstance.getController() ).to.equal( exampleViewControllerInstance )

			delete ExampleViewController
			delete ExampleView

			return
		)

		specify( 'only creates and attaches the most specific controller (i.e. the controller specified for the subclass) in an inheritance tree where multiple controllers are specified', ->
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
				controller: 'BaseViewController'
				
				constructor: ->
					@callParent( arguments )
			)
			
			Ext.define( 'ExtendedView',
				extend: 'BaseView'
				controller: 'ExtendedViewController'
				
				constructor: ->
					@callParent( arguments )
			)
			
			baseViewControllerConstructorSpy = sinon.spy( BaseViewController.prototype, 'constructor' )
			extendedViewControllerConstructorSpy = sinon.spy( ExtendedViewController.prototype, 'constructor' )
			
			baseViewInstance = Ext.create( 'BaseView' )
			
			expect( baseViewControllerConstructorSpy ).to.be.calledOnce
			expect( extendedViewControllerConstructorSpy ).not.to.be.called
			baseViewControllerInstance = baseViewControllerConstructorSpy.lastCall.thisValue
			expect( baseViewInstance.getController() ).to.equal( baseViewControllerInstance )
			
			baseViewControllerConstructorSpy.reset()
			extendedViewControllerConstructorSpy.reset()
			
			extendedViewInstance = Ext.create( 'ExtendedView' )
			
			expect( baseViewControllerConstructorSpy ).to.be.calledOnce # by @callParent()
			expect( extendedViewControllerConstructorSpy ).to.be.calledOnce
			baseViewControllerInstance = baseViewControllerConstructorSpy.lastCall.thisValue
			extendedViewControllerInstance = extendedViewControllerConstructorSpy.lastCall.thisValue
			expect( extendedViewControllerInstance ).to.equal( baseViewControllerInstance )
			expect( extendedViewInstance.getController() ).to.equal( extendedViewControllerInstance )

			delete BaseViewController
			delete ExtendedViewController
			delete BaseView
			delete ExtendedView

			return
		)

		specify( 'only creates and attaches the most specific controller (i.e. the controller specified for the subclass) in an inheritance tree where multiple controllers are specified (and the leaf class does not define a constructor)', ->
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
				controller: 'BaseViewController'
				
				constructor: ->
					@callParent( arguments )
			)
			
			Ext.define( 'ExtendedView',
				extend: 'BaseView'
				controller: 'ExtendedViewController'
			)
			
			baseViewControllerConstructorSpy = sinon.spy( BaseViewController.prototype, 'constructor' )
			extendedViewControllerConstructorSpy = sinon.spy( ExtendedViewController.prototype, 'constructor' )
			
			baseViewInstance = Ext.create( 'BaseView' )
			
			expect( baseViewControllerConstructorSpy ).to.be.calledOnce
			expect( extendedViewControllerConstructorSpy ).not.to.be.called
			baseViewControllerInstance = baseViewControllerConstructorSpy.lastCall.thisValue
			expect( baseViewInstance.getController() ).to.equal( baseViewControllerInstance )
			
			baseViewControllerConstructorSpy.reset()
			extendedViewControllerConstructorSpy.reset()
			
			extendedViewInstance = Ext.create( 'ExtendedView' )
			
			expect( baseViewControllerConstructorSpy ).to.be.calledOnce # by @callParent()
			expect( extendedViewControllerConstructorSpy ).to.be.calledOnce
			baseViewControllerInstance = baseViewControllerConstructorSpy.lastCall.thisValue
			extendedViewControllerInstance = extendedViewControllerConstructorSpy.lastCall.thisValue
			expect( extendedViewControllerInstance ).to.equal( baseViewControllerInstance )
			expect( extendedViewInstance.getController() ).to.equal( extendedViewControllerInstance )

			delete BaseViewController
			delete ExtendedViewController
			delete BaseView
			delete ExtendedView

			return
		)
		
		specify( 'only creates and attaches the most specific controller (i.e. the controller specified for the subclass) in an inheritance tree where multiple controllers are specified (and the root class does not define a constructor)', ->
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
				controller: 'BaseViewController'
			)
			
			Ext.define( 'ExtendedView',
				extend: 'BaseView'
				controller: 'ExtendedViewController'
				
				constructor: ->
					@callParent( arguments )
			)
			
			baseViewControllerConstructorSpy = sinon.spy( BaseViewController.prototype, 'constructor' )
			extendedViewControllerConstructorSpy = sinon.spy( ExtendedViewController.prototype, 'constructor' )
			
			baseViewInstance = Ext.create( 'BaseView' )
			
			expect( baseViewControllerConstructorSpy ).to.be.calledOnce
			expect( extendedViewControllerConstructorSpy ).not.to.be.called
			baseViewControllerInstance = baseViewControllerConstructorSpy.lastCall.thisValue
			expect( baseViewInstance.getController() ).to.equal( baseViewControllerInstance )
			
			baseViewControllerConstructorSpy.reset()
			extendedViewControllerConstructorSpy.reset()
			
			extendedViewInstance = Ext.create( 'ExtendedView' )
			
			expect( baseViewControllerConstructorSpy ).to.be.calledOnce # by @callParent()
			expect( extendedViewControllerConstructorSpy ).to.be.calledOnce
			baseViewControllerInstance = baseViewControllerConstructorSpy.lastCall.thisValue
			extendedViewControllerInstance = extendedViewControllerConstructorSpy.lastCall.thisValue
			expect( extendedViewControllerInstance ).to.equal( baseViewControllerInstance )
			expect( extendedViewInstance.getController() ).to.equal( extendedViewControllerInstance )

			delete BaseViewController
			delete ExtendedViewController
			delete BaseView
			delete ExtendedView

			return
		)
		
		specify( 're-throws any error thrown by the view controller during instantiation', ->
			Ext.define( 'ExampleErrorThrowingViewController',
				extend: 'Deft.mvc.ViewController'
				
				constructor: ->
					throw new Error( 'Error thrown by \`ExampleErrorThrowingViewController\`.' )
			)
			
			Ext.define( 'ExampleView',
				extend: 'Ext.Container'
				controller: 'ExampleErrorThrowingViewController'
			)
			
			expect( -> Ext.create( 'ExampleView' ) ).to.throw( Error, 'Error thrown by \`ExampleErrorThrowingViewController\`.' )

			delete ExampleErrorThrowingViewController
			delete ExampleView

			return
		)

		return
	)
)