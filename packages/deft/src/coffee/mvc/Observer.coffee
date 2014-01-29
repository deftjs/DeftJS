###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* @private
* Used by Deft.mvc.ViewController to handle events fired from injected objects.
###
Ext.define( 'Deft.mvc.Observer',
	requires: [
		'Deft.core.Class'
		'Ext.util.Observable'
		'Deft.util.Function'
	]

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

					# Default options is null
					options = null

					# If the handler is a configuration object, parse it and use those values to create the Observer.
					if( Ext.isObject( handler ) )
						options = Ext.clone( handler )
						eventName = @extract( options, "event" ) if options?.event
						handler = @extract( options, "fn" ) if options?.fn
						scope = @extract( options, "scope" ) if options?.scope

					references = @locateReferences( host, target, handler )
					if references
						references.target.on( eventName, references.handler, scope, options )
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
			return ( Deft.Class.extendsClass( hostTargetClass, 'Ext.util.Observable' ) or Deft.Class.extendsClass( hostTargetClass, 'Ext.mixin.Observable' ) )

	###*
	* Attempts to locate an observer target given the host object and target property name.
	* Checks for both host[ target ], and host.getTarget().
	###
	locateTarget: ( host, target ) ->
		if Deft.isFunction( host[ 'get' + Ext.String.capitalize( target ) ] )
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

		if Deft.isFunction( handler )
			return { target: @locateTarget( host, target ), handler: handler  }
		else if Deft.isFunction( handlerHost[ handler ] )
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
	* Retrieves the value for the specified object key and removes the pair
	* from the object.
	###
	extract: ( object, key ) ->
		value = object[key]
		delete object[key]
		return value

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
