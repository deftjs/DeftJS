###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).

sequence(), parallel(), pipeline() methods adapted from:
[when.js](https://github.com/cujojs/when)
Copyright (c) B Cavalier & J Hann
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* Utility class with static methods to create chains of Deft.promise.Promises objects.
###
Ext.define( 'Deft.promise.Chain',
	alternateClassName: [ 'Deft.Chain' ]
	requires: [
		'Deft.promise.Promise'
	]
	
	statics:
		###*
		* Execute an Array (or Deferred/Promise of an Array) of functions sequentially.
		* The specified functions may optionally return their results as Promises.
		* Returns a Promise of an Array of results for each function call (in the same order).
		###
		sequence: ( fns, scope ) ->
			return Deft.Promise.reduce( 
				fns
				( results, fn ) ->
					return Deft.Promise.when( fn.call( scope ) ).then( ( result ) -> 
						results.push( result ) 
						return results
					)
				[]
			)
		
		###*
		* Execute an Array (or Deferred/Promise of an Array) of functions in parallel.
		* The specified functions may optionally return their results as Promises.
		* Returns a Promise of an Array of results for each function call (in the same order).
		###
		parallel: ( fns, scope ) ->
			return Deft.Promise.map( 
				fns
				( fn ) ->
					return fn.call( scope )
			)
		
		###*
		* Execute an Array (or Deferred/Promise of an Array) of functions as a pipeline, where each function's result is passed to the subsequent function as input.
		* The specified functions may optionally return their results as Promises.
		* Returns a Promise of the result value for the final function in the pipeline.
		###		
		pipeline: ( fns, scope, initialValue ) ->
			return Deft.Promise.reduce( 
				fns
				( value, fn ) ->
					return fn.call( scope, value )
				initialValue
			)
)