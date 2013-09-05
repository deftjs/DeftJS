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
	
	###*
	* Overrides the fireEvent method, so the event is fired also in the custom live handlers
	###
	overrideComponent: ( component ) ->
		# Return if the component has already been patched
		if component.liveHandlers isnt undefined
			return

		component.liveHandlers = {}
		
		#TODO: define this in Deft.Component, EventBus overrides this method and doesn't call the parent method...
		# Keeps track of the original fireEvent method
		oldFireEvent = component.fireEvent
		component.fireEvent = ( event ) ->
			# Return in case the event has returned false (as in ExtJS specs)
			if(oldFireEvent.apply( @, arguments ) is false)
				return false

			if @liveHandlers[ event ] is undefined
				return

			for handler in @liveHandlers[ event ]
				# Fires the event only if the LiveEventListener is meant for this component (see matches method)
				# Breaks the loop and returns false if an event is returning false  
				if handler.observable.matches( @ ) and handler.fireEvent.apply( handler, arguments) is false
					return false
		
		if ! component.fireAction
			return
		  
		# Keeps track of the original fireAction method
		oldFireAction = component.fireAction
		component.fireAction = ( event, params ) ->
			if @liveHandlers[ event ] is undefined
				return oldFireAction.apply( @, arguments )

			for handler in @liveHandlers[ event ]
				args = [ event ].concat( params || [] )
				  
				# Fires the event only if the LiveEventListener is meant for this component (see matches method)
				# Breaks the loop and returns false if an event is returning false
				if handler.observable.matches( @ ) and handler.fireEvent.apply( handler, args ) is false
					return false
					
		return
	
	# Handles the fired event calling the LiveEventHandler's function
	handle: ->
		return @fn.apply(@scope, arguments)
		
	
	# Register a candidate component as a source of 'live' events
	register: ( component ) ->
		index = Ext.Array.indexOf( @components, component )
		# Do nothing if the component has already been registered
		if @selector is null and component isnt @container or index isnt -1
			return
			
		@components.push( component )
		@overrideComponent( component )

		if component.liveHandlers[@eventName] is undefined
			component.liveHandlers[@eventName] = []
		
		# This event is fired by component.fireEvent. 
		# It's useful to handle options such as single, buffered, etc... 
		event = Ext.create('Ext.util.Observable')
		event.observable = @
		event.addListener(@eventName, @handle, @, @options)
		
		#TODO: Some events don't fire without this, maybe there is a better solution, but test are failing... component.HasListeners.prototype[@eventName] = 1
		component.on( @eventName, Ext.emptyFn, @, @options )
		
		component.liveHandlers[@eventName].push( event )
		return

	# Unregister a candidate component as a source of 'live' events
	unregister: ( component, destroying = false ) ->
		index = Ext.Array.indexOf( @components, component )
		if index isnt -1
			component.un( @eventName, Ext.emptyFn, @, @options )
			Ext.Array.remove( component.liveHandlers[ @eventName ], @ )
			# Avoids bugs looping into @components ( during destroy )
			if destroying is false
				Ext.Array.erase( @components, index, 1 )
		return
	
	# @private
	# This method decides if this LiveEventListener is meant for the current component
	matches: ( component ) ->
		# In case the selector is null, the component has to be the root container 
		if @selector is null
			return component is @container
		
		# Avoid bugs
		if @container is null
			return true
		
		# The event has to be fired if and only if the component is a descendant of the container
		return component.isDescendantOf( @container )
)
