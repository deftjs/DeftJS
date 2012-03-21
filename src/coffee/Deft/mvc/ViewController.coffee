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
	
	config:
		###*
		View controlled by this ViewController.
		###
		view: null
	
	constructor: ( config ) ->
		@initConfig( config )
		
		if not getView() instanceof Ext.ClassManager.get( 'Ext.Component' )
			Ext.Error.raise( 'Error constructing ViewController: the \'view\' is not an Ext.Component.' )
		
		@registeredComponents = {}
		
		initializationEvent = if view.events.initialize? then 'initialize' else 'beforeRender'
		
		view.on( initializationEvent, @onInitialize, @, single: true )
		view.on( 'beforedestroy', @onBeforeDestroy, @ )
		view.on( 'destroy', @onDestroy, @, single: true )
		
		return @
	
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
	onInitialize: ->
		for id, config of @control
			component = @locateComponent( id, config )
			listeners = if Ext.isObject( config.listeners ) then config.listeners else config
			@registerComponent( id, component, listeners )
		@init()
		return
	
	###*
	@private
	###
	onBeforeDestroy: ->
		if @destroy()
			getView().un( 'onBeforeDestroy', @onBeforeDestroy, @ )
			return true
		return false
	
	###*
	@private
	###
	onDestroy: ->
		for id of @registeredComponents
			@unregisterComponent( id )
		return
	
	###*
	@private
	###
	getComponent: ( id ) ->
		return @registeredComponents[ id ].component
	
	###*
	@private
	###
	registerComponent: ( id, component, listeners ) ->
		Ext.log( "Registering '#{ id }' component." )
		
		existingComponent = @getComponent( id )
		if existingComponent?
			Ext.Error.raise( "Error registering component: an existing component already registered as '#{ id }'." )
		
		@registeredComponents[ id ] =
			component: component
			listeners: listeners
		
		if id isnt view
			getterName = 'get' + Ext.String.capitalize( id )
			@[ getterName ] = Ext.Function.pass( @getComponent, [ id ], @ ) unless @[ getterName ]
		
		if Ext.isObject( listeners )
			for event, handler of listeners
				Ext.log( "Adding '#{ event }' listener to '#{ id }'." )
				component.on( event, @[ handler ], @ )
		
		return
	
	###*
	@private
	###
	unregisterComponent: ( id ) ->
		Ext.log( "Unregistering '#{ id }' component." )
		
		existingComponent = @getComponent( id )
		if not existingComponent?
			Ext.Error.raise( "Error unregistering component: no component is registered as '#{ id }'." )
		
		{ component, listeners } = @registeredComponents[ id ]
			
		if Ext.isObject( listeners )
			for event, handler of listeners
				Ext.log( "Removing '#{ event }' listener from '#{ id }'." )
				component.un( event, @[ handler ], @ )
		
		if id isnt 'view'
			getterName = 'get' + Ext.String.capitalize( id )
			@[ getterName ] = null
		
		@registeredComponents[ id ] = null
		
		return
	
	###*
	@private
	###
	locateComponent: ( id, config ) ->
		view = getView()
		if id is 'view'
			return view
			
		if Ext.isString( config )
			matches = view.query( config )
			if matches.length is 0
				Ext.Error.raise( "Error locating component: no component found matching '#{ config }'." )
			if matches.length > 1
				Ext.Error.raise( "Error locating component: multiple components found matching '#{ config }'." )
			return matches[ 0 ]
		else if Ext.isString( config.selector )
			matches = view.query( config.selector )
			if matches.length is 0
				Ext.Error.raise( "Error locating component: no component found matching '#{ config.selector }'." )
			if matches.length > 1
				Ext.Error.raise( "Error locating component: multiple components found matching '#{ config.selector }'." )
			return matches[ 0 ]
		else
			matches = view.query( '#' + id )
			if matches.length is 0
				Ext.Error.raise( "Error locating component: no component found with an itemId of '#{ id }'." )
			if matches.length > 1
				Ext.Error.raise( "Error locating component: multiple components found with an itemId of '#{ id }'." )
			return matches[ 0 ]
)