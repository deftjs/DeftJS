###
Copyright (c) 2012-2014 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* @private
* Resolvers are used internally by Deferreds to create, resolve and reject
* Promises, and to propagate fulfillment and rejection.
*
* Developers never directly interact with a Resolver.
*
* Each Deferred has an associated Resolver, and each Resolver has an
* associated Promise. A Deferred delegates resolve() and reject() calls to
* its Resolver's resolve() and reject() methods. A Promise delegates
* then() calls to its Resolver's then() method. In this way, access to
* Resolver operations are divided between producer (Deferred) and consumer
* (Promise) roles.
*
* When a Resolver's resolve() method is called, it fulfills with the
* optionally specified value. If resolve() is called with a then-able
* (i.e.a Function or Object with a then() function, such as another
* Promise) it assimilates the then-able's result; the Resolver provides
* its own resolve() and reject() methods as the onFulfilled or onRejected
* arguments in a call to that then-able's then() function. If an error is
* thrown while calling the then-able's then() function (prior to any call
* back to the specified resolve() or reject() methods), the Resolver
* rejects with that error. If a Resolver's resolve() method is called with
* its own Promise, it rejects with a TypeError.
*
* When a Resolver's reject() method is called, it rejects with the
* optionally specified reason.
*
* Each time a Resolver's then() method is called, it captures a pair of
* optional onFulfilled and onRejected callbacks and returns a Promise of
* the Resolver's future value as transformed by those callbacks.
###
Ext.define( 'Deft.promise.Resolver',
	alternateClassName: [ 'Deft.Resolver' ]
	requires: [
		'Deft.promise.Consequence'
	]

	###*
	* @property {Deft.promise.Promise}
	* Promise of the future value of this Deferred.
	###
	promise: null

	###*
    * @private
	* @property {Deft.promise.Consequence[]}
	* Pending Consequences chained to this Resolver.
	###
	consequences: []

	###*
    * @private
	* @property {Boolean}
    * Indicates whether this Resolver has been completed.
    ###
	completed: false

	###*
    * @private
	* @property {String}
    * The completion action (i.e. 'fulfill' or 'reject').
	###
	completionAction: null

	###*
    * @private
	* @property {Mixed}
    * The completion value (i.e. resolution value or rejection error).
	###
	completionValue: null

	constructor: ->
		@promise = Ext.create( 'Deft.promise.Promise', @ )
		@consequences = []
		@completed = false
		@completionAction = null
		@completionValue = null
		return @

	###*
	* Used to specify onFulfilled and onRejected callbacks that will be
	* notified when the future value becomes available.
	*
	* Those callbacks can subsequently transform the value that was
	* fulfilled or the error that was rejected. Each call to then()
	* returns a new Promise of that transformed value; i.e., a Promise
	* that is fulfilled with the callback return value or rejected with
	* any error thrown by the callback.
	*
	* @param {Function} onFulfilled (Optional) callback to execute to transform a fulfillment value.
	* @param {Function} onRejected (Optional) callback to execute to transform a rejection reason.
	* @param {Function} onProgress (Optional) callback to execute to transform a progress value.
	*
	* @return Promise that is fulfilled with the callback return value or rejected with any error thrown by the callback.
	###
	then: ( onFulfilled, onRejected, onProgress ) ->
		consequence = Ext.create( 'Deft.promise.Consequence', onFulfilled, onRejected, onProgress )
		if @completed
			consequence.trigger( @completionAction, @completionValue )
		else
			@consequences.push( consequence )
		return consequence.promise

	###*
	* Resolve this Resolver with the (optional) specified value.
	*
	* If called with a then-able (i.e.a Function or Object with a then()
	* function, such as another Promise) it assimilates the then-able's
	* result; the Resolver provides its own resolve() and reject() methods
	* as the onFulfilled or onRejected arguments in a call to that
	* then-able's then() function.  If an error is  thrown while calling
	* the then-able's then() function (prior to any call back to the
	* specified resolve() or reject() methods), the Resolver rejects with
	* that error. If a Resolver's resolve() method is called with its own
	* Promise, it rejects with a TypeError.
	*
	* Once a Resolver has been fulfilled or rejected, it is considered to be complete
	* and subsequent calls to resolve() or reject() are ignored.
	*
	* @param {Mixed} value Value to resolve as either a fulfillment value or rejection reason.
	###
	resolve: ( value ) ->
		if @completed
			return
		try
			if value is @promise
				throw new TypeError( 'A Promise cannot be resolved with itself.' )
			if ( Ext.isObject( value ) or Deft.isFunction( value ) ) and Deft.isFunction( thenFn = value.then )
				isHandled = false
				try
					self = @
					thenFn.call(
						value
						( value ) ->
							if not isHandled
								isHandled = true
								self.resolve( value )
							return
						( error ) ->
							if not isHandled
								isHandled = true
								self.reject( error )
							return
					)
				catch error
					@reject( error ) if not isHandled
			else
				@complete( 'fulfill', value )
		catch error
			@reject( error )
		return

	###*
	* Reject this Resolver with the specified reason.
	*
	* Once a Resolver has been rejected, it is considered to be complete
	* and subsequent calls to resolve() or reject() are ignored.
	*
	* @param {Error} reason Rejection reason.
	###
	reject: ( reason ) ->
		if @completed
			return
		@complete( 'reject', reason )
		return

	###*
	* Updates progress for this Resolver, if it is still pending, triggering it to execute the 'onProgress' callback and propagate the resulting transformed progress value to Resolvers that originate from this Resolver.
	*
	* @param {Mixed} progress The progress value.
	###
	update: ( progress ) ->
		if @completed
			return
		for consequence in @consequences
			consequence.update( progress )
		return

	###*
    * @private
	* Complete this Resolver with the specified action and value.
	*
	* @param {String} action Completion action (i.e. 'fufill' or 'reject').
	* @param {Mixed} value Fulfillment value or rejection reason.
	###
	complete: ( action, value ) ->
		@completionAction = action
		@completionValue = value
		@completed = true
		for consequence in @consequences
			consequence.trigger( @completionAction, @completionValue )
		@consequences = null
		return
)