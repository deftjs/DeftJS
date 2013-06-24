###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A mixin that marks a class as participating in dependency injection. Used in conjunction with Deft.ioc.Injector.
* @deprecated 0.8 Deft.mixin.Injectable has been deprecated and can now be omitted - simply use the \'inject\' class annotation on its own.
###
Ext.define( 'Deft.mixin.Injectable',
	requires: [
		'Deft.core.Class'
		'Deft.ioc.Injector'
		'Deft.log.Logger'
	]

	###*
	@private
	###
	onClassMixedIn: ( targetClass ) ->
		Deft.Logger.deprecate( 'Deft.mixin.Injectable has been deprecated and can now be omitted - simply use the \'inject\' class annotation on its own.' )
		return
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
)

