###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A mixin that creates and attaches the specified view controller(s) to the target view. Used in conjunction with Deft.mvc.ViewController.
###
Ext.define( 'Deft.mixin.Controllable',
	requires: [
		'Ext.Component'
		'Deft.core.Class'
		'Deft.log.Logger'
	]
	
	###*
	@private
	###
	onClassMixedIn: ( target ) ->

		#@createAfterMixinInterceptor( target:: )

		# Override mixin target constructor to merge superclass inject configs and perform injections.
		# Use Ext.override( target, {obj} ) instead?
		#target::constructor = @createMixinInterceptor( target::constructor )

		target.override(
			constructor: Deft.mixin.Controllable.createControllerInterceptor()
		)

		target.onExtended( ( clazz, config ) ->
			#config.constructor = Deft.mixin.Controllable.createMixinInterceptor( config.constructor )

			clazz.override(
				constructor: Deft.mixin.Controllable.createControllerInterceptor()
			)

			return true
		)

		return


	statics:

		MIXIN_COMPLETED_KEY: "$controlled"
		PROPERTY_NAME: "controller"
		CONFIG_PROPERTY_NAME: "controllerConfig"


		createControllerInterceptor: ->
			return ( config = {} ) ->
				if @ instanceof Ext.ClassManager.get( 'Ext.Component' ) and not @$controlled
					try
						controller = Ext.create( @controller, config.controllerConfig || @controllerConfig || {} )
					catch error
						# NOTE: Ext.Logger.error() will throw an error, masking the error we intend to rethrow, so warn instead.
						Deft.Logger.warn( "Error initializing view controller: an error occurred while creating an instance of the specified controller: '#{ @controller }'." )
						throw error

					if @getController is undefined
						@getController = ->
							return controller

					@$controlled = true

					@callParent( arguments )

					controller.controlView( @ )

					return @

				return @callParent( arguments )


		###*
		@private
		###
		createMixinInterceptor: ( targetMethod ) ->
			return Ext.Function.createInterceptor( targetMethod, ->
				Deft.mixin.Controllable.constructorInterceptor( @, arguments )
				return true
			)


		###*
		@private
		###
		createAfterMixinInterceptor: ( target ) ->
			return Ext.Function.interceptAfter( target, "constructor", ->
				@getController().controlView( this )
				return true
			)



		###*
		@private
		###
		constructorInterceptor: ( target, targetInstanceConstructorArguments ) ->
			# Only continue of the target hasn't already been processed for injections.
			if( target instanceof Ext.ClassManager.get( 'Ext.Component' ) )
				if( not target[ @MIXIN_COMPLETED_KEY ] )
					controllerName = target[ @PROPERTY_NAME ]
					config = {}
					try
						controller = Ext.create( controllerName, config.controllerConfig || target[ @CONFIG_PROPERTY_NAME ] || {} )
					catch error
						# NOTE: Ext.Logger.error() will throw an error, masking the error we intend to rethrow, so warn instead.
						Deft.Logger.warn( "Error initializing view controller: an error occurred while creating an instance of the specified controller: '#{ controllerName }'." )
						throw error

					if target.getController is undefined
						target.getController = ->
							return controller

					@afterMixinProcessed( target )

					#@callOverridden( arguments )

					#controller.controlView( target )

			return true


		###*
		@private
		###
		afterMixinProcessed: ( target ) ->
			target[ @MIXIN_COMPLETED_KEY ] = true
			console.log( "Controllable afterMixinProcessed()" )
			return


			###
,
	->
		if Ext.getVersion( 'extjs' ) and Ext.getVersion( 'core' ).isLessThan( '4.1.0' )
			# Ext JS 4.0
			createControllerInterceptor = ->
				return ( config = {} ) ->
					if @ instanceof Ext.ClassManager.get( 'Ext.Component' ) and not @$controlled
						try
							controller = Ext.create( @controller, config.controllerConfig || @controllerConfig || {} )
						catch error
							# NOTE: Ext.Logger.error() will throw an error, masking the error we intend to rethrow, so warn instead.
							Deft.Logger.warn( "Error initializing view controller: an error occurred while creating an instance of the specified controller: '#{ @controller }'." )
							throw error
						
						if @getController is undefined
							@getController = ->
								return controller
						
						@$controlled = true
						
						@callOverridden( arguments )
						
						controller.controlView( @ )
						
						return @
					
					return @callOverridden( arguments )
		else
			# Sencha Touch 2.0+, Ext JS 4.1+
			createControllerInterceptor = ->
				return ( config = {} ) ->
					if @ instanceof Ext.ClassManager.get( 'Ext.Component' ) and not @$controlled
						try
							controller = Ext.create( @controller, config.controllerConfig || @controllerConfig || {} )
						catch error
							# NOTE: Ext.Logger.error() will throw an error, masking the error we intend to rethrow, so warn instead.
							Deft.Logger.warn( "Error initializing view controller: an error occurred while creating an instance of the specified controller: '#{ @controller }'." )
							throw error
					
						if @getController is undefined
							@getController = ->
								return controller
					
						@$controlled = true
					
						@callParent( arguments )
					
						controller.controlView( @ )
					
						return @
				
					return @callParent( arguments )
			
		
		Deft.Class.registerPreprocessor( 
			'controller'
			( Class, data, hooks, callback ) ->
				# Override the constructor for this class with a controller interceptor.
				Deft.Class.hookOnClassCreated( hooks, ( Class ) ->
					Class.override(
						constructor: createControllerInterceptor()
					)
					return
				)
				
				# Process any classes that extend this class.
				Deft.Class.hookOnClassExtended( data, ( Class, data, hooks ) ->
					# Override the constructor for this class with a controller interceptor.
					Deft.Class.hookOnClassCreated( hooks, ( Class ) ->
						Class.override(
							constructor: createControllerInterceptor()
						)
						return
					)
					return
				)
				
				# Automatically require the controller class.
				self = @
				Ext.require( [ data.controller ], ->
					if callback?
						callback.call( self, Class, data, hooks )
					return
				)
				return false
			'before'
			'extend'
		)
	
		return

			###
)

