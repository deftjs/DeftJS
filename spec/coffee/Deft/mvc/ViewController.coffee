###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.mvc.ViewController
###
describe( 'Deft.mvc.ViewController', ->

	hasListener = ( observable, eventName ) ->
		if Ext.getVersion( 'extjs' )?
			# Ext JS's implementation of `Ext.util.Observable::hasListener()` returns inaccurate information after `Ext.util.Observable::clearListeners()` is called.
			return observable.events[ eventName ].listeners.length isnt 0
		else
			return observable.hasListener( eventName )

	beforeEach( ->
		@addMatchers(
			# NOTE: This differs from toHaveBeenCalledWith() by comparing against the MOST RECENT call rather than any of the recorded calls.
			# NOTE: Sencha Touch passes an extra argument when firing an event, use this matcher to ensure that at least the parameters specified were passed (ignoring any extras).
			toHaveMostRecentlyBeenCalledWithAtLeast: ->
				expectedArgs = jasmine.util.argsToArray( arguments )
				if not jasmine.isSpy( @actual )
					throw new Error( 'Expected a spy, but got ' + jasmine.pp( @actual ) + '.' )

				@message = ->
					if @actual.callCount is 0
						return [
							"Expected spy #{ @actual.identity } to have been called with #{ jasmine.pp( expectedArgs ) } but it was never called."
							"Expected spy #{ @actual.identity } not to have been called with #{ jasmine.pp( expectedArgs ) } but it was."
						]
					else
						return [
							"Expected spy #{ @actual.identity } to have been called with #{ jasmine.pp( expectedArgs ) } but was called with #{ jasmine.pp( @actual.argsForCall ) }"
							"Expected spy #{ @actual.identity } not to have been called with #{ jasmine.pp( expectedArgs ) } but was called with #{ jasmine.pp( @actual.argsForCall ) }" 
						]

				mostRecentArgs =  @actual.mostRecentCall.args

				if not mostRecentArgs? or expectedArgs.length > mostRecentArgs.length
					return false 

				index = 0
				while index < expectedArgs.length
					if not @env.equals_( mostRecentArgs[ index ], expectedArgs[ index ] )
						return false
					index++

				return true
		)

		return
	)

	describe( 'Configuration', ->

		it( 'should be configurable with a reference to the view it controls', ->
			view = Ext.create( 'Ext.Container' )

			viewController = Ext.create( 'Deft.mvc.ViewController', 
				view: view
			)

			expect( viewController.getView() ).toBe( view )

			return
		)

		it( 'should be configurable at runtime with a reference to the view it controls', ->
			view = Ext.create( 'Ext.Container' )

			viewController = Ext.create( 'Deft.mvc.ViewController' )

			expect( viewController.getView() ).toBe( null )

			viewController.controlView( view )

			expect( viewController.getView() ).toBe( view )

			return
		)

		it( 'should throw an error if created and configured with a non-Ext.Container as the view', ->
			expect( ->
				Ext.create( 'Deft.mvc.ViewController',
					view: new Object()
				)
			).toThrow( new Error( "Error constructing ViewController: the configured 'view' is not an Ext.Container." ) )

			return
		)
	)

	describe( 'Creation of getters and event listeners using the \'control\' property', ->

		beforeEach( ->
			Ext.define( 'ExampleComponent',
				extend: 'Ext.Component'
				alias: 'widget.example'

				initComponent: ( config ) ->
					@addEvents(
						exampleevent: true
					)
					return @callParent( arguments )

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

				initComponent: ( config ) ->
					@addEvents(
						exampleevent: true
					)

					return @callParent( arguments )

				fireExampleEvent: ( value ) ->
					@fireEvent( 'exampleevent', @, value )
					return
			)

			Ext.DomHelper.append( Ext.getBody(), '<div id="componentTestArea" style="visibility: hidden"></div>' )

			return
		)

		afterEach( ->
			Ext.removeNode( Ext.get( 'componentTestArea' ).dom )

			return
		)

		it( 'should attach view controller scoped event listeners to events for the view', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'

				control:
					view:
						exampleevent: 'onExampleViewExampleEvent'

				onExampleViewExampleEvent: ( event ) ->
					return
			)

			spyOn( ExampleViewController.prototype, 'onExampleViewExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			expect( hasListener( view, 'exampleevent' ) ).toBe( true )
			view.fireExampleEvent( 'expected value' )
			expect( viewController.onExampleViewExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( view, 'expected value', {} )
			expect( viewController.onExampleViewExampleEvent.callCount ).toBe( 1 )

			return
		)

		it( 'should attach view controller scoped event listeners (with options) to events for the view', ->
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

			spyOn( ExampleViewController.prototype, 'onExampleViewExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			expect( hasListener( view, 'exampleevent' ) ).toBe( true )
			view.fireExampleEvent( 'expected value' )
			view.fireExampleEvent( 'unexpected value' )
			expect( viewController.onExampleViewExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( view, 'expected value', { single: true } )
			expect( viewController.onExampleViewExampleEvent.callCount ).toBe( 1 )

			return
		)

		it( 'should attach event listeners (with options) to events for the view', ->
			expectedScope = {}
			eventListenerFunction = jasmine.createSpy( 'event listener' ).andCallFake( ->
				expect( @ ).toBe( expectedScope )
			)

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
			expect( viewController.getView() ).toBe( view )

			expect( hasListener( view, 'exampleevent' ) ).toBe( true )
			view.fireExampleEvent( 'expected value' )
			view.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).toHaveMostRecentlyBeenCalledWithAtLeast( view, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 1 )

			return
		)

		it( 'should throw an error when attaching a non-existing view controller scoped event listener for the view', ->
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
			).toThrow( 'Error adding \'exampleevent\' listener: the specified handler \'onExampleViewExampleEvent\' is not a Function or does not exist.' )

			return
		)

		it( 'should create a view controller getter for a view component referenced implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'

				control:
					example: true
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).toBe( component )

			return
		)

		it( 'should throw an error when referencing a non-existent component implicitly by itemId', ->
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
			).toThrow( 'Error locating component: no component(s) found matching \'#doesntexist\'.' )

			return
		)

		it( 'should create a view controller getter for a view component referenced implicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'

				control:
					example: '#example'
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).toBe( component )

			return
		)

		it( 'should throw an error when referencing a non-existent component implicitly by selector', ->
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
			).toThrow( 'Error locating component: no component(s) found matching \'#doesntexist\'.' )

			return
		)

		it( 'should create a view controller getter for a view component referenced explicitly by selector', ->
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
			expect( viewController.getView() ).toBe( view )

			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).toBe( component )

			return
		)

		it( 'should create a view controller getter for view components referenced explicitly by selector', ->
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
			expect( viewController.getView() ).toBe( view )

			components = view.query( 'example' )
			expect( viewController.getExample() ).toEqual( components )

			return
		)

		it( 'should throw an error when referencing a non-existent component explicitly by selector', ->
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
			).toThrow( 'Error locating component: no component(s) found matching \'#doesntexist\'.' )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners to events for a view component referenced implicitly by itemId', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'

				control:
					example:
						exampleevent: 'onExampleComponentExampleEvent'

				onExampleComponentExampleEvent: ->
					return
			)

			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).toBe( component )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', {} )
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners (with options) to events for a view component referenced implicitly by itemId', ->
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

			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).toBe( component )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )

			return
		)

		it( 'should create a view controller getter and attach event listeners (with options) to events for a view component referenced implicitly by itemId', ->
			expectedScope = {}
			eventListenerFunction = jasmine.createSpy( 'event listener' ).andCallFake( ->
				expect( @ ).toBe( expectedScope )
			)

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
			expect( viewController.getView() ).toBe( view )

			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).toBe( component )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 1 )

			return
		)

		it( 'should throw an error when attaching a non-existing view controller scoped event listener for a view component referenced implicitly by itemId', ->
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
			).toThrow( 'Error adding \'exampleevent\' listener: the specified handler \'onExampleComponentExampleEvent\' is not a Function or does not exist.' )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners to events for a view component referenced by selector', ->
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

			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).toBe( component )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', {} )
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners (with options) to events for a view component referenced by selector', ->
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

			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).toBe( component )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )

			return
		)

		it( 'should create a view controller getter and attach event listeners (with options) to events for a view component referenced by selector', ->
			expectedScope = {}
			eventListenerFunction = jasmine.createSpy( 'event listener' ).andCallFake( ->
				expect( @ ).toBe( expectedScope )
			)

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
			expect( viewController.getView() ).toBe( view )

			component = view.query( '#example' )[ 0 ]
			expect( viewController.getExample() ).toBe( component )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 1 )

			return
		)

		it( 'should throw an error when attaching a non-existing view controller scoped event listener for a view component referenced implicitly by selector', ->
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
			).toThrow( 'Error adding \'exampleevent\' listener: the specified handler \'onExampleComponentExampleEvent\' is not a Function or does not exist.' )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners to events for view components referenced by selector', ->
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

			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
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
			expect( viewController.getView() ).toBe( view )

			components = view.query( 'example' )
			expect( viewController.getExample() ).toEqual( components )

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', {} )

			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 3 )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners (with options) to events for view components referenced by selector', ->
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

			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
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
			expect( viewController.getView() ).toBe( view )

			components = view.query( 'example' )
			expect( viewController.getExample() ).toEqual( components )

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )

			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 3 )

			viewController.onExampleComponentExampleEvent.reset()

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( false )
				component.fireExampleEvent( 'unexpected value' )
				expect( viewController.onExampleComponentExampleEvent ).not.toHaveBeenCalled()

			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 0 )

			return
		)

		it( 'should create a view controller getter and attach event listeners (with options) to events for view components referenced by selector', ->
			expectedScope = {}
			eventListenerFunction = jasmine.createSpy( 'event listener' ).andCallFake( ->
				expect( @ ).toBe( expectedScope )
			)

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
			expect( viewController.getView() ).toBe( view )

			components = view.query( 'example' )
			expect( viewController.getExample() ).toEqual( components )

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( eventListenerFunction ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )

			expect( eventListenerFunction.callCount ).toBe( 3 )

			eventListenerFunction.reset()

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( false )
				component.fireExampleEvent( 'unexpected value' )
				expect( eventListenerFunction ).not.toHaveBeenCalled()

			expect( eventListenerFunction.callCount ).toBe( 0 )

			return
		)

		it( 'should create a view controller getter for a dynamic view component referenced by a live selector implicitly by itemId', ->
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
			expect( viewController.getView() ).toBe( view )

			expect( viewController.getDynamicExample() ).toBe( null )

			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)

			expect( viewController.getDynamicExample() ).toBe( component )

			return
		)

		it( 'should create a view controller getter for a dynamic view component referenced explicitly by a live selector', ->
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
			expect( viewController.getView() ).toBe( view )

			expect( viewController.getDynamicExample() ).toBe( null )

			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)

			expect( viewController.getDynamicExample() ).toBe( component )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners to events for a dynamic view component referenced by a live selector implicitly by itemId', ->
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

			spyOn( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			expect( viewController.getDynamicExample() ).toBe( null )

			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			expect( viewController.getDynamicExample() ).toBe( component )

			expect( hasListener( component,'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', {} )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 1 )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners (with options) to events for a dynamic view component referenced by a live selector implicitly by itemId', ->
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

			spyOn( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			expect( viewController.getDynamicExample() ).toBe( null )

			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			expect( viewController.getDynamicExample() ).toBe( component )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 1 )

			return
		)

		it( 'should create a view controller getter and attach event listeners (with options) to events for a dynamic view component referenced by a live selector implicitly by itemId', ->
			expectedScope = {}
			eventListenerFunction = jasmine.createSpy( 'event listener' ).andCallFake( ->
				expect( @ ).toBe( expectedScope )
			)

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
			expect( viewController.getView() ).toBe( view )

			expect( viewController.getDynamicExample() ).toBe( null )

			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			expect( viewController.getDynamicExample() ).toBe( component )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 1 )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners to events for a dynamic view component referenced by a live selector', ->
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

			spyOn( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			expect( viewController.getDynamicExample() ).toBe( null )

			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			expect( viewController.getDynamicExample() ).toBe( component )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', {} )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 1 )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners (with options) to events for a dynamic view component referenced by a live selector', ->
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

			spyOn( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			expect( viewController.getDynamicExample() ).toBe( null )

			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)
			expect( viewController.getDynamicExample() ).toBe( component )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 1 )

			return
		)

		it( 'should create a view controller getter and attach event listeners (with options) to events for a dynamic view component referenced by a live selector', ->
			expectedScope = {}
			eventListenerFunction = jasmine.createSpy( 'event listener' ).andCallFake( ->
				expect( @ ).toBe( expectedScope )
			)

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
			expect( viewController.getView() ).toBe( view )

			expect( viewController.getDynamicExample() ).toBe( null )

			component = view.add(
				{
					xtype: 'example'
					itemId: 'dynamicExample'
				}
			)

			expect( viewController.getDynamicExample() ).toBe( component )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 1 )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners to events for a dynamic view components referenced by a live selector', ->
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

			spyOn( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			# Get a reference to the existing example component.
			existingComponent = view.query( 'example' )[ 0 ]
			expect( viewController.getDynamicExample() ).toBe( existingComponent )

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
			expect( viewController.getDynamicExample() ).toEqual( components )
			expect( viewController.getDynamicExample().length ).toEqual( 4 )

			# Remove one.
			view.remove( components[ 2 ] )
			components = view.query( 'example' )
			expect( viewController.getDynamicExample() ).toEqual( components )
			expect( viewController.getDynamicExample().length ).toEqual( 3 )

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', {} )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 3 )

			return
		)

		it( 'should create a view controller getter and attach view controller scoped event listeners (with options) to events for a dynamic view components referenced by a live selector', ->
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

			spyOn( ExampleViewController.prototype, 'onDynamicExampleComponentExampleEvent' ).andCallFake( ->
				expect( @ ).toBe( viewController )
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			expect( viewController.getView() ).toBe( view )

			# Get a reference to the existing example component.
			existingComponent = view.query( 'example' )[ 0 ]
			expect( viewController.getDynamicExample() ).toBe( existingComponent )

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
			expect( viewController.getDynamicExample() ).toEqual( components )
			expect( viewController.getDynamicExample().length ).toEqual( 4 )

			# Remove one.
			view.remove( components[ 2 ] )
			components = view.query( 'example' )
			expect( viewController.getDynamicExample() ).toEqual( components )
			expect( viewController.getDynamicExample().length ).toEqual( 3 )

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 3 )

			viewController.onDynamicExampleComponentExampleEvent.reset()

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( false )
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onDynamicExampleComponentExampleEvent ).not.toHaveBeenCalled()
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 0 )

			return
		)

		it( 'should create a view controller getter and attach event listeners (with options) to events for a dynamic view components referenced by a live selector', ->
			expectedScope = {}
			eventListenerFunction = jasmine.createSpy( 'event listener' ).andCallFake( ->
				expect( @ ).toBe( expectedScope )
			)

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
			expect( viewController.getView() ).toBe( view )

			# Get a reference to the existing example component.
			existingComponent = view.query( 'example' )[ 0 ]
			expect( viewController.getDynamicExample() ).toBe( existingComponent )

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
			expect( viewController.getDynamicExample() ).toEqual( components )
			expect( viewController.getDynamicExample().length ).toEqual( 4 )

			# Remove one.
			view.remove( components[ 2 ] )
			components = view.query( 'example' )
			expect( viewController.getDynamicExample() ).toEqual( components )
			expect( viewController.getDynamicExample().length ).toEqual( 3 )

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( eventListenerFunction ).toHaveMostRecentlyBeenCalledWithAtLeast( component, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 3 )

			eventListenerFunction.reset()

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( false )
				component.fireExampleEvent( 'expected value' )
				expect( eventListenerFunction ).not.toHaveBeenCalled()
			expect( eventListenerFunction.callCount ).toBe( 0 )

			return
		)
	)

	describe( 'Observer creation', ->

		it( 'should merge child observe configurations', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				observe:
					messageBus:
						parentMessage: "parentMessageHandler"
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					messageBus:
						childMessage: "childMessageHandler"
			)

			exampleInstance = Ext.create( 'ExampleSubClass' )

			expectedObserve =
				messageBus:
					childMessage: [ 'childMessageHandler' ]
					parentMessage: [ 'parentMessageHandler' ]

			expect( exampleInstance.observe ).toEqual( expectedObserve )
		)

		it( 'should merge child observe configurations when handler is a list', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				observe:
					messageBus:
						parentMessage: "parentMessageHandler"
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					messageBus:
						childMessage: "childMessageHandler1, childMessageHandler2"
			)

			exampleInstance = Ext.create( 'ExampleSubClass' )

			expectedObserve =
				messageBus:
					childMessage: [ 'childMessageHandler1', 'childMessageHandler2' ]
					parentMessage: [ 'parentMessageHandler' ]

			expect( exampleInstance.observe ).toEqual( expectedObserve )
		)

		it( 'should merge three levels of child observe configurations', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				observe:
					messageBus:
						parentMessage: "parentMessageHandler"
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					messageBus:
						childMessage: "childMessageHandler"
			)

			Ext.define( 'ExampleSubClass2',
				extend: 'ExampleSubClass'

				observe:
					messageBus:
						child2Message: "child2MessageHandler"

			)

			exampleInstance = Ext.create( 'ExampleSubClass2' )

			expectedObserve =
				messageBus:
					child2Message: [ 'child2MessageHandler' ]
					childMessage: [ 'childMessageHandler' ]
					parentMessage: [ 'parentMessageHandler' ]

			expect( exampleInstance.observe ).toEqual( expectedObserve )
		)

		it( 'should merge three levels of child observe configurations, with child observers taking precidence', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				observe:
					messageBus:
						parentMessage: "parentMessageHandler"
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					messageBus:
						childMessage: "childMessageHandler"
			)

			Ext.define( 'ExampleSubClass2',
				extend: 'ExampleSubClass'

				observe:
					messageBus:
						parentMessage: "child2MessageHandler"

			)

			exampleInstance = Ext.create( 'ExampleSubClass2' )

			expectedObserve =
				messageBus:
					parentMessage: [ 'child2MessageHandler', 'parentMessageHandler' ]
					childMessage: [ 'childMessageHandler' ]

			expect( exampleInstance.observe ).toEqual( expectedObserve )
		)

		it( 'should merge three levels of child observe configurations when middle class has no messages', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				observe:
					messageBus:
						parentMessage: "parentMessageHandler"
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'
			)

			Ext.define( 'ExampleSubClass2',
				extend: 'ExampleSubClass'

				observe:
					messageBus:
						child2Message: "child2MessageHandler"

			)

			exampleInstance = Ext.create( 'ExampleSubClass2' )

			expectedObserve =
				messageBus:
					child2Message: [ 'child2MessageHandler' ]
					parentMessage: [ 'parentMessageHandler' ]

			expect( exampleInstance.observe ).toEqual( expectedObserve )
		)

		it( 'should merge three levels of child observe configurations when parent has no messages', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					messageBus:
						childMessage: "childMessageHandler"
			)

			Ext.define( 'ExampleSubClass2',
				extend: 'ExampleSubClass'

				observe:
					messageBus:
						child2Message: "child2MessageHandler"

			)

			exampleInstance = Ext.create( 'ExampleSubClass2' )

			expectedObserve =
				messageBus:
					child2Message: [ 'child2MessageHandler' ]
					childMessage: [ 'childMessageHandler' ]

			expect( exampleInstance.observe ).toEqual( expectedObserve )
		)

		it( 'should attach listeners to observed objects in a ViewController with no subclasses', ->
			eventData = { value1: true, value2: false }

			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				config:
					messageBus: null

				observe:
					messageBus:
						myMessage: "messageHandler"

				messageHandler: ( data ) ->
					expect( data ).toEqual( eventData )
			)

			spyOn( ExampleClass.prototype, 'messageHandler' ).andCallThrough()

			messageBus = Ext.create( 'Ext.util.Observable' )

			exampleInstance = Ext.create( 'ExampleClass',
				messageBus: messageBus
			)

			waitsFor( ( -> exampleInstance.messageHandler.wasCalled ), "Message handler was not called.", 1000 )
			messageBus.fireEvent( 'myMessage', eventData )
		)

		it( 'should attach listeners to observed objects in a ViewController where the child has an observe configuration', ->

			parentEventData = { value1: true, value2: false }
			childEventData = { value2: true, value3: false }
			storeEventData = { value5: true, value6: false }

			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				config:
					messageBus: null
					store: null

				observe:
					messageBus:
						parentMessage: "parentMessageHandler"
					store:
						beforesync: "storeHandler"

				parentMessageHandler: ( data ) ->
					expect( data ).toEqual( parentEventData )

				storeHandler: ( data ) ->
					expect( data ).toEqual( storeEventData )
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					messageBus:
						childMessage: "childMessageHandler"

				childMessageHandler: ( data ) ->
					expect( data ).toEqual( childEventData )
			)

			spyOn( ExampleClass.prototype, 'parentMessageHandler' ).andCallThrough()
			spyOn( ExampleClass.prototype, 'storeHandler' ).andCallThrough()
			spyOn( ExampleSubClass.prototype, 'childMessageHandler' ).andCallThrough()

			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )

			exampleInstance = Ext.create( 'ExampleSubClass',
				messageBus: messageBus
				store: store
			)

			waitsFor( ( -> exampleInstance.parentMessageHandler.wasCalled ), "Parent message handler was not called.", 1000 )
			messageBus.fireEvent( 'parentMessage', parentEventData )

			waitsFor( ( -> exampleInstance.childMessageHandler.wasCalled ), "Child message handler was not called.", 1000 )
			messageBus.fireEvent( 'childMessage', childEventData )

			waitsFor( ( -> exampleInstance.storeHandler.wasCalled ), "Store beforesync handler was not called.", 1000 )
			store.fireEvent( 'beforesync', storeEventData )
		)

		it( 'should allow observer creation using configuration object', ->

			parentEventData = { value1: true, value2: false }
			childEventData = { value2: true, value3: false }
			storeEventData = { value5: true, value6: false }

			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				config:
					messageBus: null
					store: null

				observe:
					messageBus: [
						event: "parentMessage"
						fn: "parentMessageHandler"
						scope: @
					]
					store: [
						event: "beforesync"
						fn: "storeHandler"
						scope: @
					]

				parentMessageHandler: ( data ) ->
					expect( data ).toEqual( parentEventData )

				storeHandler: ( data ) ->
					expect( data ).toEqual( storeEventData )
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					messageBus: [
						event: "childMessage"
						fn: "childMessageHandler"
						scope: @
					]

				childMessageHandler: ( data ) ->
					expect( data ).toEqual( childEventData )
			)

			spyOn( ExampleClass.prototype, 'parentMessageHandler' ).andCallThrough()
			spyOn( ExampleClass.prototype, 'storeHandler' ).andCallThrough()
			spyOn( ExampleSubClass.prototype, 'childMessageHandler' ).andCallThrough()

			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )

			exampleInstance = Ext.create( 'ExampleSubClass',
				messageBus: messageBus
				store: store
			)

			waitsFor( ( -> exampleInstance.parentMessageHandler.wasCalled ), "Parent message handler was not called.", 1000 )
			messageBus.fireEvent( 'parentMessage', parentEventData )

			waitsFor( ( -> exampleInstance.childMessageHandler.wasCalled ), "Child message handler was not called.", 1000 )
			messageBus.fireEvent( 'childMessage', childEventData )

			waitsFor( ( -> exampleInstance.storeHandler.wasCalled ), "Store beforesync handler was not called.", 1000 )
			store.fireEvent( 'beforesync', storeEventData )
		)

		it( 'should allow observer creation using configuration object that relies on a static event name', ->

			parentEventData = { value1: true, value2: false }
			childEventData = { value2: true, value3: false }
			storeEventData = { value5: true, value6: false }

			Ext.define( 'EventConstants',
				statics:
					PARENT_EVENT: "parentMessage"
					CHILD_EVENT: "childMessage"
			)

			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				config:
					messageBus: null
					store: null

				observe:
					messageBus: [
						event: EventConstants.PARENT_EVENT
						fn: "parentMessageHandler"
					]
					store: [
						event: "beforesync"
						fn: "storeHandler"
					]

				parentMessageHandler: ( data ) ->
					expect( data ).toEqual( parentEventData )

				storeHandler: ( data ) ->
					expect( data ).toEqual( storeEventData )
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					messageBus: [
						event: EventConstants.CHILD_EVENT
						fn: "childMessageHandler"
					]

				childMessageHandler: ( data ) ->
					expect( data ).toEqual( childEventData )
			)

			spyOn( ExampleClass.prototype, 'parentMessageHandler' ).andCallThrough()
			spyOn( ExampleClass.prototype, 'storeHandler' ).andCallThrough()
			spyOn( ExampleSubClass.prototype, 'childMessageHandler' ).andCallThrough()

			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )

			exampleInstance = Ext.create( 'ExampleSubClass',
				messageBus: messageBus
				store: store
			)

			waitsFor( ( -> exampleInstance.parentMessageHandler.wasCalled ), "Parent message handler was not called.", 1000 )
			messageBus.fireEvent( EventConstants.PARENT_EVENT, parentEventData )

			waitsFor( ( -> exampleInstance.childMessageHandler.wasCalled ), "Child message handler was not called.", 1000 )
			messageBus.fireEvent( EventConstants.CHILD_EVENT, childEventData )

			waitsFor( ( -> exampleInstance.storeHandler.wasCalled ), "Store beforesync handler was not called.", 1000 )
			store.fireEvent( 'beforesync', storeEventData )
		)

		it( 'should attach listeners to observed objects using nested property declaration', ->

			parentEventData = { value1: true, value2: false }
			storeEventData = { value3: true, value4: false }
			storeReaderEventData = { value5: true, value6: false }

			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				config:
					messageBus: null
					store: null

				observe:
					messageBus:
						parentMessage: "parentMessageHandler"
					'store.proxy':
						metachange: "storeProxyHandler"

				parentMessageHandler: ( data ) ->
					expect( data ).toEqual( parentEventData )

				storeProxyHandler: ( data ) ->
					expect( data ).toEqual( storeEventData )
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					'store.proxy.reader':
						exception: "storeReaderHandler"

				storeReaderHandler: ( data ) ->
					expect( data ).toEqual( storeReaderEventData )
			)

			spyOn( ExampleClass.prototype, 'parentMessageHandler' ).andCallThrough()
			spyOn( ExampleClass.prototype, 'storeProxyHandler' ).andCallThrough()
			spyOn( ExampleSubClass.prototype, 'storeReaderHandler' ).andCallThrough()

			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )

			exampleInstance = Ext.create( 'ExampleSubClass',
				messageBus: messageBus
				store: store
			)

			waitsFor( ( -> exampleInstance.parentMessageHandler.wasCalled ), "Parent message handler was not called.", 1000 )
			messageBus.fireEvent( 'parentMessage', parentEventData )

			waitsFor( ( -> exampleInstance.storeProxyHandler.wasCalled ), "Nested store.proxy handler was not called.", 1000 )
			store.getProxy().fireEvent( 'metachange', storeEventData )

			waitsFor( ( -> exampleInstance.storeReaderHandler.wasCalled ), "Nested store.proxy.reader handler was not called.", 1000 )
			store.getProxy().getReader().fireEvent( 'exception', storeReaderEventData )
		)

		it( 'should attach listeners in child and parent to the same observed object', ->
			eventData = { value1: true, value2: false }

			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				config:
					messageBus: null
					store: null

				observe:
					messageBus:
						parentMessage: "parentMessageHandler"

				parentMessageHandler: ( data ) ->
					expect( data ).toEqual( eventData )
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					messageBus:
						parentMessage: "childMessageHandler"

				childMessageHandler: ( data ) ->
					expect( data ).toEqual( eventData )
			)

			spyOn( ExampleClass.prototype, 'parentMessageHandler' ).andCallThrough()
			spyOn( ExampleSubClass.prototype, 'childMessageHandler' ).andCallThrough()

			messageBus = Ext.create( 'Ext.util.Observable' )

			exampleInstance = Ext.create( 'ExampleSubClass',
				messageBus: messageBus
			)

			waitsFor( ( -> exampleInstance.parentMessageHandler.wasCalled and exampleInstance.childMessageHandler.wasCalled ), "Parent and child message handlers were not called.", 1000 )
			messageBus.fireEvent( 'parentMessage', eventData )
		)

		it( 'should attach listeners using config objects in child and parent to the same observed object', ->
			eventData = { value1: true, value2: false }

			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				config:
					messageBus: null
					store: null

				observe:
					messageBus: [
						event: "parentMessage"
						fn: "parentMessageHandler"
					]

				parentMessageHandler: ( data ) ->
					expect( data ).toEqual( eventData )
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					messageBus: [
						event: "parentMessage"
						fn: "childMessageHandler"
					]

				childMessageHandler: ( data ) ->
					expect( data ).toEqual( eventData )
			)

			spyOn( ExampleClass.prototype, 'parentMessageHandler' ).andCallThrough()
			spyOn( ExampleSubClass.prototype, 'childMessageHandler' ).andCallThrough()

			messageBus = Ext.create( 'Ext.util.Observable' )

			exampleInstance = Ext.create( 'ExampleSubClass',
				messageBus: messageBus
			)

			waitsFor( ( -> exampleInstance.parentMessageHandler.wasCalled and exampleInstance.childMessageHandler.wasCalled ), "Parent and child message handlers were not called.", 1000 )
			messageBus.fireEvent( 'parentMessage', eventData )
		)

		it( 'should create observers using a mix of nested properties, config objects, and standard event/handler pairs', ->

			parentEventData = { value1: true, value2: false }
			childEventData = { valueA: true, valueB: false }
			childEventData2 = { valueC: true, valueD: false }
			storeEventData = { value3: true, value4: false }
			storeReaderEventData = { value5: true, value6: false }

			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				config:
					messageBus: null
					store: null

				observe:
					messageBus:
						parentMessage: "parentMessageHandler"
					'store.proxy': [
						event: "metachange"
						fn: "storeProxyHandler"
					]

				parentMessageHandler: ( data ) ->
					expect( data ).toEqual( parentEventData )

				storeProxyHandler: ( data ) ->
					expect( data ).toEqual( storeEventData )
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				observe:
					'store.proxy.reader': [
						event: "exception"
						fn: "storeReaderHandler"
					]
					messageBus: [
						event: "parentMessage"
						fn: "childMessageHandlerForParentEvent"
					,
						event: "childMessage"
						fn: "childMessageHandler"
					,
						childMessage2: "childMessageHandler2"
					]

				childMessageHandlerForParentEvent: ( data ) ->
					expect( data ).toEqual( parentEventData )

				childMessageHandler: ( data ) ->
					expect( data ).toEqual( childEventData )

				childMessageHandler2: ( data ) ->
					expect( data ).toEqual( childEventData2 )

				storeReaderHandler: ( data ) ->
					expect( data ).toEqual( storeReaderEventData )
			)

			spyOn( ExampleClass.prototype, 'parentMessageHandler' ).andCallThrough()
			spyOn( ExampleClass.prototype, 'storeProxyHandler' ).andCallThrough()
			spyOn( ExampleSubClass.prototype, 'storeReaderHandler' ).andCallThrough()
			spyOn( ExampleSubClass.prototype, 'childMessageHandlerForParentEvent' ).andCallThrough()
			spyOn( ExampleSubClass.prototype, 'childMessageHandler' ).andCallThrough()
			spyOn( ExampleSubClass.prototype, 'childMessageHandler2' ).andCallThrough()

			messageBus = Ext.create( 'Ext.util.Observable' )
			store = Ext.create( 'Ext.data.ArrayStore' )

			exampleInstance = Ext.create( 'ExampleSubClass',
				messageBus: messageBus
				store: store
			)

			waitsFor( ( -> exampleInstance.parentMessageHandler.wasCalled and exampleInstance.childMessageHandlerForParentEvent.wasCalled ), "Parent and child message handlers were not called.", 1000 )
			messageBus.fireEvent( 'parentMessage', parentEventData )

			waitsFor( ( -> exampleInstance.childMessageHandler.wasCalled ), "Child-only message handler was not called.", 1000 )
			messageBus.fireEvent( 'childMessage', childEventData )

			waitsFor( ( -> exampleInstance.childMessageHandler2.wasCalled ), "Second child-only message handler was not called.", 1000 )
			messageBus.fireEvent( 'childMessage2', childEventData2 )

			waitsFor( ( -> exampleInstance.storeProxyHandler.wasCalled ), "Nested store.proxy handler was not called.", 1000 )
			store.getProxy().fireEvent( 'metachange', storeEventData )

			waitsFor( ( -> exampleInstance.storeReaderHandler.wasCalled ), "Nested store.proxy.reader handler was not called.", 1000 )
			store.getProxy().getReader().fireEvent( 'exception', storeReaderEventData )
		)
	)

	describe( 'Destruction and clean-up', ->

		beforeEach( ->
			Ext.define( 'ExampleComponent',
				extend: 'Ext.Component'
				alias: 'widget.example'

				initComponent: ( config ) ->
					@addEvents(
						exampleevent: true
					)
					return @callParent( arguments )
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

				initComponent: ( config ) ->
					@addEvents(
						exampleevent: true
					)

					return @callParent( arguments )
			)

			Ext.DomHelper.append( Ext.getBody(), '<div id="componentTestArea" style="visibility: hidden"></div>' )

			return
		)

		afterEach( ->
			Ext.removeNode( Ext.get( 'componentTestArea' ).dom )

			return
		)

		it( 'should be called to destroy() when the associated view is destroyed', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)

			spyOn( viewController, 'destroy' ).andCallThrough()

			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()

			expect( viewController.destroy ).toHaveBeenCalled()
			expect( isViewDestroyed ).toBe( true )

			return
		)

		it( 'should cancel view destruction if the view controller\'s destroy() returns false', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'

				destroy: ->
					return false
			)

			view = Ext.create( 'ExampleView' )

			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)

			spyOn( viewController, 'destroy' ).andCallThrough()

			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()

			expect( viewController.destroy ).toHaveBeenCalled()
			expect( isViewDestroyed ).toBe( false )

			return
		)

		it( 'should remove event listeners it attached to the view when the associated view (and view controller) is destroyed', ->
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

			expect( hasListener( view, 'exampleevent' ) ).toBe( true )

			spyOn( viewController, 'destroy' ).andCallThrough()

			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()

			expect( viewController.destroy ).toHaveBeenCalled()
			expect( isViewDestroyed ).toBe( true )

			expect( hasListener( view, 'exampleevent' ) ).toBe( false )

			return
		)

		it( 'should remove event listeners it attached to a view component referenced implicitly by itemId when the associated view (and view controller) is destroyed', ->
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

			expect( viewController.getExample ).not.toBe( null )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )

			spyOn( viewController, 'destroy' ).andCallThrough()

			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()

			expect( viewController.destroy ).toHaveBeenCalled()
			expect( viewController.getExample ).toBe( null )
			expect( isViewDestroyed ).toBe( true )

			expect( hasListener( component, 'exampleevent' ) ).toBe( false )

			return
		)

		it( 'should remove event listeners it attached to view components referenced explicitly by a selector when the associated view (and view controller) is destroyed', ->
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

			expect( viewController.getExample ).not.toBe( null )

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( true )

			spyOn( viewController, 'destroy' ).andCallThrough()

			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()

			expect( viewController.destroy ).toHaveBeenCalled()
			expect( viewController.getExample ).toBe( null )
			expect( isViewDestroyed ).toBe( true )

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( false )

			return
		)

		it( 'should remove event listeners it attached to a dynamic view component referenced by a live selector implicitly by itemId when the associated view (and view controller) is destroyed', ->
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

			expect( viewController.getDynamicExample ).not.toBe( null )

			expect( hasListener( component, 'exampleevent' ) ).toBe( true )

			spyOn( viewController, 'destroy' ).andCallThrough()

			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()

			expect( viewController.destroy ).toHaveBeenCalled()
			expect( viewController.getDynamicExample ).toBe( null )
			expect( isViewDestroyed ).toBe( true )

			expect( hasListener( component, 'exampleevent' ) ).toBe( false )

			return
		)

		it( 'should remove event listeners it attached to dynamic view components referenced explicitly by a live selector when the associated view (and view controller) is destroyed', ->
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

			expect( viewController.getDynamicExample ).not.toBe( null )
			expect( viewController.getDynamicExample() ).toEqual( components )
			expect( viewController.getDynamicExample().length ).toEqual( 4 )

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( true )

			spyOn( viewController, 'destroy' ).andCallThrough()

			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()

			expect( viewController.destroy ).toHaveBeenCalled()
			expect( viewController.getDynamicExample ).toBe( null )
			expect( isViewDestroyed ).toBe( true )

			for component in components
				expect( hasListener( component, 'exampleevent' ) ).toBe( false )

			return
		)

		it( 'should remove listeners from observed objects when the view controller is destroyed', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				config:
					store: null
					store2: null

				observe:
					store:
						beforesync: "genericHandler"
					'store.proxy':
						customevent: "genericHandler"
					store2:
						beforeload: "genericHandler"

				genericHandler: -> return
			)

			view = Ext.create( 'ExampleView' )
			store = Ext.create( 'Ext.data.ArrayStore' )
			store2 = Ext.create( 'Ext.data.ArrayStore' )

			expect( store.hasListener( 'beforesync' ) ).toBeFalsy()
			expect( store.getProxy().hasListener( 'customevent' ) ).toBeFalsy()
			expect( store2.hasListener( 'beforeload' ) ).toBeFalsy()

			viewController = Ext.create( 'ExampleClass',
				view: view
				store: store
				store2: store2
			)

			expect( store.hasListener( 'beforesync' ) ).toBeTruthy()
			expect( store.getProxy().hasListener( 'customevent' )).toBeTruthy()
			expect( store2.hasListener( 'beforeload' ) ).toBeTruthy()

			spyOn( viewController, 'removeObservers' ).andCallThrough()
			waitsFor( ( -> viewController.removeObservers.wasCalled ), "Observe listeners were not removed by view controller.", 1000 )

			view.destroy()

			runs( ->
				expect( store.hasListener( 'beforesync' ) ).toBeFalsy()
				expect( store.getProxy().hasListener( 'customevent' )).toBeFalsy()
				expect( store2.hasListener( 'beforeload' ) ).toBeFalsy()
			)

		)
	)

	return
)