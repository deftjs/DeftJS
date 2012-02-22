###*
A lightweight IoC container for dependency injection.

Used in conjunction with {@link Deft.mixin.Injectable}.
###
Ext.define( 'Deft.ioc.Injector',
	alternateClassName: [ 'Deft.Injector' ]
	requires: [ 'Deft.ioc.DependencyProvider' ]
	singleton: true
	
	constructor: ->
		@providers = {}
		return @
	
	###*
	Configure the Injector.
	###
	configure: ( configuration ) ->
		Ext.log( 'Configuring injector.' )
		Ext.Object.each(
			configuration,
			( identifier, config ) ->
				Ext.log( "Configuring dependency provider for '#{ identifier }'." )
				if Ext.isString( config )
					provider = Ext.create( 'Deft.ioc.DependencyProvider',
						identifier: identifier
						className: config
					)
				else
					provider = Ext.create( 'Deft.ioc.DependencyProvider',
						Ext.apply(
							identifier: identifier,
							config
						)
					)
				@providers[ identifier ] = provider
				return
			@
		)
		Ext.Object.each(
			@providers
			( identifier, provider ) ->
				if provider.getEager()
					Ext.log( "Eagerly creating '#{ provider.getIdentifier() }'." )
					provider.resolve()
				return
			@
		)
		return
	
	###*
	Indicates whether the Injector can resolve a dependency by the specified identifier with the corresponding object instance or value.
	###
	canResolve: ( identifier ) ->
		provider = @providers[ identifier ]
		return provider?
	
	###*
	Resolve a dependency (by identifier) with the corresponding object instance or value.
	
	Optionally, the caller may specify the target instance (to be supplied to the dependency provider's factory function, if applicable).
	###
	resolve: ( identifier, targetInstance ) ->
		provider = @providers[ identifier ]
		if provider?
			return provider.resolve( targetInstance )
		else
			Ext.Error.raise( "Error while resolving value to inject: no dependency provider found for '#{ identifier }'." )
	
	###*
	Inject dependencies (by their identifiers) into the target object instance.
	###
	inject: ( identifiers, targetInstance ) ->
		config = {}
		Ext.Object.each( 
			identifiers
			( key, value ) ->
				targetProperty = if Ext.isArray( identifiers ) then value else key
				identifier = value
				resolvedValue = @resolve( identifier, targetInstance )
				if targetInstance.config.hasOwnProperty( targetProperty )
					Ext.log( "Injecting '#{ identifier }' into 'config.#{ targetProperty }'." )
					config[ targetProperty ] = resolvedValue
				else
					Ext.log( "Injecting '#{ identifier }' into '#{ targetProperty }'." )
					targetInstance[ targetProperty ] = resolvedValue
			@
		)
		targetInstance.config = Ext.Object.merge( {}, targetInstance.config or {}, config )
		return targetInstance
)
