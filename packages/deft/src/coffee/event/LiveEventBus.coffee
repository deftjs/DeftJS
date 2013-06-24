###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* Event bus for live component selectors.
* @private
###
Ext.define( 'Deft.event.LiveEventBus',
	alternateClassName: [ 'Deft.LiveEventBus' ]
	requires: [ 
		'Ext.Component'
		'Ext.ComponentManager'
		
		'Deft.event.LiveEventListener'
	]
	singleton: true
	
	constructor: ->
		@listeners = []
		return
		
	destroy: ->
		for listener in @listeners
			listener.destroy()
		@listeners = null
		return
	
	addListener: ( container, selector, eventName, fn, scope, options ) ->
		listener = Ext.create( 'Deft.event.LiveEventListener', 
			container: container
			selector: selector
			eventName: eventName
			fn: fn
			scope: scope
			options: options
		)
		@listeners.push( listener )
		return
	
	removeListener: ( container, selector, eventName, fn, scope ) ->
		listener = @findListener( container, selector, eventName, fn, scope )
		if listener?
			Ext.Array.remove( @listeners, listener )
			listener.destroy()
		return
	
	on: ( container, selector, eventName, fn, scope, options ) ->
		return @addListener( container, selector, eventName, fn, scope, options )
	
	un: ( container, selector, eventName, fn, scope ) ->
		return @removeListener( container, selector, eventName, fn, scope )
	
	# @private
	findListener: ( container, selector, eventName, fn, scope ) ->
		for listener in @listeners
			# NOTE: Evaluating here rather than refactoring as a `Deft.event.LiveEventListener` method in order to reduce the number of function calls executed (for performance reasons).
			# TODO: Optimize via an index by selector, eventName (and maybe container id?).
			if listener.container is container and listener.selector is selector and listener.eventName is eventName and listener.fn is fn and listener.scope is scope
				return listener
		return null
	
	# @private
	register: ( component ) ->
		component.on( 'added', @onComponentAdded, @ )
		component.on( 'removed', @onComponentRemoved, @ )
		return
	
	# @private
	unregister: ( component ) ->
		component.un( 'added', @onComponentAdded, @ )
		component.un( 'removed', @onComponentRemoved, @ )
		return
	
	# @private
	onComponentAdded: ( component, container, eOpts ) ->
		for listener in @listeners
			listener.register( component )
		return
	
	# @private
	onComponentRemoved: ( component, container, eOpts ) ->
		for listener in @listeners
			listener.unregister( component )
		return
,
	->
		if Ext.getVersion( 'touch' )?
			Ext.define( 'Deft.Component',
				override: 'Ext.Component'
				
				setParent: ( newParent ) ->
					oldParent = @getParent()
					
					result = @callParent( arguments )
					
					if oldParent is null and newParent isnt null
						@fireEvent( 'added', @, newParent )
					else if oldParent isnt null and newParent isnt null
						@fireEvent( 'removed', @, oldParent )
						@fireEvent( 'added', @, newParent )
					else if oldParent isnt null and newParent is null
						@fireEvent( 'removed', @, oldParent )
					
					return result
				
				isDescendantOf: ( container ) ->
					ancestor = @getParent()
					while ancestor?
						if ancestor is container
							return true
						ancestor = ancestor.getParent()
					return false
			)
		
		Ext.Function.interceptAfter(
			Ext.ComponentManager,
			'register',
			( component ) ->
				Deft.event.LiveEventBus.register( component )
				return
		)
		
		Ext.Function.interceptAfter(
			Ext.ComponentManager,
			'unregister',
			( component ) ->
				Deft.event.LiveEventBus.unregister( component )
				return
		)
		
		return
)