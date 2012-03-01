Ext.define( 'Deft.util.Deferred',
	alternateClassName: [ 'Deft.Deferred' ]
	
	constructor: ->
		@state = 'pending'
		@progress = undefined
		@value = undefined
		
		@progressCallbacks = []
		@successCallbacks = []
		@errorCallbacks = []
		@cancelCallbacks = []
		
		@promise = Ext.create( 'Deft.Promise', @ )
		
		return @
	
	then: ( callbacks ) ->
		if Ext.isObject( callbacks )
			{ success: successCallback, error: errorCallback, progress: progressCallback, cancel: cancelCallback } = callbacks
		else
			[ successCallback, errorCallback, progressCallback, cancelCallback ] = arguments
		
		deferred = Ext.create( 'Deft.Deferred' )
		
		wrapCallback = ( callback, action ) ->
			return ( value ) ->
				if Ext.isFunction( callback )
					try
						result = callback( value )
						if result is undefined
							deferred[ action ]( value )
						else if result instanceof Ext.ClassManager.get( 'Deft.Promise' ) or result instanceof Ext.ClassManager.get( 'Deft.Deferred' )
							result.then( Ext.bind( deferred.resolve, deferred ), Ext.bind( deferred.reject, deferred ), Ext.bind( deferred.update, deferred ), Ext.bind( deferred.cancel, deferred ) )
						else
							deferred[ action ]( result )
					catch error
						deferred.reject( error )
				else
					deferred[ action ]( value )
				return
		
		@register( wrapCallback( progressCallback, 'update'  ), @progressCallbacks, 'pending',   @progress )
		@register( wrapCallback( successCallback,  'resolve' ), @successCallbacks,  'resolved',  @value    )
		@register( wrapCallback( errorCallback,    'reject'  ), @errorCallbacks,    'rejected',  @value    )
		@register( wrapCallback( cancelCallback,   'cancel'  ), @cancelCallbacks,   'cancelled', @value    )
		
		return deferred.promise
	
	always: ( alwaysCallback ) ->
		return @then( 
			success: alwaysCallback
			error: alwaysCallback
			cancel: alwaysCallback
		)
	
	update: ( progress ) ->
		if @state is 'pending'
			@progress = progress
			@notify( @progressCallbacks, progress )
		return
	
	resolve: ( value ) ->
		@complete( 'resolved', value, @successCallbacks )
		return
	
	reject: ( error ) ->
		@complete( 'rejected', error, @errorCallbacks )
		return
	
	cancel: ( reason ) ->
		@complete( 'cancelled', reason, @cancelCallbacks )
		return
		
	register: ( callback, callbacks, state, value ) ->
		if Ext.isFunction( callback )
			if @state is 'pending'
				callbacks.push( callback )
			if @state is state and value isnt undefined
				@notify( [ callback ], value )
		return
	
	complete: ( state, value, callbacks ) ->
		if @state is 'pending'
			@state = state
			@value = value
			@notify( callbacks, value )
			@releaseCallbacks()
		else
			Ext.Error.raise( 'Error: this Deferred has already been completed and cannot be modified.')
		return
	
	notify: ( callbacks, value ) ->
		for callback in callbacks
			callback( value )
		return
	
	releaseCallbacks: ->
		@progressCallbacks = null
		@successCallbacks = null
		@errorCallbacks = null
		@cancelCallbacks = null
		return
	
)