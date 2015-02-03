###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
A lightweight IoC container for dependency injection.

## <u>[Basic Configuration](https://github.com/deftjs/DeftJS/wiki/Basic-Application-and-IoC-Configuration)</u>

    // Common configuration, using dependency provider name and class.
    Deft.Injector.configure({
      companyStore: "DeftQuickStart.store.CompanyStore",
      companyService: "DeftQuickStart.store.CompanyService"
    });

In the IoC configuration above, we have created two **dependency providers**, one named `companyStore` and one named `companyService`. By default, DeftJS uses lazy instantiation to create singleton instances of the `CompanyStore` and `CompanyService` classes. This means that a singleton won't be created until an object in your application specifies one of these dependency providers as an injected dependency.

## <u>[Singleton vs. Prototype Dependency Providers](https://github.com/deftjs/DeftJS/wiki/Singleton-vs.-Prototype-Dependency-Providers)</u>

By default, the dependency providers set up with the DeftJS `Injector` are singletons. This means that only one instance of that dependency will be created, and the same instance will be injected into all objects that request that dependency.

For cases where this is not desired, you can create non-singleton (prototype) dependency providers like this:

    Deft.Injector.configure({
      editHistory: {
        className: "MyApp.util.EditHistory",
        singleton: false
      }
    });

## <u>[Lazy vs. Eager Dependency Creation](https://github.com/deftjs/DeftJS/wiki/Eager-vs.-Lazy-Instantiation)</u>

By default, dependency providers are created **lazily**. This means that the dependency will not be created by DeftJS until another object is created which specifies that dependency as an injection.

In cases where lazy instantiation is not desired, you can set up a dependency provider to be created immediately upon application startup by using the `eager` configuration:

    Deft.Injector.configure({
      notificationService: {
        className: "MyApp.service.NotificationService",
        eager: true
      }
    });

> **NOTE: Only singleton dependency providers can be eagerly instantiated.** This means that specifying `singleton: false` and `eager: true` for a dependency provider won't work. The reason may be obvious: DeftJS can't do anything with a prototype object that is eagerly created, since by definition each injection of a prototype dependency must be a new instance!

## <u>[Constructor Parameters](https://github.com/deftjs/DeftJS/wiki/Constructor-Parameters)</u>

If needed, constructor parameters can be specified for a dependency provider. These parameters will be passed into the constructor of the target object when it is created. Constructor parameters can be configured in the following way:

    Deft.Injector.configure({
      contactStore: {
        className: 'MyApp.store.ContactStore',

        // Specify an array of params to pass into ContactStore constructor
        parameters: [{
          proxy: {
            type: 'ajax',
            url: '/contacts.json',
            reader: {
              type: 'json',
              root: 'contacts'
            }
          }
        }]
      }
    });

## <u>[Factory Functions](https://github.com/deftjs/DeftJS/wiki/Factory-Functions)</u>

A dependency provider can also specify a function to use to create the object that will be injected:

    Deft.Injector.configure({

      contactStore: {
        fn: function() {
          if (useMocks) {
            return Ext.create("MyApp.mock.store.ContactStore");
          } else {
            return Ext.create("MyApp.store.ContactStore");
          }
        },
        eager: true
      },

      contactManager: {
        // The factory function will be passed a single argument:
        // The object instance that the new object will be injected into
        fn: function(instance) {
          if (instance.session.getIsAdmin()) {
            return Ext.create("MyApp.manager.admin.ContactManager");
          } else {
            return Ext.create("MyApp.manager.user.ContactManager");
          }
        },
        singleton: false
      }

    });

When the Injector is called to resolve dependencies for these identifiers, the factory function is called and the dependency is resolved with the return value.

As shown above, a lazily instantiated factory function can optionally accept a parameter, corresponding to the instance for which the Injector is currently injecting dependencies.

Factory function dependency providers can be configured as singletons or prototypes and can be eagerly or lazily instantiated.

> **NOTE: Only singleton factory functions can be eagerly instantiated.** This means that specifying `singleton: false` and `eager: true` for a dependency provider won't work. The reason may be obvious: DeftJS can't do anything with a prototype object that is eagerly created, since by definition each injection of a prototype dependency must be a new instance!

###
Ext.define( 'Deft.ioc.Injector',
	alternateClassName: [ 'Deft.Injector' ]
	requires: [
		'Ext.Component'

		'Deft.log.Logger'
		'Deft.ioc.DependencyProvider'
		'Deft.util.Function'
	]
	singleton: true

	constructor: ->
		@providers = {}
		@injectionStack = []
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
	resolve: ( identifier, targetInstance, targetInstanceConstructorArguments ) ->
		provider = @providers[ identifier ]
		if provider?
			return provider.resolve( targetInstance, targetInstanceConstructorArguments )
		else
			Ext.Error.raise( msg: "Error while resolving value to inject: no dependency provider found for '#{ identifier }'." )
		return

	###*
	Inject dependencies (by their identifiers) into the target object instance.
	###
	inject: ( identifiers, targetInstance, targetInstanceConstructorArguments, targetInstanceIsInitialized = true ) ->

		targetClass = Ext.getClassName( targetInstance )

		# Maintain a set of classes processed during this injection pass. If we hit a circular dependency, throw an error.
		if( Ext.Array.contains( @injectionStack, targetClass ) )
			stackMessage = @injectionStack.join( " -> " )
			@injectionStack = []
			Ext.Error.raise( msg: "Error resolving dependencies for '#{ targetClass }'. A circular dependency exists in its injections: #{ stackMessage } -> *#{ targetClass }*" )
			return null

		@injectionStack.push( targetClass )

		injectConfig = {}
		identifiers = [ identifiers ] if Ext.isString( identifiers )
		Ext.Object.each(
			identifiers
			( key, value ) ->
				targetProperty = if Ext.isArray( identifiers ) then value else key
				identifier = value

				resolvedValue = @resolve( identifier, targetInstance, targetInstanceConstructorArguments )
				if targetProperty of targetInstance.config
					Deft.Logger.log( "Injecting '#{ identifier }' into '#{ targetClass }.#{ targetProperty }' config." )
					injectConfig[ targetProperty ] = resolvedValue
				else
					Deft.Logger.log( "Injecting '#{ identifier }' into '#{ targetClass }.#{ targetProperty }' property." )
					targetInstance[ targetProperty ] = resolvedValue
				return
			@
		)

		@injectionStack = []

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
			else if Deft.isFunction( targetInstance.initConfig )
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
						config = Ext.apply(config or {}, @injectConfig)
						delete @injectConfig
						return @callOverridden( [ config ] )
				)
			else
				# Ext JS 4.1+
				Ext.define( 'Deft.InjectableComponent',
					override: 'Ext.Component'

					constructor: ( config ) ->
						config = Ext.apply(config or {}, @injectConfig)
						delete @injectConfig
						return @callParent( [ config ] )
				)

		return

)
