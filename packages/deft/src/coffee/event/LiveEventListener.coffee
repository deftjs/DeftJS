###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
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
	]
	
	constructor: ( config ) ->
		Ext.apply( @, config )
		
		@components = []
		components = Ext.ComponentQuery.query( @selector, @container )
		for component in components
			@components.push( component )
			component.on( @eventName, @fn, @scope, @options )
		return
	
	destroy: ->
		for component in @components
			component.un( @eventName, @fn, @scope )
		@components = null
		return
	
	# Register a candidate component as a source of 'live' events (typically called when a component is added to a container).
	register: ( component ) ->
		if @matches( component )
			@components.push( component )
			component.on( @eventName, @fn, @scope, @options )
		return
	
	# Unregister a candidate component as a source of 'live' events (typically called when a component is removed from a container).
	unregister: ( component ) ->
		index = Ext.Array.indexOf( @components, component )
		if index isnt -1
			component.un( @eventName, @fn, @scope )
			Ext.Array.erase( @components, index, 1 )
		return
	
	# @private
	matches: ( component ) ->
		if @selector is null and @container is component
			return true
		if @container is null and Ext.Array.contains( Ext.ComponentQuery.query( @selector ), component )
			return true
		if component.isDescendantOf( @container ) and Ext.Array.contains( @container.query( @selector ), component )
			return true
		return false
)