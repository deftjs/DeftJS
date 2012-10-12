###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A lightweight IoC container for dependency injection.
###
Ext.define( 'Deft.ioc.Injector',
	alternateClassName: [ 'Deft.Injector' ]
	requires: [
		'Ext.Component'
		
		'Deft.log.Logger'
		'Deft.ioc.DependencyProvider'
	]
	singleton: true
	
	constructor: ->
		@providers = {}
		return @
	
	###*
	Configure the Injector.
	###
	configure: ( configuration ) ->
		Deft.Logger.log( 'Configuring the injector.' )
		newProviders = {}
		Ext.Object.each(
			configuration,
			( identifier, config ) ->
				Deft.Logger.log( "Configuring dependency provider for '#{ identifier }'." )
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
				newProviders[ identifier ] = provider
				return
			@
		)
		Ext.Object.each(
			newProviders
			( identifier, provider ) ->
				if provider.getEager()
					Deft.Logger.log( "Eagerly creating '#{ provider.getIdentifier() }'." )
					provider.resolve()
				return
			@
		)
		return
	
	###*
	Reset the Injector.
	###
	reset: ->
		Deft.Logger.log( 'Resetting the injector.' )
		@providers = {}
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
			Ext.Error.raise( msg: "Error while resolving value to inject: no dependency provider found for '#{ identifier }'." )
		return
	
	###*
	Inject dependencies (by their identifiers) into the target object instance.
	###
	inject: ( identifiers, targetInstance, targetInstanceIsInitialized = true ) ->
		injectConfig = {}
		identifiers = [ identifiers ] if Ext.isString( identifiers )
		Ext.Object.each( 
			identifiers
			( key, value ) ->
				targetProperty = if Ext.isArray( identifiers ) then value else key
				identifier = value
				resolvedValue = @resolve( identifier, targetInstance )
				if targetProperty of targetInstance.config
					Deft.Logger.log( "Injecting '#{ identifier }' into '#{ targetProperty }' config." )
					injectConfig[ targetProperty ] = resolvedValue
				else
					Deft.Logger.log( "Injecting '#{ identifier }' into '#{ targetProperty }' property." )
					targetInstance[ targetProperty ] = resolvedValue
				return
			@
		)
		
		# Ext JS and Sencha Touch do not provide a consistent mechanism (across the target framework versions) for detecting whether initConfig() has been executed.
		# Consequently, we rely on an optional method parameter to determine this state instead.
		if targetInstanceIsInitialized
			for name, value of injectConfig
				setterFunctionName = 'set' + Ext.String.capitalize( name )
				targetInstance[ setterFunctionName ].call( targetInstance, value )
		else
			if Ext.getVersion( 'extjs' )? and targetInstance instanceof Ext.ClassManager.get( 'Ext.Component' )
				# NOTE: Ext JS's Ext.Component doesn't "play by the rules" and never actually calls Ext.Base::initConfig().
				# Store the configs to be injected and apply via the constructor override define below.
				targetInstance.injectConfig = injectConfig
			else if Ext.isFunction( targetInstance.initConfig )
				originalInitConfigFunction = targetInstance.initConfig
				targetInstance.initConfig = ( config ) ->
					result = originalInitConfigFunction.call( @, Ext.Object.merge( {}, config or {}, injectConfig ) )
					return result
		
		return targetInstance
,
	->
		# NOTE: Ext JS's Ext.Component doesn't "play by the rules" and never calls Ext.Base::initConfig().
		# Apply the stored configs to be injected via a constructor override.
		if Ext.getVersion( 'extjs' )?
			if Ext.getVersion( 'core' ).isLessThan( '4.1.0' )
				# Ext JS 4.0
				Ext.Component.override(
					constructor: ( config ) ->
						config = Ext.Object.merge( {}, config or {}, @injectConfig or {} )
						delete @injectConfig
						return @callOverridden( [ config ] )
				)
			else
				# Ext JS 4.1+
				Ext.define( 'Deft.InjectableComponent',
					override: 'Ext.Component'
					
					constructor: ( config ) ->
						config = Ext.Object.merge( {}, config or {}, @injectConfig or {} )
						delete @injectConfig
						return @callParent( [ config ] )
				)
		
		return

)
