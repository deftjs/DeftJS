###
Copyright (c) 2012-2014 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* @private
* Consequences are used internally by a Resolver to capture and notify
* callbacks, and propagate their transformed results as fulfillment or
* rejection.
*
* Developers never directly interact with a Consequence.
*
* A Consequence forms a chain between two Resolvers, where the result of
* the first Resolver is transformed by the corresponding callback before
* being applied to the second Resolver.
*
* Each time a Resolver's then() method is called, it creates a new
* Consequence that will be triggered once its originating Resolver has
* been fulfilled or rejected. A Consequence captures a pair of optional
* onFulfilled and onRejected callbacks.
*
* Each Consequence has its own Resolver (which in turn has a Promise)
* that is resolved or rejected when the Consequence is triggered. When a
* Consequence is triggered by its originating Resolver, it calls the
* corresponding callback and propagates the transformed result to its own
* Resolver; resolved with the callback return value or rejected with any
* error thrown by the callback.
###
Ext.define( 'Deft.promise.Consequence',
	alternateClassName: [ 'Deft.Consequence' ]
	requires: [
		'Deft.util.Function'
	]

	###*
    * @property {Deft.promise.Promise}
    * Promise of the future value of this Consequence.
    ###
	promise: null

	###*
    * @private
    * @property {Deft.promise.Resolver}
    * Internal Resolver for this Consequence.
    ###
	resolver: null

	###*
    * @private
    * @property {Function}
    Callback to execute when this Consequence is triggered with a fulfillment value.
    ###
	onFulfilled: null

	###*
    * @private
    * @property {Function}
    Callback to execute when this Consequence is triggered with a rejection reason.
	###
	onRejected: null

	###*
    * @private
    * @property {Function}
    Callback to execute when this Consequence is updated with a progress value.
	###
	onProgress: null

	###*
	* @param {Function} onFulfilled Callback to execute to transform a fulfillment value.
	* @param {Function} onRejected Callback to execute to transform a rejection reason.
	###
	constructor: ( @onFulfilled, @onRejected, @onProgress ) ->
		@resolver = Ext.create( 'Deft.promise.Resolver' )
		@promise = @resolver.promise
		return @

	###*
    * Trigger this Consequence with the specified action and value.
	*
	* @param {String} action Completion action (i.e. fulfill or reject).
	* @param {Mixed} value Fulfillment value or rejection reason.
	###
	trigger: ( action, value ) ->
		switch action
			when 'fulfill'
				@propagate( value, @onFulfilled, @resolver, @resolver.resolve )
			when 'reject'
				@propagate( value, @onRejected, @resolver, @resolver.reject )
		return

	###*
	* Update this Consequence with the specified progress value.
	*
	* @param {Mixed} value Progress value.
	###
	update: ( progress ) ->
		progress = @onProgress( progress ) if Deft.isFunction( @onProgress )
		@resolver.update( progress )
		return

	###*
	* @private
	* Transform and propagate the specified value using the
    * optional callback and propagate the transformed result.
	*
	* @param {Mixed} value Value to transform and/or propagate.
	* @param {Function} callback (Optional) callback to use to transform the value.
	* @param {Function} resolver Resolver to use to propagate the value, if no callback was specified.
	* @param {Function} resolverMethod Resolver method to call to propagate the value, if no callback was specified.
	###
	propagate: ( value, callback, resolver, resolverMethod ) ->
		if Deft.isFunction( callback )
			@schedule( ->
				try
					resolver.resolve( callback( value ) )
				catch error
					resolver.reject( error )
				return
			)
		else
			resolverMethod.call( @resolver, value )
		return

	###*
	* @private
	* @method
	* Schedules the specified callback function to be executed on
    * the next turn of the event loop.
	*
	* @param {Function} callback Callback function.
    * @param {Mixed[]} parameters Optional callback parameters.
	* @param {Object} scope Optional scope for the callback.
	###
	schedule: Ext.emptyFn
,
	->
		nextTick = if setImmediate? then setImmediate else ( task ) -> setTimeout( task, 0 )

		class CallbackQueue
			constructor: ->
				queuedCallbacks = new Array(1e4)
				queuedCallbackCount = 0
				execute = ->
					index = 0
					while index < queuedCallbackCount
						queuedCallbacks[ index ]()
						queuedCallbacks[ index ] = null
						index++
					queuedCallbackCount = 0
					return
				@schedule = ( callback ) ->
					queuedCallbacks[ queuedCallbackCount++ ] = callback
					nextTick( execute ) if queuedCallbackCount is 1
					return

		callbackQueue = new CallbackQueue()

		@::schedule = ( callback, parameters, scope ) ->
			callbackQueue.schedule( callback, parameters, scope )
			return

		return
)
