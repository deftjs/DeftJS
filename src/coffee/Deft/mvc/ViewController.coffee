###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
A lightweight MVC view controller.

Used in conjunction with {@link Deft.mixin.Controllable}.
###
Ext.define( 'Deft.mvc.ViewController',
	alternateClassName: [ 'Deft.ViewController' ]
	requires: [ 
		'Deft.log.Logger'
		'Deft.mvc.ComponentSelector'
	]

	config:
		###*
		View controlled by this ViewController.
		###
		view: null

	###*
	Observers automatically created and removed by this ViewController.
	###
	observe: null
	
	constructor: ( config = {} ) ->
		if config.view
			@controlView( config.view )
		initializedConfig = @initConfig( config ) #Ensure any config values are set before creating observers.
		if @observe
			@createObservers()
		return initializedConfig

	###*
	@protected
	###
	controlView: ( view ) ->
		if view instanceof Ext.ClassManager.get( 'Ext.Container' )
			@setView( view )
			@registeredComponentReferences = {}
			@registeredComponentSelectors = {}
			
			if Ext.getVersion( 'extjs' )?
				# Ext JS
				if @getView().rendered
					@onViewInitialize()
				else
					@getView().on( 'afterrender', @onViewInitialize, @, single: true )
			else
				# Sencha Touch
				if @getView().initialized
					@onViewInitialize()
				else
					@getView().on( 'initialize', @onViewInitialize, @, single: true )
		else
			Ext.Error.raise( msg: 'Error constructing ViewController: the configured \'view\' is not an Ext.Container.' )
		return
	
	###*
	Initialize the ViewController
	###
	init: ->
		return
	
	###*
	Destroy the ViewController
	###
	destroy: ->
		return true
	
	###*
	@private
	###
	onViewInitialize: ->
		if Ext.getVersion( 'extjs' )?
			# Ext JS
			@getView().on( 'beforedestroy', @onViewBeforeDestroy, @ )
			@getView().on( 'destroy', @onViewDestroy, @, single: true )
		else
			# Sencha Touch
			self = this
			originalViewDestroyFunction = @getView().destroy
			@getView().destroy = ->
				if self.destroy()
					originalViewDestroyFunction.call( @ )
				return
		
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
				listeners = config unless config.selector? or config.live?
			live = config.live? and config.live
			@addComponentReference( id, selector, live )
			@addComponentSelector( selector, listeners, live )

		@init()
		return
	
	###*
	@private
	###
	onViewBeforeDestroy: ->
		if @destroy()
			@getView().un( 'beforedestroy', @onBeforeDestroy, @ )
			return true
		return false
	
	###*
	@private
	###
	onViewDestroy: ->
		for id of @registeredComponentReferences
			@removeComponentReference( id )
		for selector of @registeredComponentSelectors
			@removeComponentSelector( selector )
		@removeObservers()
		return
	
	###*
	Add a component accessor method the ViewController for the specified view-relative selector.
	###
	addComponentReference: ( id, selector, live = false ) ->
		Deft.Logger.log( "Adding '#{ id }' component reference for selector: '#{ selector }'." )
		
		if @registeredComponentReferences[ id ]?
			Ext.Error.raise( msg: "Error adding component reference: an existing component reference was already registered as '#{ id }'." )
		
		# Add generated getter function.
		if id isnt 'view'
			getterName = 'get' + Ext.String.capitalize( id )
			unless @[ getterName ]?
				if live
					@[ getterName ] = Ext.Function.pass( @getViewComponent, [ selector ], @ )
				else
					matches = @getViewComponent( selector )
					unless matches?
						Ext.Error.raise( msg: "Error locating component: no component(s) found matching '#{ selector }'." )
					@[ getterName ] = -> matches
				@[ getterName ].generated = true
				
		@registeredComponentReferences[ id ] = true
		return
	
	###*
	Remove a component accessor method the ViewController for the specified view-relative selector.
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
	Get the component(s) corresponding to the specified view-relative selector.
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
	Add a component selector with the specified listeners for the specified view-relative selector.
	###
	addComponentSelector: ( selector, listeners, live = false ) ->
		Deft.Logger.log( "Adding component selector for: '#{ selector }'." )
		
		existingComponentSelector = @getComponentSelector( selector )
		if existingComponentSelector?
			Ext.Error.raise( msg: "Error adding component selector: an existing component selector was already registered for '#{ selector }'." )
		
		componentSelector = Ext.create( 'Deft.mvc.ComponentSelector',
			view: @getView()
			selector: selector
			listeners: listeners
			scope: @
			live: live
		)
		@registeredComponentSelectors[ selector ] = componentSelector
		
		return
	
	###*
	Remove a component selector with the specified listeners for the specified view-relative selector.
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
	Get the component selectorcorresponding to the specified view-relative selector.
	###
	getComponentSelector: ( selector ) ->
		return @registeredComponentSelectors[ selector ]

	###*
	@protected
	###
	createObservers: ->
		for target, events of @observe
			if @[ target ] and @[ target ]?.isObservable
				for eventName, listener of events
					Deft.Logger.log( "Creating observer on '#{ target }' for event '#{ eventName }'." )
					if Ext.isFunction( listener )
						@[ target ].on( eventName, listener, @ )
					else if Ext.isFunction( @[ listener ] )
						@[ target ].on( eventName, @[ listener ], @)
					else
						Deft.Logger.warn( "Could not create observer on '#{ target }' for event '#{ eventName }'." )
			else
				Deft.Logger.warn( "Could not create observers on '#{ target }' because '#{ target }' is not an Ext.util.Observable" )

		return

	###*
	@protected
	###
	removeObservers: ->
		for target, events of @observe
			if @[ target ] and @[ target ]?.isObservable
				for eventName, listener of events
					Deft.Logger.log( "Removing observer on '#{ target }' for event '#{ eventName }'." )
					if Ext.isFunction( listener )
						@[ target ].un( eventName, listener, false )
					else if Ext.isFunction( @[ listener ] )
						@[ target ].un( eventName, @[ listener ], @)

		return

)


Ext.Class.registerPreprocessor( 'observe', ( Class, data, hooks, callback ) ->

	# Workaround: Ext JS 4.0 passes the callback as the third parameter, Sencha Touch 2.0.1 and Ext JS 4.1 passes it as the fourth parameter
	if arguments.length is 3
		# NOTE: Altering a parameter also modifies arguments, so clone it to a true Array first.
		parameters = Ext.toArray( arguments )
		hooks = parameters[ 1 ]
		callback = parameters[ 2 ]

	if Class.superclass and Class.superclass?.observe
		data.observe = {} if not data?.observe
		data.observe = Ext.merge( {}, Class.superclass.observe, data.observe )

	return
)

Ext.Class.setDefaultPreprocessorPosition( 'observe', 'before', 'extend' )