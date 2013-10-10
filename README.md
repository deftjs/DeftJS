# Deft JS

[![Build Status](https://travis-ci.org/deftjs/DeftJS.png?branch=master)](https://travis-ci.org/deftjs/DeftJS)
[![Stories in Ready](https://badge.waffle.io/deftjs/DeftJS.png?label=Ready)](http://waffle.io/deftjs/DeftJS)

Essential extensions for large-scale web and mobile application development with [Ext JS](http://www.sencha.com/products/extjs/) and [Sencha Touch](http://www.sencha.com/products/touch/).

# About

Deft JS enhances Ext JS and Sencha Touch's APIs with additional building blocks that enable large development teams to rapidly build enterprise scale applications, leveraging best practices and proven patterns discovered by top RIA developers at some of the best consulting firms in the industry.

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

## IoC Container

* Provides class annotation-driven dependency injection.
* Maps dependencies by user-defined identifiers.
* Resolves dependencies by class instance, factory function or value.
* Supports singleton and prototype resolution of class instance and factory function dependencies.
* Offers eager and lazy instantiation of dependencies.
* Injects dependencies into Ext JS class configs and properties before the class constructor is executed.

## MVC with ViewControllers

* Provides class annotation-driven association between a given view and its ViewController.
* Clarifies the role of the controller - i.e. controlling a view and delegating work to injected business services (service classes, Stores, etc.). ([Martin Fowler's description of a Passive View using a controller.](http://martinfowler.com/eaaDev/PassiveScreen.html))
* Supports multiple independent instances of a given view, each with their own ViewController instance.
* Reduces memory usage by automatically creating and destroying view controllers in tandem with their associated views.
* Supports concise configuration for referencing view components and registering event listeners with view controller methods.
* Integrates with the view destruction lifecycle to allow the view controller to potentially cancel removal and destruction.
* Simplifies clean-up by automatically removing view and view component references and event listeners.

## Promises and Deferreds

* Provides an elegant way to represent a ëfuture valueí resulting from an asynchronous operation.
* Offers a consistent, readable API for registering success, failure, cancellation or progress callbacks.
* Allows chaining of transformation and processing of future values.
* Simplifies processing of a set of future values via utility functions including all(), any(), map() and reduce().
* Implements the [Promises/A+ specification](https://github.com/promises-aplus/promises-spec) and passes the [Promises/A+ Compliance Test Suite](https://github.com/promises-aplus/promises-tests).

# Documentation Wiki

Full documentation on the features and usage of Deft JS is available in the [Wiki](https://github.com/deftjs/DeftJS/wiki).

# API Docs

The latest API documentation for Deft JS is available at [http://docs.deftjs.org/deft-js/latest/](http://docs.deftjs.org/deft-js/latest/). If you're interested in API docs for a specific version, you can substitue the version in the URL (e.g. [http://docs.deftjs.org/deft-js/0-8-0/](http://docs.deftjs.org/deft-js/0-8-0/))

# Help

The best place to ask for help is on the [Deft JS Google Group](https://groups.google.com/forum/?fromgroups#!forum/deftjs).

# Version History

* 0.9.0 - Promises and Deferreds rewritten to be Promises/A+ compliant, migrated from Jasmine to Mocha.
* 0.8.0 - Moved from mixins to class preprocessors. Added: Promises API, ViewController Observer feature, Deft.Application class, hundreds of Jasmine tests, improved logging, JSDuck documentation, and numerous other improvements.
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
* [Brian Kotek](https://twitter.com/brian428)
* [Isaac Johnston](https://twitter.com/superstructor)
* [Ryan Campbell](https://twitter.com/bobjim)
* [David Tucker](https://twitter.com/mindmillmedia)

# Acknowledgements

* Inspiration drawn from other IoC frameworks:
	* [Spring](http://www.springsource.org/)
	* [Swiz](http://swizframework.org/)
	* [Robotlegs](http://www.robotlegs.org/)
	* [Swift Suspenders](https://github.com/tschneidereit/SwiftSuspenders)
	* [AngularJS](http://angularjs.org/)
* The Promises/A+ Community
	* [Kris Zyp](https://github.com/kriszyp), who proposed the original [Common JS Promises/A Specification](http://wiki.commonjs.org/wiki/Promises/A) and created [node-promise](https://github.com/kriszyp/node-promise) and [promised-io](https://github.com/kriszyp/promised-io),
	* [Domenic Denicola](https://github.com/domenic) for the [Promises/A+ Specification](https://github.com/promises-aplus/promises-spec) and [Promises/A+ Compliance Test Suite](https://github.com/promises-aplus/promises-tests), [mocha-as-promised](https://github.com/domenic/mocha-as-promised), [chai-as-promised](https://github.com/domenic/chai-as-promised), and for his work with:
	* [Kris Kowal](https://github.com/kriskowal), who created [q](https://github.com/kriskowal/q), a JavaScript promise library that pioneered many of the practices now codified in the [Promises/A+ Specification](https://github.com/promises-aplus/promises-spec),
	* [Brian Cavalier](https://github.com/briancavalier) for his contributions to the [Promises/A+ Specification](https://github.com/promises-aplus/promises-spec) and [Promises/A+ Compliance Test Suite](https://github.com/promises-aplus/promises-tests), the inspiration that [avow.js](https://github.com/briancavalier/avow) provided, and for permitting us to derive some of the utility methods from [when.js](https://github.com/cujojs/when) (with [John Hann](https://github.com/unscriptable)).
* Special thanks to:
	* [Jason Barry](http://dribbble.com/artifactdesign) for creating the Deft JS logo.
	* [Thomas Burleson](http://twitter.com/thomasburleson) for beta-testing and providing feedback on view controllers and promises.
	* [David Tucker](http://www.davidtucker.net/) for reviewing several iterations of the proposed syntax.
	* [Claude Gauthier](mailto:claude_r_gauthier@hotmail.com) for leading the 5-day ['Fast Track to Ext JS'](http://www.sencha.com/training) training where this idea was born.
	* [Tim Marshall](http://twitter.com/timothymarshall) for parting with the twitter account and project name, which he'd previously used for a personal project.
