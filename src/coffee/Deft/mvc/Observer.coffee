###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* Used by Deft.mvc.ViewController to handle events fired from injected objects.
###
Ext.define( 'Deft.mvc.Observer',
	requires: [
    'Deft.core.Class'
		'Ext.util.Observable'
	]

	statics:

		###*
		* Merges child and parent observers into a single object. This differs from a normal object merge because
		* a given observer target and event can potentially have multiple handlers declared in different parent or
		* child classes. It transforms an event handler value into an array of values, and merges the arrays of handlers
		* from child to parent. This maintains the handlers even if both parent and child classes have handlers for the
		* same target and event.
		###
		mergeObserve: ( originalParentObserve, originalChildObserve ) ->

			# Make sure we aren't modifying the original objects, particularly for the parent object, since it is a CLASS-LEVEL object.
			if not Ext.isObject( originalParentObserve )
				parentObserve = {}
			else
				parentObserve = Ext.clone( originalParentObserve )

			if not Ext.isObject( originalChildObserve )
				childObserve = {}
			else
				childObserve = Ext.clone( originalChildObserve )

			# Convert any observers that use an array of configuration objects into object keys for event name, and array of configuration objects
			for parentTarget, parentEvents of parentObserve
				if( Ext.isArray( parentEvents ) )
					newParentEvents = {}
					for thisParentEvent in parentEvents
						# Object with only one key means this is just an event name/handler pair, not a config object.
						if( Ext.Object.getSize( thisParentEvent ) is 1 )
							Ext.apply( newParentEvents, thisParentEvent )
						else
							handlerConfig = {}
							handlerConfig.fn = thisParentEvent.fn if thisParentEvent?.fn
							handlerConfig.scope = thisParentEvent.scope if thisParentEvent?.scope
							newParentEvents[ thisParentEvent.event ] = [ handlerConfig ]

					parentObserve[ parentTarget ] = newParentEvents

			for childTarget, childEvents of childObserve
				if( Ext.isArray( childEvents ) )
					newChildEvents = {}
					for thisChildEvent in childEvents
						# Object with only one key means this is just an event name/handler pair, not a config object.
						if( Ext.Object.getSize( thisChildEvent ) is 1 )
							Ext.apply( newChildEvents, thisChildEvent )
						else
							handlerConfig = {}
							handlerConfig.fn = thisChildEvent.fn if thisChildEvent?.fn
							handlerConfig.scope = thisChildEvent.scope if thisChildEvent?.scope
							newChildEvents[ thisChildEvent.event ] = [ handlerConfig ]

					childObserve[ childTarget ] = newChildEvents

			# Ensure that all child handler elements are arrays, then copy any targets not present in parent into parent and remove from child.
			for childTarget, childEvents of childObserve
				for childEvent, childHandler of childEvents
					if Ext.isString( childHandler )
						childObserve[ childTarget ][ childEvent ] = childHandler.replace( ' ', '' ).split( ',' )
					if not parentObserve?[ childTarget ]
						parentObserve[ childTarget ] = {}
					if not parentObserve?[ childTarget ]?[ childEvent ]
						parentObserve[ childTarget ][ childEvent ] = childObserve[ childTarget ][ childEvent ]
						delete childObserve[ childTarget ][ childEvent ]

			# Ensure that all parent handler elements are arrays, then prepend duplicate handler arrays from child into parent.
			for parentTarget, parentEvents of parentObserve
				for parentEvent, parentHandler of parentEvents
					if Ext.isString( parentHandler )
						parentObserve[ parentTarget ][ parentEvent ] = parentHandler.split( ',' )

					if childObserve?[ parentTarget ]?[ parentEvent ]
						childHandlerArray = childObserve[ parentTarget ][ parentEvent ]
						parentHandlerArray = parentObserve[ parentTarget ][ parentEvent ]
						parentObserve[ parentTarget ][ parentEvent ] = Ext.Array.unique( Ext.Array.insert( parentHandlerArray, 0, childHandlerArray ) )

			return parentObserve

	###*
	* Expects a config object with properties for host, target, and events.
	###
	constructor: ( config ) ->
		@listeners = []

		host = config?.host
		target = config?.target
		events = config?.events

		if host and target and ( @isPropertyChain( target ) or @isTargetObservable( host, target ) )

			for eventName, handlerArray of events

				# If a ViewController has no subclasses, the onExtended() preprocessor won't fire, so transform any string handlers into arrays.
				handlerArray = handlerArray.replace( ' ', '' ).split( ',' ) if Ext.isString( handlerArray )
				for handler in handlerArray

					# Default scope is the object hosting the Observer.
					scope = host

					# If the handler is a configuration object, parse it and use those values to create the Observer.
					if( Ext.isObject( handler ) )
						eventName = handler.event if handler?.event
						handler = handler.fn if handler?.fn
						scope = handler.scope if handler?.scope

					references = @locateReferences( host, target, handler )
					if references
						references.target.on( eventName, references.handler, host )
						@listeners.push( { targetName: target, target: references.target, event: eventName, handler: references.handler, scope: scope } )
						Deft.Logger.log( "Created observer on '#{ target }' for event '#{ eventName }'." )
					else
						Deft.Logger.warn( "Could not create observer on '#{ target }' for event '#{ eventName }'." )
		else
			Deft.Logger.warn( "Could not create observers on '#{ target }' because '#{ target }' is not an Ext.util.Observable" )

		return @

	###*
	* Returns true if the passed host has a target that is Observable.
	* Checks for an isObservable=true property, observable mixin, or if the class extends Observable.
	###
	isTargetObservable: ( host, target ) ->
		hostTarget = @locateTarget( host, target )
		return false if not hostTarget?

		if hostTarget.isObservable? or hostTarget.mixins?.observable?
			return true
		else
			hostTargetClass = Ext.ClassManager.getClass( hostTarget )
			return ( Deft.Class.extendsClass( 'Ext.util.Observable', hostTargetClass ) or Deft.Class.extendsClass( 'Ext.mixin.Observable', hostTargetClass ) )

	###*
	* Attempts to locate an observer target given the host object and target property name.
	* Checks for both host[ target ], and host.getTarget().
	###
	locateTarget: ( host, target ) ->
		if Ext.isFunction( host[ 'get' + Ext.String.capitalize( target ) ] )
			result = host[ 'get' + Ext.String.capitalize( target ) ].call( host )
			return result
		else if host?[ target ]?
			result = host[ target ]
			return result
		else
			return null

	###*
	* Returns true if the passed target is a string containing a '.', indicating that it is referencing a nested property.
	###
	isPropertyChain: ( target ) ->
		return Ext.isString( target ) and target.indexOf( '.' ) > -1

	###*
	* Given a host object, target property name, and handler, return object references for the final target and handler function.
	* If necessary, recurse down a property chain to locate the final target object for the event listener.
	###
	locateReferences: ( host, target, handler ) ->
		handlerHost = host

		if @isPropertyChain( target )
			propertyChain = @parsePropertyChain( host, target )
			return null if not propertyChain
			host = propertyChain.host
			target = propertyChain.target

		if Ext.isFunction( handler )
			return { target: @locateTarget( host, target ), handler: handler  }
		else if Ext.isFunction( handlerHost[ handler ] )
			return { target: @locateTarget( host, target ), handler: handlerHost[ handler ]  }
		else
			return null

	###*
	* Given a target property chain and a property host object, recurse down the property chain and return
	* the final host object from the property chain, and the final object that will accept the event listener.
	###
	parsePropertyChain: ( host, target ) ->
		if Ext.isString( target )
			propertyChain = target.split( '.' )
		else if Ext.isArray( target )
			propertyChain = target
		else
			return null

		if propertyChain.length > 1 and @locateTarget( host, propertyChain[0] )?
			return @parsePropertyChain( @locateTarget( host, propertyChain[0] ), propertyChain[1..] )
		else if @isTargetObservable( host, propertyChain[0] )
			return { host: host, target: propertyChain[0] }
		else
			return null

	###*
	* Iterate through the listeners array and remove each event listener.
	###
	destroy: ->
		for listenerData in @listeners
			Deft.Logger.log( "Removing observer on '#{ listenerData.targetName }' for event '#{ listenerData.event }'." )
			listenerData.target.un( listenerData.event, listenerData.handler, listenerData.scope )
		@listeners = []
		return
)
