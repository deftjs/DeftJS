###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A lightweight Application template class.
###
Ext.define( 'Deft.mvc.Application',
	alternateClassName: [ 'Deft.Application' ]
	
	###*
	* Indicates whether this Application instance has been initialized.
	###
	initialized = false
	
	###*
	* @param {Object} [config] Configuration object.
	###
	constructor: ( config = {} ) ->
		@initConfig( config )
		Ext.onReady(
			->
				@init()
				@initialized = true
				return
			@
		)
		return @
	
	###*
	* Initialize the Application
	###
	init: ->
		return
)
