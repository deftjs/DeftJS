# DeftJS

Essential extensions for enterprise web and mobile application development with [Ext JS](http://www.sencha.com/products/extjs/) and [Sencha Touch](http://www.sencha.com/products/touch/).

# About

DeftJS enhances Ext JS and Sencha Touch's APIs with additional building blocks that enable large development teams to rapidly build enterprise scale applications, leveraging best practices and proven patterns discovered by top RIA developers at some of the best consulting firms in the industry.

# Goals

* **Flexibility**
	* Coordinates dynamic assembly of object dependencies based on a configurable IoC container.
* **Approachability**
	* Builds on familiar Ext JS API syntax conventions for 'pay-as-you-go' complexity.
* **Simplicity**
	* Eliminates boilerplate code in favor of the simplest expression of developer intent.
* **Testability**
	* Promotes loose coupling through class annotation driven dependency injection.
* **Extensibility**
	* Leverages the advanced class system provided by Ext JS and Sencha Touch.
* **Reusability**
	* Enables business layer code reuse between Ext JS and Sencha Touch applications.

# Features

* **IoC Container**
	* Provides class annotation driven dependency injection.
	* Maps dependencies by user-defined identifiers.
	* Resolves dependencies by class instance, factory function or value.
	* Supports singleton and prototype resolution of class instance and factory function dependencies.
	* Offers eager and lazy instantiation of dependencies.
	* Injects dependencies into Ext JS class configs and properties before the class constructor is executed.

# API

## Deft.ioc.Injector

A lightweight IoC container for dependency injection.

### Configuration

**Classes**

In the simplest scenario, the Injector can be configured to map identifiers by class names:

```javascript
Deft.Injector.configure({
	contactStore: 'MyApp.store.ContactStore',
	contactManager: 'MyApp.manager.ContactManager',
	...
});
```

When the Injector is called to resolve dependencies for these identifiers, a singleton instance of the specified class will be created and returned.

Where necessary, you can also specify constructor parameters:

```javascript
Deft.Injector.configure({
	contactStore: {
		className: 'MyApp.store.ContactStore',
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
	},
	contactManager: 'MyApp.manager.ContactManager',
	...
});
```

You can also specify whether a class is instantiated as a singleton (the default) or a prototype:

```javascript
Deft.Injector.configure({
	contactController: {
		className: 'MyApp.controller.ContactViewController',
		singleton: false
	},
	...
});
```

Additionally, you can configure dependency providers to be eagerly or lazily (the default) instantiated:

```javascript
Deft.Injector.configure({
	preferences:  {
		className: 'MyApp.preferences.Preferences',
		eager: true
	},
	...
});
```

When a dependency provider is configured for eager instantiation, it will be created and cached in the Injector immediately after all the identifiers in that `configure()` call have been processed.

*NOTE:* Only singletons can be eagerly instantiated.

**Factory Functions**

The Injector can also be configured to map identifiers to factory functions:

```javascript
Deft.Injector.configure({
	contactStore: {
		fn: function() {
			if ( useMocks ) {
				return Ext.create( 'MyApp.mock.store.ContactStore' );
			}
			else {
				return Ext.create( 'MyApp.store.ContactStore' );
			}
		},
		eager: true
	},
	contactManager: {
		fn: function( instance ) {
			if ( instance.session.getIsAdmin() ) {
				return Ext.create( 'MyApp.manager.admin.ContactManager' );
			}
			else {
				return Ext.create( 'MyApp.manager.user.ContactManager' );
			}
		},
		singleton: false
	},
	...
});
```
 
When the Injector is called to resolve dependencies for these identifiers, the factory function is called and the dependency is resolved with the return value.

As shown above, a lazily instantiated factory function can optionally accept a parameter, corresponding to the instance for which the Injector is currently injecting dependencies.

Factory function dependency providers can be configured as singletons or prototypes and can be eagerly or lazily instantiated.

*NOTE:* Only singleton factory functions can be eagerly instantiated.

**Values**

The Injector can also be configured to map identifiers to values:

```javascript
Deft.Injector.configure({
	brandedApplicationName: {
		value: "Contact Manager"
	},
	versionNumber: {
		value: 1.0
	},
	modules: {
		value: [ 'contacts', 'customers', 'orders' ]
	},
	...
});
```

A value can be any native JavaScript type, including Strings, Arrays, Numbers, Objects or class instances… even Functions!

*NOTE:* Values can only be configured as singletons and cannot be eagerly instantiated.

## Deft.mixin.Injectable

A class is marked as participating in dependency injection by including the Injectable mixin:

```javascript
Ext.define( 'MyApp.manager.ContactManager', {
	extend: 'MyApp.manager.AbstractManager',
	mixins: [ 'Deft.mixin.Injectable' ],
	...
});
```

Its dependencies are expressed using the `inject` annotation:

```javascript
Ext.define( 'MyApp.manager.ContactManager', {
	extend: 'MyApp.manager.AbstractManager',
	mixins: [ 'Deft.mixin.Injectable' ],
	
	inject: [ 'contactStore' ],
	...
});
```

Any class that includes the Injectable mixin will have the dependencies described in its `inject` annotation resolved and injected by the Injector prior to the class constructor being called.

By default, each dependency will be injected into the config or property of the same name.

You can override this behavior and indicate the specific property to inject into, by using slightly more verbose syntax:

```javascript
Ext.define( 'MyApp.manager.ContactManager', {
	extend: 'MyApp.manager.AbstractManager',
	mixins: [ 'Deft.mixin.Injectable' ],
	
	inject: {
		store: 'contactStore'
	},
	...
});
```

In this case, the `contactStore` dependency will be resolved into a new `store` property.

A class does not need to explicitly define a config or property for the property to be injected.  However, if that property is defined as an existing config (even in a superclass), the Injector will correctly populate the config value.

```javascript
Ext.define( 'MyApp.manager.ContactManager', {
	extend: 'MyApp.manager.AbstractManager',
	mixins: [ 'Deft.mixin.Injectable' ],
	
	inject: {
		store: 'contactStore'
	},
	
	config: {
		store: null
	},
	
	constructor: function( config ) {
		this.initConfig( config );
		
		// this.getStore() will return the injected value.
		
		return this.callParent( arguments )
	}
	...
});
```

# Version History

* 0.1.1 - Preview release, added Jasmine test suite.
* 0.1.0 - Preview release, introducing an IoC container for dependency injection.

# Roadmap

* Logo (*in progress*)
* Website (*in progress*)
* Alternative MVC implementation - Model View ViewController (*in progress*)
* Deferreds / Promises (*in progress*)
* Forums (*in progress*)
* FAQ
* Example Ext JS and Sencha Touch applications
* Routing
* Navigation - support for hierarchical views, route-aware
* AOP with an Ext JS-style API (i.e. JSON style configuration)
* Occasionally-Connected Store (simplifing online / offline capabilities)

# Development Team

* [John Yanarella](http://twitter.com/johnyanarella) (Creator)
* [David Tucker](http://www.davidtucker.net/)
* [Ryan Campbell](http://www.ryancampbell.com/)

# Acknowledgements

* Inspiration drawn from other IoC frameworks:
	* [Spring](http://www.springsource.org/)
	* [Swiz](http://swizframework.org/)
	* [Robotlegs](http://www.robotlegs.org/)
	* [Swift Suspenders](https://github.com/tschneidereit/SwiftSuspenders)
	* [AngularJS](http://angularjs.org/)
* Special thanks to:
	* [David Tucker](http://www.davidtucker.net/) for reviewing several iterations of the proposed syntax.
	* [Claude Gauthier](http://www.sencha.com/training) for leading the 5-day 'Fast Track to Ext JS' training where this idea was born.
	* [Tim Marshall](http://twitter.com/timothymarshall) for parting with the twitter account and project name, which he'd previously used for a personal project.

