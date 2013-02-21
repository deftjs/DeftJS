###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
A lightweight MVC view controller. Full usage instructions in the [DeftJS documentation](https://github.com/deftjs/DeftJS/wiki/ViewController).

First, specify a ViewController to attach to a view:

		Ext.define("DeftQuickStart.view.MyTabPanel", {
			extend: "Ext.tab.Panel",
			controller: "DeftQuickStart.controller.MainController",
			...
		});

Next, define the ViewController:

		Ext.define("DeftQuickStart.controller.MainController", {
			extend: "Deft.mvc.ViewController",

			init: function() {
				return this.callParent(arguments);
			}

		});

## Inject dependencies using the <u>[`inject` property](https://github.com/deftjs/DeftJS/wiki/Injecting-Dependencies)</u>:

		Ext.define("DeftQuickStart.controller.MainController", {
			extend: "Deft.mvc.ViewController",
			inject: ["companyStore"],

			config: {
				companyStore: null
			},

			init: function() {
				return this.callParent(arguments);
			}

		});

## Define <u>[references to view components](https://github.com/deftjs/DeftJS/wiki/Accessing-Views)</u> and <u>[add view listeners](https://github.com/deftjs/DeftJS/wiki/Handling-View-Events)</u> with the `control` property:

		Ext.define("DeftQuickStart.controller.MainController", {
			extend: "Deft.mvc.ViewController",

			control: {

				// Most common configuration, using an itemId and listener
				manufacturingFilter: {
					change: "onFilterChange"
				},

				// Reference only, with no listeners
				serviceIndustryFilter: true,

				// Configuration using selector, listeners, and event listener options
				salesFilter: {
					selector: "toolbar > checkbox",
					listeners: {
						change: {
							fn: "onFilterChange",
							buffer: 50,
							single: true
						}
					}
				}
			},

			init: function() {
				return this.callParent(arguments);
			}

			// Event handlers or other methods here...

		});

## Dynamically monitor view to attach listeners to added components with <u>[live selectors](https://github.com/deftjs/DeftJS/wiki/ViewController-Live-Selectors)</u>:

		control: {
			manufacturingFilter: {
				live: true,
				listeners: {
					change: "onFilterChange"
				}
			}
		};

## Observe events on injected objects with the <u>[`observe` property](https://github.com/deftjs/DeftJS/wiki/ViewController-Observe-Configuration)</u>:

		Ext.define("DeftQuickStart.controller.MainController", {
			extend: "Deft.mvc.ViewController",
			inject: ["companyStore"],

			config: {
				companyStore: null
			},

			observe: {
				// Observe companyStore for the update event
				companyStore: {
					update: "onCompanyStoreUpdateEvent"
				}
			},

			init: function() {
				return this.callParent(arguments);
			},

			onCompanyStoreUpdateEvent: function(store, model, operation, fieldNames) {
				// Do something when store fires update event
			}

		});

###
Ext.define( 'Deft.mvc.ViewController',
	alternateClassName: [ 'Deft.ViewController' ]
	requires: [
		'Deft.core.Class'
		'Deft.log.Logger'
		'Deft.mvc.ComponentSelector'
		'Deft.mvc.Observer'
	]
	
	config:
		###*
		* View controlled by this ViewController.
		###
		view: null
	
	###*
	* Observers automatically created and removed by this ViewController.
	###
	observe: {}

	###*
	* Controls automatically created and removed by this ViewController.
	###
	control: {}
	
	###*
	* @private
	###
	$control: do() ->
		if Ext.getVersion( 'extjs' )
			config =
				view :
					beforedestroy :
						fn: "onViewBeforeDestroy"
					afterrender:
						single: true
						fn: "onViewInitialize"
		else
			config =
				view:
					intiialize:
						single: true,
						fn: "onViewInitialize"
	
	
	constructor: ( config = {} ) ->
		@initConfig( config ) # Ensure any config values are set before creating observers.
		if config.view
			@controlView( config.view )
		if Ext.Object.getSize( @observe ) > 0 then @createObservers()
		return @
	
	###*
	* @protected
	###
	controlView: ( view ) ->
		if view instanceof Ext.ClassManager.get( 'Ext.Component' )
			@setView( view )
			@registeredComponentReferences = {}
			@registeredComponentSelectors = {}
			@initializeView()
		else
			Ext.Error.raise( msg: 'Error constructing ViewController: the configured \'view\' is not an Ext.Component.' )
		return

	###*
	* Initialize the ViewController
	###
	init: ->
		return
	
	###*
	* Destroy the ViewController
	###
	destroy: ->
		@cleanupDefaultViewListeners()
		for id of @registeredComponentReferences
			@removeComponentReference( id )
		for selector of @registeredComponentSelectors
			@removeComponentSelector( selector )
		@removeObservers()
		return true
	
	###*
	* @private
	###
	setupDefaultViewListeners : ->
		componentSelector = Ext.create( 'Deft.mvc.ComponentSelector',
			view: @getView()
			selector: null
			listeners: @$control.view
			scope: @
			live: true
		)
		@registeredComponentSelectors[ '$default' ] = componentSelector
		
		if not @control.view
			@control.view = {}
		return
					
	###*
	* @private
	###
	cleanupDefaultViewListeners : ->
		@registeredComponentSelectors[ '$default' ].destroy()
		delete @registeredComponentSelectors[ '$default' ]
		return
	
	###*
	* @private
	###
	onViewInitialize: ->
		@init()
		if Ext.Object.getSize( @observe ) > 0 then @createViewObservers()
		return
			
	###*
	* @private
	###
	initializeView: ->
		rendered = @getView().rendered or @getView().initialized
		
		@setupDefaultViewListeners()
		
		for id, config of @control
			selector = null
			if id isnt 'view'
				if Ext.isString( config )
					selector = config
				else if config.selector?
					selector = config.selector
				else
					selector = '#' + id
			listeners = null
			if Ext.isObject( config.listeners )
				listeners = config.listeners
			else
			#TODO: config.live remains for backward compatibility
				listeners = config unless config.selector? or config.live?
				
			@addComponentReference( id, selector )
			@addComponentSelector( selector, listeners )
			
			if rendered is true
				getterName = 'get' + Ext.String.capitalize( id )
				elements = @[ getterName ]()
				if ! Ext.isArray( elements )
					elements = [ elements ]

				for element in elements
					if element isnt null
						Deft.LiveEventBus.register( element, selector )
		
		if Ext.getVersion( 'extjs' )?
			# Ext JS
			if @getView().rendered
				@onViewInitialize()
		else
			# Sencha Touch
			self = this
			originalViewDestroyFunction = @getView().destroy
			@getView().destroy = ->
				if self.destroy()
					originalViewDestroyFunction.call( @ )
				return
			if @getView().initialized
				@onViewInitialize()
		
		return
	
	###*
	* @private
	###
	onViewBeforeDestroy: ->
		return @destroy()
	
	###*
	* Add a component accessor method the ViewController for the specified view-relative selector.
	###
	addComponentReference: ( id, selector ) ->
		if @registeredComponentReferences[ id ]?
			Ext.Error.raise( msg: "Error adding component reference: an existing component reference was already registered as '#{ id }'." )
		
		# Add generated getter function.
		if id isnt 'view'
			getterName = 'get' + Ext.String.capitalize( id )
			unless @[ getterName ]?
				Deft.Logger.log( "Adding '#{ id }' component reference for selector: '#{ selector }'." )
				@[ getterName ] = Ext.Function.pass( @getViewComponent, [ selector ], @ )
				@[ getterName ].generated = true
				@registeredComponentReferences[ id ] = true

		return
	
	###*
	* Remove a component accessor method the ViewController for the specified view-relative selector.
	###
	removeComponentReference: ( id ) ->
		Deft.Logger.log( "Removing '#{ id }' component reference." )
		
		unless @registeredComponentReferences[ id ]?
			Ext.Error.raise( msg: "Error removing component reference: no component reference is registered as '#{ id }'." )
		
		# Remove generated getter function.
		if id isnt 'view'
			getterName = 'get' + Ext.String.capitalize( id )
			if @[ getterName ].generated
				@[ getterName ] = null
		
		delete @registeredComponentReferences[ id ]
		
		return
	
	###*
	* Get the component(s) corresponding to the specified view-relative selector.
	###
	getViewComponent: ( selector ) ->
		if selector?
			matches = Ext.ComponentQuery.query( selector, @getView() )
			if matches.length is 0
				return null
			else if matches.length is 1
				return matches[ 0 ]
			else
				return matches
		else
			return @getView()
	
	###*
	* Add a component selector with the specified listeners for the specified view-relative selector.
	###
	addComponentSelector: ( selector, listeners ) ->
		Deft.Logger.log( "Adding component selector for: '#{ selector or 'view' }'." )
		
		existingComponentSelector = @getComponentSelector( selector )
		if existingComponentSelector?
			Ext.Error.raise( msg: "Error adding component selector: an existing component selector was already registered for '#{ selector }'." )
		
		componentSelector = Ext.create( 'Deft.mvc.ComponentSelector',
			view: @getView()
			selector: selector
			listeners: listeners
			scope: @
			live: true
		)
		@registeredComponentSelectors[ selector ] = componentSelector
		
		return
	
	###*
	* Remove a component selector with the specified listeners for the specified view-relative selector.
	###
	removeComponentSelector: ( selector ) ->
		Deft.Logger.log( "Removing component selector for '#{ selector }'." )
		
		existingComponentSelector = @getComponentSelector( selector )
		unless existingComponentSelector?
			Ext.Error.raise( msg: "Error removing component selector: no component selector registered for '#{ selector }'." )
		
		existingComponentSelector.destroy()
		delete @registeredComponentSelectors[ selector ]
		
		return
	
	###*
	* Get the component selector corresponding to the specified view-relative selector.
	###
	getComponentSelector: ( selector ) ->
		return @registeredComponentSelectors[ selector ]
	
	###*
	* @protected
	###
	createObservers: ->
		@registeredObservers = {}
		for target, events of @observe
			#TODO: find a better way...
			if not(target is "view" or target.substring(0, 5) is "view.")
				@addObserver( target, events, @registeredObservers )
		return

	###*
	* @protected
	###
	createViewObservers: ->
		for target, events of @observe
			#TODO: find a better way...
			if target is "view" or target.substring(0, 5) is "view."
				@addObserver( target, events, @registeredObservers )
		
		return
			
	addObserver: ( target, events, observerContainer = @registeredObservers ) ->
		observer = Ext.create( 'Deft.mvc.Observer',
			host: @
			target: target
			events: events
		)
		observerContainer[ target ] = observer
	
	###*
	* @protected
	###
	removeObservers: ->
		for target, observer of @registeredObservers
			observer.destroy()
			delete @registeredObservers[ target ]
			
		return
, ->
	###*
	* Preprocessor to handle merging of 'observe' objects on parent and child classes.
	###
	Deft.Class.registerPreprocessor(
		'observe'
		( Class, data, hooks, callback ) ->
			# Process any classes that extend this class.
			Deft.Class.hookOnClassExtended( data, ( Class, data, hooks ) ->
				# If the Class extends ViewController at some point in its inheritance chain, merge the parent and child class observers.
				if Class.superclass and Class.superclass?.observe and Deft.Class.extendsClass( 'Deft.mvc.ViewController', Class )
					data.observe = Deft.mvc.Observer.mergeObserve( Class.superclass.observe, data.observe )
				return
			)
			return
		'before'
		'extend'
	)
)
