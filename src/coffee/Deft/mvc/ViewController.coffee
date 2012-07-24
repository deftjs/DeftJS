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
	
	constructor: ( config = {} ) ->
		if config.view
			@controlView( config.view )
		return @initConfig( config )
	
	###*
	@protected
	###
	controlView: ( view ) ->
		if view instanceof Ext.ClassManager.get( 'Ext.Container' )
			@setView( view )
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
			@registerComponent( id, selector, listeners, live )
		
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
		for id of @registeredComponentSelectors
			@unregisterComponent( id )
		return
	
	registerComponent: ( id, selector, listeners, live = false ) ->
		Deft.Logger.log( "Registering '#{ id }' component." )
		
		if @registeredComponentSelectors[ id ]?
			Ext.Error.raise( msg: "Error registering component: an existing component already registered as '#{ id }'." )
		
		componentSelector = Ext.create( 'Deft.mvc.ComponentSelector',
			id: id
			view: @getView()
			selector: selector
			listeners: listeners
			scope: @
			live: live
		)
		
		# Add generated getter function.
		if id isnt 'view'
			getterName = 'get' + Ext.String.capitalize( id )
			unless @[ getterName ]?
				if live
					@[ getterName ] = -> componentSelector.locate()
				else
					matches = componentSelector.locate()
					unless matches?
						Ext.Error.raise( msg: "Error locating component: no component(s) found matching '#{ selector }'." )
					@[ getterName ] = -> matches
				@[ getterName ].generated = true
		
		@registeredComponentSelectors[ id ] = componentSelector
		return
	
	unregisterComponent: ( id ) ->
		Deft.Logger.log( "Unregistering '#{ id }' component." )
		
		unless @registeredComponentSelectors[ id ]?
			Ext.Error.raise( msg: "Error unregistering component: no component is registered as '#{ id }'." )
			
		componentSelector = @registeredComponentSelectors[ id ]
		componentSelector.destroy()
		
		# Remove generated getter function.
		if id isnt 'view'
			getterName = 'get' + Ext.String.capitalize( id )
			if @[ getterName ].generated
				@[ getterName ] = null
		
		@registeredComponentSelectors[ id ] = null
		return
)