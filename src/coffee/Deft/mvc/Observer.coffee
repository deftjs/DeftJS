###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

# @private
Ext.define( 'Deft.mvc.Observer',

	constructor: ( config ) ->
		@listeners = []

		host = config?.host
		target = config?.target
		events = config?.events

		if host and target and ( @isPropertyChain( target ) or host?[ target ]?.isObservable )
			for eventName, handler of events
				references = @locateReferences( host, target, handler )
				if references
					references.target.on( eventName, references.handler, host )
					@listeners.push( { targetName: target, target: references.target, event: eventName, handler: references.handler, scope: host } )
					Deft.Logger.log( "Created observer on '#{ target }' for event '#{ eventName }'." )
					console.log( "Created observer on '#{ target }' for event '#{ eventName }'." )
				else
					Deft.Logger.warn( "Could not create observer on '#{ target }' for event '#{ eventName }'." )
					console.log( "Could not create observers on '#{ target }' because '#{ target }' is not an Ext.util.Observable" )

		else
			Deft.Logger.warn( "Could not create observers on '#{ target }' because '#{ target }' is not an Ext.util.Observable" )
			console.log( "Could not create observers on '#{ target }' because '#{ target }' is not an Ext.util.Observable" )

		return @


	isPropertyChain: ( target ) ->
		return Ext.isString( target ) and target.indexOf( '.' ) > -1


	locateReferences: ( host, target, handler ) ->
		handlerHost = host

		if @isPropertyChain( target )
			propertyChain = @parsePropertyChain( host, target )
			host = propertyChain.host
			target = propertyChain.target

		if Ext.isFunction( handler )
			return { target: host[ target ], handler: handler  }
		else if Ext.isFunction( handlerHost[ handler ] )
			return { target: host[ target ], handler: handlerHost[ handler ]  }
		else
			return null


	parsePropertyChain: ( host, target ) ->
		if Ext.isString( target )
			propertyChain = target.split( '.' )
		else if Ext.isArray( target )
			propertyChain = target
		else
			return null

		if propertyChain.length > 1 and host?[ propertyChain[0] ]
			@parsePropertyChain( host[ propertyChain[0] ], propertyChain[1..] )
		else if host?[ propertyChain[0] ] and host?[ propertyChain[0] ]?.isObservable
			return { host: host, target: propertyChain[0] }
		else
			return null


	destroy: ->
		for listenerData in @listeners
			Deft.Logger.log( "Removing observer on '#{ listenerData.targetName }' for event '#{ listenerData.event }'." )
			listenerData.target.un( listenerData.event, listenerData.handler, listenerData.scope )
		@listeners = []
		return
)