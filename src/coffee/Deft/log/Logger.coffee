###*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

Ext.define( 'Deft.log.Logger',
	alternateClassName: [ 'Deft.Logger' ]
	singleton: true

	log: ( message, priority ) ->
		return

	error: ( message ) ->
		@log( message, 'error' )
		return

	info: ( message ) ->
		@log( message, 'info' )
		return

	verbose: ( message ) ->
		@log( message, 'verbose' )
		return

	warn: ( message ) ->
		@log( message, 'warn' )
		return

	deprecate: ( message ) ->
		@log( message, 'deprecate' )
		return
,
	->
		if Ext.isFunction( Ext.Logger?.log )
			@log = Ext.bind( Ext.Logger.log, Ext.Logger )
		else if Ext.isFunction( Ext.log )
			@log = ( message, priority = 'info' ) ->
				if priority is 'deprecate'
					priority = 'warn'
				Ext.log(
					msg: message
					level: priority
				)
				return

		return
)
