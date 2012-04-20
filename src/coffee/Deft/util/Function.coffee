###*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

Ext.define( 'Deft.util.Function',
	alternateClassName: [ 'Deft.Function' ]
	
	statics:
		###*
		Creates a new wrapper function that spreads the passed Array over the target function arguments.
		###
		spread: ( fn, scope ) ->
			return ( array ) ->
				if not Ext.isArray( array )
					Ext.Error.raise( msg: "Error spreading passed Array over target function arguments: passed a non-Array." )
				fn.apply( scope, array )
				return
		###*
		Returns a new function that wraps the specified function that caches the results for previously processed inputs.
		###
		memoize: ( fn, hashFn ) ->
			memo = {}
			return ( value ) ->
				key = if Ext.isFunction( hashFn ) then hashFn.apply( @, arguments ) else value
				memo[ key ] = fn( value ) unless key of memo
				return memo[ key ]
)