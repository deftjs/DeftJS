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
		
		it( 'should throw an error if created and configured with a non-Ext.Component as the view', ->
			expect( ->
				Ext.create( 'Deft.mvc.ViewController',
					view: new Object()
				)
			).toThrow( new Error( "Error constructing ViewController: the configured 'view' is not an Ext.Component." ) )
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
					@fireEvent( 'exampleevent', value )
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
					@fireEvent( 'exampleevent', value )
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
			
			spyOn( ExampleViewController.prototype, 'onExampleViewExampleEvent' ).andCallFake( ( value ) ->
				expect( @ ).toBe( viewController )
				expect( value ).toBe( 'expected value' )
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			expect( viewController.getView() ).toBe( view )
			expect( view.hasListener( 'exampleevent' ) ).toBe( true )
			
			view.fireExampleEvent( 'expected value' )
			
			expect( viewController.onExampleViewExampleEvent ).toHaveBeenCalled()
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
			
			spyOn( ExampleViewController.prototype, 'onExampleViewExampleEvent' ).andCallFake( ( value ) ->
				expect( @ ).toBe( viewController )
				expect( value ).toBe( 'expected value' )
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			expect( viewController.getView() ).toBe( view )
			expect( view.hasListener( 'exampleevent' ) ).toBe( true )
			
			view.fireExampleEvent( 'expected value' )
			view.fireExampleEvent( 'expected value' )
			
			expect( viewController.onExampleViewExampleEvent ).toHaveBeenCalled()
			expect( viewController.onExampleViewExampleEvent.callCount ).toBe( 1 )
		)
		
		it( 'should attach event listeners (with options) to events for the view', ->
			expectedScope = {}
			eventListenerFunction = jasmine.createSpy( 'event listener' ).andCallFake( ( value ) ->
				expect( @ ).toBe( expectedScope )
				expect( value ).toBe( 'expected value' )
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
			view.fireExampleEvent( 'expected value' )
			
			expect( eventListenerFunction ).toHaveBeenCalled()
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
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
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
			).toThrow( 'Error locating component: no component found with an itemId of \'doesntexist\'.' )
		)
		
		it( 'should create a view controller getter for a view component referenced implicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: "#example"
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
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
			).toThrow( 'Error locating component: no component found matching \'#doesntexist\'.' )
		)
		
		it( 'should create a view controller getter for a view component referenced explicitly by selector', ->
			Ext.define( 'ExampleViewController',
				extend: 'Deft.mvc.ViewController'
				
				control:
					example: 
						selector: "#example"
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
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
			).toThrow( 'Error locating component: no component found matching \'#doesntexist\'.' )
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
			
			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ( value ) ->
				expect( @ ).toBe( viewController )
				expect( value ).toBe( 'expected value' )
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			component.fireExampleEvent( 'expected value' )
			
			expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalled()
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
			
			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ( value ) ->
				expect( @ ).toBe( viewController )
				expect( value ).toBe( 'expected value' )
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'expected value' )
			
			expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalled()
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )
		)
		
		it( 'should create a view controller getter and attach event listeners (with options) to events for a view component referenced implicitly by itemId', ->
			expectedScope = {}
			eventListenerFunction = jasmine.createSpy( 'event listener' ).andCallFake( ( value ) ->
				expect( @ ).toBe( expectedScope )
				expect( value ).toBe( 'expected value' )
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
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'expected value' )
			
			expect( eventListenerFunction ).toHaveBeenCalled()
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
			
			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ( value ) ->
				expect( @ ).toBe( viewController )
				expect( value ).toBe( 'expected value' )
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			component.fireExampleEvent( 'expected value' )
			
			expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalled()
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
			
			spyOn( ExampleViewController.prototype, 'onExampleComponentExampleEvent' ).andCallFake( ( value ) ->
				expect( @ ).toBe( viewController )
				expect( value ).toBe( 'expected value' )
			)
			
			view = Ext.create( 'ExampleView' )
			
			viewController = Ext.create( 'ExampleViewController', 
				view: view
			)
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'expected value' )
			
			expect( viewController.onExampleComponentExampleEvent ).toHaveBeenCalled()
			expect( viewController.onExampleComponentExampleEvent.callCount ).toBe( 1 )
		)
		
		it( 'should create a view controller getter and attach event listeners (with options) to events for a view component referenced by selector', ->
			expectedScope = {}
			eventListenerFunction = jasmine.createSpy( 'event listener' ).andCallFake( ( value ) ->
				expect( @ ).toBe( expectedScope )
				expect( value ).toBe( 'expected value' )
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
			
			component = view.query( '#example' )[ 0 ]
			
			expect( viewController.getView() ).toBe( view )
			expect( viewController.getExample() ).toBe( component )
			expect( component.hasListener( 'exampleevent' ) ).toBe( true )
			
			component.fireExampleEvent( 'expected value' )
			component.fireExampleEvent( 'expected value' )
			
			expect( eventListenerFunction ).toHaveBeenCalled()
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
	)

	describe( 'Message handling via global message bus', ->

		it( 'should merge child message configurations', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				messages:
					parentMessage: "parentMessageHandler"
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				messages:
					childMessage: "childMessageHandler"
			)

			exampleInstance = Ext.create( 'ExampleSubClass' )
			expect( exampleInstance.messages ).toEqual( { childMessage: "childMessageHandler", parentMessage: "parentMessageHandler" } )
		)

		it( 'should merge three levels of child message configurations', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				messages:
					parentMessage: "parentMessageHandler"
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				messages:
					childMessage: "childMessageHandler"
			)

			Ext.define( 'ExampleSubClass2',
				extend: 'ExampleSubClass'

				messages:
					child2Message: "child2MessageHandler"

			)

			exampleInstance = Ext.create( 'ExampleSubClass2' )
			expect( exampleInstance.messages ).toEqual( { child2Message: "child2MessageHandler", childMessage: "childMessageHandler", parentMessage: "parentMessageHandler" } )
		)

		it( 'should merge three levels of child message configurations when middle class has no messages', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				messages:
					parentMessage: "parentMessageHandler"
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'
			)

			Ext.define( 'ExampleSubClass2',
				extend: 'ExampleSubClass'

				messages:
					child2Message: "child2MessageHandler"

			)

			exampleInstance = Ext.create( 'ExampleSubClass2' )
			expect( exampleInstance.messages ).toEqual( { child2Message: "child2MessageHandler", parentMessage: "parentMessageHandler" } )
		)

		it( 'should merge three levels of child message configurations when parent has no messages', ->
			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				messages:
					childMessage: "childMessageHandler"
			)

			Ext.define( 'ExampleSubClass2',
				extend: 'ExampleSubClass'

				messages:
					child2Message: "child2MessageHandler"

			)

			exampleInstance = Ext.create( 'ExampleSubClass2' )
			expect( exampleInstance.messages ).toEqual( { child2Message: "child2MessageHandler", childMessage: "childMessageHandler" } )
		)

		it( 'should attach message listeners to global message bus', ->
			messageBus = Deft.ioc.Injector.resolve( 'messageBus' )
			messageBus.clearListeners()

			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				messages:
					parentMessage: "parentMessageHandler"

				parentMessageHandlerCalled: false

				parentMessageHandler: ( eventData ) ->
					@parentMessageHandlerCalled = eventData
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				messages:
					childMessage: "childMessageHandler"

				childMessageHandlerCalled: false

				childMessageHandler: ( eventData ) ->
					@childMessageHandlerCalled = eventData
			)

			exampleInstance = Ext.create( 'ExampleSubClass' )
			expect( messageBus.hasListener( 'parentMessage' ) ).toBeTruthy()
			expect( messageBus.hasListener( 'childMessage' ) ).toBeTruthy()

			# Cannot just spy on the handler methods because messageBus listener will always reference the original method, not the spy.
			waitsFor( ( -> exampleInstance.parentMessageHandlerCalled ), "Parent message handler was not called.", 1000 )

			parentEventData =
				value1: true
				value2: false
			messageBus.fireEvent( 'parentMessage', parentEventData )

			runs( ->
				expect( exampleInstance.parentMessageHandlerCalled ).toEqual( parentEventData )
			)

			waitsFor( ( -> exampleInstance.childMessageHandlerCalled ), "Child message handler was not called.", 1000 )

			messageBus.fireEvent( 'childMessage', 'childMessageEventData' )

			runs( ->
				expect( exampleInstance.childMessageHandlerCalled ).toEqual( 'childMessageEventData' )
				messageBus.clearListeners()
			)
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
		
		it( 'should remove event listeners it attached to view components when the associated view (and view controller) is destroyed', ->
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

		it( 'should remove message listeners from the global message bus when the view controller is destroyed', ->
			messageBus = Deft.ioc.Injector.resolve( 'messageBus' )
			messageBus.clearListeners()

			# For some reason, clearListeners() DOES remove all listeners, but does NOT appear to make
			# hasListener( 'listenerName' ) return false? Bug in Observable?
			# So we dig into the listeners array for the event and check its length.
			getMessageBusListenerLength = ( listenerName ) ->
				messageBus.events?[ listenerName ].listeners.length

			expect( getMessageBusListenerLength( 'childmessage' ) ).toBe( 0 )
			expect( getMessageBusListenerLength( 'parentmessage' ) ).toBe( 0 )

			Ext.define( 'ExampleClass',
				extend: 'Deft.mvc.ViewController'

				messages:
					parentMessage: "parentMessageHandler"

				parentMessageHandler: ->
					return
			)

			Ext.define( 'ExampleSubClass',
				extend: 'ExampleClass'

				messages:
					childMessage: "childMessageHandler"

				childMessageHandler: ->
					return
			)

			view = Ext.create( 'ExampleView' )
			viewController = Ext.create( 'ExampleSubClass',
				view: view
			)

			expect( getMessageBusListenerLength( 'childmessage' ) ).toBe( 1 )
			expect( getMessageBusListenerLength( 'parentmessage' ) ).toBe( 1 )

			spyOn( viewController, 'removeMessageHandlers' ).andCallThrough()
			waitsFor( ( -> viewController.removeMessageHandlers.wasCalled ), "Messages were not removed by view controller.", 1000 )

			view.destroy()

			runs( ->
				expect( getMessageBusListenerLength( 'childmessage' ) ).toBe( 0 )
				expect( getMessageBusListenerLength( 'parentmessage' ) ).toBe( 0 )
			)

		)

	)
	
	return
)