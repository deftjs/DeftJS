###*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* Logger used by DeftJS. Output is shown in the console when using ext-dev/ext-all-dev.
* @private
###
Ext.define( 'Deft.log.Logger',
	alternateClassName: [ 'Deft.Logger' ]
	singleton: true

	log: ( message, priority = 'info' ) ->
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
		if Ext.getVersion( 'extjs' )?
			# Ext JS
			@log = ( message, priority = 'info' ) ->
				if priority is 'verbose'
					priority is 'info'
				if priority is 'deprecate'
					priority = 'warn'
				Ext.log(
					msg: message
					level: priority
				)
				return
		else
			# Sencha Touch
			if Ext.isFunction( Ext.Logger?.log )
				@log = Ext.bind( Ext.Logger.log, Ext.Logger )
		return
)
