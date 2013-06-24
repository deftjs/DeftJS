###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A mixin that creates and attaches the specified view controller(s) to the target view. Used in conjunction with Deft.mvc.ViewController.
* @deprecated 0.8 Deft.mixin.Controllable has been deprecated and can now be omitted - simply use the \'controller\' class annotation on its own.
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
	onClassMixedIn: ( targetClass ) ->
		Deft.Logger.deprecate( 'Deft.mixin.Controllable has been deprecated and can now be omitted - simply use the \'controller\' class annotation on its own.' )
		return
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
)

