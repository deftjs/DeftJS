###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.mvc.ViewController
###
describe( 'Deft.mvc.ViewController', ->
	
	describe( 'Configuration', ->
		
		it( 'should be configurable with a reference to the view it controls', ->
			view = Ext.create( 'Ext.Container' )
		
			viewController = Ext.create( 'Deft.mvc.ViewController', 
				view: view
			)
		
			expect( viewController.getView() ).toBe( view )
		)
		
		it( 'should be configurable at runtime with a reference to the view it controls', ->
			view = Ext.create( 'Ext.Container' )
		
			viewController = Ext.create( 'Deft.mvc.ViewController' )
			
			expect( viewController.getView() ).toBe( null )
			
			viewController.controlView( view )
			
			expect( viewController.getView() ).toBe( view )
		)
		
		it( 'should throw an error if created and configured with a non-Ext.Container as the view', ->
			expect( ->
				Ext.create( 'Deft.mvc.ViewController',
					view: new Object()
				)
			).toThrow( new Error( "Error constructing ViewController: the configured 'view' is not an Ext.Container." ) )
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
		)
		
		afterEach( ->
			Ext.removeNode( Ext.get( 'componentTestArea' ).dom )
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
			
			expect( view.hasListener( 'exampleevent' ) ).toBe( true )
			view.fireExampleEvent( 'expected value' )
			expect( viewController.onExampleViewExampleEvent ).toHaveBeenCalledWith( view, 'expected value', {} )
			expect( viewController.onExampleViewExampleEvent.callCount ).toBe( 1 )
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
			
			expect( view.hasListener( 'exampleevent' ) ).toBe( true )
			view.fireExampleEvent( 'expected value' )
			view.fireExampleEvent( 'unexpected value' )
			expect( viewController.onExampleViewExampleEvent ).toHaveBeenCalledWith( view, 'expected value', { single: true } )
			expect( viewController.onExampleViewExampleEvent.callCount ).toBe( 1 )
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
			
			expect( view.hasListener( 'exampleevent' ) ).toBe( true )
			view.fireExampleEvent( 'expected value' )
			view.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).toHaveBeenCalledWith( view, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 1 )
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', {} )
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )
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

			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 1 )
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

			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', {} )
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 1 )
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
				expect( component.hasListener( 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', {} )
			
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 3 )
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
				expect( component.hasListener( 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 3 )
			
			viewController.onExampleComponentExampleEvent.reset()
			
			for component in components
				expect( component.hasListener( 'exampleevent' ) ).toBe( false )
				component.fireExampleEvent( 'unexpected value' )
				expect( viewController.onExampleComponentExampleEvent ).not.toHaveBeenCalled()
			
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 0 )
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
				expect( component.hasListener( 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( eventListenerFunction ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			
			expect( eventListenerFunction.callCount ).toBe( 3 )
			
			eventListenerFunction.reset()
			
			for component in components
				expect( component.hasListener( 'exampleevent' ) ).toBe( false )
				component.fireExampleEvent( 'unexpected value' )
				expect( eventListenerFunction ).not.toHaveBeenCalled()
			
			expect( eventListenerFunction.callCount ).toBe( 0 )
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', {} )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 1 )
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 1 )
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 1 )
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', {} )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 1 )
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 1 )
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'unexpected value' )
			expect( eventListenerFunction ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 1 )
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
				{
					xtype: 'example'
				}
				{
					xtype: 'example'
				}
				{
					xtype: 'example'
				}
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
				expect( component.hasListener( 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', {} )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 3 )
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
				{
					xtype: 'example'
				}
				{
					xtype: 'example'
				}
				{
					xtype: 'example'
				}
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
				expect( component.hasListener( 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onDynamicExampleComponentExampleEvent ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 3 )
			
			viewController.onDynamicExampleComponentExampleEvent.reset()
			
			for component in components
				expect( component.hasListener( 'exampleevent' ) ).toBe( false )
				component.fireExampleEvent( 'expected value' )
				expect( viewController.onDynamicExampleComponentExampleEvent ).not.toHaveBeenCalled()
			expect( viewController.onDynamicExampleComponentExampleEvent.callCount ).toBe( 0 )
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
				{
					xtype: 'example'
				}
				{
					xtype: 'example'
				}
				{
					xtype: 'example'
				}
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
				expect( component.hasListener( 'exampleevent' ) ).toBe( true )
				component.fireExampleEvent( 'expected value' )
				expect( eventListenerFunction ).toHaveBeenCalledWith( component, 'expected value', { single: true } )
			expect( eventListenerFunction.callCount ).toBe( 3 )
			
			eventListenerFunction.reset()
			
			for component in components
				expect( component.hasListener( 'exampleevent' ) ).toBe( false )
				component.fireExampleEvent( 'expected value' )
				expect( eventListenerFunction ).not.toHaveBeenCalled()
			expect( eventListenerFunction.callCount ).toBe( 0 )
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
		)
		
		afterEach( ->
			Ext.removeNode( Ext.get( 'componentTestArea' ).dom )
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
			
			expect( view.hasListener( 'exampleevent' ) ).toBe( true )
			
			spyOn( viewController, 'destroy' ).andCallThrough()
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).toHaveBeenCalled()
			expect( isViewDestroyed ).toBe( true )
			
			expect( view.hasListener( 'exampleevent' ) ).toBe( false )
		)
		
		it( 'should remove event listeners it attached to a view component referenced implicitly by item id when the associated view (and view controller) is destroyed', ->
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			spyOn( viewController, 'destroy' ).andCallThrough()
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).toHaveBeenCalled()
			expect( isViewDestroyed ).toBe( true )
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( false )
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
			
			for component in components
				expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			spyOn( viewController, 'destroy' ).andCallThrough()
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).toHaveBeenCalled()
			expect( isViewDestroyed ).toBe( true )
			
			for component in components
				expect( component.hasListener( 'exampleevent' ) ).toBe( false )
		)
		
		it( 'should remove event listeners it attached to a dynamic view component referenced by a live selector implicitly by item id when the associated view (and view controller) is destroyed', ->
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
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			spyOn( viewController, 'destroy' ).andCallThrough()
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).toHaveBeenCalled()
			expect( isViewDestroyed ).toBe( true )
			
			expect( component.hasListener( 'exampleevent' ) ).toBe( false )
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
				{
					xtype: 'example'
				}
				{
					xtype: 'example'
				}
				{
					xtype: 'example'
				}
			)
			components = view.query( 'example' )
			expect( viewController.getDynamicExample() ).toEqual( components )
			expect( viewController.getDynamicExample().length ).toEqual( 4 )
			
			for component in components
				expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			spyOn( viewController, 'destroy' ).andCallThrough()
			
			isViewDestroyed = false
			view.on( 'destroy', -> isViewDestroyed = true )
			view.destroy()
			
			expect( viewController.destroy ).toHaveBeenCalled()
			expect( isViewDestroyed ).toBe( true )
			
			for component in components
				expect( component.hasListener( 'exampleevent' ) ).toBe( false )
		)
	)
	
	return
)