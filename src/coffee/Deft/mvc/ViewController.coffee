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
	requires: [ 'Deft.log.Logger' ]
	
	config:
		###*
		View controlled by this ViewController.
		###
		view: null
	
	constructor: ( config ) ->
		@initConfig( config )
		
		if @getView() instanceof Ext.ClassManager.get( 'Ext.Component' )
			@registeredComponents = {}
			
			# TODO: Find a more reliable way to detect the difference between Ext JS and Sencha Touch.
			# Extract to static utility class or singleton property or method.
			@isExtJS = @getView().events?
			@isSenchaTouch = not @isExtJS
			
			if @isExtJS
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
			Ext.Error.raise( msg: 'Error constructing ViewController: the configured \'view\' is not an Ext.Component.' )
		
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
		if @isExtJS
			@getView().on( 'beforedestroy', @onViewBeforeDestroy, @ )
			@getView().on( 'destroy', @onViewDestroy, @, single: true )
		else
			self = this
			originalViewDestroyFunction = @getView().destroy
			@getView().destroy = ->
				if self.destroy()
					originalViewDestroyFunction.call( @ )
				return
		
		for id, config of @control
			component = @locateComponent( id, config )
			listeners = if Ext.isObject( config.listeners ) then config.listeners else config if not config.selector?
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
		return @registeredComponents[ id ]?.component
	
	###*
	@private
	###
	registerComponent: ( id, component, listeners ) ->
		Deft.Logger.log( "Registering '#{ id }' component." )
		
		existingComponent = @getComponent( id )
		if existingComponent?
			Ext.Error.raise( msg: "Error registering component: an existing component already registered as '#{ id }'." )
		
		@registeredComponents[ id ] =
			component: component
			listeners: listeners
		
		if id isnt 'view'
			getterName = 'get' + Ext.String.capitalize( id )
			@[ getterName ] = Ext.Function.pass( @getComponent, [ id ], @ ) unless @[ getterName ]
		
		if Ext.isObject( listeners )
			for event, listener of listeners
				fn = listener
				scope = @
				options = null
				if Ext.isObject( listener )
					options = Ext.apply( {}, listener )
					if options.fn?
						fn = options.fn
						delete options.fn
					if options.scope?
						scope = options.scope
						delete options.scope
				Deft.Logger.log( "Adding '#{ event }' listener to '#{ id }'." )
				if Ext.isFunction( fn )
					component.on( event, fn, scope, options )
				else if Ext.isFunction( @[ fn ] )
					component.on( event, @[ fn ], scope, options )
				else
					Ext.Error.raise( msg: "Error adding '#{ event }' listener: the specified handler '#{ fn }' is not a Function or does not exist." )
		
		return
	
	###*
	@private
	###
	unregisterComponent: ( id ) ->
		Deft.Logger.log( "Unregistering '#{ id }' component." )
		
		existingComponent = @getComponent( id )
		if not existingComponent?
			Ext.Error.raise( msg: "Error unregistering component: no component is registered as '#{ id }'." )
		
		{ component, listeners } = @registeredComponents[ id ]
			
		if Ext.isObject( listeners )
			for event, listener of listeners
				fn = listener
				scope = @
				if Ext.isObject( listener )
					options = listener
					if options.fn?
						fn = options.fn
					if options.scope?
						scope = options.scope
				Deft.Logger.log( "Removing '#{ event }' listener from '#{ id }'." )
				if Ext.isFunction( fn )
					component.un( event, fn, scope )
				else if Ext.isFunction( @[ fn ] )
					component.un( event, @[ fn ], scope )
				else
					Ext.Error.raise( msg: "Error removing '#{ event }' listener: the specified handler '#{ fn }' is not a Function or does not exist." )
		
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
				Ext.Error.raise( msg: "Error locating component: no component found matching '#{ config }'." )
			if matches.length > 1
				Ext.Error.raise( msg: "Error locating component: multiple components found matching '#{ config }'." )
			return matches[ 0 ]
		else if Ext.isString( config.selector )
			matches = view.query( config.selector )
			if matches.length is 0
				Ext.Error.raise( msg: "Error locating component: no component found matching '#{ config.selector }'." )
			if matches.length > 1
				Ext.Error.raise( msg: "Error locating component: multiple components found matching '#{ config.selector }'." )
			return matches[ 0 ]
		else
			matches = view.query( '#' + id )
			if matches.length is 0
				Ext.Error.raise( msg: "Error locating component: no component found with an itemId of '#{ id }'." )
			if matches.length > 1
				Ext.Error.raise( msg: "Error locating component: multiple components found with an itemId of '#{ id }'." )
			return matches[ 0 ]
)