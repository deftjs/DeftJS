###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Resolvers are used internally by Deferreds and Promises to capture and notify
callbacks, process callback return values and propagate resolution or rejection
to chained Resolvers.

Developers never directly interact with a Resolver.

A Resolver captures a pair of optional onResolved and onRejected callbacks and 
has an associated Promise. That Promise delegates its then() calls to the 
Resolver's then() method, which creates a new Resolver and schedules its 
delayed addition as a chained Resolver.

Each Deferred has an associated Resolver. A Deferred delegates resolve() and 
reject() calls to that Resolver's resolve() and reject() methods. The Resolver 
processes the resolution value and rejection reason, and propagates the 
processed resolution value or rejection reason to any chained Resolvers it may 
have created in response to then() calls. Once a chained Resolver has been 
notified, it is cleared out of the set of chained Resolvers and will not be 
notified again.
@private
###
Ext.define( 'Deft.promise.Resolver',
	alternateClassName: [ 'Deft.Resolver' ]
	requires: [ 'Deft.util.Function' ]
	
	constructor: ( onResolved, onRejected, onProgress ) ->
		@promise = Ext.create( 'Deft.promise.Promise', @ )
		pendingResolvers = []
		processed = false
		completed = false
		completionAction = null
		completionValue = null
		
		if not Ext.isFunction( onRejected )
			onRejected = ( error ) -> throw error
		
		nextTick = Deft.util.Function.nextTick
		propagate = ->
			for pendingResolver in pendingResolvers
				pendingResolver[ completionAction ]( completionValue )
			pendingResolvers = []
			return
		schedule = ( pendingResolver ) ->
			pendingResolvers.push( pendingResolver )
			propagate() if completed
			return
		complete = ( action, value ) ->
			onResolved = onRejected = onProgress = null
			completionAction = action
			completionValue = value
			completed = true
			propagate()
			return
		completeResolved = ( value ) -> 
			complete( 'resolve', value )
			return
		completeRejected = ( reason ) -> 
			complete( 'reject', reason )
			return
		process = ( callback, value ) ->
			processed = true
			try
				value = callback( value ) if Ext.isFunction( callback )
				if value and Ext.isFunction( value.then )
					value.then( completeResolved, completeRejected )
				else
					completeResolved( value )
			catch error
				completeRejected( error )
			return
		
		@resolve = ( value ) ->
			process( onResolved, value ) if not processed
			return
		@reject = ( reason ) ->
			process( onRejected, reason ) if not processed
			return 
		@update = ( progress ) ->
			if not completed
				progress = onProgress( progress ) if Ext.isFunction( onProgress )
				for pendingResolver in pendingResolvers
					pendingResolver.update( progress )
			return
		@then = ( onResolved, onRejected, onProgress ) ->
			if Ext.isFunction( onResolved ) or Ext.isFunction( onRejected ) or Ext.isFunction( onProgress )
				pendingResolver = Ext.create( 'Deft.promise.Resolver', onResolved, onRejected, onProgress )
				nextTick( -> schedule( pendingResolver ) )
				return pendingResolver.promise
			return @promise
		
		return @
)