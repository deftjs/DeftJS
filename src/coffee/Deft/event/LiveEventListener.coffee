###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* Event listener for events fired via the Deft.event.LiveEventBus.
* @private
###
Ext.define( 'Deft.event.LiveEventListener',
	alternateClassName: [ 'Deft.LiveEventListener' ]
	requires: [
		'Ext.ComponentQuery'
	],
	mixins : 
		observable : 'Ext.util.Observable'
	
	constructor: ( config ) ->
		Ext.apply( @, config )
		
		if(@options is null)
			@options = {}
		
		@mixins.observable.constructor.call(@)
			
		@components = []
		return
			
	destroy: ->
		for component in @components
			@unregister( component, true )
		@components = null
		return
	
	overrideComponent: ( component ) ->
		if component.liveHandlers isnt undefined
			return

		component.liveHandlers = {}
		
		#TODO: define this in Deft.Component, EventBus overrides this method and doesn't call the parent method...
		oldFireEvent = component.fireEvent
		component.fireEvent = ( event ) ->
			if(oldFireEvent.apply( @, arguments ) is false)
				return false

			if @liveHandlers[ event ] is undefined
				return

			for handler in @liveHandlers[ event ]
				if handler.observable.matches( @ ) and handler.fireEvent.apply( handler, arguments) is false
					return false
		return
	
	handle: ->
		return @fn.apply(@scope, arguments)
		
	
	# Register a candidate component as a source of 'live' events (typically called when a component is added to a container).
	register: ( component ) ->
		index = Ext.Array.indexOf( @components, component )
		if @selector is null and component isnt @container or index isnt -1
			return
			
		@components.push( component )
		@overrideComponent( component )

		if component.liveHandlers[@eventName] is undefined
			component.liveHandlers[@eventName] = []
		
		event = Ext.create('Ext.util.Observable')
		event.observable = @
		event.addListener(@eventName, @handle, @, @options)
		
		#TODO: Some events don't fire without this, maybe there is a better solution, but test are failing... component.HasListeners.prototype[@eventName] = 1
		component.on( @eventName, Ext.emptyFn, @, @options )
		
		component.liveHandlers[@eventName].push( event )
		return

	# Unregister a candidate component as a source of 'live' events (typically called when a component is removed from a container).
	unregister: ( component, destroying = false ) ->
		index = Ext.Array.indexOf( @components, component )
		if index isnt -1
			component.un( @eventName, Ext.emptyFn, @, @options )
			Ext.Array.remove( component.liveHandlers[ @eventName ], @ )
			if destroying is false
				Ext.Array.erase( @components, index, 1 )
		return
	
	# @private
	matches: ( component ) ->
		if @selector is null
			return component is @container
		if @container is null
			return true
		
		return component.isDescendantOf( @container )
)