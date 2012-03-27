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
		
		if not @getView() instanceof Ext.ClassManager.get( 'Ext.Component' )
			Ext.Error.raise( 'Error constructing ViewController: the \'view\' is not an Ext.Component.' )
		
		@registeredComponents = {}
		
		if @getView().events.initialize
			@getView().on( 'initialize', @onViewInitialize, @, single: true )
		else
			if @getView().rendered
				@init()
			else
				@getView().on( 'afterrender', @onViewInitialize, @, single: true )
		
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
	onViewInitialize: ->
		@getView().on( 'beforedestroy', @onViewBeforeDestroy, @ )
		@getView().on( 'destroy', @onViewDestroy, @, single: true )
		
		for id, config of @control
			component = @locateComponent( id, config )
			listeners = if Ext.isObject( config.listeners ) then config.listeners else config
			@registerComponent( id, component, listeners )
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
		
		if id isnt 'view'
			getterName = 'get' + Ext.String.capitalize( id )
			@[ getterName ] = Ext.Function.pass( @getComponent, [ id ], @ ) unless @[ getterName ]
		
		if Ext.isObject( listeners )
			for event, listener of listeners
				Ext.log( "Adding '#{ event }' listener to '#{ id }'." )
				if Ext.isFunction( @[ listener ] )
					component.on( event, @[ listener ], @ )
				else
					Ext.Error.raise( "Error adding '#{ event }' listener: the specified handler '#{ listener }' is not a Function or does not exist." )
		
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
			for event, listener of listeners
				Ext.log( "Removing '#{ event }' listener from '#{ id }'." )
				if Ext.isFunction( @[ listener ] )
					component.un( event, @[ listener ], @ )
				else
					Ext.Error.raise( "Error removing '#{ event }' listener: the specified handler '#{ listener }' is not a Function or does not exist." )
		
		if id isnt 'view'
			getterName = 'get' + Ext.String.capitalize( id )
			@[ getterName ] = null
		
		@registeredComponents[ id ] = null
		
		return
	
	###*
	@private
	###
	locateComponent: ( id, config ) ->
		view = @getView()
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