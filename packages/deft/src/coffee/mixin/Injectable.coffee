###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A mixin that marks a class as participating in dependency injection. Used in conjunction with Deft.ioc.Injector.
###
Ext.define( 'Deft.mixin.Injectable',
	requires: [
		'Deft.core.Class'
		'Deft.ioc.Injector'
		'Deft.log.Logger'
		'Deft.util.DeftMixinUtils'
	]

	###*
	@private
	###
	onClassMixedIn: ( target ) ->

		target::constructor = @createMixinInterceptor( target::constructor )

		target.onExtended( ( clazz, config ) ->
			config.constructor = Deft.mixin.Injectable.createMixinInterceptor( config.constructor )
			return true
		)

		return


	statics:

		MIXIN_COMPLETED_KEY: "$injected"
		PROPERTY_NAME: "inject"


		###*
		* @private
		###
		createMixinInterceptor: ( targetMethod ) ->
			return Ext.Function.createInterceptor( targetMethod, ->
				Deft.mixin.Injectable.constructorInterceptor( @, arguments )
				return true
			)


		###*
		* @private
		###
		constructorInterceptor: ( target, targetInstanceConstructorArguments ) ->
			# Only continue of the target hasn't already been processed for injections.
			if( not target[ @MIXIN_COMPLETED_KEY ] )
				Deft.util.DeftMixinUtils.mergeSuperclassProperty( target, @PROPERTY_NAME, @propertyMergeHandler )
				injectConfig = target[ @PROPERTY_NAME ]
				Deft.Injector.inject( injectConfig, target, targetInstanceConstructorArguments, false )
				@afterMixinProcessed( target )

			return true


		###*
		* @private
		* Called by DeftMixinUtils.mergeSuperclassProperty(). Allows each mixin to define its own
		* customized subclass/superclass merge logic.
		###
		propertyMergeHandler: ( mergeTarget, mergeSource ) ->
			# Convert a String or Array of Strings specified in source config into Objects.
			mergeSource = [ mergeSource ] if Ext.isString( mergeSource )

			if Ext.isArray( mergeSource )
				dataInjectObject = {}
				for identifier in mergeSource
					dataInjectObject[ identifier ] = identifier
				mergeSource = dataInjectObject

			# Since child inject overrides parent inject, apply source config onto target config
			mergeTarget = Ext.apply( mergeTarget, mergeSource )
			return mergeTarget


		###*
		@private
		###
		afterMixinProcessed: ( target ) ->
			target[ @MIXIN_COMPLETED_KEY ] = true
			return


			###
,
	->
		if Ext.getVersion( 'extjs' ) and Ext.getVersion( 'core' ).isLessThan( '4.1.0' )
			# Ext JS 4.0
			createInjectionInterceptor = ->
				return ->
					if not @$injected
						Deft.Injector.inject( @inject, @, arguments, false )
						@$injected = true
					return @callOverridden( arguments )
		else
			# Sencha Touch 2.0+, Ext JS 4.1+
			createInjectionInterceptor = ->
				return ->
					if not @$injected
						Deft.Injector.inject( @inject, @, arguments, false )
						@$injected = true
					return @callParent( arguments )

		Deft.Class.registerPreprocessor(
			'inject'
			( Class, data, hooks, callback ) ->
				# Convert a String or Array of Strings specified for data.inject into an Object.
				data.inject = [ data.inject ] if Ext.isString( data.inject )
				if Ext.isArray( data.inject )
					dataInjectObject = {}
					for identifier in data.inject
						dataInjectObject[ identifier ] = identifier
					data.inject = dataInjectObject

				# Override the constructor for this class with an injection interceptor.
				Deft.Class.hookOnClassCreated( hooks, ( Class ) ->
					Class.override(
						constructor: createInjectionInterceptor()
					)
					return
				)

				# Process any classes that extend this class.
				Deft.Class.hookOnClassExtended( data, ( Class, data, hooks ) ->
					# Override the constructor for this class with an injection interceptor.
					Deft.Class.hookOnClassCreated( hooks, ( Class ) ->
						Class.override(
							constructor: createInjectionInterceptor()
						)
						return
					)

					# Merge identifiers, ensuring that identifiers in data override identifiers in superclass.
					data.inject ?= {}
					Ext.applyIf( data.inject, Class.superclass.inject )
					return
				)

				return
			'before'
			'extend'
		)

		return

			###

)

