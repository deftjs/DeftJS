###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

# @private
Ext.define( 'Deft.mvc.Observer',

	###

	target = "propName"
	events = // is object
		event1: "handler1" // is string or function
		event2: "handler2 // is string or function"

	target = "propName2.prop"
	events = // is object
		event3: // is object
			fn: "handler3"
			scope: @
			options:
				option1: "value"
		event4: [ "handler4", "handler5" ] //is array

	if (map.indexOf('.') > -1) {
    map = map.split('.', 2);
    var v = n[map[0]][map[1]];
	} else {
	    var v = n[map];
	}
	###
	constructor: ( config ) ->
		@listeners = []

		#TODO: Remove instance variables for target, host, and events, and pull these from the config object for use below.
		host = config?.host
		target = config?.target
		events = config?.events

		#TODO: handle nested property value for target

		if host and target and ( @isPropertyChain( target ) or host?[ target ]?.isObservable )
			for eventName, fn of events
				fnReference = @locateFunctionReference( host, target, fn )
				if fnReference
					fnReference.target.on( eventName, fnReference.fn, host )
					@listeners.push( { targetName: target, target: fnReference.target, event: eventName, fn: fnReference.fn, scope: host } )
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

	locateFunctionReference: ( host, target, handler ) ->
		handlerHost = host

		if @isPropertyChain( target )
			parseResults = @parsePropertyChain( host, target )
			host = parseResults.host
			target = parseResults.target

		if Ext.isFunction( handler )
			return { target: host[ target ], fn: handler  }
		else if Ext.isFunction( handlerHost[ handler ] )
			return { target: host[ target ], fn: handlerHost[ handler ]  }
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
			listenerData.target.un( listenerData.event, listenerData.fn, listenerData.scope )
		@listeners = []
		return
)