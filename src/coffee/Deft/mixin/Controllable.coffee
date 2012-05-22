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
	
	if data.mixins? and Ext.Array.contains( data.mixins, Ext.ClassManager.get( 'Deft.mixin.Controllable' ) )
		controller = data.controller
		delete data.controller
		
		controllers = []
		if controller?
			controllers = if Ext.isArray( controller ) then controller else [ controller ]
		
		Class::constructor = Ext.Function.createSequence( Class::constructor, ->
			for controllerClass in controllers
				try
					Ext.create( controllerClass,
						view: @
					)
				catch error
					# NOTE: Ext.Logger.error() will throw an error, masking the error we intend to rethrow, so warn instead.
					Deft.Logger.warn( "Error initializing Controllable instance: an error occurred while creating an instance of the specified controller: '#{ controllerClass }'." )
					throw error
			return
		)
		
		if controllers.length > 0
			self = @
			Ext.require( controllers, ->
				if callback?
					callback.call( self, Class, data, hooks )
				return
			)
			return false
	return
)

Ext.Class.setDefaultPreprocessorPosition( 'controller', 'before', 'mixins' )
