###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A Deferred manages the state of an asynchronous process that will eventually be exposed to external code via a Deft.promise.Promise.
###
Ext.define( 'Deft.promise.Deferred',
	alternateClassName: [ 'Deft.Deferred' ]
	requires: [
		'Deft.promise.Promise'
	]
	
	constructor: ->
		@state = 'pending'
		@progress = undefined
		@value = undefined
		
		@progressCallbacks = []
		@successCallbacks  = []
		@failureCallbacks  = []
		@cancelCallbacks   = []
		
		@promise = Ext.create( 'Deft.Promise', @ )
		
		return @
	
	###*
	* Returns a new {@link Deft.promise.Promise} with the specified callbacks registered to be called when this {@link Deft.promise.Deferred} is resolved, rejected, updated or cancelled.
	###
	then: ( callbacks ) ->
		if Ext.isObject( callbacks )
			{ success: successCallback, failure: failureCallback, progress: progressCallback, cancel: cancelCallback, scope: scope } = callbacks
		else
			[ successCallback, failureCallback, progressCallback, cancelCallback, scope ] = arguments
		
		for callback in [ successCallback, failureCallback, progressCallback, cancelCallback ]
			if not ( Ext.isFunction( callback ) or callback is null or callback is undefined )
				Ext.Error.raise( msg: 'Error while configuring callback: a non-function specified.' )
		
		deferred = Ext.create( 'Deft.promise.Deferred' )
		
		wrapCallback = ( callback, action ) ->
			return ( value ) ->
				if Ext.isFunction( callback )
					try
						result = callback.call( scope, value )
						if result instanceof Ext.ClassManager.get( 'Deft.promise.Promise' ) or result instanceof Ext.ClassManager.get( 'Deft.promise.Deferred' )
							result.then( Ext.bind( deferred.resolve, deferred ), Ext.bind( deferred.reject, deferred ), Ext.bind( deferred.update, deferred ), Ext.bind( deferred.cancel, deferred ) )
						else
							deferred.resolve( result )
					catch error
						deferred.reject( error )
				else
					deferred[ action ]( value )
				return
		
		@register( wrapCallback( successCallback, 'resolve' ), @successCallbacks, 'resolved',  @value )
		@register( wrapCallback( failureCallback, 'reject'  ), @failureCallbacks, 'rejected',  @value )	
		@register( wrapCallback( cancelCallback,  'cancel'  ), @cancelCallbacks,  'cancelled', @value )
		
		wrapProgressCallback = ( callback ) ->
			return ( value ) ->
				if Ext.isFunction( callback )
					result = callback.call( scope, value )
					deferred.update( result )
				else
					deferred.update( value )
				return
		
		@register( wrapProgressCallback( progressCallback ), @progressCallbacks, 'pending', @progress )
		
		return deferred.getPromise()
	
	###*
	* Returns a new {@link Deft.promise.Promise} with the specified callback registered to be called when this {@link Deft.promise.Deferred} is rejected.
	###
	otherwise: ( callback, scope ) ->
		if Ext.isObject( callback )
			{ fn: callback, scope: scope } = callback
		return @then(
			failure: callback
			scope: scope
		)
	
	###*
	* Returns a new {@link Deft.promise.Promise} with the specified callback registered to be called when this {@link Deft.promise.Deferred} is either resolved, rejected, or cancelled.
	###
	always: ( callback, scope ) ->
		if Ext.isObject( callback )
			{ fn: callback, scope: scope } = callback
		return @then( 
			success: callback
			failure: callback
			cancel: callback
			scope: scope
		)
	
	###*
	* Update progress for this {@link Deft.promise.Deferred} and notify relevant callbacks.
	###
	update: ( progress ) ->
		if @state is 'pending'
			@progress = progress
			@notify( @progressCallbacks, progress )
		else
			if @state isnt 'cancelled'
				Ext.Error.raise( msg: 'Error: this Deferred has already been completed and cannot be modified.')
		return
	
	###*
	* Resolve this {@link Deft.promise.Deferred} and notify relevant callbacks.
	###
	resolve: ( value ) ->
		@complete( 'resolved', value, @successCallbacks )
		return
	
	###*
	* Reject this {@link Deft.promise.Deferred} and notify relevant callbacks.
	###
	reject: ( error ) ->
		@complete( 'rejected', error, @failureCallbacks )
		return
	
	###*
	* Cancel this {@link Deft.promise.Deferred} and notify relevant callbacks.
	###
	cancel: ( reason ) ->
		@complete( 'cancelled', reason, @cancelCallbacks )
		return
	
	###*
	* Get this {@link Deft.promise.Deferred}'s associated {@link Deft.promise.Promise}.
	###
	getPromise: ->
		return @promise
	
	###*
	* Get this {@link Deft.promise.Deferred}'s current state.
	###
	getState: ->
		return @state
	
	###*
	* Register a callback for this {@link Deft.promise.Deferred} for the specified callbacks and state, immediately notifying with the specified value (if applicable).
	* @private
	###
	register: ( callback, callbacks, state, value ) ->
		if Ext.isFunction( callback )
			if @state is 'pending'
				callbacks.push( callback )
				if @state is state and value isnt undefined
					@notify( [ callback ], value )
			else 
				if @state is state
					@notify( [ callback ], value )
		return
	
	###*
	* Complete this {@link Deft.promise.Deferred} with the specified state and value.
	* @private
	###
	complete: ( state, value, callbacks ) ->
		if @state is 'pending'
			@state = state
			@value = value
			@notify( callbacks, value )
			@releaseCallbacks()
		else
			if @state isnt 'cancelled'
				Ext.Error.raise( msg: 'Error: this Deferred has already been completed and cannot be modified.')
		return
	
	###*
	* Notify the specified callbacks with the specified value.
	* @private
	###
	notify: ( callbacks, value ) ->
		for callback in callbacks
			callback( value )
		return
	
	###*
	* Release references to all callbacks registered with this {@link Deft.promise.Deferred}.
	* @private
	###
	releaseCallbacks: ->
		@progressCallbacks = null
		@successCallbacks  = null
		@failureCallbacks  = null
		@cancelCallbacks   = null
		return
	
)