###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A mixin that marks a class as an observer of events from Observable objects.
* Classes using the mixin should call the mixed-in method 'createObservers()' to
* trigger creation of the event listeners using the 'observe:' configuration.
* The Deft JS ViewController uses this mixin, adding the Observers at construction
* and removing them on ViewController destruction.
*
* **IMPORTANT NOTE:** If you choose to use this mixin in your own classes, and you intend
* to destroy the instance, you **MUST** call the mixed-in method 'removeObservers()' at
* destruction time! Failure to do this will result in memory leaks, since the event
* listeners will not be cleaned up. There is no standard way for this mixin to be notified
* of pending instance destruction, so the developer must ensure that this is done.
###
Ext.define( 'Deft.mixin.Observer',
	requires: [
		'Deft.log.Logger'
		'Deft.util.DeftMixinUtils'
	]

	###*
	@private
	###
	onClassMixedIn: ( target ) ->

		target.override(
			constructor: Deft.mixin.Observer.createMixinInterceptor()
		)

		target.onExtended( ( clazz, config ) ->
			clazz.override(
				constructor: Deft.mixin.Observer.createMixinInterceptor()
			)

			return true
		)

		return


	###*
	* @protected
	###
	createObservers: ->
		@removeObservers()
		@registeredObservers = {}
		for target, events of @observe
			@addObserver( target, events )

		return


	###*
	* @protected
	###
	addObserver: ( target, events ) ->
		observer = Ext.create( 'Deft.mvc.Observer',
			host: @
			target: target
			events: events
		)

		@registeredObservers[ target ] = observer
		return


	###*
	* @protected
	###
	removeObservers: ->
		for target, observer of @registeredObservers
			observer.destroy()
			delete @registeredObservers[ target ]

		return


	statics:

		MIXIN_COMPLETED_KEY: "$observing"
		PROPERTY_NAME: "observe"


		###*
		* @private
		###
		createMixinInterceptor: ->
			return ( config = {} ) ->

				mixinCompletedKey = Deft.mixin.Observer.MIXIN_COMPLETED_KEY
				propertyName = Deft.mixin.Observer.PROPERTY_NAME

				if not @[ propertyName ]? then @[ propertyName ] = {}

				if( not @[ mixinCompletedKey ] and Ext.Object.getSize( @[ propertyName ] ) > 0 )
					Deft.util.DeftMixinUtils.mergeSuperclassProperty( @, propertyName, Deft.mixin.Observer.propertyMergeHandler )
					Deft.mixin.Observer.afterMixinProcessed( @ )

					# TODO: These calls based on Ext JS version can revert to @callParent() if we end up dropping 4.0.x support...
					@[ Deft.util.DeftMixinUtils.parentConstructorForVersion() ]( arguments )

					return @

				return @[ Deft.util.DeftMixinUtils.parentConstructorForVersion() ]( arguments )


		###*
		* @private
		* Called by DeftMixinUtils.mergeSuperclassProperty(). Allows each mixin to define its own
		* customized subclass/superclass merge logic.
		*
		* Merges child and parent observers into a single object. This differs from a normal object merge because
		* a given observer target and event can potentially have multiple handlers declared in different parent or
		* child classes. It transforms an event handler value into an array of values, and merges the arrays of handlers
		* from child to parent. This maintains the handlers even if both parent and child classes have handlers for the
		* same target and event.
		###
		propertyMergeHandler: ( originalParentObserve, originalChildObserve ) ->
			# Make sure we aren't modifying the original objects, particularly for the parent object, since it may be a CLASS-LEVEL object.
			if not Ext.isObject( originalParentObserve )
				parentObserve = {}
			else
				parentObserve = Ext.clone( originalParentObserve )

			if not Ext.isObject( originalChildObserve )
				childObserve = {}
			else
				childObserve = Ext.clone( originalChildObserve )

			# List of available event options to look for and use if they are specified
			eventOptionNames = [ "buffer", "single", "delay", "element", "target", "destroyable" ]

			# Convert any observers that use an array of configuration objects into object keys for event name, and array of configuration objects.
			Deft.mixin.Observer.convertConfigArray( parentObserve, eventOptionNames )
			Deft.mixin.Observer.convertConfigArray( childObserve, eventOptionNames )

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
		* @private
		* Converts an observe configuration that use an array of event configuration objects into object keys for
		* event name, containing an array of configuration objects.
		###
		convertConfigArray: ( observeConfig, eventOptionNames ) ->
			for observeTarget, observeEvents of observeConfig
				if( Ext.isArray( observeEvents ) )
					newObserveEvents = {}
					for thisObserveEvent in observeEvents
						# Object with only one key means this is just an event name/handler pair, not a config object.
						if( Ext.Object.getSize( thisObserveEvent ) is 1 )
							Ext.apply( newObserveEvents, thisObserveEvent )
						else
							handlerConfig = {}
							handlerConfig.fn = thisObserveEvent.fn if thisObserveEvent?.fn?
							handlerConfig.scope = thisObserveEvent.scope if thisObserveEvent?.scope?

							# Add any passed event options
							for thisEventOptionName in eventOptionNames
								handlerConfig[ thisEventOptionName ] = thisObserveEvent[ thisEventOptionName ] if thisObserveEvent?[ thisEventOptionName ]?

							newObserveEvents[ thisObserveEvent.event ] = [ handlerConfig ]

					observeConfig[ observeTarget ] = newObserveEvents

		###*
		@private
		###
		afterMixinProcessed: ( target ) ->
			target[ Deft.mixin.Observer.MIXIN_COMPLETED_KEY ] = true
			return

)

