###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

describe( 'Deft.mvc.ViewController', ->
	
	hasListener = ( observable, eventName ) ->
		if Ext.getVersion( 'extjs' )?
			# Workaround: Prior to 4.1.0, events had to be explicitly added.
			if Ext.getVersion( 'extjs' ).isLessThan( '4.1.0' )
				if observable.events[ eventName ] is undefined
					observable.addEvents( eventName )
			
			# Ext JS's implementation of `Ext.util.Observable::hasListener()` returns inaccurate information after `Ext.util.Observable::clearListeners()` is called.
			if ( observable.hasListener( eventName ) or observable.events[ eventName ]?.listeners?.length > 0 )
				return true
			else
				return false
		else
			return observable.hasListener( eventName )
	
	describe( 'Configuration', ->
		
		specify( 'configurable with a reference to the view it controls', ->
			view = Ext.create( 'Ext.Container' )
			
			viewController = Ext.create( 'Deft.mvc.ViewController', 
				view: view
			)
			
			expect( viewController.getView() ).to.equal( view )
			
			return
		)
		
		specify( 'configurable at runtime with a reference to the view it controls', ->
			view = Ext.create( 'Ext.Container' )
			
			viewController = Ext.create( 'Deft.mvc.ViewController' )
			
			expect( viewController.getView() ).to.equal( null )
			
			viewController.controlView( view )
			
			expect( viewController.getView() ).to.equal( view )
			
			return
		)
		
		specify( 'throws an error if created and configured with a non-Ext.Component as the view', ->
			expect( ->
				Ext.create( 'Deft.mvc.ViewController',
					view: new Object()
				)
			).to.throw( Error, "Error constructing ViewController: the configured 'view' is not an Ext.Component." )
			
			return
		)
	)
	
	describe( 'Creation of getters and event listeners using the \'control\' property', ->

		before( ->
			Ext.define( 'ExampleComponent',
				extend: 'Ext.Component'
				alias: 'widget.example'

				renderTo: 'componentTestArea'

				fireExampleEvent: ( value ) ->
					@fireEvent( 'exampleevent', @, value )
					return
			)

			Ext.define( 'ExampleView',
				extend: 'Ext.Container'

				renderTo: 'componentTestArea'

				# Ext JS
				items: [
					{
						xtype: 'example'
						itemId: 'example'
					}
				]
				config:
				# Sencha Touch
					items: [
						{
							xtype: 'example'
							itemId: 'example'
						}
					]

				fireExampleEvent: ( value ) ->
					@fireEvent( 'exampleevent', @, value )
					return
			)

			return
		)

		after( ->
			delete ExampleComponent
			delete ExampleView

			return
		)

		beforeEach( ->
			Ext.DomHelper.append( Ext.getBody(), '<div id="componentTestArea" style="visibility: hidden"></div>' )

			return
		)
		
		afterEach( ->
			Ext.removeNode( Ext.get( 'componentTestArea' ).dom )

			return
		)
		
		specify( 'attaches view controller scoped event listeners to events for the view', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					view:
						exampleevent: 'onExampleViewExampleEvent'
				
				onExampleViewExampleEvent: ( event ) ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onExampleViewExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( hasListener( view, 'exampleevent' ) ).to.be.true
			view.fireExampleEvent( 'expected value' )
			expect( viewController.onExampleViewExampleEvent ).to.be.calledOnce.and.calledWith( view, 'expected value' ).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'attaches view controller scoped event listeners to events for a component view', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					view:
						exampleevent: 'onExampleViewExampleEvent'
				
				onExampleViewExampleEvent: ( event ) ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onExampleViewExampleEvent' )
			
			view = Ext.create( 'ExampleComponent' )
			
			viewController = Ext.create( 'ExampleViewController',
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( hasListener( view, 'exampleevent' ) ).to.be.true
			view.fireExampleEvent( 'expected value' )
			expect( viewController.onExampleViewExampleEvent ).to.be.calledOnce.and.calledWith( view, 'expected value' ).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'attaches view controller scoped event listeners (with options) to events for the view', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					view:
						exampleevent:
							fn: 'onExampleViewExampleEvent'
							single: true
				
				onExampleViewExampleEvent: ( event ) ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onExampleViewExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( hasListener( view, 'exampleevent' ) ).to.be.true
			view.fireExampleEvent( 'expected value' )
			view.fireExampleEvent( 'unexpected value' )
			expect( viewController.onExampleViewExampleEvent ).to.be.calledOnce.and.calledWith( view, 'expected value', { single: true } ).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'attaches event listeners (with options) to events for the view', ->
			Ext.define( 'ExampleScope', {} )
			expectedScope = Ext.create( 'ExampleScope' )
			eventListenerFunction = sinon.stub()
			
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					view:
						exampleevent:
							fn: eventListenerFunction
							scope: expectedScope
							single: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( hasListener( view, 'exampleevent' ) ).to.be.true
			view.fireExampleEvent( 'expected value' )
			view.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).to.be.calledOnce.and.calledWith( view, 'expected value', { single: true } ).and.calledOn( expectedScope )

			delete ExampleScope
			delete ExampleViewController

			return
		)
		
		specify( 'throws an error when attaching a non-existing view controller scoped event listener for the view', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					view:
						exampleevent: 'onExampleViewExampleEvent'
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).to.throw( Error, 'Error adding \'exampleevent\' listener: the specified handler \'onExampleViewExampleEvent\' is not a Function or does not exist.' )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter for a view component referenced implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).to.equal( component )

			delete ExampleViewController

			return
		)
		
		specify( 'throws an error when referencing a non-existent component implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					doesntexist: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).to.throw( Error, 'Error locating component: no component(s) found matching \'#doesntexist\'.' )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter for a view component referenced implicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: '#example'
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).to.equal( component )

			delete ExampleViewController

			return
		)
		
		specify( 'throws an error when referencing a non-existent component implicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: '#doesntexist'
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).to.throw( Error, 'Error locating component: no component(s) found matching \'#doesntexist\'.' )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter for a view component referenced explicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: 
						selector: '#example'
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).to.equal( component )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter for view components referenced explicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: 
						selector: 'example'
			)
			
			view = Ext.create( 'ExampleView',
				items: [
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
				]
			)
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			components = view.query( 'example' )
			expect( viewController.getExample() ).to.deep.equal( components )

			delete ExampleViewController

			return
		)
		
		specify( 'throws an error when referencing a non-existent component explicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: 
						selector: '#doesntexist'
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).to.throw( Error, 'Error locating component: no component(s) found matching \'#doesntexist\'.' )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners to events for a view component referenced implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						exampleevent: 'onExampleComponentExampleEvent'
				
				onExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).to.equal( component )
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onExampleComponentExampleEvent ).to.be.calledOnce.and.calledWith( component, 'expected value' ).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners (with options) to events for a view component referenced implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						exampleevent:
							fn: 'onExampleComponentExampleEvent'
							single: true
				
				onExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).to.equal( component )
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onExampleComponentExampleEvent ).to.be.calledOnce.and.calledWith( component, 'expected value', { single: true } ).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach event listeners (with options) to events for a view component referenced implicitly by itemId', ->
			Ext.define( 'ExampleScope', {} )
			expectedScope = Ext.create( 'ExampleScope' )
			eventListenerFunction = sinon.stub()
			
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						exampleevent:
							fn: eventListenerFunction
							scope: expectedScope
							single: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).to.equal( component )
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).to.be.calledOnce.and.calledWith( component, 'expected value', { single: true } ).and.calledOn( expectedScope )

			delete ExampleScope
			delete ExampleViewController

			return
		)
		
		specify( 'throws an error when attaching a non-existing view controller scoped event listener for a view component referenced implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						exampleevent: 'onExampleComponentExampleEvent'
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).to.throw( Error, 'Error adding \'exampleevent\' listener: the specified handler \'onExampleComponentExampleEvent\' is not a Function or does not exist.' )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners to events for a view component referenced by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						selector: '#example'
						listeners:
							exampleevent: 'onExampleComponentExampleEvent'
				
				onExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).to.equal( component )
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onExampleComponentExampleEvent ).to.be.calledOnce.and.calledWith( component, 'expected value' ).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners (with options) to events for a view component referenced by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						selector: '#example'
						listeners:
							exampleevent:
								fn: 'onExampleComponentExampleEvent'
								single: true
				
				onExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).to.equal( component )
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onExampleComponentExampleEvent ).to.be.calledOnce.and.calledWith( component, 'expected value', { single: true } ).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach event listeners (with options) to events for a view component referenced by selector', ->
			Ext.define( 'ExampleScope', {} )
			expectedScope = Ext.create( 'ExampleScope' )
			eventListenerFunction = sinon.stub()
			
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						selector: '#example'
						listeners:
							exampleevent:
								fn: eventListenerFunction
								scope: expectedScope
								single: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).to.equal( component )
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).to.be.calledOnce.and.calledWith( component, 'expected value', { single: true } ).and.calledOn( expectedScope )

			delete ExampleScope
			delete ExampleViewController

			return
		)
		
		specify( 'throws an error when attaching a non-existing view controller scoped event listener for a view component referenced implicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						selector: '#example'
						listeners:
							exampleevent: 'onExampleComponentExampleEvent'
			)
			
			view = Ext.create( 'ExampleView' )
			
			expect( ->
				viewController = Ext.create( 'ExampleViewController', 
					view: view
				)
			).to.throw( Error, 'Error adding \'exampleevent\' listener: the specified handler \'onExampleComponentExampleEvent\' is not a Function or does not exist.' )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners to events for view components referenced by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						selector: 'example'
						listeners:
							exampleevent: 'onExampleComponentExampleEvent'
				
				onExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView',
				items: [
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
				]
			)
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			components = view.query( 'example' )
			expect( viewController.getExample() ).to.deep.equal( components )
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.true
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onExampleComponentExampleEvent.lastCall ).to.be.calledWith( component, 'expected value' ).and.calledOn( viewController )
				
			expect( viewController.onExampleComponentExampleEvent.callCount ).to.equal( components.length )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners (with options) to events for view components referenced by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						selector: 'example'
						listeners:
							exampleevent:
								fn: 'onExampleComponentExampleEvent'
								single: true
				
				onExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView',
				items: [
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
				]
			)
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			components = view.query( 'example' )
			expect( viewController.getExample() ).to.deep.equal( components )
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.true
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onExampleComponentExampleEvent.lastCall ).to.be.calledWith( component, 'expected value', { single: true } ).and.calledOn( viewController )
			
			expect( viewController.onExampleComponentExampleEvent.callCount ).to.equal( 3 )
			
			viewController.onExampleComponentExampleEvent.reset()
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.false
				component.fireExampleEvent( 'unexpected value' )
				expect( viewController.onExampleComponentExampleEvent ).not.to.be.called
				
			expect( viewController.onExampleComponentExampleEvent.callCount ).to.equal( 0 )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach event listeners (with options) to events for view components referenced by selector', ->
			Ext.define( 'ExampleScope', {} )
			expectedScope = Ext.create( 'ExampleScope' )
			eventListenerFunction = sinon.stub()
			
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						selector: 'example'
						listeners:
							exampleevent:
								fn: eventListenerFunction
								scope: expectedScope
								single: true
			)
			
			view = Ext.create( 'ExampleView',
				items: [
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
				]
			)
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			components = view.query( 'example' )
			expect( viewController.getExample() ).to.deep.equal( components )
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.true
				component.fireExampleEvent( 'expected value' )
				expect( eventListenerFunction.lastCall ).to.be.calledWith( component, 'expected value', { single: true } ).and.calledOn( expectedScope )
				
			expect( eventListenerFunction.callCount ).to.equal( 3 )
			
			eventListenerFunction.reset()
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.false
				component.fireExampleEvent( 'unexpected value' )
				expect( eventListenerFunction ).not.to.be.called
				
			expect( eventListenerFunction.callCount ).to.equal( 0 )

			delete ExampleScope
			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter for a dynamic view component referenced by a live selector implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( viewController.getDynamicExample() ).to.equal( null )
			
			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			
			expect( viewController.getDynamicExample() ).to.equal( component )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter for a dynamic view component referenced explicitly by a live selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample: 
						selector: '#dynamicExample'
						live: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( viewController.getDynamicExample() ).to.equal( null )
			
			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			
			expect( viewController.getDynamicExample() ).to.equal( component )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners to events for a dynamic view component referenced by a live selector implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
						listeners:
							exampleevent: 'onDynamicExampleComponentExampleEvent'
				
				onDynamicExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( viewController.getDynamicExample() ).to.equal( null )
			
			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			expect( viewController.getDynamicExample() ).to.equal( component )
			
			expect( hasListener( component,'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).to.be.calledOnce.and.calledWith( component, 'expected value' ).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners (with options) to events for a dynamic view component referenced by a live selector implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
						listeners:
							exampleevent:
								fn: 'onDynamicExampleComponentExampleEvent'
								single: true
				
				onDynamicExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( viewController.getDynamicExample() ).to.equal( null )
			
			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			expect( viewController.getDynamicExample() ).to.equal( component )
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).to.be.calledOnce.and.calledWith( component, 'expected value', { single: true } ).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach event listeners (with options) to events for a dynamic view component referenced by a live selector implicitly by itemId', ->
			Ext.define( 'ExampleScope', {} )
			expectedScope = Ext.create( 'ExampleScope' )
			eventListenerFunction = sinon.stub()
			
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
						listeners:
							exampleevent:
								fn: eventListenerFunction
								scope: expectedScope
								single: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( viewController.getDynamicExample() ).to.equal( null )
			
			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			expect( viewController.getDynamicExample() ).to.equal( component )
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).to.be.calledOnce.and.calledWith( component, 'expected value', { single: true } ).and.calledOn( expectedScope )

			delete ExampleScope
			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners to events for a dynamic view component referenced by a live selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
						selector: '#dynamicExample'
						listeners:
							exampleevent: 'onDynamicExampleComponentExampleEvent'
				
				onDynamicExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( viewController.getDynamicExample() ).to.equal( null )
			
			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			expect( viewController.getDynamicExample() ).to.equal( component )
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).to.be.calledOnce.and.calledWith( component, 'expected value' ).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners (with options) to events for a dynamic view component referenced by a live selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
						selector: '#dynamicExample'
						listeners:
							exampleevent:
								fn: 'onDynamicExampleComponentExampleEvent'
								single: true
				
				onDynamicExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( viewController.getDynamicExample() ).to.equal( null )
			
			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			expect( viewController.getDynamicExample() ).to.equal( component )
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).to.be.calledOnce.and.calledWith( component, 'expected value', { single: true } ).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach event listeners (with options) to events for a dynamic view component referenced by a live selector', ->
			Ext.define( 'ExampleScope', {} )
			expectedScope = Ext.create( 'ExampleScope' )
			eventListenerFunction = sinon.stub()
			
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
						selector: '#dynamicExample'
						listeners:
							exampleevent:
								fn: eventListenerFunction
								scope: expectedScope
								single: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			expect( viewController.getDynamicExample() ).to.equal( null )
			
			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			
			expect( viewController.getDynamicExample() ).to.equal( component )
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).to.be.calledOnce.and.calledWith( component, 'expected value', { single: true } ).and.calledOn( expectedScope )

			delete ExampleScope
			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners to events for a dynamic view components referenced by a live selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
						selector: 'example'
						listeners:
							exampleevent: 'onDynamicExampleComponentExampleEvent'
				
				onDynamicExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			# Get a reference to the existing example component.
			existingComponent = view.query( 'example' )[ 0 ]
			expect( viewController.getDynamicExample() ).to.equal( existingComponent )
			
			# Add a few more.
			view.add(
				[
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
				]
			)
			components = view.query( 'example' )
			expect( viewController.getDynamicExample() ).to.deep.equal( components )
			expect( viewController.getDynamicExample().length ).to.equal( 4 )
			
			# Remove one.
			view.remove( components[ 2 ] )
			components = view.query( 'example' )
			expect( viewController.getDynamicExample() ).to.deep.equal( components )
			expect( viewController.getDynamicExample().length ).to.equal( 3 )
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.true
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onDynamicExampleComponentExampleEvent.lastCall ).to.be.calledWith( component, 'expected value' ).and.calledOn( viewController )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).to.equal( 3 )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach view controller scoped event listeners (with options) to events for a dynamic view components referenced by a live selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
						selector: 'example'
						listeners:
							exampleevent: 
								fn: 'onDynamicExampleComponentExampleEvent'
								single: true
								
				onDynamicExampleComponentExampleEvent: ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' )
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			# Get a reference to the existing example component.
			existingComponent = view.query( 'example' )[ 0 ]
			expect( viewController.getDynamicExample() ).to.equal( existingComponent )
			
			# Add a few more.
			view.add(
				[
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
				]
			)
			components = view.query( 'example' )
			expect( viewController.getDynamicExample() ).to.deep.equal( components )
			expect( viewController.getDynamicExample().length ).to.equal( 4 )
			
			# Remove one.
			view.remove( components[ 2 ] )
			components = view.query( 'example' )
			expect( viewController.getDynamicExample() ).to.deep.equal( components )
			expect( viewController.getDynamicExample().length ).to.equal( 3 )
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.true
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onDynamicExampleComponentExampleEvent.lastCall ).to.be.calledWith( component, 'expected value', { single: true } ).and.calledOn( viewController )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).to.equal( 3 )
			
			viewController.onDynamicExampleComponentExampleEvent.reset()
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.false
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onDynamicExampleComponentExampleEvent ).not.be.called
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).to.equal( 0 )

			delete ExampleViewController

			return
		)
		
		specify( 'creates a view controller getter and attach event listeners (with options) to events for a dynamic view components referenced by a live selector', ->
			Ext.define( 'ExampleScope', {} )
			expectedScope = Ext.create( 'ExampleScope' )
			eventListenerFunction = sinon.stub()
			
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
						selector: 'example'
						listeners:
							exampleevent: 
								fn: eventListenerFunction
								scope: expectedScope
								single: true
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).to.equal( view )
			
			# Get a reference to the existing example component.
			existingComponent = view.query( 'example' )[ 0 ]
			expect( viewController.getDynamicExample() ).to.equal( existingComponent )
			
			# Add a few more.
			view.add(
				[
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
				]
			)
			components = view.query( 'example' )
			expect( viewController.getDynamicExample() ).to.deep.equal( components )
			expect( viewController.getDynamicExample().length ).to.equal( 4 )
			
			# Remove one.
			view.remove( components[ 2 ] )
			components = view.query( 'example' )
			expect( viewController.getDynamicExample() ).to.deep.equal( components )
			expect( viewController.getDynamicExample().length ).to.equal( 3 )
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.true
				component.fireExampleEvent( 'expected value' )
				expect( eventListenerFunction.lastCall ).to.be.calledWith( component, 'expected value', { single: true } ).and.calledOn( expectedScope )
			expect( eventListenerFunction.callCount ).to.equal( 3 )
			
			eventListenerFunction.reset()
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.false
				component.fireExampleEvent( 'expected value' )
				expect( eventListenerFunction ).not.to.be.called
			expect( eventListenerFunction.callCount ).to.equal( 0 )

			delete ExampleScope
			delete ExampleViewController

			return
		)
	)
	
	describe( 'Observer creation', ->
		
		beforeEach( ->
			Ext.define( 'NestedObservable',
				constructor: ->
					@observable = Ext.create( 'Ext.util.Observable' )
					@callParent( arguments )
			)
			
			Ext.define( 'DeeplyNestedObservable',
				constructor: ->
					@nested = Ext.create( 'NestedObservable' )
					@callParent( arguments )
			)
			
			return
		)

		afterEach( ->
			delete NestedObservable
			delete DeeplyNestedObservable

			return
		)
		
		specify( 'merges child observe configurations', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: 'subclassMessageHandler'
			)
			
			viewController = Ext.create( 'ExampleSubclassViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					subclassMessage: [ 'subclassMessageHandler' ]
					baseMessage: [ 'baseMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'merges observe configurations when extend when a handler is a list', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: 'subclassMessageHandler1, subclassMessageHandler2'
			)
			
			viewController = Ext.create( 'ExampleSubclassViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					subclassMessage: [ 'subclassMessageHandler1', 'subclassMessageHandler2' ]
					baseMessage: [ 'baseMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'merges multiple levels of observe configurations throughout a class hierarchy', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				observe:
					messageBus:
						baseMessage: "baseMessageHandler"
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: "subclassMessageHandler"
			)
			
			Ext.define( 'ExampleSubclass2ViewController',
				extend: 'ExampleSubclassViewController'
				
				observe:
					messageBus:
						subclass2Message: "subclass2MessageHandler"
			)
			
			viewController = Ext.create( 'ExampleSubclass2ViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					subclass2Message: [ 'subclass2MessageHandler' ]
					subclassMessage: [ 'subclassMessageHandler' ]
					baseMessage: [ 'baseMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController
			delete ExampleSubclass2ViewController

			return
		)
		
		specify( 'merges multiple levels of child observe configurations, with child observers taking precedence', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: 'subclassMessageHandler'
			)
			
			Ext.define( 'ExampleSubclass2ViewController',
				extend: 'ExampleSubclassViewController'
				
				observe:
					messageBus:
						baseMessage: 'subclass2MessageHandler'
			)
			
			viewController = Ext.create( 'ExampleSubclass2ViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					baseMessage: [ 'subclass2MessageHandler', 'baseMessageHandler' ]
					subclassMessage: [ 'subclassMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController
			delete ExampleSubclass2ViewController

			return
		)
		
		specify( 'merges multiple levels of child observe configurations when middle subclass has no observers', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
			)
			
			Ext.define( 'ExampleSubclass2ViewController',
				extend: 'ExampleSubclassViewController'
				
				observe:
					messageBus:
						subclass2Message: 'subclass2MessageHandler'
			)
			
			viewController = Ext.create( 'ExampleSubclass2ViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					subclass2Message: [ 'subclass2MessageHandler' ]
					baseMessage: [ 'baseMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController
			delete ExampleSubclass2ViewController

			return
		)
		
		specify( 'merges multiple levels of subclass observe configurations when the base class has no observers', ->
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: 'subclassMessageHandler'
			)
			
			Ext.define( 'ExampleSubclass2ViewController',
				extend: 'ExampleSubclassViewController'
				
				observe:
					messageBus:
						subclass2Message: 'subclass2MessageHandler'
			)
			
			viewController = Ext.create( 'ExampleSubclass2ViewController' )
			
			expectedObserveConfiguration =
				messageBus:
					subclass2Message: [ 'subclass2MessageHandler' ]
					subclassMessage: [ 'subclassMessageHandler' ]
			
			expect( viewController.observe ).to.deep.equal( expectedObserveConfiguration )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController
			delete ExampleSubclass2ViewController

			return
		)
		
		specify( 'attaches listeners to observed objects in a ViewController with no subclasses', ->
			eventData = { value1: true, value2: false }
			
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
				
				observe:
					messageBus:
						message: 'messageHandler'
				
				messageHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleViewController.prototype, 'messageHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			
			viewController = Ext.create( 'ExampleViewController',
				messageBus: messageBus
			)
			
			expect( hasListener( messageBus, 'message' ) ).to.be.true
			
			messageBus.fireEvent( 'message', eventData )
			
			expect( viewController.messageHandler ).to.be.calledOnce.and.calledWith( eventData).and.calledOn( viewController )

			delete ExampleViewController

			return
		)
		
		specify( 'attaches listeners to observed objects in a ViewController subclass where the subclass has an observe configuration', ->
			baseEventData = { value1: true, value2: false }
			subclassEventData = { value2: true, value3: false }
			storeEventData = { value5: true, value6: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					store: null
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
					store:
						beforesync: 'storeHandler'
				
				baseMessageHandler: ( data ) ->
					return
				
				storeHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						subclassMessage: 'subclassMessageHandler'
				
				subclassMessageHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleBaseViewController.prototype, 'storeHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
				store: store
			)
			
			expect( hasListener( messageBus, 'baseMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage' ) ).to.be.true
			expect( hasListener( store, 'beforesync' ) ).to.be.true
			
			messageBus.fireEvent( 'baseMessage', baseEventData )
			messageBus.fireEvent( 'subclassMessage', subclassEventData )
			store.fireEvent( 'beforesync', storeEventData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( subclassEventData ).and.calledOn( viewController )
			expect( viewController.storeHandler ).to.be.calledOnce.and.calledWith( storeEventData ).and.calledOn( viewController )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'attaches listeners (with options) to observed objects in a ViewController', ->
			Ext.define( 'ExampleScope', {} )
			expectedScope = Ext.create( 'ExampleScope' )
			baseEventData = { value1: true, value2: false }
			subclassEventData = { value2: true, value3: false }
			storeEventData = { value5: true, value6: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					store: null
				
				observe:
					messageBus: [
						event: 'baseMessage'
						fn: 'baseMessageHandler'
						scope: expectedScope
					]
					store: [
						event: 'beforesync'
						fn: 'storeHandler'
						scope: expectedScope
					]
				
				baseMessageHandler: ( data ) ->
					return
				
				storeHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus: [
						event: 'subclassMessage'
						fn: 'subclassMessageHandler'
						scope: expectedScope
					]
				
				subclassMessageHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleBaseViewController.prototype, 'storeHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
				store: store
			)
			
			expect( hasListener( messageBus, 'baseMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage' ) ).to.be.true
			expect( hasListener( store, 'beforesync' ) ).to.be.true
			
			messageBus.fireEvent( 'baseMessage', baseEventData )
			messageBus.fireEvent( 'subclassMessage', subclassEventData )
			store.fireEvent( 'beforesync', storeEventData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( expectedScope )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( subclassEventData ).and.calledOn( expectedScope )
			expect( viewController.storeHandler ).to.be.calledOnce.and.calledWith( storeEventData ).and.calledOn( expectedScope )

			delete ExampleScope
			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'attaches listeners to nested properties of observed objects', ->
			messageEventData = { value1: true, value2: false }
			storeProxyEventData = { value3: true, value4: false }
			deeplyNestedObservableEventData = { value5: true, value6: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					store: null
					deeply: null
				
				observe:
					messageBus:
						message: 'messageHandler'
					'store.proxy':
						metachange: 'storeProxyHandler'
				
				messageHandler: ( data ) ->
					return
				
				storeProxyHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					'deeply.nested.observable':
						exception: "deeplyNestedObservableHandler"
				
				deeplyNestedObservableHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'messageHandler' )
			sinon.spy( ExampleBaseViewController.prototype, 'storeProxyHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'deeplyNestedObservableHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )
			deeply = Ext.create( 'DeeplyNestedObservable' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
				store: store
				deeply: deeply
			)
			
			messageBus.fireEvent( 'message', messageEventData )
			store.getProxy().fireEvent( 'metachange', storeProxyEventData )
			deeply.nested.observable.fireEvent( 'exception', deeplyNestedObservableEventData )
			
			expect( viewController.messageHandler ).to.be.calledOnce.and.calledWith( messageEventData ).and.calledOn( viewController )
			expect( viewController.storeProxyHandler ).to.be.calledOnce.and.calledWith( storeProxyEventData ).and.calledOn( viewController )
			expect( viewController.deeplyNestedObservableHandler ).to.be.calledOnce.and.calledWith( deeplyNestedObservableEventData ).and.calledOn( viewController )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'attaches listeners in the base class and subclass to the same observed object', ->
			eventData = { value1: true, value2: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					store: null
				
				observe:
					messageBus:
						message: 'baseMessageHandler'
				
				baseMessageHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus:
						message: 'subclassMessageHandler'
				
				subclassMessageHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
			)
			
			expect( hasListener( messageBus, 'message' ) ).to.be.true
			
			messageBus.fireEvent( 'message', eventData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( eventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( eventData ).and.calledOn( viewController )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'attaches listeners (with options) in the base class and subclass to the same observed object', ->
			Ext.define( 'ExampleScope', {} )
			expectedScope = Ext.create( 'ExampleScope' )
			eventData = { value1: true, value2: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					store: null
				
				observe:
					messageBus: [
						event: 'message'
						fn: 'baseMessageHandler'
						scope: expectedScope
					]
				
				baseMessageHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus: [
						event: 'message'
						fn: 'subclassMessageHandler'
						scope: expectedScope
					]
				
				subclassMessageHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
			)
			
			expect( hasListener( messageBus, 'message' ) ).to.be.true
			
			messageBus.fireEvent( 'message', eventData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( eventData ).and.calledOn( expectedScope )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( eventData ).and.calledOn( expectedScope )

			delete ExampleScope
			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'creates observers specified via a variety of the available observe property syntax', ->
			baseEventData = { value1: true, value2: false }
			subclassEventData = { valueA: true, valueB: false }
			subclassEventData2 = { valueC: true, valueD: false }
			storeEventData = { value3: true, value4: false }
			deeplyNestedObservableData = { value5: true, value6: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					store: null
					deeply: null
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
					'store.proxy': [
						event: 'metachange'
						fn: 'storeProxyHandler'
					]
				
				baseMessageHandler: ( data ) ->
					return
				
				storeProxyHandler: ( data ) ->
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus: [
						{
							event: 'baseMessage'
							fn: 'subclassMessageHandlerForBaseMessage'
						}
						{
							event: 'subclassMessage'
							fn: 'subclassMessageHandler'
						}
						{
							subclassMessage2: 'subclassMessageHandler2'
						}
					]
					'deeply.nested.observable': [
						event: 'exception'
						fn: 'deeplyNestedObservableHandler'
					]
				
				subclassMessageHandlerForBaseMessage: ( data ) ->
					return
				
				subclassMessageHandler: ( data ) ->
					return
				
				subclassMessageHandler2: ( data ) ->
					return
				
				deeplyNestedObservableHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleBaseViewController.prototype, 'storeProxyHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandlerForBaseMessage' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler2' )
			sinon.spy( ExampleSubclassViewController.prototype, 'deeplyNestedObservableHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )
			deeply = Ext.create( 'DeeplyNestedObservable' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
				store: store
				deeply: deeply
			)
			
			expect( hasListener( messageBus, 'baseMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage2' ) ).to.be.true
			expect( hasListener( store.getProxy(), 'metachange' ) ).to.be.true
			expect( hasListener( deeply.nested.observable, 'exception' ) ).to.be.true
			
			messageBus.fireEvent( 'baseMessage', baseEventData )
			messageBus.fireEvent( 'subclassMessage', subclassEventData )
			messageBus.fireEvent( 'subclassMessage2', subclassEventData2 )
			store.getProxy().fireEvent( 'metachange', storeEventData )
			deeply.nested.observable.fireEvent( 'exception', deeplyNestedObservableData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandlerForBaseMessage ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( subclassEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler2 ).to.be.calledOnce.and.calledWith( subclassEventData2 ).and.calledOn( viewController )
			expect( viewController.storeProxyHandler ).to.be.calledOnce.and.calledWith( storeEventData ).and.calledOn( viewController )
			expect( viewController.deeplyNestedObservableHandler ).to.be.calledOnce.and.calledWith( deeplyNestedObservableData ).and.calledOn( viewController )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		specify( 'creates observers specified via a variety of the available observe property syntax (with event options)', ->
			baseEventData = { value1: true, value2: false }
			subclassEventData = { valueA: true, valueB: false }
			subclassEventData2 = { valueC: true, valueD: false }
			storeEventData = { value3: true, value4: false }
			deeplyNestedObservableEventData = { value5: true, value6: false }
			
			Ext.define( 'ExampleBaseViewController',
				extend: 'Deft.mvc.ViewController'
				
				config:
					messageBus: null
					store: null
					deeply: null
				
				observe:
					messageBus:
						baseMessage: 'baseMessageHandler'
					'store.proxy': [
						event: 'metachange'
						fn: 'storeProxyHandler'
						single: true
					]
				
				baseMessageHandler: ( data ) ->
					return
				
				storeProxyHandler: ( data, eventOptions ) ->
					expect( eventOptions.single ).to.be.true
					return
			)
			
			Ext.define( 'ExampleSubclassViewController',
				extend: 'ExampleBaseViewController'
				
				observe:
					messageBus: [
						{
							event: 'baseMessage'
							fn: 'subclassMessageHandlerForBaseMessage'
						}
						{
							event: 'subclassMessage'
							fn: 'subclassMessageHandler'
							single: true
						}
						{
							subclassMessage2: 'subclassMessageHandler2'
						}
					]
					'deeply.nested.observable': [
						event: 'exception'
						fn: 'deeplyNestedObservableHandler'
						single: true
					]
				
				subclassMessageHandlerForBaseMessage: ( data ) ->
					return
				
				subclassMessageHandler: ( data, eventOptions ) ->
					expect( eventOptions.single ).to.be.true
					return
				
				subclassMessageHandler2: ( data ) ->
					return
				
				deeplyNestedObservableHandler: ( data ) ->
					return
			)
			
			sinon.spy( ExampleBaseViewController.prototype, 'baseMessageHandler' )
			sinon.spy( ExampleBaseViewController.prototype, 'storeProxyHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandlerForBaseMessage' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler' )
			sinon.spy( ExampleSubclassViewController.prototype, 'subclassMessageHandler2' )
			sinon.spy( ExampleSubclassViewController.prototype, 'deeplyNestedObservableHandler' )
			
			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )
			deeply = Ext.create( 'DeeplyNestedObservable' )
			
			viewController = Ext.create( 'ExampleSubclassViewController',
				messageBus: messageBus
				store: store
				deeply: deeply
			)
			
			expect( hasListener( messageBus, 'baseMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage' ) ).to.be.true
			expect( hasListener( messageBus, 'subclassMessage2' ) ).to.be.true
			expect( hasListener( store.getProxy(), 'metachange' ) ).to.be.true
			expect( hasListener( deeply.nested.observable, 'exception' ) ).to.be.true
			
			messageBus.fireEvent( 'baseMessage', baseEventData )
			messageBus.fireEvent( 'subclassMessage', subclassEventData )
			messageBus.fireEvent( 'subclassMessage2', subclassEventData2 )
			store.getProxy().fireEvent( 'metachange', storeEventData )
			deeply.nested.observable.fireEvent( 'exception', deeplyNestedObservableEventData )
			
			# Fire extra events to verify single: true
			messageBus.fireEvent( 'subclassMessage', subclassEventData )
			store.getProxy().fireEvent( 'metachange', storeEventData )
			deeply.nested.observable.fireEvent( 'exception', deeplyNestedObservableEventData )
			
			expect( viewController.baseMessageHandler ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandlerForBaseMessage ).to.be.calledOnce.and.calledWith( baseEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler ).to.be.calledOnce.and.calledWith( subclassEventData ).and.calledOn( viewController )
			expect( viewController.subclassMessageHandler2 ).to.be.calledOnce.and.calledWith( subclassEventData2 ).and.calledOn( viewController )
			expect( viewController.storeProxyHandler ).to.be.calledOnce.and.calledWith( storeEventData ).and.calledOn( viewController )
			expect( viewController.deeplyNestedObservableHandler ).to.be.calledOnce.and.calledWith( deeplyNestedObservableEventData ).and.calledOn( viewController )

			delete ExampleBaseViewController
			delete ExampleSubclassViewController

			return
		)
		
		return
	)
	
	describe( 'Destruction and clean-up', ->

		before( ->
			Ext.define( 'ExampleComponent',
				extend: 'Ext.Component'
				alias: 'widget.example'
			)

			Ext.define( 'ExampleView',
				extend: 'Ext.Container'

				renderTo: 'componentTestArea'
			# Ext JS
				items: [
					{
						xtype: 'example'
						itemId: 'example'
					}
				]
				config:
				# Sencha Touch
					items: [
						{
							xtype: 'example'
							itemId: 'example'
						}
					]
			)

			return
		)

		after( ->
			delete ExampleComponent
			delete ExampleView

			return
		)

		beforeEach( ->
			Ext.DomHelper.append( Ext.getBody(), '<div id="componentTestArea" style="visibility: hidden"></div>' )
			
			return
		)
		
		afterEach( ->
			Ext.removeNode( Ext.get( 'componentTestArea' ).dom )

			return
		)
		
		specify( 'calls destroy() when the associated view is destroyed', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			sinon.spy( viewController, 'destroy' )
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).to.be.calledOnce
			expect( isViewDestroyed ).to.be.true

			delete ExampleViewController

			return
		)
		
		specify( 'cancels view destruction if the view controller\'s destroy() returns false', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				destroy: ->
					return false
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			sinon.spy( viewController, 'destroy' )
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).to.be.calledOnce
			expect( isViewDestroyed ).to.be.false

			delete ExampleViewController
			
			return
		)
		
		specify( 'removes event listeners it attached to the view when the associated view (and view controller) is destroyed', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					view:
						exampleevent: 'onExampleViewExampleEvent'
				
				onExampleViewExampleEvent: ( event ) ->
					return
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			expect( hasListener( view, 'exampleevent' ) ).to.be.true
			
			sinon.spy( viewController, 'destroy' )
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).to.be.called
			expect( isViewDestroyed ).to.be.true
			
			expect( hasListener( view, 'exampleevent' ) ).to.be.false

			delete ExampleViewController
			
			return
		)
		
		specify( 'removes event listeners it attached to a view component referenced implicitly by itemId when the associated view (and view controller) is destroyed', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						selector: '#example'
						listeners:
							exampleevent: 'onExampleComponentExampleEvent'
				
				onExampleComponentExampleEvent: ->
					return
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getExample ).not.to.be.null
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			
			sinon.spy( viewController, 'destroy' )
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).to.be.calledOnce
			expect( viewController.getExample ).to.be.null
			expect( isViewDestroyed ).to.be.true
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.false

			delete ExampleViewController
			
			return
		)
		
		specify( 'removes event listeners it attached to view components referenced explicitly by a selector when the associated view (and view controller) is destroyed', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example:
						selector: 'example'
						listeners:
							exampleevent: 'onExampleComponentExampleEvent'
				
				onExampleComponentExampleEvent: ->
					return
			)
			
			view = Ext.create( 'ExampleView', 
				items: [
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
				]
			)
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			components = view.query( 'example' )
			
			expect( viewController.getExample ).not.to.be.null
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.true
			
			sinon.spy( viewController, 'destroy' )
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).to.be.calledOnce
			expect( viewController.getExample ).to.be.null
			expect( isViewDestroyed ).to.be.true
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.false

			delete ExampleViewController
			
			return
		)
		
		specify( 'removes event listeners it attached to a dynamic view component referenced by a live selector implicitly by itemId when the associated view (and view controller) is destroyed', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
						selector: '#dynamicExample'
						listeners:
							exampleevent: 'onDynamicExampleComponentExampleEvent'
				
				onDynamicExampleComponentExampleEvent: ->
					return
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			
			expect( viewController.getDynamicExample ).not.to.be.null
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.true
			
			sinon.spy( viewController, 'destroy' )
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).to.be.calledOnce
			expect( viewController.getDynamicExample ).to.be.null
			expect( isViewDestroyed ).to.be.true
			
			expect( hasListener( component, 'exampleevent' ) ).to.be.false

			delete ExampleViewController
			
			return
		)
		
		specify( 'removes event listeners it attached to dynamic view components referenced explicitly by a live selector when the associated view (and view controller) is destroyed', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					dynamicExample:
						live: true
						selector: 'example'
						listeners:
							exampleevent: 'onDynamicExampleComponentExampleEvent'
				
				onDynamicExampleComponentExampleEvent: ->
					return
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			# Add a few more.
			view.add(
				[
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
					{
						xtype: 'example'
					}
				]
			)
			components = view.query( 'example' )
			
			expect( viewController.getDynamicExample ).not.to.be.null
			expect( viewController.getDynamicExample() ).to.deep.equal( components )
			expect( viewController.getDynamicExample().length ).to.equal( 4 )
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.true
			
			sinon.spy( viewController, 'destroy' )
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).to.be.calledOnce
			expect( viewController.getDynamicExample ).to.be.null
			expect( isViewDestroyed ).to.be.true
			
			for component in components
				expect( hasListener( component, 'exampleevent' ) ).to.be.false

			delete ExampleViewController
			
			return
		)
		
		specify( 'removes listeners from observed objects when the view controller is destroyed', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'
				
				config:
					store: null
					store2: null
				
				observe:
					store:
						beforesync: 'genericHandler'
					'store.proxy':
						customevent: 'genericHandler'
					store2:
						beforesync: 'genericHandler'
						beforeload: 'genericHandler'
				
				genericHandler: ->
					return
			)
			
			view = Ext.create( 'ExampleView' )
			store = Ext.create( 'Ext.data.ArrayStore' )
			store2 = Ext.create( 'Ext.data.ArrayStore' )
			
			expect( hasListener( store, 'beforesync' ) ).to.be.false
			expect( hasListener( store.getProxy(), 'customevent' ) ).to.be.false
			expect( hasListener( store2, 'beforeload' ) ).to.be.false
			
			viewController = Ext.create( 'ExampleClass',
				view: view
				store: store
				store2: store2
			)
			
			sinon.spy( viewController, 'removeObservers' )
			
			expect( hasListener( store, 'beforesync' ) ).to.be.true
			expect( hasListener( store.getProxy(), 'customevent' ) ).to.be.true
			expect( hasListener( store2, 'beforeload' ) ).to.be.true
			expect( hasListener( store2, 'beforesync' ) ).to.be.true
			
			view.destroy()
			
			expect( viewController.removeObservers ).to.be.calledOnce
			
			expect( hasListener( store, 'beforesync' ) ).to.be.false
			expect( hasListener( store.getProxy(), 'customevent' ) ).to.be.false
			expect( hasListener( store2, 'beforesync' ) ).to.be.false
			expect( hasListener( store2, 'beforeload' ) ).to.be.false

			delete ExampleClass

			return
		)
	)

	return
)