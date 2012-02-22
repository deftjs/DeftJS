/*
 * DeftJS v0.1.0
 * Copyright (c) 2012 DeftJS Framework Contributors
 * Open source under the MIT License.
 */

/**
A lightweight IoC container for dependency injection.

Used in conjunction with {@link Deft.mixin.Injectable}.
*/
Ext.define('Deft.ioc.Injector', {
  alternateClassName: ['Deft.Injector'],
  requires: ['Deft.ioc.DependencyProvider'],
  singleton: true,
  constructor: function() {
    this.providers = {};
    return this;
  },
  /**
  	Configure the Injector.
  */
  configure: function(configuration) {
    Ext.log('Configuring injector.');
    Ext.Object.each(configuration, function(identifier, config) {
      var provider;
      Ext.log("Configuring dependency provider for '" + identifier + "'.");
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
    }, this);
    Ext.Object.each(this.providers, function(identifier, provider) {
      if (provider.getEager()) {
        Ext.log("Eagerly creating '" + (provider.getIdentifier()) + "'.");
        provider.resolve();
      }
    }, this);
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
  resolve: function(identifier, targetInstance) {
    var provider;
    provider = this.providers[identifier];
    if (provider != null) {
      return provider.resolve(targetInstance);
    } else {
      return Ext.Error.raise("Error while resolving value to inject: no dependency provider found for '" + identifier + "'.");
    }
  },
  /**
  	Inject dependencies (by their identifiers) into the target object instance.
  */
  inject: function(identifiers, targetInstance) {
    var config;
    config = {};
    Ext.Object.each(identifiers, function(key, value) {
      var identifier, resolvedValue, targetProperty;
      targetProperty = Ext.isArray(identifiers) ? value : key;
      identifier = value;
      resolvedValue = this.resolve(identifier, targetInstance);
      if (targetInstance.config.hasOwnProperty(targetProperty)) {
        Ext.log("Injecting '" + identifier + "' into 'config." + targetProperty + "'.");
        return config[targetProperty] = resolvedValue;
      } else {
        Ext.log("Injecting '" + identifier + "' into '" + targetProperty + "'.");
        return targetInstance[targetProperty] = resolvedValue;
      }
    }, this);
    targetInstance.config = Ext.Object.merge({}, targetInstance.config || {}, config);
    return targetInstance;
  }
});
