###*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###


###*
* Common utility functions used by DeftJS.
###
Ext.define( 'Deft.util.Function',
	alternateClassName: [ 'Deft.Function' ]
	
	statics:
		###*
		* Creates a new wrapper function that spreads the passed Array over the target function arguments.
		###
		spread: ( fn, scope ) ->
			return ( array ) ->
				if not Ext.isArray( array )
					Ext.Error.raise( msg: "Error spreading passed Array over target function arguments: passed a non-Array." )
				return fn.apply( scope, array )
		
		###*
		* Returns a new wrapper function that caches the return value for previously processed function argument(s).
		###
		memoize: ( fn, scope, hashFn ) ->
			memo = {}
			return ( value ) ->
				key = if Ext.isFunction( hashFn ) then hashFn.apply( scope, arguments ) else value
				memo[ key ] = fn.apply( scope, arguments ) unless key of memo
				return memo[ key ]
)