###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* Event bus for live component selectors.
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
		@listeners = {}
		return
		
	destroy: ->
		for selector, listeners of @listeners
			for listener in listeners
				listener.destroy()
		@listeners = null
		return
	
	addListener: ( container, selector, eventName, fn, scope, options ) ->
		listener = Ext.create( 'Deft.event.LiveEventListener', 
			selector : selector
			container: container
			eventName: eventName
			fn: fn
			scope: scope
			options: options
		)
		@listeners[selector] = @listeners[selector] || []
		@listeners[selector].push( listener )
		return
	
	removeListener: ( container, selector, eventName, fn, scope ) ->
		listener = @findListener( container, selector, eventName, fn, scope )
		if listener?
			Ext.Array.remove( @listeners[selector], listener )
			listener.destroy()
		return
	
	on: ( container, selector, eventName, fn, scope, options ) ->
		return @addListener( container, selector, eventName, fn, scope, options )
	
	un: ( container, selector, eventName, fn, scope ) ->
		return @removeListener( container, selector, eventName, fn, scope )
	
	# @private
	findListener: ( container, selector, eventName, fn, scope ) ->
		if @listeners[selector] is undefined
			return null
			
		for listener in @listeners[selector]
			# NOTE: Evaluating here rather than refactoring as a `Deft.event.LiveEventListener` method in order to reduce the number of function calls executed (for performance reasons).
			# TODO: Optimize via an index by selector, eventName (and maybe container id?).
			if listener.container is container and listener.eventName is eventName and listener.fn is fn and listener.scope is scope
				return listener
		return null
	
	# @private
	register: ( component, selector = null ) ->
		component.on( 'added', @onComponentAdded, @ )
		component.on( 'removed', @onComponentRemoved, @ )
		if(@listeners[selector])
			for listener in @listeners[selector]
				listener.register.apply( listener, arguments )
		return
	
	# @private
	unregister: ( component ) ->
		component.un( 'added', @onComponentAdded, @ )
		component.un( 'removed', @onComponentRemoved, @ )
		
		if(@listeners[null])
			for listener in @listeners[null]
				listener.unregister( component )
		return
	
	# @private
	onComponentAdded: ( component, container, pos, eOpts ) ->
		for selector, listeners of @listeners
			if(selector isnt null and component.is(selector))
				for listener in listeners
					listener.register.apply( listener, arguments )
		return
	
	# @private
	onComponentRemoved: ( component, container, eOpts ) ->
		for selector, listeners of @listeners
			if(selector isnt null and component.is(selector))
				for listener in listeners
					listener.unregister( component )
		return
,
	->
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