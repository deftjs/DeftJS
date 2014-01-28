###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* @private
* Models a component selector used by Deft.mvc.ViewController to locate view components and attach event listeners.
###
Ext.define( 'Deft.mvc.ComponentSelector',
	requires: [
		'Ext.ComponentQuery'
		'Deft.log.Logger'
		'Deft.mvc.ComponentSelectorListener'
		'Deft.util.Function'
	]
	
	constructor: ( config ) ->
		Ext.apply( @, config )
		
		if not @live
			@components = if @selector? then Ext.ComponentQuery.query( @selector, @view ) else [ @view ]
		
		@selectorListeners = []
		
		if Ext.isObject( @listeners )
			for eventName, listener of @listeners
				fn = listener
				scope = @scope
				options = null
				
				# Parse `options` if present.
				if Ext.isObject( listener )
					options = Ext.apply( {}, listener )
					if options.fn?
						fn = options.fn
						delete options.fn
					if options.scope?
						scope = options.scope
						delete options.scope
						
				# Parse `fn`.
				if Ext.isString( fn ) and Deft.isFunction( scope[ fn ] )
					fn = scope[ fn ]
				if not Deft.isFunction ( fn )
					Ext.Error.raise( msg: "Error adding '#{ eventName }' listener: the specified handler '#{ fn }' is not a Function or does not exist." )
				
				@addListener( eventName, fn, scope, options )
		return @
	
	destroy: ->
		for selectorListener in @selectorListeners
			selectorListener.destroy()
		@selectorListeners = []
		return
	
	###*
	Add an event listener to this component selector.
	###
	addListener: ( eventName, fn, scope, options ) ->
		if @findListener( eventName, fn, scope )?
			Ext.Error.raise( msg: "Error adding '#{ eventName }' listener: an existing listener for the specified function was already registered for '#{ @selector }." )
		
		Deft.Logger.log( "Adding '#{ eventName }' listener to '#{ @selector }'." )
		selectorListener = Ext.create( 'Deft.mvc.ComponentSelectorListener',
			componentSelector: @
			eventName: eventName
			fn: fn
			scope: scope
			options: options
		)
		@selectorListeners.push( selectorListener )
		return
	
	###*
	Remove an event listener from this component selector.
	###
	removeListener: ( eventName, fn, scope ) ->
		selectorListener = @findListener( eventName, fn, scope )
		if selectorListener?
			Deft.Logger.log( "Removing '#{ eventName }' listener from '#{ @selector }'." )
			selectorListener.destroy()
			Ext.Array.remove( @selectorListeners, selectorListener )
		return
	
	# @private
	findListener: ( eventName, fn, scope ) ->
		for selectorListener in @selectorListeners
			if selectorListener.eventName is eventName and selectorListener.fn is fn and selectorListener.scope is scope
				return selectorListener
		return null
)