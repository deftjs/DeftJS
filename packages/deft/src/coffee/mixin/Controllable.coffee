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
		'Deft.util.DeftMixinUtils'
	]
	
	###*
	@private
	###
	onClassMixedIn: ( target ) ->

		target.override(
			constructor: Deft.mixin.Controllable.createMixinInterceptor()
		)

		target.onExtended( ( clazz, config ) ->
			clazz.override(
				constructor: Deft.mixin.Controllable.createMixinInterceptor()
			)

			return true
		)

		return


	statics:

		MIXIN_COMPLETED_KEY: "$controlled"
		PROPERTY_NAME: "controller"
		CONFIG_PROPERTY_NAME: "controllerConfig"
		CONTROLLER_GETTER_NAME: "getController"


		###*
		* @private
		###
		createMixinInterceptor: ->
			return ( config = {} ) ->

				# TODO: Check with John on using statics. Idea is to make it easy to change these if it ever becomes necessary.
				mixinCompletedKey = Deft.mixin.Controllable.MIXIN_COMPLETED_KEY
				controllerName = Deft.mixin.Controllable.PROPERTY_NAME
				configPropertyName = Deft.mixin.Controllable.CONFIG_PROPERTY_NAME
				controllerGetterName = Deft.mixin.Controllable.CONTROLLER_GETTER_NAME

				if @ instanceof Ext.ClassManager.get( 'Ext.Component' ) and not @[ mixinCompletedKey ]
					try
						controller = Ext.create( config[ controllerName ] || @[ controllerName ], config[ configPropertyName ] || @[ configPropertyName ] || {} )
					catch error
						# NOTE: Ext.Logger.error() will throw an error, masking the error we intend to rethrow, so warn instead.
						Deft.Logger.warn( "Error initializing view controller: an error occurred while creating an instance of the specified controller: '#{ config[ controllerName ] || @[ controllerName ] }'." )
						throw error

					if @[ controllerGetterName ] is undefined
						@[ controllerGetterName ] = ->
							return controller

					Deft.mixin.Controllable.afterMixinProcessed( @ )

					# TODO: These calls based on Ext JS version can revert to @callParent() if we end up dropping 4.0.x support...
					@[ Deft.util.DeftMixinUtils.parentConstructorForVersion() ]( arguments )

					controller.controlView( @ )

					return @

				return @[ Deft.util.DeftMixinUtils.parentConstructorForVersion() ]( arguments )


		###*
		* @private
		###
		afterMixinProcessed: ( target ) ->
			target[ Deft.mixin.Controllable.MIXIN_COMPLETED_KEY ] = true
			return

)

