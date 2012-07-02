###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
A mixin that creates and attaches the specified view controller(s) to the target view.

Used in conjunction with {@link Deft.mvc.ViewController}.
###
Ext.define( 'Deft.mixin.Controllable', {} )

Ext.Class.registerPreprocessor( 'controller', ( Class, data, hooks, callback ) ->
	# Workaround: Ext JS 4.0 passes the callback as the third parameter, Sencha Touch 2.0.1 and Ext JS 4.1 passes it as the fourth parameter
	if arguments.length is 3
		# NOTE: Altering a parameter also modifies arguments, so clone it to a true Array first.
		parameters = Ext.toArray( arguments )
		hooks = parameters[ 1 ]
		callback = parameters[ 2 ]
	
	if data.mixins? and Ext.Array.contains( Ext.Object.getValues( data.mixins ), Ext.ClassManager.get( 'Deft.mixin.Controllable' ) )
		controllerClass = data.controller
		delete data.controller
		
		if controllerClass?
			# Intercept constructor method.
			if not data.hasOwnProperty( 'constructor' )
				data.constructor = -> @callParent( arguments )
			originalConstructor = data.constructor
			data.constructor = ( config = {} ) ->
				try
					controller = Ext.create( controllerClass, config.controllerConfig || @controllerConfig || {} )
				catch error
					# NOTE: Ext.Logger.error() will throw an error, masking the error we intend to rethrow, so warn instead.
					Deft.Logger.warn( "Error initializing Controllable instance: an error occurred while creating an instance of the specified controller: '#{ controllerClass }'." )
					throw error
					
				@getController = ->
					return controller
				
				originalConstructor.apply( @, arguments )
				controller.controlView( @ )
				
				return @
			
			# Intercept destroy method.
			if not data.hasOwnProperty( 'destroy' )
				data.destroy = -> @callParent( arguments )
			originalDestroy = data.destroy
			data.destroy = ->
				delete @getController
				return originalDestroy.apply( @, arguments )
			
			self = @
			Ext.require( [ controllerClass ], ->
				if callback?
					callback.call( self, Class, data, hooks )
				return
			)
			return false
	return
)

Ext.Class.setDefaultPreprocessorPosition( 'controller', 'before', 'mixins' )
