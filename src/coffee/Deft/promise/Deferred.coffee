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
		'Deft.log.Logger'
		'Deft.promise.Promise'
	]
	
	id: null
	
	constructor: ( config = {} ) ->
		@id = config.id
		
		@state = 'pending'
		@progress = undefined
		@value = undefined
		
		@progressCallbacks = []
		@successCallbacks  = []
		@failureCallbacks  = []
		@cancelCallbacks   = []
		
		@promise = Ext.create( 'Deft.Promise', 
			id: if @id then "of #{ @id }" else null
			deferred: @
		)
		
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
				Ext.Error.raise( msg: "Error while registering callback with #{ @ }: a non-function specified." )
		
		deferred = Ext.create( 'Deft.promise.Deferred',
			id: "transformed result of #{ @ }"
		)
		
		@register( @wrapCallback( deferred, successCallback, scope, 'success', 'resolve' ), @successCallbacks, 'resolved',  @value )
		@register( @wrapCallback( deferred, failureCallback, scope, 'failure', 'reject'  ), @failureCallbacks, 'rejected',  @value )
		@register( @wrapCallback( deferred, cancelCallback,  scope, 'cancel',  'cancel'  ), @cancelCallbacks,  'cancelled', @value )
		
		@register( @wrapProgressCallback( deferred, progressCallback, scope ), @progressCallbacks, 'pending', @progress )
		
		Deft.Logger.log( "Returning #{ deferred.getPromise() }." )
		
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
		Deft.Logger.log( "#{ @ } updated with progress: #{ progress }" )
		if @state is 'pending'
			@progress = progress
			@notify( @progressCallbacks, progress )
		else
			if @state isnt 'cancelled'
				Ext.Error.raise( msg: "Error: this #{ @ } has already been completed and cannot be modified." )
		return
	
	###*
	* Resolve this {@link Deft.promise.Deferred} and notify relevant callbacks.
	###
	resolve: ( value ) ->
		Deft.Logger.log( "#{ @ } resolved with value: #{ value }" )
		@complete( 'resolved', value, @successCallbacks )
		return
	
	###*
	* Reject this {@link Deft.promise.Deferred} and notify relevant callbacks.
	###
	reject: ( error ) ->
		Deft.Logger.log( "#{ @ } rejected with error: #{ error }" )
		@complete( 'rejected', error, @failureCallbacks )
		return
	
	###*
	* Cancel this {@link Deft.promise.Deferred} and notify relevant callbacks.
	###
	cancel: ( reason ) ->
		Deft.Logger.log( "#{ @ } cancelled with reason: #{ reason }" )
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
	* Returns a text representation of this {@link Deft.promise.Deferred}, including its optional id.
	###
	toString: ->
		if @id?
			return "Deferred #{ @id }"
		return "Deferred"
	
	###*
	* Wraps a success, failure or cancel callback.
	* @private
	###
	wrapCallback: ( deferred, callback, scope, callbackType, action ) ->
		self = @
		if callback?
			Deft.Logger.log( "Registering #{ callbackType } callback for #{ self }." )
		return ( value ) ->
			if Ext.isFunction( callback )
				try
					Deft.Logger.log( "Calling #{ callbackType } callback registered for #{ self }." )
					result = callback.call( scope, value )
					if result instanceof Ext.ClassManager.get( 'Deft.promise.Promise' ) or result instanceof Ext.ClassManager.get( 'Deft.promise.Deferred' )
						Deft.Logger.log( "#{ deferred.getPromise() } will be completed based on the #{ result } returned by the #{ callbackType } callback." )
						result.then( Ext.bind( deferred.resolve, deferred ), Ext.bind( deferred.reject, deferred ), Ext.bind( deferred.update, deferred ), Ext.bind( deferred.cancel, deferred ) )
					else
						Deft.Logger.log( "#{ deferred.getPromise() } resolved with the value returned by the #{ callbackType } callback: #{ result }." )
						deferred.resolve( result )
				catch error
					if Ext.Array.contains( [ 'RangeError', 'ReferenceError', 'SyntaxError', 'TypeError' ], error.name )
						Deft.Logger.error( "Error: #{ callbackType } callback for #{ self } threw: #{ if error.stack? then error.stack else error }" )
					else
						Deft.Logger.log( "#{ deferred.getPromise() } rejected with the Error returned by the #{ callbackType } callback: #{ error }" )
					deferred.reject( error )
			else
				Deft.Logger.log( "#{ deferred.getPromise() } resolved with the value: #{ value }." )
				deferred[ action ]( value )
			return
	
	###*
	* Wraps a success, failure or cancel callback.
	* @private
	###
	wrapProgressCallback: ( deferred, callback, scope ) ->
		self = @
		if callback?
			Deft.Logger.log( "Registering progress callback for #{ self }." )
		return ( value ) ->
			if Ext.isFunction( callback )
				try
					Deft.Logger.log( "Calling progress callback registered for #{ self }." )
					result = callback.call( scope, value )
					Deft.Logger.log( "#{ deferred.getPromise() } updated with progress returned by the progress callback: #{ result }." )
					deferred.update( result )
				catch error
					Deft.Logger.error( "Error: progress callback registered for #{ self } threw: #{ if error.stack? then error.stack else error }" )
			else
				Deft.Logger.log( "#{ deferred.getPromise() } updated with progress: #{ value }" )
				deferred.update( value )
			return
	
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
				Ext.Error.raise( msg: "Error: this #{ @ } has already been completed and cannot be modified." )
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