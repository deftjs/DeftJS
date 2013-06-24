###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
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
	
	###*
	* Resolves this Resolver with the specified value, triggering it to execute the 'onResolved' callback and propagate the resulting resolution value or rejection reason to Resolvers that originate from this Resolver.
	*
	* @param {Mixed} value The resolved future value.
	###
	resolve: Ext.emptyFn
	
	###*
	* Rejects this Resolver with the specified reason, triggering it to execute the 'onRejected' callback and propagate the resulting resolution value or rejection reason to Resolvers that originate from this Resolver.
	*
	* @param {Error} reason The rejection reason.
	###
	reject: Ext.emptyFn
	
	###*
	* Updates progress for this Resolver, if it is still pending, triggering it to execute the 'onProgress' callback and propagate the resulting transformed progress value to Resolvers that originate from this Resolver.
	*
	* @param {Mixed} progress The progress value.
	###
	update: Ext.emptyFn
	
	###*
	* Schedules creation of a new Resolver that originates from this Resolver, configured with the specified callbacks.  Those callbacks can subsequently transform the value that was resolved or the reason that was rejected.
	*
	* Each call to then() returns a new Promise of that transformed value; i.e., a Promise that is resolved with the callback return value or rejected with any error thrown by the callback.
	*
	* @param {Function} onFulfilled Callback function to be called when resolved.
	* @param {Function} onRejected Callback function to be called when rejected.
	* @param {Function} onProgress Callback function to be called with progress updates.
	* @param {Object} scope Optional scope for the callback(s).
	* @return {Deft.promise.Promise} A Promise of the transformed future value.
	###
	then: Ext.emptyFn
)