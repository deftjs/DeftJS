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

* **MVC with View Controllers**
	* Provides class annotation driven association between a given view and its view controller.
	* Clarifies the role of the controller - i.e. controlling a view and delegating work to injected business services (ex. Stores).
	* Supports multiple independent instances of a given view, each with their own view controller instance.
	* Reduces memory usage by automatically creating and destroying view controllers in tandem with their associated views.
	* Supports concise configuration for referencing view components and registering event listeners with view controller methods.
	* Integrates with the view destruction lifecycle to allow the view controller to potentially cancel removal and destruction.
	* Simplifies clean-up by automatically removing view and view component references and event listeners.

* **Promises and Deferreds**
	* Provides an elegant way to represent a 'future value' resulting from an asynchronous operation.
	* Offers a consistent, readable API for registering success, failure, cancellation or progress callbacks.
	* Allows chaining of transformation and processing of future values.
	* Simplifies processing of a set of future values via utility functions including all(), any(), map() and reduce().
	* Implements the CommonJS Promises/A specification.

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
	contactManager: {
		className: 'MyApp.manager.ContactManager',
		singleton: false
	},
	...
});
```

When configured as a prototype, each call to resolve an identifier will return a new instance of the specified class.

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

A class does not need to explicitly define a config or property for the property to be injected. However, if that property is defined as an existing config (even in a superclass), the Injector will correctly populate the config value.

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

## Deft.mvc.ViewController ##

A lightweight controller for a view, responsible for managing the state of the view and its child components, listening for events dispatched by the view and its child components in response to user gestures, and delegating work to injected business services (such as Stores, Models, Managers, etc.).

The ViewController is an abstract base class which can be extended to create view-specific view controllers.

```javascript
Ext.define( 'MyApp.controller.ContactsViewController', {
	extend: 'Deft.mvc.ViewController',
	...
});
```

References to view components can be established via the `control` annotation and view-relative component query selectors:

```javascript
Ext.define( 'MyApp.controller.ContactsViewController', {
	extend: 'Deft.mvc.ViewController',	
	...
	control: {
		submitButton: 'panel > button[text="Submit"]',
		cancelButton: 'panel > button[text="Cancel"]',
		...
	}
	...
	init: function() {
		// getSubmitButton() accessor will be automatically created.
		this.getSubmitButton().disable();
		
		return this.callParent( arguments );
	}
	...
});
```

*NOTE:* The specified component query selector is evaluated relative to the view, rather than globally as in `Ext.app.Controller`.

As seen above, a getter function will automatically created and added to the view controller for each referenced component.

Alternatively, the selector can be omitted if the component identifier being registered matches the view component's `itemId`:

```javascript
Ext.define( 'MyApp.controller.ContactsViewController', {
	extend: 'Deft.mvc.ViewController',	
	...
	control: {
		submitButton: true, // indicates the Button in the view has an itemId of 'submitButton'
		...
	}
});
```

As before, this will create and add a `getSubmitButton()` accessor to the view controller.

The `control` annotation can also be used to register event listeners for events dispatched by referenced view components.

```javascript
Ext.define( 'MyApp.controller.ContactsViewController', {
	extend: 'Deft.mvc.ViewController',	
	...
	control: {
		submitButton: {
			click: 'onSubmitButtonClick'
		}
	}
	...
	onSubmitButtonClick: function() {
		// executed in the view controller's scope
		...
	}
	...
});
```

In this example, in addition to creating and adding a `getSubmitButton()` accessor, the view controller will add a `click` event listener to the Button with an itemId of `submitButton` in the corresponding view.

*NOTE:* The specified event listener will be called in the view controller's scope.

Standard event listener options such as `buffer`, `delay`, `scope`, `single` and `element` can be specified for a given view component event using slightly more verbose syntax:

```javascript
Ext.define( 'MyApp.controller.ContactsViewController', {
	extend: 'Deft.mvc.ViewController',	
	...
	control: {
		valueSlider: {
			listeners: {
				change: {
					fn: 'onValueSliderChange',
					buffer: 70
				}
			}
		}
	}
	...
});
```

As an alternative to relying on matching component `itemId`'s, the `control` annotation can be configured to both reference a component by a view-relative component query selector and add event listeners, using slightly more verbose syntax:

```javascript
Ext.define( 'MyApp.controller.ContactsViewController', {
	extend: 'Deft.mvc.ViewController',	
	...
	control: {
		submitButton: {
			selector: 'panel > button[text="Submit"]',
			listeners: {
				click: 'onSubmitButtonClick'
			}
		}
	}
	...
});
```

To listen to events dispatched by the view, use the `view` identifier:

```javascript
Ext.define( 'MyApp.controller.ContactsViewController', {
	extend: 'Deft.mvc.ViewController',	
	...
	control: {
		view: {
			show: 'onViewShow',
			hide: 'onViewHide'
		}
	}
	...
	init: function() {
		this.getView().show()
	
		return this.callParent( arguments );
	}
});
```

*NOTE:* The `getView()` accessor is always available, regardless of whether you explicitly create a reference and add event listeners to `view`.

After the view has been initialized or rendered for the first time, the view controller's `init()` template method will be called.

```javascript
Ext.define( 'MyApp.controller.ContactsViewController', {
	extend: 'Deft.mvc.ViewController',	
	...
	control: {
		...
	}
	...
	init: function() {
		// all accessors will have been created and all event listeners will have been added
	
		return this.callParent( arguments );
	}
});
```

When the `destroy()` is called on the view, the view controller's `destroy()` template method is called. If this method returns `false`, view destruction will be cancelled. If this method returns `true`, the view will be destroyed, and all references and event listeners created in the view controller using `control` will automatically be removed.

```javascript
Ext.define( 'MyApp.controller.ContactsViewController', {
	extend: 'Deft.mvc.ViewController',	
	...
	control: {
		...
	}
	...
	destroy: function() {
		if (this.hasUnsavedChanges) {
			// cancel destruction
			return false
		}
		
		// burn baby burn
		return this.callParent( arguments );
	}
});
```

Recall that a view controller is expected to delegate work to injected business services. This can be accomplished by leveraging `Deft.ioc.Injector` and including the `Deft.mixin.Injectable` mixin.


```javascript
Ext.define( 'MyApp.controller.ContactsViewController', {
	extend: 'Deft.mvc.ViewController', 
	mixins: [ 'Deft.mixin.Injectable' ]
	inject: [ 'contactStore' ]
	...
	control: {
		refreshButton: {
			click: 'onRefreshButtonClick'
		}
	}
	...
	onRefreshButtonClick: function() {
		contactStore.load()
	}
});
```

See the documentation for `Deft.ioc.Injector` and `Deft.mixin.Injectable` for more details.

## Deft.mixin.Controllable ##

A view class can be configured to be controlled by a view controller by including the Controllable mixin:

```javascript
Ext.define( 'MyApp.view.ContactsView', {
	extend: 'Ext.panel.Panel',
	mixins: [ 'Deft.mixin.Controllable' ],
	controller: 'MyApp.controller.ContactsViewController'
	...
});
```

The corresponding view controller class is specified using the `controller` annotation.

In this case, whenever an instance of ContactsView is created, an instance of the ContactsViewController will also be created and associated with that view instance.

Consequently, multiple independent instances of a given view class can be created, each with their own independent view controller instances. Views can communicate by interacting with shared injected business services. Nested views can also communicate via custom events.

Provided the specified `controller` extends `Deft.mvc.ViewController`, the controller will automatically be destroyed when the view is destroyed.

# Version History

* 0.6.7 - Controllable now automatically adds a `getController()` accessor to view. Fixes reported issue with Deferreds completed with 'undefined' values.
* 0.6.6 - Fixes to improve error handling and reporting; especially those associated with nonexistent classes and classes that were not Ext.require()-ed.
* 0.6.5 - Enhanced IoC container to support classes defined as singletons using the Sencha class system.
* 0.6.4 - Hotfix for Sencha Touch Logger issue.
* 0.6.3 - Added memoization feature. Fixed reported Sencha Touch issues.
* 0.6.2 - Added support for View Controller event listener options. Ext JS 4.1rc3 compatibility fixes.
* 0.6.1 - Sencha Touch compatibility fixes.
* 0.6.0 - Introducing View Controller and Controllable. Preview release of Deferred and Promise.
* 0.1.1 - Preview release, added Jasmine test suite.
* 0.1.0 - Preview release, introducing an IoC container for dependency injection.

# Roadmap

* Promise unit tests (*in progress*)
* Promise and Deferred documentation (*in progress*)
* Forums (*in progress*)
* JSDuck-compliant comments and Sencha-style documentation browser.
* Website
* FAQ
* Example Ext JS and Sencha Touch applications
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
	* [Jason Barry](http://dribbble.com/artifactdesign) for creating the Deft JS logo.
	* [Thomas Burleson](http://twitter.com/thomasburleson) for beta-testing and providing feedback on view controllers and promises.
	* [David Tucker](http://www.davidtucker.net/) for reviewing several iterations of the proposed syntax.
	* [Claude Gauthier](http://www.sencha.com/training) for leading the 5-day 'Fast Track to Ext JS' training where this idea was born.
	* [Tim Marshall](http://twitter.com/timothymarshall) for parting with the twitter account and project name, which he'd previously used for a personal project.

