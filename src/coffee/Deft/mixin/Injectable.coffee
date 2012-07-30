###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
A mixin that marks a class as participating in dependency injection.

Used in conjunction with {@link Deft.ioc.Injector}.
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
		# Create the injection interceptor.
		injectionInterceptor = ->
			if not @$injected
				Deft.Injector.inject( @inject, @, false )
				@$injected = true
			return
		
		# Apply the injection interceptor to the specified target (if it hasn't already been applied).
		applyInjectionInterceptor = ( data ) ->
			if not data.constructor.$injectable
				data.constructor = Ext.Function.createInterceptor( data.constructor, injectionInterceptor )
				data.constructor.$injectable = true
			return
		
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
				
				# Intercept before the constructor for this class with the injection interceptor.
				if not data.hasOwnProperty( 'constructor' )
					data.constructor = -> @callParent( arguments )
				applyInjectionInterceptor( data )
			
				# Process any classes that extend this class.
				data.onClassExtended =  ( Class, data, hooks ) ->
					# Intercept before the constructor for this class with the injection interceptor.
					if not data.hasOwnProperty( 'inject' ) and data.hasOwnProperty( 'constructor' )
						applyInjectionInterceptor( data )
					
					# Merge identifiers, ensuring that identifiers in data override identifiers in superclass.
					data.inject ?= {}
					Ext.applyIf( data.inject, Class.superclass.inject )
					return
				
				return
			'before'
			'extend'
		)
		
		return
)

