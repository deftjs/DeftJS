###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
A Deferred is typically used within the body of a function that performs an 
asynchronous operation. When that operation succeeds, the Deferred should be 
resolved; if that operation fails, the Deferred should be rejected.

Once a Deferred has been resolved or rejected, it is considered to be complete 
and subsequent calls to resolve() or reject() are ignored.

Deferreds are the mechanism used to create new Promises. A Deferred has a 
single associated Promise that can be safely returned to external consumers 
to ensure they do not interfere with the resolution or rejection of the deferred 
operation.
###
Ext.define( 'Deft.promise.Deferred',
	alternateClassName: [ 'Deft.Deferred' ]
	requires: [ 'Deft.promise.Resolver' ]
	
	statics:
		###*
		* Returns a new {@link Deft.promise.Promise} that resolves immediately with
		* the specified value.
		* @param The resolved future value.
		###
		resolve: ( value ) ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			deferred.resolve( value )
			return deferred.promise
		
		###*
		* Returns a new {@link Deft.promise.Promise} that rejects immediately with
		* the specified reason.
		* @param {Error} The rejection reason.
		###
		reject: ( reason ) ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			deferred.reject( reason )
			return deferred.promise
	
	###*
	* The {@link Deft.promise.Promise} of a future value associated with this
	* {@link Deft.promise.Deferred}.
	###
	promise: null
	
	constructor: ->
		resolver = Ext.create( 'Deft.promise.Resolver' )
		
		@promise = resolver.promise
		@resolve = ( value ) -> resolver.resolve( value )
		@reject = ( reason ) -> resolver.reject( reason )
		@update = ( progress ) -> resolver.update( progress )
		
		return @
	
	###*
	* Resolves the {@link Deft.promise.Promise} associated with this
	* {@link Deft.promise.Deferred} with the specified value.
	*
	* @param The resolved future value.
	###
	resolve: Ext.emptyFn
	
	###*
	* Rejects this {@link Deft.promise.Deferred} with the specified reason.
	*
	* @param {Error} The rejection reason.
	###
	reject: Ext.emptyFn
	
	###*
	* Updates progress for this {@link Deft.promise.Deferred} if it is 
	* still pending, notifying callbacks with the specified progress value 
	* that will propagate to any Promises originating from this Promise.
	*
	* @param {Error} The progress value.
	###
	update: Ext.emptyFn
	
	###*
	* Returns the {@link Deft.promise.Promise} of a future value associated 
	* with this {@link Deft.promise.Deferred}.
	*
	* @return {Deft.promise.Promise} Promise of the associated future value.
	###
	getPromise: ->
		return @promise
)