Ext.define( 'Deft.util.Promise',
	alternateClassName: [ 'Deft.Promise' ]
	
	statics:
		when: ( promiseOrValue, callbacks ) ->
			if promiseOrValue instanceof Ext.ClassManager.get( 'Deft.util.Promise' ) or promiseOrValue instanceof Ext.ClassManager.get( 'Deft.util.Deferred' )
				return promiseOrValue.then( callbacks )
			else
				return Ext.create( 'Deft.util.Deferred' ).resolve( promiseOrValue ).then( callbacks )
		
		all: ( promisesOrValues, callbacks ) ->
			results = new Array[ promisesOrValues.length ]
			promise = @reduce( promisesOrValues, @reduceIntoArray, results )
			
			return @when( promise, callbacks )
		
		any: ( promisesOrValues, callbacks ) ->
			deferred = Ext.create( 'Deft.util.Deferred' )
			
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
			
			complete = ->
				updater = resolver = rejecter = -> return
				
			resolveFunction  = ( value ) -> resolver( value )
			rejectFunction   = ( value ) -> rejector( value )
			progressFunction = ( value ) -> updater( value )
			
			for index, promiseOrValue in promisesOrValues
				if index of promiseOrValue
					@when( promiseOrValue, resolveFunction, rejectFunction, progressFunction )
			
			return deferred.then( callbacks )
		
		map: ( promisesOrValues, mapFunction ) ->
			# Since the map function may be asynchronous, get all invocations of it into flight ASAP.
			results = new Array[ promisesOrValues.length ]
			for index, promiseOrValue in promisesOrValues
				if index of promisesOrValues
					results[ index ] = @when( promiseOrValue, mapFunction )
				
			# Then use reduce() to collect all the results.
			return @reduce( results, @reduceIntoArray, results )
		
		reduce: ( promisesOrValues, reduceFunction, initialValue ) ->
			# Wrap the reduce function with one that handles promises and then delegates to it.
			reduceArguments = [
				( previousValueOrPromise, currentValueOrPromise, currentIndex ) ->
					return @when( previousValueOrPromise, ( previousValue ) ->
						return @when( currentValueOrPromise, ( currentValue ) ->
							return reduceFunction( previousValue, currentValue, currentIndex, promisesOrValues )
						)
					)
			]
			
			if ( arguments.length is 3 )
				reduceArguments.push( initialValue )
			
			return Ext.create( 'Deft.util.Deferred' ).resolve( @reduceArray.apply( promisesOrValues, reduceArguments ) ).promise
		
		###*
		@private
		###
		reduceArray: ( reduceFunction, initialValue ) ->
			if Array.reduce?
				return Array.reduce( reduceFunction, initialValue )
			
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
					reduced = reduceFunc( reduced, array[ index ], index, array )
				index++
			
			return reduced
		
		###*
		@private
		###
		reduceIntoArray: ( previousValue, currentValue, currentIndex ) ->
			previousValue[ currentIndex ] = value
			return previousValue
	
	constructor: ( deferred ) ->
		@deferred = deferred
		return @
	
	then: ( callbacks ) ->
		return @deferred.then( callbacks )
	
	cancel: ( reason ) ->
		return @deferred.cancel( reason )
)