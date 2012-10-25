###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).

Promise.when(), all(), any(), map() and reduce() methods adapted from:
[when.js](https://github.com/cujojs/when)
Copyright (c) B Cavalier & J Hann
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A Promise represents the result of a future value that has not been defined yet, typically because it is created asynchronously. Used in conjunction with Deft.promise.Deferred.
###
Ext.define( 'Deft.promise.Promise',
	alternateClassName: [ 'Deft.Promise' ]
	
	statics:
		###*
		* Returns a new {@link Deft.promise.Promise} that:
		* - resolves immediately for the specified value, or
		* - resolves, rejects, updates or cancels when the specified {@link Deft.promise.Deferred} or {@link Deft.promise.Promise} is resolved, rejected, updated or cancelled.
		###
		when: ( promiseOrValue ) ->
			if promiseOrValue instanceof Ext.ClassManager.get( 'Deft.promise.Promise' ) or promiseOrValue instanceof Ext.ClassManager.get( 'Deft.promise.Deferred' )
				return promiseOrValue.then()
			else if Ext.isObject( promiseOrValue ) and Ext.isFunction( promiseOrValue.then )
				deferred = Ext.create( 'Deft.promise.Deferred' )
				promiseOrValue.then(
					( value ) -> 
						deferred.resolve( value )
						return
					( error ) -> 
						deferred.reject( error )
						return
				)
				return deferred.then()
			else
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.resolve( promiseOrValue )
				return deferred.then()
		
		###*
		* Returns a new {@link Deft.promise.Promise} that will only resolve once all the specified `promisesOrValues` have resolved.
		* The resolution value will be an Array containing the resolution value of each of the `promisesOrValues`.
		###
		all: ( promisesOrValues ) ->
			return @when( promisesOrValues ).then( 
				success: ( promisesOrValues ) ->
					deferred = Ext.create( 'Deft.promise.Deferred' )
					
					total = promisesOrValues.length
					resolvedValues = new Array( promisesOrValues )
					resolvedCount = 0
					
					updater = ( progress ) ->
						deferred.update( progress )
						return
					resolver = ( index, value ) ->
						resolvedValues[ index ] = value
						resolvedCount++
						if resolvedCount is total
							complete()
							deferred.resolve( resolvedValues )
						return
					rejecter = ( error ) ->
						complete()
						deferred.reject( error )
						return
					canceller = ( reason ) ->
						complete()
						deferred.cancel( reason )
						return
					
					complete = ->
						updater = resolver = rejecter = canceller = Ext.emptyFn
					
					createSuccessFunction = ( index ) ->
						return ( value ) -> resolver( index, value )
					
					failureFunction  = ( value ) -> rejecter( value )
					progressFunction = ( value ) -> updater( value )
					cancelFunction   = ( value ) -> canceller( value )
					
					for promiseOrValue, index in promisesOrValues
						if index of promisesOrValues
							@when( promiseOrValue )
								.then( 
									success: createSuccessFunction( index )
									failure: failureFunction
									progress: progressFunction
									cancel: cancelFunction
								)
					
					return deferred.getPromise()
				scope: @
			)
		
		
		###*
		* Returns a new {@link Deft.promise.Promise} that will only resolve once any one of the the specified `promisesOrValues` has resolved.
		* The resolution value will be the resolution value of the triggering `promiseOrValue`.
		###
		any: ( promisesOrValues ) ->
			return @when( promisesOrValues ).then( 
				success: ( promisesOrValues ) ->
					deferred = Ext.create( 'Deft.promise.Deferred' )
					
					updater = ( progress ) ->
						deferred.update( progress )
						return
					resolver = ( value ) ->
						complete()
						deferred.resolve( value )
						return
					rejecter = ( error ) ->
						complete()
						deferred.reject( error )
						return
					canceller = ( reason ) ->
						complete()
						deferred.cancel( reason )
					
					complete = ->
						updater = resolver = rejecter = canceller = Ext.emptyFn
					
					successFunction  = ( value ) -> resolver( value )
					failureFunction  = ( value ) -> rejecter( value )
					progressFunction = ( value ) -> updater( value )
					cancelFunction   = ( value ) -> canceller( value )
					
					for promiseOrValue, index in promisesOrValues
						if index of promisesOrValues
							@when( promiseOrValue )
								.then( 
									success: successFunction
									failure: failureFunction
									progress: progressFunction
									cancel: cancelFunction
								)
					
					return deferred.getPromise()
				scope: @
			)
		
		###*
		* Returns a new function that wraps the specified function and caches the results for previously processed inputs.
		* Similar to `Deft.util.Function::memoize()`, except it allows input to contain promises and/or values.
		###
		memoize: ( fn, scope, hashFn ) ->
			memoizedFn = Deft.util.Function.memoize( fn, scope, hashFn )
			return Ext.bind(
				->
					return @all( Ext.Array.toArray( arguments ) ).then( ( values ) ->
						return memoizedFn.apply( scope, values )
					)
				@
			)
		
		###*
		* Traditional map function, similar to `Array.prototype.map()`, that allows input to contain promises and/or values.
		* The specified map function may return either a value or a promise.
		###
		map: ( promisesOrValues, mapFunction ) ->
			createCallback = ( index ) ->
				return ( value ) -> mapFunction( value, index, promisesOrValues )
			
			return @when( promisesOrValues ).then( 
				success: ( promisesOrValues ) ->
					# Since the map function may be asynchronous, get all invocations of it into flight ASAP.
					results = new Array( promisesOrValues.length )
					for promiseOrValue, index in promisesOrValues
						if index of promisesOrValues
							results[ index ] = @when( promiseOrValue ).then( createCallback( index ) )
					
					# Then use reduce() to collect all the results.
					return @reduce( results, @reduceIntoArray, results )
				scope: @
			)
		
		###*
		* Traditional reduce function, similar to `Array.reduce()`, that allows input to contain promises and/or values.
		###
		reduce: ( promisesOrValues, reduceFunction, initialValue ) ->
			initialValueSpecified = arguments.length is 3
			return @when( promisesOrValues ).then( 
				success: ( promisesOrValues ) ->
					# Wrap the reduce function with one that handles promises and then delegates to it.
					whenFunction = @when
					reduceArguments = [
						( previousValueOrPromise, currentValueOrPromise, currentIndex ) ->
							return whenFunction( previousValueOrPromise ).then( ( previousValue ) ->
								return whenFunction( currentValueOrPromise ).then( ( currentValue ) ->
										return reduceFunction( previousValue, currentValue, currentIndex, promisesOrValues )
								)
							)
					]
					
					if initialValueSpecified
						reduceArguments.push( initialValue )
					
					return @when( @reduceArray.apply( promisesOrValues, reduceArguments ) )
				scope: @
			)
		
		###*
		* Fallback implementation when Array.reduce is not available.
		* @private
		###
		reduceArray: ( reduceFunction, initialValue ) ->
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
						throw new TypeError()
			else
				# If initialValue provided, use it
				reduced = args[ 1 ]
			
			# Do the actual reduce
			while index < length
				# Skip holes
				if index of array
					reduced = reduceFunction( reduced, array[ index ], index, array )
				index++
			
			return reduced
		
		###*
		* @private
		###
		reduceIntoArray: ( previousValue, currentValue, currentIndex ) ->
			previousValue[ currentIndex ] = currentValue
			return previousValue
	
	constructor: ( deferred ) ->
		@deferred = deferred
		return @
	
	###*
	* Returns a new {@link Deft.promise.Promise} with the specified callbacks registered to be called when this {@link Deft.promise.Promise} is resolved, rejected, updated or cancelled.
	###
	then: ( callbacks ) ->
		return @deferred.then.apply( @deferred, arguments )
	
	###*
	* Returns a new {@link Deft.promise.Promise} with the specified callback registered to be called when this {@link Deft.promise.Promise} is rejected.
	###	
	otherwise: ( callback, scope ) ->
		return @deferred.otherwise.apply( @deferred, arguments )
		
	###*
	* Returns a new {@link Deft.promise.Promise} with the specified callback registered to be called when this {@link Deft.promise.Promise} is resolved, rejected or cancelled.
	###	
	always: ( callback, scope ) ->
		return @deferred.always.apply( @deferred, arguments )
	
	###*
	* Cancel this {@link Deft.promise.Promise} and notify relevant callbacks.
	###
	cancel: ( reason ) ->
		return @deferred.cancel( reason )
	
	###*
	* Get this {@link Deft.promise.Promise}'s current state.
	###
	getState: ->
		return @deferred.getState()
,
	->
		# Use native reduce implementation, if available.
		if Array::reduce?
			@reduceArray = Array::reduce
		return
)