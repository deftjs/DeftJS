###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* Logger used by DeftJS.
* 
* Output is displayed in the console when using `ext-dev`/`ext-all-dev` or `sencha-debug`/`sencha-all-debug`.
*
* @private
###
Ext.define( 'Deft.log.Logger',
	alternateClassName: [ 'Deft.Logger' ]
	requires: [
		'Deft.util.Function'
	]
	singleton: true

	###*
	* Logs a message with the specified priority.
	*
	* @param {String} message The message to log.
	* @param {String} priority The priority of the log message. Valid values are: `verbose`, `info`, `deprecate`, `warn` and `error`.
	###
	log: ( message, priority = 'info' ) ->
		# NOTE: Stubbed implementation, replaced in class creation callback below.
		return

	###*
	* Logs a message with 'verbose' priority.
	*
	* @param {String} message The message to log.
	###
	verbose: ( message ) ->
		@log( message, 'verbose' )
		return

	###*
	* Logs a message with 'info' priority.
	*
	* @param {String} message The message to log.
	###
	info: ( message ) ->
		@log( message, 'info' )
		return

	###*
	* Logs a message with 'deprecate' priority.
	*
	* @param {String} message The message to log.
	###
	deprecate: ( message ) ->
		@log( message, 'deprecate' )
		return

	###*
	* Logs a message with 'warn' priority.
	*
	* @param {String} message The message to log.
	###
	warn: ( message ) ->
		@log( message, 'warn' )
		return

	###*
	* Logs a message with 'error' priority.
	*
	* @param {String} message The message to log.
	###
	error: ( message ) ->
		@log( message, 'error' )
		return
,
	->
		if Ext.getVersion( 'extjs' )?
			# Ext JS
			@log = ( message, priority = 'info' ) ->
				if priority is 'verbose'
					priority = 'info'
				if priority is 'deprecate'
					priority = 'warn'
				Ext.log(
					msg: message
					level: priority
				)
				return
		else
			# Sencha Touch
			@log = ( message, priority = 'info' ) ->
				if Ext.Logger? and Deft.isFunction( Ext.Logger.log )
					Ext.Logger.log( message, priority )
				return
		return
)
