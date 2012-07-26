###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

# @private
Ext.define( 'Deft.mvc.Observer',

	host: null
	target: null
	events: null
	listeners: []

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
		Ext.apply( @, config )

		if @host[ @target ] and @host[ @target ]?.isObservable
			for eventName, listener of @events
				Deft.Logger.log( "Creating observer on '#{ @target }' for event '#{ eventName }'." )
				console.log( "Creating observer on '#{ @target }' for event '#{ eventName }'." )
				if Ext.isFunction( listener )
					@host[ @target ].on( eventName, listener, @host )
				else if Ext.isFunction( @host[ listener ] )
					@host[ @target ].on( eventName, @host[ listener ], @host )
				else
					Deft.Logger.warn( "Could not create observer on '#{ @target }' for event '#{ eventName }'." )
		else
			Deft.Logger.warn( "Could not create observers on '#{ @target }' because '#{ @target }' is not an Ext.util.Observable" )
			console.log( "Could not create observers on '#{ @target }' because '#{ @target }' is not an Ext.util.Observable" )

		return @

	destroy: ->
		if @host[ @target ] and @host[ @target ]?.isObservable
			for eventName, listener of @events
				Deft.Logger.log( "Removing observer on '#{ @target }' for event '#{ eventName }'." )
				console.log( "Removing observer on '#{ @target }' for event '#{ eventName }'." )
				if Ext.isFunction( listener )
					@host[ @target ].un( eventName, listener, @host )
				else if Ext.isFunction( @host[ listener ] )
					@host[ @target ].un( eventName, @host[ listener ], @host )

		delete @host
		return
)