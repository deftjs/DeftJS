###*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

Ext.define( 'Deft.util.Function',
	alternateClassName: [ 'Deft.Function' ]
	
	statics:
		###*
		TODO: document
		###
		spread: ( fn, scope ) ->
			return ( array ) ->
				if not Ext.isArray( array )
					Ext.Error.raise( "Error spreading passed Array to target function arguments: passed a non-Array." )
				fn.apply( scope, array )
)