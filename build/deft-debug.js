/*!
DeftJS 0.9.0-pre

Copyright (c) 2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* DeftJS Class-related static utility methods.
* @private
*/
Ext.define('Deft.core.Class', {
  alternateClassName: ['Deft.Class'],
  statics: {
    /**
    		Register a new pre-processor to be used during the class creation process.
    		(Normalizes API differences between the various Sencha frameworks and versions.)
    */

    registerPreprocessor: function(name, fn, position, relativeTo) {
      if (Ext.getVersion('extjs') && Ext.getVersion('core').isLessThan('4.1.0')) {
        Ext.Class.registerPreprocessor(name, function(Class, data, callback) {
          return fn.call(this, Class, data, data, callback);
        }).setDefaultPreprocessorPosition(name, position, relativeTo);
      } else {
        Ext.Class.registerPreprocessor(name, function(Class, data, hooks, callback) {
          return fn.call(this, Class, data, hooks, callback);
        }, [name], position, relativeTo);
      }
    },
    hookOnClassCreated: function(hooks, fn) {
      if (Ext.getVersion('extjs') && Ext.getVersion('core').isLessThan('4.1.0')) {
        Ext.Function.interceptBefore(hooks, 'onClassCreated', fn);
      } else {
        Ext.Function.interceptBefore(hooks, 'onCreated', fn);
      }
    },
    hookOnClassExtended: function(data, fn) {
      var onClassExtended;

      if (Ext.getVersion('extjs') && Ext.getVersion('core').isLessThan('4.1.0')) {
        onClassExtended = function(Class, data) {
          return fn.call(this, Class, data, data);
        };
      } else {
        onClassExtended = fn;
      }
      if (data.onClassExtended != null) {
        Ext.Function.interceptBefore(data, 'onClassExtended', onClassExtended);
      } else {
        data.onClassExtended = onClassExtended;
      }
    },
    /**
    		* Returns true if the passed class name is a superclass of the passed Class reference.
    */

    extendsClass: function(className, currentClass) {
      var error;

      try {
        if (Ext.getClassName(currentClass) === className) {
          return true;
        }
        if (currentClass != null ? currentClass.superclass : void 0) {
          if (Ext.getClassName(currentClass.superclass) === className) {
            return true;
          } else {
            return Deft.Class.extendsClass(className, Ext.getClass(currentClass.superclass));
          }
        } else {
          return false;
        }
      } catch (_error) {
        error = _error;
        return false;
      }
    }
  }
});
/**
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* Logger used by DeftJS. Output is displayed in the console when using ext-dev/ext-all-dev.
* @private
*/
Ext.define('Deft.log.Logger', {
  alternateClassName: ['Deft.Logger'],
  singleton: true,
  log: function(message, priority) {
    if (priority == null) {
      priority = 'info';
    }
  },
  error: function(message) {
    this.log(message, 'error');
  },
  info: function(message) {
    this.log(message, 'info');
  },
  verbose: function(message) {
    this.log(message, 'verbose');
  },
  warn: function(message) {
    this.log(message, 'warn');
  },
  deprecate: function(message) {
    this.log(message, 'deprecate');
  }
}, function() {
  var _ref;

  if (Ext.getVersion('extjs') != null) {
    this.log = function(message, priority) {
      if (priority == null) {
        priority = 'info';
      }
      if (priority === 'verbose') {
        priority === 'info';
      }
      if (priority === 'deprecate') {
        priority = 'warn';
      }
      Ext.log({
        msg: message,
        level: priority
      });
    };
  } else {
    if (Ext.isFunction((_ref = Ext.Logger) != null ? _ref.log : void 0)) {
      this.log = Ext.bind(Ext.Logger.log, Ext.Logger);
    }
  }
});
/**
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* Common utility functions used by DeftJS.
*/
Ext.define('Deft.util.Function', {
  alternateClassName: ['Deft.Function'],
  statics: {
    /**
    		* Schedules the specified callback function to be executed on the next
    		* turn of the event loop.
    		* 
    		* @param {Function} Callback function.
    		* @param {Object} Optional scope for the callback.
    */

    nextTick: function(fn, scope) {
      if (scope != null) {
        fn = Ext.Function.bind(fn, scope);
      }
      setTimeout(fn, 0);
    },
    /**
    		* Creates a new wrapper function that spreads the passed Array over the
    		* target function arguments.
    		* 
    		* @param {Function} Function to wrap.
    		* @param {Object} Optional scope in which to execute the wrapped function.
    		* @return {Function} The new wrapper function.
    */

    spread: function(fn, scope) {
      return function(array) {
        if (!Ext.isArray(array)) {
          Ext.Error.raise({
            msg: "Error spreading passed Array over target function arguments: passed a non-Array."
          });
        }
        return fn.apply(scope, array);
      };
    },
    /**
    		* Returns a new wrapper function that caches the return value for 
    		* previously processed function argument(s).
    		* 
    		* @param {Function} Function to wrap.
    		* @param {Object} Optional scope in which to execute the wrapped function.
    		* @return {Function} The new wrapper function.
    */

    memoize: function(fn, scope, hashFn) {
      var memo;

      memo = {};
      return function(value) {
        var key;

        key = Ext.isFunction(hashFn) ? hashFn.apply(scope, arguments) : value;
        if (!(key in memo)) {
          memo[key] = fn.apply(scope, arguments);
        }
        return memo[key];
      };
    },
    /**
    		* Retrieves the value for the specified object key and removes the pair
    		* from the object.
    */

    extract: function(object, key) {
      var value;

      value = object[key];
      delete object[key];
      return value;
    }
  }
}, function() {
  if (typeof setImmediate !== "undefined" && setImmediate !== null) {
    return this.nextTick = function() {
      var fn;

      if (typeof scope !== "undefined" && scope !== null) {
        fn = Ext.Function.bind(fn, scope);
      }
      setImmediate(fn);
    };
  }
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* Event listener for events fired via the Deft.event.LiveEventBus.
* @private
*/
Ext.define('Deft.event.LiveEventListener', {
  alternateClassName: ['Deft.LiveEventListener'],
  requires: ['Ext.ComponentQuery'],
  constructor: function(config) {
    var component, components, _i, _len;

    Ext.apply(this, config);
    this.components = [];
    components = Ext.ComponentQuery.query(this.selector, this.container);
    for (_i = 0, _len = components.length; _i < _len; _i++) {
      component = components[_i];
      this.components.push(component);
      component.on(this.eventName, this.fn, this.scope, this.options);
    }
  },
  destroy: function() {
    var component, _i, _len, _ref;

    _ref = this.components;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      component = _ref[_i];
      component.un(this.eventName, this.fn, this.scope);
    }
    this.components = null;
  },
  register: function(component) {
    if (this.matches(component)) {
      this.components.push(component);
      component.on(this.eventName, this.fn, this.scope, this.options);
    }
  },
  unregister: function(component) {
    var index;

    index = Ext.Array.indexOf(this.components, component);
    if (index !== -1) {
      component.un(this.eventName, this.fn, this.scope);
      Ext.Array.erase(this.components, index, 1);
    }
  },
  matches: function(component) {
    if (this.selector === null && this.container === component) {
      return true;
    }
    if (this.container === null && Ext.Array.contains(Ext.ComponentQuery.query(this.selector), component)) {
      return true;
    }
    if (component.isDescendantOf(this.container) && Ext.Array.contains(this.container.query(this.selector), component)) {
      return true;
    }
    return false;
  }
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* Event bus for live component selectors.
*/
Ext.define('Deft.event.LiveEventBus', {
  alternateClassName: ['Deft.LiveEventBus'],
  requires: ['Ext.Component', 'Ext.ComponentManager', 'Deft.event.LiveEventListener'],
  singleton: true,
  constructor: function() {
    this.listeners = [];
  },
  destroy: function() {
    var listener, _i, _len, _ref;

    _ref = this.listeners;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      listener = _ref[_i];
      listener.destroy();
    }
    this.listeners = null;
  },
  addListener: function(container, selector, eventName, fn, scope, options) {
    var listener;

    listener = Ext.create('Deft.event.LiveEventListener', {
      container: container,
      selector: selector,
      eventName: eventName,
      fn: fn,
      scope: scope,
      options: options
    });
    this.listeners.push(listener);
  },
  removeListener: function(container, selector, eventName, fn, scope) {
    var listener;

    listener = this.findListener(container, selector, eventName, fn, scope);
    if (listener != null) {
      Ext.Array.remove(this.listeners, listener);
      listener.destroy();
    }
  },
  on: function(container, selector, eventName, fn, scope, options) {
    return this.addListener(container, selector, eventName, fn, scope, options);
  },
  un: function(container, selector, eventName, fn, scope) {
    return this.removeListener(container, selector, eventName, fn, scope);
  },
  findListener: function(container, selector, eventName, fn, scope) {
    var listener, _i, _len, _ref;

    _ref = this.listeners;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      listener = _ref[_i];
      if (listener.container === container && listener.selector === selector && listener.eventName === eventName && listener.fn === fn && listener.scope === scope) {
        return listener;
      }
    }
    return null;
  },
  register: function(component) {
    component.on('added', this.onComponentAdded, this);
    component.on('removed', this.onComponentRemoved, this);
  },
  unregister: function(component) {
    component.un('added', this.onComponentAdded, this);
    component.un('removed', this.onComponentRemoved, this);
  },
  onComponentAdded: function(component, container, eOpts) {
    var listener, _i, _len, _ref;

    _ref = this.listeners;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      listener = _ref[_i];
      listener.register(component);
    }
  },
  onComponentRemoved: function(component, container, eOpts) {
    var listener, _i, _len, _ref;

    _ref = this.listeners;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      listener = _ref[_i];
      listener.unregister(component);
    }
  }
}, function() {
  if (Ext.getVersion('touch') != null) {
    Ext.define('Deft.Component', {
      override: 'Ext.Component',
      setParent: function(newParent) {
        var oldParent, result;

        oldParent = this.getParent();
        result = this.callParent(arguments);
        if (oldParent === null && newParent !== null) {
          this.fireEvent('added', this, newParent);
        } else if (oldParent !== null && newParent !== null) {
          this.fireEvent('removed', this, oldParent);
          this.fireEvent('added', this, newParent);
        } else if (oldParent !== null && newParent === null) {
          this.fireEvent('removed', this, oldParent);
        }
        return result;
      },
      isDescendantOf: function(container) {
        var ancestor;

        ancestor = this.getParent();
        while (ancestor != null) {
          if (ancestor === container) {
            return true;
          }
          ancestor = ancestor.getParent();
        }
        return false;
      }
    });
  }
  Ext.Function.interceptAfter(Ext.ComponentManager, 'register', function(component) {
    Deft.event.LiveEventBus.register(component);
  });
  Ext.Function.interceptAfter(Ext.ComponentManager, 'unregister', function(component) {
    Deft.event.LiveEventBus.unregister(component);
  });
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* Used by Deft.ioc.Injector.
* @private
*/
Ext.define('Deft.ioc.DependencyProvider', {
  requires: ['Deft.log.Logger'],
  config: {
    identifier: null,
    /**
    		Class to be instantiated, by either full name, alias or alternate name, to resolve this dependency.
    */

    className: null,
    /**
    		Optional arguments to pass to the class' constructor when instantiating a class to resolve this dependency.
    */

    parameters: null,
    /**
    		Factory function to be executed to obtain the corresponding object instance or value to resolve this dependency.
    
    		NOTE: For lazily instantiated dependencies, this function will be passed the object instance for which the dependency is being resolved.
    */

    fn: null,
    /**
    		Value to use to resolve this dependency.
    */

    value: void 0,
    /**
    		Indicates whether this dependency should be resolved as a singleton, or as a transient value for each resolution request.
    */

    singleton: true,
    /**
    		Indicates whether this dependency should be 'eagerly' instantiated when this provider is defined, rather than 'lazily' instantiated when later requested.
    
    		NOTE: Only valid when either a factory function or class is specified as a singleton.
    */

    eager: false
  },
  constructor: function(config) {
    var classDefinition;

    this.initConfig(config);
    if ((config.value != null) && config.value.constructor === Object) {
      this.setValue(config.value);
    }
    if (this.getEager()) {
      if (this.getValue() != null) {
        Ext.Error.raise({
          msg: "Error while configuring '" + (this.getIdentifier()) + "': a 'value' cannot be created eagerly."
        });
      }
      if (!this.getSingleton()) {
        Ext.Error.raise({
          msg: "Error while configuring '" + (this.getIdentifier()) + "': only singletons can be created eagerly."
        });
      }
    }
    if (this.getClassName() != null) {
      classDefinition = Ext.ClassManager.get(this.getClassName());
      if (classDefinition == null) {
        Deft.Logger.warn("Synchronously loading '" + (this.getClassName()) + "'; consider adding Ext.require('" + (this.getClassName()) + "') above Ext.onReady.");
        Ext.syncRequire(this.getClassName());
        classDefinition = Ext.ClassManager.get(this.getClassName());
      }
      if (classDefinition == null) {
        Ext.Error.raise({
          msg: "Error while configuring rule for '" + (this.getIdentifier()) + "': unrecognized class name or alias: '" + (this.getClassName()) + "'"
        });
      }
    }
    if (!this.getSingleton()) {
      if (this.getClassName() != null) {
        if (Ext.ClassManager.get(this.getClassName()).singleton) {
          Ext.Error.raise({
            msg: "Error while configuring rule for '" + (this.getIdentifier()) + "': singleton classes cannot be configured for injection as a prototype. Consider removing 'singleton: true' from the class definition."
          });
        }
      }
      if (this.getValue() != null) {
        Ext.Error.raise({
          msg: "Error while configuring '" + (this.getIdentifier()) + "': a 'value' can only be configured as a singleton."
        });
      }
    } else {
      if ((this.getClassName() != null) && (this.getParameters() != null)) {
        if (Ext.ClassManager.get(this.getClassName()).singleton) {
          Ext.Error.raise({
            msg: "Error while configuring rule for '" + (this.getIdentifier()) + "': parameters cannot be applied to singleton classes. Consider removing 'singleton: true' from the class definition."
          });
        }
      }
    }
    return this;
  },
  /**
  	Resolve a target instance's dependency with an object instance or value generated by this dependency provider.
  */

  resolve: function(targetInstance, targetInstanceConstructorArguments) {
    var instance, parameters;

    Deft.Logger.log("Resolving '" + (this.getIdentifier()) + "'.");
    if (this.getValue() !== void 0) {
      return this.getValue();
    }
    instance = null;
    if (this.getFn() != null) {
      Deft.Logger.log("Executing factory function.");
      instance = this.getFn().apply(targetInstance, targetInstanceConstructorArguments);
    } else if (this.getClassName() != null) {
      if (Ext.ClassManager.get(this.getClassName()).singleton) {
        Deft.Logger.log("Using existing singleton instance of '" + (this.getClassName()) + "'.");
        instance = Ext.ClassManager.get(this.getClassName());
      } else {
        Deft.Logger.log("Creating instance of '" + (this.getClassName()) + "'.");
        parameters = this.getParameters() != null ? [this.getClassName()].concat(this.getParameters()) : [this.getClassName()];
        instance = Ext.create.apply(this, parameters);
      }
    } else {
      Ext.Error.raise({
        msg: "Error while configuring rule for '" + (this.getIdentifier()) + "': no 'value', 'fn', or 'className' was specified."
      });
    }
    if (this.getSingleton()) {
      this.setValue(instance);
    }
    return instance;
  }
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
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

## <u>[Constructor Parameters](https://github.com/deftjs/DeftJS/wiki/Factory-Functions)</u>

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
*/
Ext.define('Deft.ioc.Injector', {
  alternateClassName: ['Deft.Injector'],
  requires: ['Ext.Component', 'Deft.log.Logger', 'Deft.ioc.DependencyProvider'],
  singleton: true,
  constructor: function() {
    this.providers = {};
    this.injectionStack = [];
    return this;
  },
  /**
  	Configure the Injector.
  */

  configure: function(configuration) {
    var newProviders;

    Deft.Logger.log('Configuring the injector.');
    newProviders = {};
    Ext.Object.each(configuration, function(identifier, config) {
      var provider;

      Deft.Logger.log("Configuring dependency provider for '" + identifier + "'.");
      if (Ext.isString(config)) {
        provider = Ext.create('Deft.ioc.DependencyProvider', {
          identifier: identifier,
          className: config
        });
      } else {
        provider = Ext.create('Deft.ioc.DependencyProvider', Ext.apply({
          identifier: identifier
        }, config));
      }
      this.providers[identifier] = provider;
      newProviders[identifier] = provider;
    }, this);
    Ext.Object.each(newProviders, function(identifier, provider) {
      if (provider.getEager()) {
        Deft.Logger.log("Eagerly creating '" + (provider.getIdentifier()) + "'.");
        provider.resolve();
      }
    }, this);
  },
  /**
  	Reset the Injector.
  */

  reset: function() {
    Deft.Logger.log('Resetting the injector.');
    this.providers = {};
  },
  /**
  	Indicates whether the Injector can resolve a dependency by the specified identifier with the corresponding object instance or value.
  */

  canResolve: function(identifier) {
    var provider;

    provider = this.providers[identifier];
    return provider != null;
  },
  /**
  	Resolve a dependency (by identifier) with the corresponding object instance or value.
  
  	Optionally, the caller may specify the target instance (to be supplied to the dependency provider's factory function, if applicable).
  */

  resolve: function(identifier, targetInstance, targetInstanceConstructorArguments) {
    var provider;

    provider = this.providers[identifier];
    if (provider != null) {
      if (targetInstance && !targetInstanceConstructorArguments) {
        targetInstanceConstructorArguments = [targetInstance.getInitialConfig()];
      }
      return provider.resolve(targetInstance, targetInstanceConstructorArguments);
    } else {
      Ext.Error.raise({
        msg: "Error while resolving value to inject: no dependency provider found for '" + identifier + "'."
      });
    }
  },
  /**
  	Inject dependencies (by their identifiers) into the target object instance.
  */

  inject: function(identifiers, targetInstance, targetInstanceConstructorArguments, targetInstanceIsInitialized) {
    var injectConfig, name, originalInitConfigFunction, setterFunctionName, stackMessage, targetClass, value;

    if (targetInstanceIsInitialized == null) {
      targetInstanceIsInitialized = true;
    }
    targetClass = Ext.getClassName(targetInstance);
    if (targetInstanceIsInitialized) {
      targetInstanceConstructorArguments = [targetInstance.getInitialConfig()];
    }
    if (Ext.Array.contains(this.injectionStack, targetClass)) {
      stackMessage = this.injectionStack.join(" -> ");
      this.injectionStack = [];
      Ext.Error.raise({
        msg: "Error resolving dependencies for '" + targetClass + "'. A circular dependency exists in its injections: " + stackMessage + " -> *" + targetClass + "*"
      });
      return null;
    }
    this.injectionStack.push(targetClass);
    injectConfig = {};
    if (Ext.isString(identifiers)) {
      identifiers = [identifiers];
    }
    Ext.Object.each(identifiers, function(key, value) {
      var identifier, resolvedValue, targetProperty;

      targetProperty = Ext.isArray(identifiers) ? value : key;
      identifier = value;
      resolvedValue = this.resolve(identifier, targetInstance, targetInstanceConstructorArguments);
      if (targetProperty in targetInstance.config) {
        Deft.Logger.log("Injecting '" + identifier + "' into '" + targetClass + "." + targetProperty + "' config.");
        injectConfig[targetProperty] = resolvedValue;
      } else {
        Deft.Logger.log("Injecting '" + identifier + "' into '" + targetClass + "." + targetProperty + "' property.");
        targetInstance[targetProperty] = resolvedValue;
      }
    }, this);
    this.injectionStack = [];
    if (targetInstanceIsInitialized) {
      for (name in injectConfig) {
        value = injectConfig[name];
        setterFunctionName = 'set' + Ext.String.capitalize(name);
        targetInstance[setterFunctionName].call(targetInstance, value);
      }
    } else {
      if ((Ext.getVersion('extjs') != null) && targetInstance instanceof Ext.ClassManager.get('Ext.Component')) {
        targetInstance.injectConfig = injectConfig;
      } else if (Ext.isFunction(targetInstance.initConfig)) {
        originalInitConfigFunction = targetInstance.initConfig;
        targetInstance.initConfig = function(config) {
          var result;

          result = originalInitConfigFunction.call(this, Ext.Object.merge({}, config || {}, injectConfig));
          return result;
        };
      }
    }
    return targetInstance;
  }
}, function() {
  if (Ext.getVersion('extjs') != null) {
    if (Ext.getVersion('core').isLessThan('4.1.0')) {
      Ext.Component.override({
        constructor: function(config) {
          config = Ext.Object.merge({}, config || {}, this.injectConfig || {});
          delete this.injectConfig;
          return this.callOverridden([config]);
        }
      });
    } else {
      Ext.define('Deft.InjectableComponent', {
        override: 'Ext.Component',
        constructor: function(config) {
          config = Ext.Object.merge({}, config || {}, this.injectConfig || {});
          delete this.injectConfig;
          return this.callParent([config]);
        }
      });
    }
  }
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* A mixin that marks a class as participating in dependency injection. Used in conjunction with Deft.ioc.Injector.
* @deprecated 0.8 Deft.mixin.Injectable has been deprecated and can now be omitted - simply use the \'inject\' class annotation on its own.
*/
Ext.define('Deft.mixin.Injectable', {
  requires: ['Deft.core.Class', 'Deft.ioc.Injector', 'Deft.log.Logger'],
  /**
  	@private
  */

  onClassMixedIn: function(targetClass) {
    Deft.Logger.deprecate('Deft.mixin.Injectable has been deprecated and can now be omitted - simply use the \'inject\' class annotation on its own.');
  }
}, function() {
  var createInjectionInterceptor;

  if (Ext.getVersion('extjs') && Ext.getVersion('core').isLessThan('4.1.0')) {
    createInjectionInterceptor = function() {
      return function() {
        if (!this.$injected) {
          Deft.Injector.inject(this.inject, this, arguments, false);
          this.$injected = true;
        }
        return this.callOverridden(arguments);
      };
    };
  } else {
    createInjectionInterceptor = function() {
      return function() {
        if (!this.$injected) {
          Deft.Injector.inject(this.inject, this, arguments, false);
          this.$injected = true;
        }
        return this.callParent(arguments);
      };
    };
  }
  Deft.Class.registerPreprocessor('inject', function(Class, data, hooks, callback) {
    var dataInjectObject, identifier, _i, _len, _ref;

    if (Ext.isString(data.inject)) {
      data.inject = [data.inject];
    }
    if (Ext.isArray(data.inject)) {
      dataInjectObject = {};
      _ref = data.inject;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        identifier = _ref[_i];
        dataInjectObject[identifier] = identifier;
      }
      data.inject = dataInjectObject;
    }
    Deft.Class.hookOnClassCreated(hooks, function(Class) {
      Class.override({
        constructor: createInjectionInterceptor()
      });
    });
    Deft.Class.hookOnClassExtended(data, function(Class, data, hooks) {
      var _ref1;

      Deft.Class.hookOnClassCreated(hooks, function(Class) {
        Class.override({
          constructor: createInjectionInterceptor()
        });
      });
      if ((_ref1 = data.inject) == null) {
        data.inject = {};
      }
      Ext.applyIf(data.inject, Class.superclass.inject);
    });
  }, 'before', 'extend');
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* @private
* Used by Deft.mvc.ViewController to handle events fired from injected objects.
*/
Ext.define('Deft.mvc.Observer', {
  requires: ['Deft.core.Class', 'Ext.util.Observable', 'Deft.util.Function'],
  statics: {
    /**
    		* Merges child and parent observers into a single object. This differs from a normal object merge because
    		* a given observer target and event can potentially have multiple handlers declared in different parent or
    		* child classes. It transforms an event handler value into an array of values, and merges the arrays of handlers
    		* from child to parent. This maintains the handlers even if both parent and child classes have handlers for the
    		* same target and event.
    */

    mergeObserve: function(originalParentObserve, originalChildObserve) {
      var childEvent, childEvents, childHandler, childHandlerArray, childObserve, childTarget, convertConfigArray, eventOptionNames, parentEvent, parentEvents, parentHandler, parentHandlerArray, parentObserve, parentTarget, _ref, _ref1;

      if (!Ext.isObject(originalParentObserve)) {
        parentObserve = {};
      } else {
        parentObserve = Ext.clone(originalParentObserve);
      }
      if (!Ext.isObject(originalChildObserve)) {
        childObserve = {};
      } else {
        childObserve = Ext.clone(originalChildObserve);
      }
      eventOptionNames = ["buffer", "single", "delay", "element", "target", "destroyable"];
      convertConfigArray = function(observeConfig) {
        var handlerConfig, newObserveEvents, observeEvents, observeTarget, thisEventOptionName, thisObserveEvent, _i, _j, _len, _len1, _results;

        _results = [];
        for (observeTarget in observeConfig) {
          observeEvents = observeConfig[observeTarget];
          if (Ext.isArray(observeEvents)) {
            newObserveEvents = {};
            for (_i = 0, _len = observeEvents.length; _i < _len; _i++) {
              thisObserveEvent = observeEvents[_i];
              if (Ext.Object.getSize(thisObserveEvent) === 1) {
                Ext.apply(newObserveEvents, thisObserveEvent);
              } else {
                handlerConfig = {};
                if ((thisObserveEvent != null ? thisObserveEvent.fn : void 0) != null) {
                  handlerConfig.fn = thisObserveEvent.fn;
                }
                if ((thisObserveEvent != null ? thisObserveEvent.scope : void 0) != null) {
                  handlerConfig.scope = thisObserveEvent.scope;
                }
                for (_j = 0, _len1 = eventOptionNames.length; _j < _len1; _j++) {
                  thisEventOptionName = eventOptionNames[_j];
                  if ((thisObserveEvent != null ? thisObserveEvent[thisEventOptionName] : void 0) != null) {
                    handlerConfig[thisEventOptionName] = thisObserveEvent[thisEventOptionName];
                  }
                }
                newObserveEvents[thisObserveEvent.event] = [handlerConfig];
              }
            }
            _results.push(observeConfig[observeTarget] = newObserveEvents);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
      convertConfigArray(parentObserve);
      convertConfigArray(childObserve);
      for (childTarget in childObserve) {
        childEvents = childObserve[childTarget];
        for (childEvent in childEvents) {
          childHandler = childEvents[childEvent];
          if (Ext.isString(childHandler)) {
            childObserve[childTarget][childEvent] = childHandler.replace(' ', '').split(',');
          }
          if (!(parentObserve != null ? parentObserve[childTarget] : void 0)) {
            parentObserve[childTarget] = {};
          }
          if (!(parentObserve != null ? (_ref = parentObserve[childTarget]) != null ? _ref[childEvent] : void 0 : void 0)) {
            parentObserve[childTarget][childEvent] = childObserve[childTarget][childEvent];
            delete childObserve[childTarget][childEvent];
          }
        }
      }
      for (parentTarget in parentObserve) {
        parentEvents = parentObserve[parentTarget];
        for (parentEvent in parentEvents) {
          parentHandler = parentEvents[parentEvent];
          if (Ext.isString(parentHandler)) {
            parentObserve[parentTarget][parentEvent] = parentHandler.split(',');
          }
          if (childObserve != null ? (_ref1 = childObserve[parentTarget]) != null ? _ref1[parentEvent] : void 0 : void 0) {
            childHandlerArray = childObserve[parentTarget][parentEvent];
            parentHandlerArray = parentObserve[parentTarget][parentEvent];
            parentObserve[parentTarget][parentEvent] = Ext.Array.unique(Ext.Array.insert(parentHandlerArray, 0, childHandlerArray));
          }
        }
      }
      return parentObserve;
    }
  },
  /**
  	* Expects a config object with properties for host, target, and events.
  */

  constructor: function(config) {
    var eventName, events, handler, handlerArray, host, options, references, scope, target, _i, _len;

    this.listeners = [];
    host = config != null ? config.host : void 0;
    target = config != null ? config.target : void 0;
    events = config != null ? config.events : void 0;
    if (host && target && (this.isPropertyChain(target) || this.isTargetObservable(host, target))) {
      for (eventName in events) {
        handlerArray = events[eventName];
        if (Ext.isString(handlerArray)) {
          handlerArray = handlerArray.replace(' ', '').split(',');
        }
        for (_i = 0, _len = handlerArray.length; _i < _len; _i++) {
          handler = handlerArray[_i];
          scope = host;
          options = null;
          if (Ext.isObject(handler)) {
            options = Ext.clone(handler);
            if (options != null ? options.event : void 0) {
              eventName = Deft.util.Function.extract(options, "event");
            }
            if (options != null ? options.fn : void 0) {
              handler = Deft.util.Function.extract(options, "fn");
            }
            if (options != null ? options.scope : void 0) {
              scope = Deft.util.Function.extract(options, "scope");
            }
          }
          references = this.locateReferences(host, target, handler);
          if (references) {
            references.target.on(eventName, references.handler, scope, options);
            this.listeners.push({
              targetName: target,
              target: references.target,
              event: eventName,
              handler: references.handler,
              scope: scope
            });
            Deft.Logger.log("Created observer on '" + target + "' for event '" + eventName + "'.");
          } else {
            Deft.Logger.warn("Could not create observer on '" + target + "' for event '" + eventName + "'.");
          }
        }
      }
    } else {
      Deft.Logger.warn("Could not create observers on '" + target + "' because '" + target + "' is not an Ext.util.Observable");
    }
    return this;
  },
  /**
  	* Returns true if the passed host has a target that is Observable.
  	* Checks for an isObservable=true property, observable mixin, or if the class extends Observable.
  */

  isTargetObservable: function(host, target) {
    var hostTarget, hostTargetClass, _ref;

    hostTarget = this.locateTarget(host, target);
    if (hostTarget == null) {
      return false;
    }
    if ((hostTarget.isObservable != null) || (((_ref = hostTarget.mixins) != null ? _ref.observable : void 0) != null)) {
      return true;
    } else {
      hostTargetClass = Ext.ClassManager.getClass(hostTarget);
      return Deft.Class.extendsClass('Ext.util.Observable', hostTargetClass) || Deft.Class.extendsClass('Ext.mixin.Observable', hostTargetClass);
    }
  },
  /**
  	* Attempts to locate an observer target given the host object and target property name.
  	* Checks for both host[ target ], and host.getTarget().
  */

  locateTarget: function(host, target) {
    var result;

    if (Ext.isFunction(host['get' + Ext.String.capitalize(target)])) {
      result = host['get' + Ext.String.capitalize(target)].call(host);
      return result;
    } else if ((host != null ? host[target] : void 0) != null) {
      result = host[target];
      return result;
    } else {
      return null;
    }
  },
  /**
  	* Returns true if the passed target is a string containing a '.', indicating that it is referencing a nested property.
  */

  isPropertyChain: function(target) {
    return Ext.isString(target) && target.indexOf('.') > -1;
  },
  /**
  	* Given a host object, target property name, and handler, return object references for the final target and handler function.
  	* If necessary, recurse down a property chain to locate the final target object for the event listener.
  */

  locateReferences: function(host, target, handler) {
    var handlerHost, propertyChain;

    handlerHost = host;
    if (this.isPropertyChain(target)) {
      propertyChain = this.parsePropertyChain(host, target);
      if (!propertyChain) {
        return null;
      }
      host = propertyChain.host;
      target = propertyChain.target;
    }
    if (Ext.isFunction(handler)) {
      return {
        target: this.locateTarget(host, target),
        handler: handler
      };
    } else if (Ext.isFunction(handlerHost[handler])) {
      return {
        target: this.locateTarget(host, target),
        handler: handlerHost[handler]
      };
    } else {
      return null;
    }
  },
  /**
  	* Given a target property chain and a property host object, recurse down the property chain and return
  	* the final host object from the property chain, and the final object that will accept the event listener.
  */

  parsePropertyChain: function(host, target) {
    var propertyChain;

    if (Ext.isString(target)) {
      propertyChain = target.split('.');
    } else if (Ext.isArray(target)) {
      propertyChain = target;
    } else {
      return null;
    }
    if (propertyChain.length > 1 && (this.locateTarget(host, propertyChain[0]) != null)) {
      return this.parsePropertyChain(this.locateTarget(host, propertyChain[0]), propertyChain.slice(1));
    } else if (this.isTargetObservable(host, propertyChain[0])) {
      return {
        host: host,
        target: propertyChain[0]
      };
    } else {
      return null;
    }
  },
  /**
  	* Iterate through the listeners array and remove each event listener.
  */

  destroy: function() {
    var listenerData, _i, _len, _ref;

    _ref = this.listeners;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      listenerData = _ref[_i];
      Deft.Logger.log("Removing observer on '" + listenerData.targetName + "' for event '" + listenerData.event + "'.");
      listenerData.target.un(listenerData.event, listenerData.handler, listenerData.scope);
    }
    this.listeners = [];
  }
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* Manages live events attached to component selectors. Used by Deft.mvc.ComponentSelector.
* @private
*/
Ext.define('Deft.mvc.ComponentSelectorListener', {
  requires: ['Deft.event.LiveEventBus'],
  constructor: function(config) {
    var component, _i, _len, _ref;

    Ext.apply(this, config);
    if (this.componentSelector.live) {
      Deft.LiveEventBus.addListener(this.componentSelector.view, this.componentSelector.selector, this.eventName, this.fn, this.scope, this.options);
    } else {
      _ref = this.componentSelector.components;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        component = _ref[_i];
        component.on(this.eventName, this.fn, this.scope, this.options);
      }
    }
    return this;
  },
  destroy: function() {
    var component, _i, _len, _ref;

    if (this.componentSelector.live) {
      Deft.LiveEventBus.removeListener(this.componentSelector.view, this.componentSelector.selector, this.eventName, this.fn, this.scope);
    } else {
      _ref = this.componentSelector.components;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        component = _ref[_i];
        component.un(this.eventName, this.fn, this.scope);
      }
    }
  }
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* @private
* Models a component selector used by Deft.mvc.ViewController to locate view components and attach event listeners.
*/
Ext.define('Deft.mvc.ComponentSelector', {
  requires: ['Ext.ComponentQuery', 'Deft.log.Logger', 'Deft.mvc.ComponentSelectorListener'],
  constructor: function(config) {
    var eventName, fn, listener, options, scope, _ref;

    Ext.apply(this, config);
    if (!this.live) {
      this.components = this.selector != null ? Ext.ComponentQuery.query(this.selector, this.view) : [this.view];
    }
    this.selectorListeners = [];
    if (Ext.isObject(this.listeners)) {
      _ref = this.listeners;
      for (eventName in _ref) {
        listener = _ref[eventName];
        fn = listener;
        scope = this.scope;
        options = null;
        if (Ext.isObject(listener)) {
          options = Ext.apply({}, listener);
          if (options.fn != null) {
            fn = options.fn;
            delete options.fn;
          }
          if (options.scope != null) {
            scope = options.scope;
            delete options.scope;
          }
        }
        if (Ext.isString(fn) && Ext.isFunction(scope[fn])) {
          fn = scope[fn];
        }
        if (!Ext.isFunction(fn)) {
          Ext.Error.raise({
            msg: "Error adding '" + eventName + "' listener: the specified handler '" + fn + "' is not a Function or does not exist."
          });
        }
        this.addListener(eventName, fn, scope, options);
      }
    }
    return this;
  },
  destroy: function() {
    var selectorListener, _i, _len, _ref;

    _ref = this.selectorListeners;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      selectorListener = _ref[_i];
      selectorListener.destroy();
    }
    this.selectorListeners = [];
  },
  /**
  	Add an event listener to this component selector.
  */

  addListener: function(eventName, fn, scope, options) {
    var selectorListener;

    if (this.findListener(eventName, fn, scope) != null) {
      Ext.Error.raise({
        msg: "Error adding '" + eventName + "' listener: an existing listener for the specified function was already registered for '" + this.selector + "."
      });
    }
    Deft.Logger.log("Adding '" + eventName + "' listener to '" + this.selector + "'.");
    selectorListener = Ext.create('Deft.mvc.ComponentSelectorListener', {
      componentSelector: this,
      eventName: eventName,
      fn: fn,
      scope: scope,
      options: options
    });
    this.selectorListeners.push(selectorListener);
  },
  /**
  	Remove an event listener from this component selector.
  */

  removeListener: function(eventName, fn, scope) {
    var selectorListener;

    selectorListener = this.findListener(eventName, fn, scope);
    if (selectorListener != null) {
      Deft.Logger.log("Removing '" + eventName + "' listener from '" + this.selector + "'.");
      selectorListener.destroy();
      Ext.Array.remove(this.selectorListeners, selectorListener);
    }
  },
  findListener: function(eventName, fn, scope) {
    var selectorListener, _i, _len, _ref;

    _ref = this.selectorListeners;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      selectorListener = _ref[_i];
      if (selectorListener.eventName === eventName && selectorListener.fn === fn && selectorListener.scope === scope) {
        return selectorListener;
      }
    }
    return null;
  }
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
A lightweight MVC view controller. Full usage instructions in the [DeftJS documentation](https://github.com/deftjs/DeftJS/wiki/ViewController).

First, specify a ViewController to attach to a view:

    Ext.define("DeftQuickStart.view.MyTabPanel", {
      extend: "Ext.tab.Panel",
      controller: "DeftQuickStart.controller.MainController",
      ...
    });

Next, define the ViewController:

    Ext.define("DeftQuickStart.controller.MainController", {
      extend: "Deft.mvc.ViewController",

      init: function() {
        return this.callParent(arguments);
      }

    });

## Inject dependencies using the <u>[`inject` property](https://github.com/deftjs/DeftJS/wiki/Injecting-Dependencies)</u>:

    Ext.define("DeftQuickStart.controller.MainController", {
      extend: "Deft.mvc.ViewController",
      inject: ["companyStore"],

      config: {
        companyStore: null
      },

      init: function() {
        return this.callParent(arguments);
      }

    });

## Define <u>[references to view components](https://github.com/deftjs/DeftJS/wiki/Accessing-Views)</u> and <u>[add view listeners](https://github.com/deftjs/DeftJS/wiki/Handling-View-Events)</u> with the `control` property:

    Ext.define("DeftQuickStart.controller.MainController", {
      extend: "Deft.mvc.ViewController",

      control: {

        // Most common configuration, using an itemId and listener
        manufacturingFilter: {
          change: "onFilterChange"
        },

        // Reference only, with no listeners
        serviceIndustryFilter: true,

        // Configuration using selector, listeners, and event listener options
        salesFilter: {
          selector: "toolbar > checkbox",
          listeners: {
            change: {
              fn: "onFilterChange",
              buffer: 50,
              single: true
            }
          }
        }
      },

      init: function() {
        return this.callParent(arguments);
      }

      // Event handlers or other methods here...

    });

## Dynamically monitor view to attach listeners to added components with <u>[live selectors](https://github.com/deftjs/DeftJS/wiki/ViewController-Live-Selectors)</u>:

    control: {
      manufacturingFilter: {
        live: true,
        listeners: {
          change: "onFilterChange"
        }
      }
    };

## Observe events on injected objects with the <u>[`observe` property](https://github.com/deftjs/DeftJS/wiki/ViewController-Observe-Configuration)</u>:

    Ext.define("DeftQuickStart.controller.MainController", {
      extend: "Deft.mvc.ViewController",
      inject: ["companyStore"],

      config: {
        companyStore: null
      },

      observe: {
        // Observe companyStore for the update event
        companyStore: {
          update: "onCompanyStoreUpdateEvent"
        }
      },

      init: function() {
        return this.callParent(arguments);
      },

      onCompanyStoreUpdateEvent: function(store, model, operation, fieldNames) {
        // Do something when store fires update event
      }

    });
*/
Ext.define('Deft.mvc.ViewController', {
  alternateClassName: ['Deft.ViewController'],
  requires: ['Deft.core.Class', 'Deft.log.Logger', 'Deft.mvc.ComponentSelector', 'Deft.mvc.Observer'],
  config: {
    /**
    		* View controlled by this ViewController.
    */

    view: null
  },
  /**
  	* Observers automatically created and removed by this ViewController.
  */

  observe: {},
  constructor: function(config) {
    if (config == null) {
      config = {};
    }
    if (config.view) {
      this.controlView(config.view);
    }
    this.initConfig(config);
    if (Ext.Object.getSize(this.observe) > 0) {
      this.createObservers();
    }
    return this;
  },
  /**
  	* @protected
  */

  controlView: function(view) {
    if (view instanceof Ext.ClassManager.get('Ext.Component')) {
      this.setView(view);
      this.registeredComponentReferences = {};
      this.registeredComponentSelectors = {};
      if (Ext.getVersion('extjs') != null) {
        if (this.getView().rendered) {
          this.onViewInitialize();
        } else {
          this.getView().on('afterrender', this.onViewInitialize, this, {
            single: true
          });
        }
      } else {
        if (this.getView().initialized) {
          this.onViewInitialize();
        } else {
          this.getView().on('initialize', this.onViewInitialize, this, {
            single: true
          });
        }
      }
    } else {
      Ext.Error.raise({
        msg: 'Error constructing ViewController: the configured \'view\' is not an Ext.Component.'
      });
    }
  },
  /**
  	* Initialize the ViewController
  */

  init: function() {},
  /**
  	* Destroy the ViewController
  */

  destroy: function() {
    var id, selector;

    for (id in this.registeredComponentReferences) {
      this.removeComponentReference(id);
    }
    for (selector in this.registeredComponentSelectors) {
      this.removeComponentSelector(selector);
    }
    this.removeObservers();
    return true;
  },
  /**
  	* @private
  */

  onViewInitialize: function() {
    var config, id, listeners, live, originalViewDestroyFunction, selector, self, _ref;

    if (Ext.getVersion('extjs') != null) {
      this.getView().on('beforedestroy', this.onViewBeforeDestroy, this);
    } else {
      self = this;
      originalViewDestroyFunction = this.getView().destroy;
      this.getView().destroy = function() {
        if (self.destroy()) {
          originalViewDestroyFunction.call(this);
        }
      };
    }
    _ref = this.control;
    for (id in _ref) {
      config = _ref[id];
      selector = null;
      if (id !== 'view') {
        if (Ext.isString(config)) {
          selector = config;
        } else if (config.selector != null) {
          selector = config.selector;
        } else {
          selector = '#' + id;
        }
      }
      listeners = null;
      if (Ext.isObject(config.listeners)) {
        listeners = config.listeners;
      } else {
        if (!((config.selector != null) || (config.live != null))) {
          listeners = config;
        }
      }
      live = (config.live != null) && config.live;
      this.addComponentReference(id, selector, live);
      this.addComponentSelector(selector, listeners, live);
    }
    this.init();
  },
  /**
  	* @private
  */

  onViewBeforeDestroy: function() {
    if (this.destroy()) {
      this.getView().un('beforedestroy', this.onViewBeforeDestroy, this);
      return true;
    }
    return false;
  },
  /**
  	* Add a component accessor method the ViewController for the specified view-relative selector.
  */

  addComponentReference: function(id, selector, live) {
    var getterName, matches;

    if (live == null) {
      live = false;
    }
    Deft.Logger.log("Adding '" + id + "' component reference for selector: '" + selector + "'.");
    if (this.registeredComponentReferences[id] != null) {
      Ext.Error.raise({
        msg: "Error adding component reference: an existing component reference was already registered as '" + id + "'."
      });
    }
    if (id !== 'view') {
      getterName = 'get' + Ext.String.capitalize(id);
      if (this[getterName] == null) {
        if (live) {
          this[getterName] = Ext.Function.pass(this.getViewComponent, [selector], this);
        } else {
          matches = this.getViewComponent(selector);
          if (matches == null) {
            Ext.Error.raise({
              msg: "Error locating component: no component(s) found matching '" + selector + "'."
            });
          }
          this[getterName] = function() {
            return matches;
          };
        }
        this[getterName].generated = true;
      }
    }
    this.registeredComponentReferences[id] = true;
  },
  /**
  	* Remove a component accessor method the ViewController for the specified view-relative selector.
  */

  removeComponentReference: function(id) {
    var getterName;

    Deft.Logger.log("Removing '" + id + "' component reference.");
    if (this.registeredComponentReferences[id] == null) {
      Ext.Error.raise({
        msg: "Error removing component reference: no component reference is registered as '" + id + "'."
      });
    }
    if (id !== 'view') {
      getterName = 'get' + Ext.String.capitalize(id);
      if (this[getterName].generated) {
        this[getterName] = null;
      }
    }
    delete this.registeredComponentReferences[id];
  },
  /**
  	* Get the component(s) corresponding to the specified view-relative selector.
  */

  getViewComponent: function(selector) {
    var matches;

    if (selector != null) {
      matches = Ext.ComponentQuery.query(selector, this.getView());
      if (matches.length === 0) {
        return null;
      } else if (matches.length === 1) {
        return matches[0];
      } else {
        return matches;
      }
    } else {
      return this.getView();
    }
  },
  /**
  	* Add a component selector with the specified listeners for the specified view-relative selector.
  */

  addComponentSelector: function(selector, listeners, live) {
    var componentSelector, existingComponentSelector;

    if (live == null) {
      live = false;
    }
    Deft.Logger.log("Adding component selector for: '" + selector + "'.");
    existingComponentSelector = this.getComponentSelector(selector);
    if (existingComponentSelector != null) {
      Ext.Error.raise({
        msg: "Error adding component selector: an existing component selector was already registered for '" + selector + "'."
      });
    }
    componentSelector = Ext.create('Deft.mvc.ComponentSelector', {
      view: this.getView(),
      selector: selector,
      listeners: listeners,
      scope: this,
      live: live
    });
    this.registeredComponentSelectors[selector] = componentSelector;
  },
  /**
  	* Remove a component selector with the specified listeners for the specified view-relative selector.
  */

  removeComponentSelector: function(selector) {
    var existingComponentSelector;

    Deft.Logger.log("Removing component selector for '" + selector + "'.");
    existingComponentSelector = this.getComponentSelector(selector);
    if (existingComponentSelector == null) {
      Ext.Error.raise({
        msg: "Error removing component selector: no component selector registered for '" + selector + "'."
      });
    }
    existingComponentSelector.destroy();
    delete this.registeredComponentSelectors[selector];
  },
  /**
  	* Get the component selectorcorresponding to the specified view-relative selector.
  */

  getComponentSelector: function(selector) {
    return this.registeredComponentSelectors[selector];
  },
  /**
  	* @protected
  */

  createObservers: function() {
    var events, target, _ref;

    this.registeredObservers = {};
    _ref = this.observe;
    for (target in _ref) {
      events = _ref[target];
      this.addObserver(target, events);
    }
  },
  addObserver: function(target, events) {
    var observer;

    observer = Ext.create('Deft.mvc.Observer', {
      host: this,
      target: target,
      events: events
    });
    return this.registeredObservers[target] = observer;
  },
  /**
  	* @protected
  */

  removeObservers: function() {
    var observer, target, _ref;

    _ref = this.registeredObservers;
    for (target in _ref) {
      observer = _ref[target];
      observer.destroy();
      delete this.registeredObservers[target];
    }
  }
}, function() {
  /**
  	* Preprocessor to handle merging of 'observe' objects on parent and child classes.
  */
  return Deft.Class.registerPreprocessor('observe', function(Class, data, hooks, callback) {
    Deft.Class.hookOnClassExtended(data, function(Class, data, hooks) {
      var _ref;

      if (Class.superclass && ((_ref = Class.superclass) != null ? _ref.observe : void 0) && Deft.Class.extendsClass('Deft.mvc.ViewController', Class)) {
        data.observe = Deft.mvc.Observer.mergeObserve(Class.superclass.observe, data.observe);
      }
    });
  }, 'before', 'extend');
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* A lightweight Application template class for use with Ext JS.
*/
Ext.define('Deft.mvc.Application', {
  alternateClassName: ['Deft.Application'],
  /**
  	* Indicates whether this Application instance has been initialized.
  */

  initialized: false,
  /**
  	* @param {Object} [config] Configuration object.
  */

  constructor: function(config) {
    if (config == null) {
      config = {};
    }
    this.initConfig(config);
    Ext.onReady(function() {
      this.init();
      this.initialized = true;
    }, this);
    return this;
  },
  /**
  	* Initialize the Application
  */

  init: function() {}
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* A mixin that creates and attaches the specified view controller(s) to the target view. Used in conjunction with Deft.mvc.ViewController.
* @deprecated 0.8 Deft.mixin.Controllable has been deprecated and can now be omitted - simply use the \'controller\' class annotation on its own.
*/
Ext.define('Deft.mixin.Controllable', {
  requires: ['Ext.Component', 'Deft.core.Class', 'Deft.log.Logger'],
  /**
  	@private
  */

  onClassMixedIn: function(targetClass) {
    Deft.Logger.deprecate('Deft.mixin.Controllable has been deprecated and can now be omitted - simply use the \'controller\' class annotation on its own.');
  }
}, function() {
  var createControllerInterceptor;

  if (Ext.getVersion('extjs') && Ext.getVersion('core').isLessThan('4.1.0')) {
    createControllerInterceptor = function() {
      return function(config) {
        var controller, error;

        if (config == null) {
          config = {};
        }
        if (this instanceof Ext.ClassManager.get('Ext.Component') && !this.$controlled) {
          try {
            controller = Ext.create(this.controller, config.controllerConfig || this.controllerConfig || {});
          } catch (_error) {
            error = _error;
            Deft.Logger.warn("Error initializing view controller: an error occurred while creating an instance of the specified controller: '" + this.controller + "'.");
            throw error;
          }
          if (this.getController === void 0) {
            this.getController = function() {
              return controller;
            };
          }
          this.$controlled = true;
          this.callOverridden(arguments);
          controller.controlView(this);
          return this;
        }
        return this.callOverridden(arguments);
      };
    };
  } else {
    createControllerInterceptor = function() {
      return function(config) {
        var controller, error;

        if (config == null) {
          config = {};
        }
        if (this instanceof Ext.ClassManager.get('Ext.Component') && !this.$controlled) {
          try {
            controller = Ext.create(this.controller, config.controllerConfig || this.controllerConfig || {});
          } catch (_error) {
            error = _error;
            Deft.Logger.warn("Error initializing view controller: an error occurred while creating an instance of the specified controller: '" + this.controller + "'.");
            throw error;
          }
          if (this.getController === void 0) {
            this.getController = function() {
              return controller;
            };
          }
          this.$controlled = true;
          this.callParent(arguments);
          controller.controlView(this);
          return this;
        }
        return this.callParent(arguments);
      };
    };
  }
  Deft.Class.registerPreprocessor('controller', function(Class, data, hooks, callback) {
    var self;

    Deft.Class.hookOnClassCreated(hooks, function(Class) {
      Class.override({
        constructor: createControllerInterceptor()
      });
    });
    Deft.Class.hookOnClassExtended(data, function(Class, data, hooks) {
      Deft.Class.hookOnClassCreated(hooks, function(Class) {
        Class.override({
          constructor: createControllerInterceptor()
        });
      });
    });
    self = this;
    Ext.require([data.controller], function() {
      if (callback != null) {
        callback.call(self, Class, data, hooks);
      }
    });
    return false;
  }, 'before', 'extend');
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/*
Resolvers are used internally by Deferreds and Promises to capture and notify
callbacks, process callback return values and propagate resolution or rejection
to chained Resolvers.

Developers never directly interact with a Resolver.

A Resolver captures a pair of optional onResolved and onRejected callbacks and 
has an associated Promise. That Promise delegates its then() calls to the 
Resolver's then() method, which creates a new Resolver and schedules its 
delayed addition as a chained Resolver.

Each Deferred has an associated Resolver. A Deferred delegates resolve() and 
reject() calls to that Resolver's resolve() and reject() methods. The Resolver 
processes the resolution value and rejection reason, and propagates the 
processed resolution value or rejection reason to any chained Resolvers it may 
have created in response to then() calls. Once a chained Resolver has been 
notified, it is cleared out of the set of chained Resolvers and will not be 
notified again.
@private
*/
Ext.define('Deft.promise.Resolver', {
  alternateClassName: ['Deft.Resolver'],
  requires: ['Deft.util.Function'],
  constructor: function(onResolved, onRejected, onProgress) {
    var complete, completeRejected, completeResolved, completed, completionAction, completionValue, nextTick, pendingResolvers, process, processed, propagate, schedule;

    this.promise = Ext.create('Deft.promise.Promise', this);
    pendingResolvers = [];
    processed = false;
    completed = false;
    completionAction = null;
    completionValue = null;
    if (!Ext.isFunction(onRejected)) {
      onRejected = function(error) {
        throw error;
      };
    }
    nextTick = Deft.util.Function.nextTick;
    propagate = function() {
      var pendingResolver, _i, _len;

      for (_i = 0, _len = pendingResolvers.length; _i < _len; _i++) {
        pendingResolver = pendingResolvers[_i];
        pendingResolver[completionAction](completionValue);
      }
      pendingResolvers = [];
    };
    schedule = function(pendingResolver) {
      pendingResolvers.push(pendingResolver);
      if (completed) {
        propagate();
      }
    };
    complete = function(action, value) {
      onResolved = onRejected = onProgress = null;
      completionAction = action;
      completionValue = value;
      completed = true;
      propagate();
    };
    completeResolved = function(value) {
      complete('resolve', value);
    };
    completeRejected = function(reason) {
      complete('reject', reason);
    };
    process = function(callback, value) {
      var error;

      processed = true;
      try {
        if (Ext.isFunction(callback)) {
          value = callback(value);
        }
        if (value && Ext.isFunction(value.then)) {
          value.then(completeResolved, completeRejected);
        } else {
          completeResolved(value);
        }
      } catch (_error) {
        error = _error;
        completeRejected(error);
      }
    };
    this.resolve = function(value) {
      if (!processed) {
        process(onResolved, value);
      }
    };
    this.reject = function(reason) {
      if (!processed) {
        process(onRejected, reason);
      }
    };
    this.update = function(progress) {
      var pendingResolver, _i, _len;

      if (!completed) {
        if (Ext.isFunction(onProgress)) {
          progress = onProgress(progress);
        }
        for (_i = 0, _len = pendingResolvers.length; _i < _len; _i++) {
          pendingResolver = pendingResolvers[_i];
          pendingResolver.update(progress);
        }
      }
    };
    this.then = function(onResolved, onRejected, onProgress) {
      var pendingResolver;

      if (Ext.isFunction(onResolved) || Ext.isFunction(onRejected) || Ext.isFunction(onProgress)) {
        pendingResolver = Ext.create('Deft.promise.Resolver', onResolved, onRejected, onProgress);
        nextTick(function() {
          return schedule(pendingResolver);
        });
        return pendingResolver.promise;
      }
      return this.promise;
    };
    return this;
  }
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).

Promise.when(), all(), any(), some(), map(), reduce(), delay() and timeout()
methods adapted from: [when.js](https://github.com/cujojs/when)
Copyright (c) B Cavalier & J Hann
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/*
Promises represent a future value; i.e., a value that may not yet be available.

A Promise's then() method is used to specify onFulfilled and onRejected 
callbacks that will be notified when the future value becomes available. Those 
callbacks can subsequently transform the value that was resolved or the reason 
that was rejected. Each call to then() returns a new Promise of that 
transformed value; i.e., a Promise that is resolved with the callback return 
value or rejected with any error thrown by the callback.
*/
Ext.define('Deft.promise.Promise', {
  alternateClassName: ['Deft.Promise'],
  requires: ['Deft.promise.Resolver'],
  statics: {
    /**
    		* Returns a new {@link Deft.promise.Promise} that:
    		* - resolves immediately for the specified value, or
    		* - resolves or rejects when the specified {@link Deft.promise.Promise} is
    		* resolved or rejected.
    */

    when: function(promiseOrValue) {
      var deferred;

      deferred = Ext.create('Deft.promise.Deferred');
      deferred.resolve(promiseOrValue);
      return deferred.promise;
    },
    /**
    		* Determines whether the specified value is a Promise (including third-party
    		* untrusted Promises), based on the Promises/A specification feature test.
    */

    isPromise: function(value) {
      return (value && Ext.isFunction(value.then)) === true;
    },
    /**
    		* Returns a new {@link Deft.promise.Promise} that will only resolve
    		* once all the specified `promisesOrValues` have resolved.
    		* 
    		* The resolution value will be an Array containing the resolution
    		* value of each of the `promisesOrValues`.
    */

    all: function(promisesOrValues) {
      if (!(Ext.isArray(promisesOrValues) || Deft.Promise.isPromise(promisesOrValues))) {
        throw new Error('Invalid parameter: expected an Array or Promise of an Array.');
      }
      return Deft.Promise.map(promisesOrValues, function(x) {
        return x;
      });
    },
    /**
    		* Initiates a competitive race, returning a new {@link Deft.promise.Promise}
    		* that will resolve when any one of the specified `promisesOrValues`
    		* have resolved, or will reject when all `promisesOrValues` have
    		* rejected or cancelled.
    		* 
    		* The resolution value will the first value of `promisesOrValues` to resolve.
    */

    any: function(promisesOrValues) {
      if (!(Ext.isArray(promisesOrValues) || Deft.Promise.isPromise(promisesOrValues))) {
        throw new Error('Invalid parameter: expected an Array or Promise of an Array.');
      }
      return Deft.Promise.some(promisesOrValues, 1).then(function(array) {
        return array[0];
      }, function(error) {
        if (error.message === 'Too few Promises were resolved.') {
          throw new Error('No Promises were resolved.');
        } else {
          throw error;
        }
      });
    },
    /**
    		* Initiates a competitive race, returning a new {@link Deft.promise.Promise}
    		* that will resolve when `howMany` of the specified `promisesOrValues`
    		* have resolved, or will reject when it becomes impossible for
    		* `howMany` to resolve.
    		* 
    		* The resolution value will be an Array of the first `howMany` values
    		* of `promisesOrValues` to resolve.
    */

    some: function(promisesOrValues, howMany) {
      if (!(Ext.isArray(promisesOrValues) || Deft.Promise.isPromise(promisesOrValues))) {
        throw new Error('Invalid parameter: expected an Array or Promise of an Array.');
      }
      if (!Ext.isNumeric(howMany) || howMany <= 0) {
        throw new Error('Invalid parameter: expected a positive integer.');
      }
      return Deft.Promise.when(promisesOrValues).then(function(promisesOrValues) {
        var complete, deferred, index, onReject, onResolve, promiseOrValue, rejecter, remainingToReject, remainingToResolve, resolver, values, _i, _len;

        values = [];
        remainingToResolve = howMany;
        remainingToReject = (promisesOrValues.length - remainingToResolve) + 1;
        deferred = Ext.create('Deft.promise.Deferred');
        if (promisesOrValues.length < howMany) {
          deferred.reject(new Error('Too few Promises were resolved.'));
        } else {
          resolver = function(value) {
            values.push(value);
            remainingToResolve--;
            if (remainingToResolve === 0) {
              complete();
              deferred.resolve(values);
            }
            return value;
          };
          rejecter = function(error) {
            remainingToReject--;
            if (remainingToReject === 0) {
              complete();
              deferred.reject(new Error('Too few Promises were resolved.'));
            }
            return error;
          };
          complete = function() {
            return resolver = rejecter = Ext.emptyFn;
          };
          onResolve = function(value) {
            return resolver(value);
          };
          onReject = function(value) {
            return rejecter(value);
          };
          for (index = _i = 0, _len = promisesOrValues.length; _i < _len; index = ++_i) {
            promiseOrValue = promisesOrValues[index];
            if (index in promisesOrValues) {
              Deft.Promise.when(promiseOrValue).then(onResolve, onReject);
            }
          }
        }
        return deferred.promise;
      });
    },
    /**
    		* Returns a new {@link Deft.promise.Promise} that will automatically
    		* resolve with the specified Promise or value after the specified
    		* delay (in milliseconds).
    */

    delay: function(promiseOrValue, milliseconds) {
      var deferred;

      if (arguments.length === 1) {
        milliseconds = promiseOrValue;
        promiseOrValue = void 0;
      }
      milliseconds = Math.max(milliseconds, 0);
      deferred = Ext.create('Deft.promise.Deferred');
      setTimeout(function() {
        deferred.resolve(promiseOrValue);
      }, milliseconds);
      return deferred.promise;
    },
    /**
    		* Returns a new {@link Deft.promise.Promise} that will automatically
    		* reject after the specified timeout (in milliseconds) if the specified 
    		* promise has not resolved or rejected.
    */

    timeout: function(promiseOrValue, milliseconds) {
      var cancelTimeout, deferred, timeoutId;

      deferred = Ext.create('Deft.promise.Deferred');
      timeoutId = setTimeout(function() {
        if (timeoutId) {
          deferred.reject(new Error('Promise timed out.'));
        }
      }, milliseconds);
      cancelTimeout = function() {
        clearTimeout(timeoutId);
        return timeoutId = null;
      };
      Deft.Promise.when(promiseOrValue).then(function(value) {
        cancelTimeout();
        deferred.resolve(value);
      }, function(reason) {
        cancelTimeout();
        deferred.reject(reason);
      });
      return deferred.promise;
    },
    /**
    		* Returns a new function that wraps the specified function and caches
    		* the results for previously processed inputs.
    		* 
    		* Similar to `Deft.util.Function::memoize()`, except it allows for
    		* parameters that are {@link Deft.promise.Promise}s and/or values.
    */

    memoize: function(fn, scope, hashFn) {
      var memoizedFn;

      memoizedFn = Deft.util.Function.memoize(fn, scope, hashFn);
      return function() {
        return Deft.Promise.all(Ext.Array.toArray(arguments)).then(function(values) {
          return memoizedFn.apply(scope, values);
        });
      };
    },
    /**
    		* Traditional map function, similar to `Array.prototype.map()`, that
    		* allows input to contain promises and/or values.
    		* 
    		* The specified map function may return either a value or a promise.
    */

    map: function(promisesOrValues, mapFn) {
      if (!(Ext.isArray(promisesOrValues) || Deft.Promise.isPromise(promisesOrValues))) {
        throw new Error('Invalid parameter: expected an Array or Promise of an Array.');
      }
      if (!Ext.isFunction(mapFn)) {
        throw new Error('Invalid parameter: expected a function.');
      }
      return Deft.Promise.when(promisesOrValues).then(function(promisesOrValues) {
        var deferred, index, promiseOrValue, remainingToResolve, resolve, results, _i, _len;

        remainingToResolve = promisesOrValues.length;
        results = new Array(promisesOrValues.length);
        deferred = Ext.create('Deft.promise.Deferred');
        if (!remainingToResolve) {
          deferred.resolve(results);
        } else {
          resolve = function(item, index) {
            return Deft.Promise.when(item).then(function(value) {
              return mapFn(value, index, results);
            }).then(function(value) {
              results[index] = value;
              if (!--remainingToResolve) {
                deferred.resolve(results);
              }
              return value;
            }, deferred.reject);
          };
          for (index = _i = 0, _len = promisesOrValues.length; _i < _len; index = ++_i) {
            promiseOrValue = promisesOrValues[index];
            if (index in promisesOrValues) {
              resolve(promisesOrValues[index], index);
            } else {
              remainingToResolve--;
            }
          }
        }
        return deferred.promise;
      });
    },
    /**
    		* Traditional reduce function, similar to `Array.reduce()`, that allows
    		* input to contain promises and/or values.
    */

    reduce: function(promisesOrValues, reduceFn, initialValue) {
      var initialValueSpecified;

      if (!(Ext.isArray(promisesOrValues) || Deft.Promise.isPromise(promisesOrValues))) {
        throw new Error('Invalid parameter: expected an Array or Promise of an Array.');
      }
      if (!Ext.isFunction(reduceFn)) {
        throw new Error('Invalid parameter: expected a function.');
      }
      initialValueSpecified = arguments.length === 3;
      return Deft.Promise.when(promisesOrValues).then(function(promisesOrValues) {
        var reduceArguments;

        reduceArguments = [
          function(previousValueOrPromise, currentValueOrPromise, currentIndex) {
            return Deft.Promise.when(previousValueOrPromise).then(function(previousValue) {
              return Deft.Promise.when(currentValueOrPromise).then(function(currentValue) {
                return reduceFn(previousValue, currentValue, currentIndex, promisesOrValues);
              });
            });
          }
        ];
        if (initialValueSpecified) {
          reduceArguments.push(initialValue);
        }
        return Deft.Promise.reduceArray.apply(promisesOrValues, reduceArguments);
      });
    },
    /**
    		* Fallback implementation when Array.reduce is not available.
    		* @private
    */

    reduceArray: function(reduceFn, initialValue) {
      var args, array, index, length, reduced;

      index = 0;
      array = Object(this);
      length = array.length >>> 0;
      args = arguments;
      if (args.length <= 1) {
        while (true) {
          if (index in array) {
            reduced = array[index++];
            break;
          }
          if (++index >= length) {
            throw new TypeError('Reduce of empty array with no initial value');
          }
        }
      } else {
        reduced = args[1];
      }
      while (index < length) {
        if (index in array) {
          reduced = reduceFn(reduced, array[index], index, array);
        }
        index++;
      }
      return reduced;
    }
  },
  constructor: function(resolver) {
    var rethrowError;

    rethrowError = function(error) {
      Deft.util.Function.nextTick(function() {
        throw error;
      });
    };
    this.then = function(onFulfilled, onRejected, onProgress, scope) {
      var _ref;

      if (arguments.length === 1 && Ext.isObject(arguments[0])) {
        _ref = arguments[0], onFulfilled = _ref.success, onRejected = _ref.failure, onProgress = _ref.progress, scope = _ref.scope;
      }
      if (scope != null) {
        if (Ext.isFunction(onFulfilled)) {
          onFulfilled = Ext.Function.bind(onFulfilled, scope);
        }
        if (Ext.isFunction(onRejected)) {
          onRejected = Ext.Function.bind(onRejected, scope);
        }
        if (Ext.isFunction(onProgress)) {
          onProgress = Ext.Function.bind(onProgress, scope);
        }
      }
      return resolver.then(onFulfilled, onRejected, onProgress);
    };
    this.otherwise = function(onRejected, scope) {
      var _ref;

      if (arguments.length === 1 && Ext.isObject(arguments[0])) {
        _ref = arguments[0], onRejected = _ref.fn, scope = _ref.scope;
      }
      if (scope != null) {
        onRejected = Ext.Function.bind(onRejected, scope);
      }
      return resolver.then(null, onRejected);
    };
    this.always = function(onCompleted, scope) {
      var _ref;

      if (arguments.length === 1 && Ext.isObject(arguments[0])) {
        _ref = arguments[0], onCompleted = _ref.fn, scope = _ref.scope;
      }
      if (scope != null) {
        onCompleted = Ext.Function.bind(onCompleted, scope);
      }
      return resolver.then(function(value) {
        var error;

        try {
          onCompleted();
        } catch (_error) {
          error = _error;
          rethrowError(error);
        }
        return value;
      }, function(reason) {
        var error;

        try {
          onCompleted();
        } catch (_error) {
          error = _error;
          rethrowError(error);
        }
        throw reason;
      });
    };
    this.done = function() {
      resolver.then(null, rethrowError);
    };
    this.cancel = function(reason) {
      if (reason == null) {
        reason = null;
      }
      resolver.reject(new CancellationError(reason));
    };
    this.log = function(name) {
      if (name == null) {
        name = '';
      }
      return resolver.then(function(value) {
        Deft.Logger.log("" + (name || 'Promise') + " resolved with value: " + value);
        return value;
      }, function(reason) {
        Deft.Logger.log("" + (name || 'Promise') + " rejected with reason: " + reason);
        throw reason;
      });
    };
    return this;
  },
  /**
  	* Attaches callbacks that will be notified when this 
  	* {@link Deft.promise.Promise}'s future value becomes available. Those
  	* callbacks can subsequently transform the value that was resolved or
  	* the reason that was rejected.
  	* 
  	* Each call to then() returns a new Promise of that transformed value;
  	* i.e., a Promise that is resolved with the callback return value or 
  	* rejected with any error thrown by the callback.
  	*
  	* @param {Function} fn Callback function to be called when resolved.
  	* @param {Function} fn Callback function to be called when rejected.
  	* @param {Function} fn Callback function to be called with progress updates.
  	* @param {Object} scope Optional scope for the callback(s).
  	* @param {Deft.promise.Promise} A Promise of the transformed future value.
  */

  then: Ext.emptyFn,
  /**
  	* Attaches a callback that will be called if this 
  	* {@link Deft.promise.Promise} is rejected. The callbacks can 
  	* subsequently transform the reason that was rejected.
  	* 
  	* Each call to otherwise() returns a new Promise of that transformed value;
  	* i.e., a Promise that is resolved with the callback return value or 
  	* rejected with any error thrown by the callback.
  	*
  	* @param {Function} fn Callback function to be called when rejected.
  	* @param {Object} scope Optional scope for the callback.
  	* @param {Deft.promise.Promise} A Promise of the transformed future value.
  */

  otherwise: Ext.emptyFn,
  /**
  	* Attaches a callback to this {Deft.promise.Promise} that will be 
  	* called when it resolves or rejects. Similar to "finally" in 
  	* "try..catch..finally".
  	*
  	* @param {Function} fn Callback function.
  	* @param {Object} scope Optional scope for the callback.
  	* @return {Deft.promise.Promise} A new "pass-through" Promise that 
  	* resolves with the original value or rejects with the original reason.
  */

  always: Ext.emptyFn,
  /**
  	* Terminates a {Deft.promise.Promise} chain, ensuring that unhandled
  	* rejections will be thrown as Errors.
  */

  done: Ext.emptyFn,
  /**
  	* Cancels this {Deft.promise.Promise} if it is still pending, triggering 
  	* a rejection with a CancellationError that will propagate to any Promises
  	* originating from this Promise.
  */

  cancel: Ext.emptyFn,
  /**
  	* Logs the resolution or rejection of this Promise using 
  	* {@link Deft.Logger#log}.
  	*
  	* @param {String} An optional identifier to incorporate into the 
  	* resulting log entry.
  	* @return {Deft.promise.Promise} A new "pass-through" Promise that 
  	* resolves with the original value or rejects with the original reason.
  */

  log: Ext.emptyFn
}, function() {
  var target;

  if (Array.prototype.reduce != null) {
    this.reduceArray = Array.prototype.reduce;
  }
  target = typeof exports !== "undefined" && exports !== null ? exports : window;
  target.CancellationError = function(reason) {
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, CancellationError);
    }
    this.name = 'Canceled';
    this.message = reason;
  };
  target.CancellationError.prototype = new Error();
  target.CancellationError.constructor = target.CancellationError;
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/*
A Deferred is typically used within the body of a function that performs an 
asynchronous operation. When that operation succeeds, the Deferred should be 
resolved; if that operation fails, the Deferred should be rejected.

Once a Deferred has been resolved or rejected, it is considered to be complete 
and subsequent calls to resolve() or reject() are ignored.

Deferreds are the mechanism used to create new Promises. A Deferred has a 
single associated Promise that can be safely returned to external consumers 
to ensure they do not interfere with the resolution or rejection of the deferred 
operation.
*/
Ext.define('Deft.promise.Deferred', {
  alternateClassName: ['Deft.Deferred'],
  requires: ['Deft.promise.Resolver'],
  statics: {
    /**
    		* Returns a new {@link Deft.promise.Promise} that resolves immediately with
    		* the specified value.
    		* @param The resolved future value.
    */

    resolve: function(value) {
      var deferred;

      deferred = Ext.create('Deft.promise.Deferred');
      deferred.resolve(value);
      return deferred.promise;
    },
    /**
    		* Returns a new {@link Deft.promise.Promise} that rejects immediately with
    		* the specified reason.
    		* @param {Error} The rejection reason.
    */

    reject: function(reason) {
      var deferred;

      deferred = Ext.create('Deft.promise.Deferred');
      deferred.reject(reason);
      return deferred.promise;
    }
  },
  /**
  	* The {@link Deft.promise.Promise} of a future value associated with this
  	* {@link Deft.promise.Deferred}.
  */

  promise: null,
  constructor: function() {
    var resolver;

    resolver = Ext.create('Deft.promise.Resolver');
    this.promise = resolver.promise;
    this.resolve = function(value) {
      return resolver.resolve(value);
    };
    this.reject = function(reason) {
      return resolver.reject(reason);
    };
    this.update = function(progress) {
      return resolver.update(progress);
    };
    return this;
  },
  /**
  	* Resolves the {@link Deft.promise.Promise} associated with this
  	* {@link Deft.promise.Deferred} with the specified value.
  	*
  	* @param The resolved future value.
  */

  resolve: Ext.emptyFn,
  /**
  	* Rejects this {@link Deft.promise.Deferred} with the specified reason.
  	*
  	* @param {Error} The rejection reason.
  */

  reject: Ext.emptyFn,
  /**
  	* Updates progress for this {@link Deft.promise.Deferred} if it is 
  	* still pending, notifying callbacks with the specified progress value 
  	* that will propagate to any Promises originating from this Promise.
  	*
  	* @param {Error} The progress value.
  */

  update: Ext.emptyFn,
  /**
  	* Returns the {@link Deft.promise.Promise} of a future value associated 
  	* with this {@link Deft.promise.Deferred}.
  	*
  	* @return {Deft.promise.Promise} Promise of the associated future value.
  */

  getPromise: function() {
    return this.promise;
  }
});
/*
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).

sequence(), parallel(), pipeline() methods adapted from:
[when.js](https://github.com/cujojs/when)
Copyright (c) B Cavalier & J Hann
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
*/

/**
* Utility class with static methods to create chains of {@link Deft.promise.Promise}s.
*/

var __slice = [].slice;

Ext.define('Deft.promise.Chain', {
  alternateClassName: ['Deft.Chain'],
  requires: ['Deft.promise.Promise'],
  statics: {
    /**
    		* Execute an Array (or {@link Deft.promise.Promise} of an Array) of functions sequentially.
    		* The specified functions may optionally return their results as {@link Deft.promise.Promise}s.
    		* Returns a {@link Deft.promise.Promise} of an Array of results for each function call (in the same order).
    */

    sequence: function() {
      var args, fns, scope;

      fns = arguments[0], scope = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      if (scope == null) {
        scope = null;
      }
      return Deft.Promise.reduce(fns, function(results, fn) {
        if (!Ext.isFunction(fn)) {
          throw new Error('Invalid parameter: expected a function.');
        }
        return Deft.Promise.when(fn.apply(scope, args)).then(function(result) {
          results.push(result);
          return results;
        });
      }, []);
    },
    /**
    		* Execute an Array (or {@link Deft.promise.Promise} of an Array) of functions in parallel.
    		* The specified functions may optionally return their results as {@link Deft.promise.Promise}s.
    		* Returns a {@link Deft.promise.Promise} of an Array of results for each function call (in the same order).
    */

    parallel: function() {
      var args, fns, scope;

      fns = arguments[0], scope = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
      if (scope == null) {
        scope = null;
      }
      return Deft.Promise.map(fns, function(fn) {
        if (!Ext.isFunction(fn)) {
          throw new Error('Invalid parameter: expected a function.');
        }
        return fn.apply(scope, args);
      });
    },
    /**
    		* Execute an Array (or {@link Deft.promise.Promise} of an Array) of functions as a pipeline, where each function's result is passed to the subsequent function as input.
    		* The specified functions may optionally return their results as {@link Deft.promise.Promise}s.
    		* Returns a {@link Deft.promise.Promise} of the result value for the final function in the pipeline.
    */

    pipeline: function(fns, initialValue, scope) {
      if (scope == null) {
        scope = null;
      }
      return Deft.Promise.reduce(fns, function(value, fn) {
        if (!Ext.isFunction(fn)) {
          throw new Error('Invalid parameter: expected a function.');
        }
        return fn.call(scope, value);
      }, initialValue);
    }
  }
});
