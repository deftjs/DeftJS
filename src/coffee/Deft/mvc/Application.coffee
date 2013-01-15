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
	initialized: false
	
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
    @beforeInit()
    injectorConfig = @buildInjectorConfig()
    Deft.Injector.configure( injectorConfig ) if injectorConfig?
    @afterInit()

  ###*
  * @protected
  * Returns the configuration object to pass to Deft.Injector.configure(). Override in subclasses to alter the Injector configuration before returning the config object.
  * @param {Object} injectorConfig
  * @return {Object} The Injector configuration object.
  ###
  buildInjectorConfig: ( injectorConfig ) ->
    return injectorConfig

  ###*
  * @protected
  * Runs at the start of the init() method. Override in subclasses if needed.
  ###
  beforeInit: ->
    return

  ###*
  * @protected
  * Runs at the end of the init() method. Override in subclasses. Useful to create initial Viewport, start Jasmine tests, etc.
  ###
  afterInit: ->
    return

)
