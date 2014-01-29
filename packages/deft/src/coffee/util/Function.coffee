###
Copyright (c) 2012-2014 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A collection of useful static methods for interacting with Functions.
###
Ext.define( 'Deft.util.Function',
	alternateClassName: [ 'Deft.Function' ]
	
	statics:
		###*
		* Returns a new wrapper function that caches the return value for previously processed function argument(s).
		* 
		* @param {Function} fn Function to wrap.
		* @param {Object} scope Optional scope in which to execute the wrapped function.
		* @param {Function} hashFn Optional function used to compute a hash key for storing the result, based on the arguments to the original function.
		* @return {Function} The new wrapper function.
		###
		memoize: ( fn, scope, hashFn ) ->
			memo = {}
			return ( value ) ->
				key = if Deft.isFunction( hashFn ) then hashFn.apply( scope, arguments ) else value
				memo[ key ] = fn.apply( scope, arguments ) unless key of memo
				return memo[ key ]
		
		###*
		* @method
		* Schedules the specified callback function to be executed on the next turn of the event loop.
		* 
		* @param {Function} fn Callback function.
		* @param {Object} scope Optional scope for the callback.
        * @param {Mixed[]} parameters Optional callback parameters.
		###
		nextTick: Ext.emptyFn

		###*
		* @method
		* Evalutes whether the specified value is a Function.
		* Also available as Deft.isFunction().
		* **NOTE:** Ext JS 4.2.0 and 4.2.1 shipped with a broken version of Ext.isFunction.
		* @param {Mixed} value Value to evaluate.
		* @return {Boolean}
		###
		isFunction: Ext.emptyFn

		###*
		* Creates a new wrapper function that spreads the passed Array over the target function arguments.
		* 
		* @param {Function} fn Function to wrap.
		* @param {Object} scope Optional scope in which to execute the wrapped function.
		* @return {Function} The new wrapper function.
		###
		spread: ( fn, scope ) ->
			return ( array ) ->
				if not Ext.isArray( array )
					Ext.Error.raise( msg: "Error spreading passed Array over target function arguments: passed a non-Array." )
				return fn.apply( scope, array )
,
	->
		if setImmediate?
			@nextTick = ( fn, scope, parameters ) ->
				if scope? or parameters?
					fn = Ext.Function.bind( fn, scope, parameters)
				setImmediate( fn )
				return
		else
			@nextTick = ( fn, scope, parameters ) ->
				if scope? or parameters?
					fn = Ext.Function.bind( fn, scope, parameters )
				setTimeout( fn, 0 )
				return

		if (typeof document isnt 'undefined' and typeof document.getElementsByTagName( 'body' ) is 'function')
			# Safari 3.x and 4.x return 'function' for typeof <NodeList> - fall back to Object.prototype.toString (slower)
			@isFunction = (value) -> !!value and toString.call(value) is '[object Function]'
		else
			@isFunction = (value) -> !!value and typeof value is 'function'

		Deft.isFunction = @isFunction

		return
)