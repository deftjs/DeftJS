###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
A mixin that creates and attaches the specified view controller(s) to the target view.

Used in conjunction with {@link Deft.mvc.ViewController}.
###
Ext.define( 'Deft.mixin.Controllable',
	requires: [ 
		'Deft.core.Class'
		'Deft.log.Logger'
	]
	
	###*
	@private
	###
	onClassMixedIn: ( targetClass ) ->
		Deft.Logger.deprecate( 'Deft.mixin.Controllable has been deprecated and can now be omitted - simply use the \'controller\' class annotation on its own.' )
		return
,
	->
		# Apply the controller interceptor to the specified target (if it hasn't already been applied).
		applyControllerInterceptor = ( data ) ->
			if not data.constructor.$controllable
				originalConstructor = data.constructor
				data.constructor = ( config = {} ) ->
					if @ instanceof Ext.ClassManager.get( 'Ext.Container' ) and not @$controlled
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
						
						originalConstructor.apply( @, arguments )
						
						controller.controlView( @ )
						
						return @
					
					return originalConstructor.apply( @, arguments )
				
				data.constructor.$controllable = true
			return
		
		Deft.Class.registerPreprocessor( 
			'controller'
			( Class, data, hooks, callback ) ->
				# Intercept before the constructor for this class with the controller interceptor.
				if not data.hasOwnProperty( 'constructor' )
					data.constructor = -> @callParent( arguments )
				applyControllerInterceptor( data )
				
				# Process any classes that extend this class.
				data.onClassExtended =  ( Class, data, hooks ) ->
					# Intercept before the constructor for this class with the controller interceptor.
					if not data.hasOwnProperty( 'controller' ) and data.hasOwnProperty( 'constructor' )
						applyControllerInterceptor( data )
					return
				
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
)

