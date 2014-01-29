###
Copyright (c) 2012-2014 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).

Promise.when(), all(), any(), some(), map(), reduce(), delay() and timeout()
methods adapted from: [when.js](https://github.com/cujojs/when)
Copyright (c) B Cavalier & J Hann
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
Promises represent a future value; i.e., a value that may not yet be available.

A Promise's then() method is used to specify onFulfilled and onRejected
callbacks that will be notified when the future value becomes available. Those
callbacks can subsequently transform the value that was resolved or the reason
that was rejected. Each call to then() returns a new Promise of that
transformed value; i.e., a Promise that is resolved with the callback return
value or rejected with any error thrown by the callback.

## <u>[Basic Usage](https://github.com/deftjs/DeftJS/wiki/Promises%20API)</u>

In it's most basic and common form, a method will create and return a Promise like this:

    // A method in a service class which uses a Store and returns a Promise
    loadCompanies: function() {
      var deferred = Ext.create('Deft.Deferred');

      this.companyStore.load({

        callback: function(records, operation, success) {
          if (success) {
            deferred.resolve(records);
          } else {
            deferred.reject("Error loading Companies.");
          }
        }

      });

      return deferred.promise;
    }

You can see this method first creates a Deferred object. It then returns a Promise object for
use by the caller. Finally, in the asynchronous callback, it resolves the Deferred object if
the call was successful, and rejects the Deferred if the call failed.

The method which calls the above code and works with the returned Promise might look like:

    // Using a Promise returned by another object.
    loadCompanies: function() {

      this.companyService.loadCompanies().then({
        success: function(records) {
          // Do something with result.
        },
        failure: function(error) {
          // Do something on failure.
        }
      }).always(function() {
        // Do something whether call succeeded or failed
      });

    }

The calling code uses the Promise returned from the companyService.loadCompanies() method and
uses then() to attach success and failure handlers. Finally, an always() method call is chained
onto the returned Promise. This specifies a callback function that will run whether the underlying
call succeeded or failed.
###
Ext.define( 'Deft.promise.Promise',
	alternateClassName: [ 'Deft.Promise' ]
	requires: [
		'Deft.promise.Deferred'
		'Deft.util.Function'
	]

	statics:
		###*
		* Returns a new Promise that:
		*
		* * resolves immediately for the specified value, or
		* * resolves or rejects when the specified {@link Deft.promise.Promise Promise} (or third-party Promise or then()-able) is resolved or rejected.
		*
		* @param {Mixed} promiseOrValue A Promise (or third-party Promise or then()-able) or value.
		* @return {Deft.promise.Promise} A Promise of the specified Promise or value.
		###
		when: ( promiseOrValue ) ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			deferred.resolve( promiseOrValue )
			return deferred.promise
		
		###*
		* Determines whether the specified value is a Promise (including third-party untrusted Promises or then()-ables), based on the Promises/A specification feature test.
		* 
		* @param {Mixed} value A potential Promise.
		* @return {Boolean} A Boolean indicating whether the specified value was a Promise.
		###
		isPromise: ( value ) ->
			return ( Ext.isObject( value ) or Deft.isFunction( value ) ) and Deft.isFunction( value.then )
		
		###*
		* Returns a new Promise that will only resolve once all the specified `promisesOrValues` have resolved.
		* 
		* The resolution value will be an Array containing the resolution value of each of the `promisesOrValues`.
		*
		* @param {Mixed[]/Deft.promise.Promise[]/Deft.promise.Promise} promisesOrValues An Array of values or Promises, or a Promise of an Array of values or Promises.
		* @return {Deft.promise.Promise} A Promise of an Array of the resolved values.
		###
		all: ( promisesOrValues ) ->
			if not ( Ext.isArray( promisesOrValues ) or Deft.Promise.isPromise( promisesOrValues ) )
				throw new Error( 'Invalid parameter: expected an Array or Promise of an Array.' )
			return Deft.Promise.when( promisesOrValues ).then(
				( promisesOrValues ) ->
					remainingToResolve = promisesOrValues.length
					results = new Array( promisesOrValues.length )

					deferred = Ext.create( 'Deft.promise.Deferred' )

					if not remainingToResolve
						deferred.resolve( results )
					else
						resolve = ( item, index ) ->
							Deft.Promise.when( item ).then(
								( value ) ->
									results[ index ] = value
									if not --remainingToResolve
										deferred.resolve( results )
									return value
								( reason ) ->
									deferred.reject( reason )
							)

						for promiseOrValue, index in promisesOrValues
							if index of promisesOrValues
								resolve( promiseOrValue, index )
							else
								remainingToResolve--

					return deferred.promise
			)

		###*
		* Initiates a competitive race, returning a new Promise that will resolve when any one of the specified `promisesOrValues` have resolved, or will reject when all `promisesOrValues` have rejected or cancelled.
		* 
		* The resolution value will the first value of `promisesOrValues` to resolve.
		*
		* @param {Mixed[]/Deft.promise.Promise[]/Deft.promise.Promise} promisesOrValues An Array of values or Promises, or a Promise of an Array of values or Promises.
		* @return {Deft.promise.Promise} A Promise of the first resolved value.
		###
		any: ( promisesOrValues ) ->
			if not ( Ext.isArray( promisesOrValues ) or Deft.Promise.isPromise( promisesOrValues ) )
				throw new Error( 'Invalid parameter: expected an Array or Promise of an Array.' )
			return Deft.Promise.some( promisesOrValues, 1 )
				.then( 
					( array ) -> 
						return array[ 0 ]
					( error ) ->
						if error instanceof Error and error.message is 'Too few Promises were resolved.'
							throw new Error( 'No Promises were resolved.' )
						else
							throw error
				)
		
		###*
		* Initiates a competitive race, returning a new Promise that will resolve when `howMany` of the specified `promisesOrValues` have resolved, or will reject when it becomes impossible for `howMany` to resolve.
		* 
		* The resolution value will be an Array of the first `howMany` values of `promisesOrValues` to resolve.
		*
		* @param {Mixed[]/Deft.promise.Promise[]/Deft.promise.Promise} promisesOrValues An Array of values or Promises, or a Promise of an Array of values or Promises.
		* @param {Number} howMany The expected number of resolved values.
		* @return {Deft.promise.Promise} A Promise of the expected number of resolved values.
		###
		some: ( promisesOrValues, howMany ) ->
			if not ( Ext.isArray( promisesOrValues ) or Deft.Promise.isPromise( promisesOrValues ) )
				throw new Error( 'Invalid parameter: expected an Array or Promise of an Array.' )
			if not Ext.isNumeric( howMany ) or howMany <= 0
				throw new Error( 'Invalid parameter: expected a positive integer.' )
			return Deft.Promise.when( promisesOrValues ).then(
				( promisesOrValues ) ->
					values = []
					remainingToResolve = howMany
					remainingToReject = ( promisesOrValues.length - remainingToResolve ) + 1
					
					deferred = Ext.create( 'Deft.promise.Deferred' )
					
					if promisesOrValues.length < howMany
						deferred.reject( new Error( 'Too few Promises were resolved.' ) )
					else
						onResolve = ( value ) ->
							if remainingToResolve > 0
								values.push( value )
							remainingToResolve--
							if remainingToResolve is 0
								deferred.resolve( values )
							return value
						onReject = ( reason ) ->
							remainingToReject--
							if remainingToReject is 0
								deferred.reject( new Error( 'Too few Promises were resolved.' ) )
							return reason
						
						for promiseOrValue, index in promisesOrValues
							if index of promisesOrValues
								Deft.Promise.when( promiseOrValue ).then( onResolve, onReject )
					
					return deferred.promise
			)
		
		###*
		* Returns a new Promise that will automatically resolve with the specified Promise or value after the specified delay (in milliseconds).
		*
		* @param {Mixed} promiseOrValue A Promise or value.
		* @param {Number} milliseconds A delay duration (in milliseconds).
		* @return {Deft.promise.Promise} A Promise of the specified Promise or value that will resolve after the specified delay.
		###
		delay: ( promiseOrValue, milliseconds ) ->
			if arguments.length is 1
				milliseconds = promiseOrValue
				promiseOrValue = undefined
			milliseconds = Math.max( milliseconds, 0 )
			
			deferred = Ext.create( 'Deft.promise.Deferred' )
			setTimeout( 
				->
					deferred.resolve( promiseOrValue )
					return
				milliseconds
			)
			return deferred.promise
		
		###*
		* Returns a new Promise that will automatically reject after the specified timeout (in milliseconds) if the specified promise has not resolved or rejected.
		*
		* @param {Mixed} promiseOrValue A Promise or value.
		* @param {Number} milliseconds A timeout duration (in milliseconds).
		* @return {Deft.promise.Promise} A Promise of the specified Promise or value that enforces the specified timeout.
		###
		timeout: ( promiseOrValue, milliseconds ) ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			timeoutId = setTimeout( 
				->
					if timeoutId
						deferred.reject( new Error( 'Promise timed out.' ) )
					return
				milliseconds
			)
			
			cancelTimeout = ->
				clearTimeout( timeoutId )
				timeoutId = null
			
			Deft.Promise.when( promiseOrValue ).then(
				( value ) ->
					cancelTimeout()
					deferred.resolve( value )
					return
				( reason ) ->
					cancelTimeout()
					deferred.reject( reason )
					return
			)
			
			return deferred.promise
		
		###*
		* Returns a new function that wraps the specified function and caches the results for previously processed inputs.
		* 
		* Similar to {@link Deft.Function#memoize Deft.util.Function::memoize()}, except it allows for parameters that are Promises and/or values.
		*
		* @param {Function} fn A Function to wrap.
		* @param {Object} scope An optional scope in which to execute the wrapped function.
		* @param {Function} hashFn An optional function used to compute a hash key for storing the result, based on the arguments to the original function.
		* @return {Function} The new wrapper function.
		###
		memoize: ( fn, scope, hashFn ) ->
			memoizedFn = Deft.util.Function.memoize( fn, scope, hashFn )
			return ->
				return Deft.Promise.all( Ext.Array.toArray( arguments ) ).then( ( values ) ->
					return memoizedFn.apply( scope, values )
				)
		
		###*
		* Traditional map function, similar to `Array.prototype.map()`, that allows input to contain promises and/or values.
		* 
		* The specified map function may return either a value or a promise.
		*
		* @param {Mixed[]/Deft.promise.Promise[]/Deft.promise.Promise} promisesOrValues An Array of values or Promises, or a Promise of an Array of values or Promises.
		* @param {Function} mapFn A Function to call to transform each resolved value in the Array.
		* @return {Deft.promise.Promise} A Promise of an Array of the mapped resolved values.
		###
		map: ( promisesOrValues, mapFn ) ->
			if not ( Ext.isArray( promisesOrValues ) or Deft.Promise.isPromise( promisesOrValues ) )
				throw new Error( 'Invalid parameter: expected an Array or Promise of an Array.' )
			if not Deft.isFunction( mapFn )
				throw new Error( 'Invalid parameter: expected a function.' )
			return Deft.Promise.when( promisesOrValues ).then(
				( promisesOrValues ) ->
					remainingToResolve = promisesOrValues.length
					results = new Array( promisesOrValues.length )
					
					deferred = Ext.create( 'Deft.promise.Deferred' )
					
					if not remainingToResolve
						deferred.resolve( results )
					else
						resolve = ( item, index ) ->
							Deft.Promise.when( item )
								.then(
									( value ) ->
										return mapFn( value, index, results )
								)
								.then(
									( value ) ->
										results[ index ] = value
										if not --remainingToResolve
											deferred.resolve( results )
										return value
									( reason ) ->
										deferred.reject( reason )
								)
						
						for promiseOrValue, index in promisesOrValues
							if index of promisesOrValues
								resolve( promiseOrValue, index )
							else
								remainingToResolve--
					
					return deferred.promise
			)
		
		###*
		* Traditional reduce function, similar to `Array.reduce()`, that allows input to contain promises and/or values.
		*
		* @param {Mixed[]/Deft.promise.Promise[]/Deft.promise.Promise} promisesOrValues An Array of values or Promises, or a Promise of an Array of values or Promises.
		* @param {Function} reduceFn A Function to call to transform each successive item in the Array into the final reduced value.
		* @param {Mixed} initialValue An initial Promise or value.
		* @return {Deft.promise.Promise} A Promise of the reduced value.
		###
		reduce: ( promisesOrValues, reduceFn, initialValue ) ->
			if not ( Ext.isArray( promisesOrValues ) or Deft.Promise.isPromise( promisesOrValues ) )
				throw new Error( 'Invalid parameter: expected an Array or Promise of an Array.' )
			if not Deft.isFunction( reduceFn )
				throw new Error( 'Invalid parameter: expected a function.' )
			initialValueSpecified = arguments.length is 3
			return Deft.Promise.when( promisesOrValues ).then( 
				( promisesOrValues ) ->
					# Wrap the reduce function with one that handles promises and then delegates to it.
					reduceArguments = [
						( previousValueOrPromise, currentValueOrPromise, currentIndex ) ->
							return Deft.Promise.when( previousValueOrPromise ).then( ( previousValue ) ->
								return Deft.Promise.when( currentValueOrPromise ).then( ( currentValue ) ->
									return reduceFn( previousValue, currentValue, currentIndex, promisesOrValues )
								)
							)
					]
					
					if initialValueSpecified
						reduceArguments.push( initialValue )
					
					return Deft.Promise.reduceArray.apply( promisesOrValues, reduceArguments )
			)
		
		###*
		* Fallback implementation when Array.reduce is not available.
		* @private
		###
		reduceArray: ( reduceFn, initialValue ) ->
			# ES5 reduce implementation if native not available
			# See: http://es5.github.com/#x15.4.4.21 as there are many specifics and edge cases.
			# ES5 dictates that reduce.length === 1
			# This implementation deviates from ES5 spec in the following ways:
			# 1. It does not check if reduceFunc is a Callable
			index = 0
			array = Object( @ )
			length = array.length >>> 0
			args = arguments
			
			# If no initialValue, use first item of array (we know length !== 0 here) and adjust index to start at second item
			if args.length <= 1
				# Skip to the first real element in the array
				loop
					if index of array
						reduced = array[ index++ ]
						break
					# If we reached the end of the array without finding any real elements, it's a TypeError
					if ++index >= length
						throw new TypeError( 'Reduce of empty array with no initial value' )
			else
				# If initialValue provided, use it
				reduced = args[ 1 ]
			
			# Do the actual reduce
			while index < length
				# Skip holes
				if index of array
					reduced = reduceFn( reduced, array[ index ], index, array )
				index++
			
			return reduced

		###*
		* @private
		* Rethrows the specified Error on the next turn of the event loop.
		###
		rethrowError: ( error ) ->
			Deft.util.Function.nextTick(
				->
					throw error
			)
			return

	###*
	* @private
	* @property {Deft.promise.Resolver}
	* Internal Resolver for this Promise.
	###
	resolver: null

	###*
	* @private
	* NOTE: {@link Deft.promise.Deferred Deferreds} are the mechanism used to create new Promises.
	* @param {Deft.promise.Resolver} onRejected Callback to execute to transform a rejection reason.
	###
	constructor: ( @resolver ) ->
		return @

	###*
    * Attaches onFulfilled and onRejected callbacks that will be
	* notified when the future value becomes available.
	*
	* Those callbacks can subsequently transform the value that was
	* fulfilled or the error that was rejected. Each call to then()
	* returns a new Promise of that transformed value; i.e., a Promise
	* that is fulfilled with the callback return value or rejected with
	* any error thrown by the callback.
	*
	* @param {Function} onFulfilled Optional callback to execute to transform a fulfillment value.
	* @param {Function} onRejected Optional callback to execute to transform a rejection reason.
	* @param {Function} onProgress Optional callback function to be called with progress updates.
	* @param {Object} scope Optional scope for the callback(s).
	*
	* @return {Deft.promise.Promise} Promise that is fulfilled with the callback return value or rejected with any error thrown by the callback.
	###
	then: ( onFulfilled, onRejected, onProgress, scope ) ->
		if arguments.length is 1 and Ext.isObject( arguments[0] )
			{ success: onFulfilled, failure: onRejected, progress: onProgress, scope: scope } = arguments[0]
		if scope?
			if Deft.isFunction( onFulfilled )
				onFulfilled = Ext.Function.bind( onFulfilled, scope )
			if Deft.isFunction( onRejected )
				onRejected = Ext.Function.bind( onRejected, scope )
			if Deft.isFunction( onProgress )
				onProgress = Ext.Function.bind( onProgress, scope )
		return @resolver.then( onFulfilled, onRejected, onProgress )

	###*
	* Attaches an onRejected callback that will be notified if this
	* Promise is rejected.
	*
	* The callback can subsequently transform the reason that was
	* rejected. Each call to otherwise() returns a new Promise of that
	* transformed value; i.e., a Promise that is resolved with the
	* original resolved value, or resolved with the callback return value
	* or rejected with any error thrown by the callback.
	*
	* @param {Function} onRejected Callback to execute to transform a rejection reason.
	* @param {Object} scope Optional scope for the callback.
	*
	* @return {Deft.promise.Promise} Promise of the transformed future value.
	###
	otherwise: ( onRejected, scope ) ->
		if arguments.length is 1 and Ext.isObject( arguments[0] )
			{ fn: onRejected, scope: scope } = arguments[0]
		if scope?
			onRejected = Ext.Function.bind( onRejected, scope )
		return @resolver.then( null, onRejected )

	###*
	* Attaches an onCompleted callback that will be notified when this
	* Promise is completed.
	*
	* Similar to "finally" in "try..catch..finally".
	*
	* NOTE: The specified callback does not affect the resulting Promise's
	* outcome; any return value is ignored and any Error is rethrown.
	*
	* @param {Function} onCompleted Callback to execute when the Promise is resolved or rejected.
	* @param {Object} scope Optional scope for the callback.
	*
	* @return {Deft.promise.Promise} A new "pass-through" Promise that is resolved with the original value or rejected with the original reason.
	###
	always: ( onCompleted, scope ) ->
		if arguments.length is 1 and Ext.isObject( arguments[0] )
			{ fn: onCompleted, scope: scope } = arguments[0]
		if scope?
			onCompleted = Ext.Function.bind( onCompleted, scope )
		return @resolver.then(
			( value ) ->
				try
					onCompleted()
				catch error
					Deft.promise.Promise.rethrowError( error )
				return value
			( reason ) ->
				try
					onCompleted()
				catch error
					Deft.promise.Promise.rethrowError( error )
				throw reason
		)

	###*
	* Terminates a Promise chain, ensuring that unhandled rejections will
	* be rethrown as Errors.
	*
	* One of the pitfalls of interacting with Promise-based APIs is the
	* tendency for important errors to be silently swallowed unless an
	* explicit rejection handler is specified.
	*
	* For example:
	*
	*     promise
	*         .then( function () {
	*             // logic in your callback throws an error and it is interpreted as a rejection.
	*             throw new Error("Boom!");
	*         });
	*     // The Error was not handled by the Promise chain and is silently swallowed.
	*
	* This problem can be addressed by terminating the Promise chain with the done() method:
	*
	*     promise
	*         .then( function () {
	*             // logic in your callback throws an error and it is interpreted as a rejection.
	*             throw new Error("Boom!");
	*         })
	*         .done();
	*     // The Error was not handled by the Promise chain and is rethrown by done() on the next tick.
	*
	* The done() method ensures that any unhandled rejections are rethrown
	* as Errors.
	###
	done: ->
		@resolver.then( null, Deft.promise.Promise.rethrowError );
		return

	###*
	* Cancels this Promise if it is still pending, triggering a rejection
	* with a CancellationError that will propagate to any Promises
	* originating from this Promise.
	*
	* NOTE: Cancellation only propagates to Promises that branch from the
	* target Promise. It does not traverse back up to parent branches, as
	* this would reject nodes from which other Promises may have branched,
	* causing unintended side-effects.
	*
	* @param {Error} reason Cancellation reason.
	###
	cancel: ( reason = null ) ->
		@resolver.reject( new CancellationError( reason ) )
		return

	###*
	* Logs the resolution or rejection of this Promise with the specified
	* category and optional identifier. Messages are logged via all
	* registered custom logger functions.
	*
	* @param {String} identifier An optional identifier to incorporate into the resulting log entry.
	*
	* @return {Deft.promise.Promise} A new "pass-through" Promise that is resolved with the original value or rejected with the original reason.
	###
	log: ( identifier = '' ) ->
		return @resolver.then(
			( value ) ->
				Deft.Logger.log( "#{ identifier or 'Promise' } resolved with value: #{ value }" )
				return value
			( reason ) ->
				Deft.Logger.log( "#{ identifier or 'Promise' } rejected with reason: #{ reason }" )
				throw reason
		)
,
	->
		# Use native reduce implementation, if available.
		if Array::reduce?
			@reduceArray = Array::reduce
		
		# Define and export custom CancellationError
		target = exports ? window
		target.CancellationError = 
			( reason ) ->
				if Error.captureStackTrace
					Error.captureStackTrace( @, CancellationError )
				@name = 'Canceled'
				@message = reason
				return
		target.CancellationError.prototype = new Error()
		target.CancellationError.constructor = target.CancellationError
		return
)