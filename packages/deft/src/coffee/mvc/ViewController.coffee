###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
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

###
Ext.define( 'Deft.mvc.ViewController',
	alternateClassName: [ 'Deft.ViewController' ]
	mixins: [ 'Deft.mixin.Observer' ]
	requires: [
		'Deft.core.Class'
		'Deft.log.Logger'
		'Deft.mvc.ComponentSelector'
		'Deft.mixin.Observer'
		'Deft.mvc.Observer'
		'Deft.util.DeftMixinUtils'
	]
	
	config:
		###*
		* View controlled by this ViewController.
		###
		view: null
	

	constructor: ( config = {} ) ->
		if config.view
			@controlView( config.view )
		@initConfig( config ) # Ensure any config values are set before creating observers.
		@createObservers()
		return @
	
	###*
	* @protected
	###
	controlView: ( view ) ->
		if view instanceof Ext.ClassManager.get( 'Ext.Component' )
			@setView( view )
			@registeredComponentReferences = {}
			@registeredComponentSelectors = {}
			
			if Ext.getVersion( 'extjs' )?
				# Ext JS
				if @getView().rendered
					@onViewInitialize()
				else
					@getView().on( 'afterrender', @onViewInitialize, @, single: true )
			else
				# Sencha Touch
				if @getView().initialized
					@onViewInitialize()
				else
					@getView().on( 'initialize', @onViewInitialize, @, single: true )
		else
			Ext.Error.raise( msg: 'Error constructing ViewController: the configured \'view\' is not an Ext.Component.' )
		return

	###*
	* Initialize the ViewController
	###
	init: ->
		return
	
	###*
	* Destroy the ViewController
	###
	destroy: ->
		for id of @registeredComponentReferences
			@removeComponentReference( id )
		for selector of @registeredComponentSelectors
			@removeComponentSelector( selector )
		@removeObservers()
		return true
	
	###*
	* @private
	###
	onViewInitialize: ->
		if Ext.getVersion( 'extjs' )?
			# Ext JS
			@getView().on( 'beforedestroy', @onViewBeforeDestroy, @ )
		else
			# Sencha Touch
			self = this
			originalViewDestroyFunction = @getView().destroy
			@getView().destroy = ->
				if self.destroy()
					originalViewDestroyFunction.call( @ )
				return
		
		for id, config of @control
			selector = null
			if id isnt 'view'
				if Ext.isString( config )
					selector = config
				else if config.selector?
					selector = config.selector
				else
					selector = '#' + id
			listeners = null
			if Ext.isObject( config.listeners )
				listeners = config.listeners
			else
				listeners = config unless config.selector? or config.live?
			live = config.live? and config.live
			@addComponentReference( id, selector, live )
			@addComponentSelector( selector, listeners, live )
		
		@init()
		return
	
	###*
	* @private
	###
	onViewBeforeDestroy: ->
		if @destroy()
			@getView().un( 'beforedestroy', @onViewBeforeDestroy, @ )
			return true
		return false
	
	###*
	* Add a component accessor method the ViewController for the specified view-relative selector.
	###
	addComponentReference: ( id, selector, live = false ) ->
		Deft.Logger.log( "Adding '#{ id }' component reference for selector: '#{ selector }'." )
		
		if @registeredComponentReferences[ id ]?
			Ext.Error.raise( msg: "Error adding component reference: an existing component reference was already registered as '#{ id }'." )
		
		# Add generated getter function.
		if id isnt 'view'
			getterName = 'get' + Ext.String.capitalize( id )
			unless @[ getterName ]?
				if live
					@[ getterName ] = Ext.Function.pass( @getViewComponent, [ selector ], @ )
				else
					matches = @getViewComponent( selector )
					unless matches?
						Ext.Error.raise( msg: "Error locating component: no component(s) found matching '#{ selector }'." )
					@[ getterName ] = -> matches
				@[ getterName ].generated = true
		
		@registeredComponentReferences[ id ] = true
		return
	
	###*
	* Remove a component accessor method the ViewController for the specified view-relative selector.
	###
	removeComponentReference: ( id ) ->
		Deft.Logger.log( "Removing '#{ id }' component reference." )
		
		unless @registeredComponentReferences[ id ]?
			Ext.Error.raise( msg: "Error removing component reference: no component reference is registered as '#{ id }'." )
		
		# Remove generated getter function.
		if id isnt 'view'
			getterName = 'get' + Ext.String.capitalize( id )
			if @[ getterName ].generated
				@[ getterName ] = null
		
		delete @registeredComponentReferences[ id ]
		
		return
	
	###*
	* Get the component(s) corresponding to the specified view-relative selector.
	###
	getViewComponent: ( selector ) ->
		if selector?
			matches = Ext.ComponentQuery.query( selector, @getView() )
			if matches.length is 0
				return null
			else if matches.length is 1
				return matches[ 0 ]
			else
				return matches
		else
			return @getView()
	
	###*
	* Add a component selector with the specified listeners for the specified view-relative selector.
	###
	addComponentSelector: ( selector, listeners, live = false ) ->
		Deft.Logger.log( "Adding component selector for: '#{ selector }'." )
		
		existingComponentSelector = @getComponentSelector( selector )
		if existingComponentSelector?
			Ext.Error.raise( msg: "Error adding component selector: an existing component selector was already registered for '#{ selector }'." )
		
		componentSelector = Ext.create( 'Deft.mvc.ComponentSelector',
			view: @getView()
			selector: selector
			listeners: listeners
			scope: @
			live: live
		)
		@registeredComponentSelectors[ selector ] = componentSelector
		
		return
	
	###*
	* Remove a component selector with the specified listeners for the specified view-relative selector.
	###
	removeComponentSelector: ( selector ) ->
		Deft.Logger.log( "Removing component selector for '#{ selector }'." )
		
		existingComponentSelector = @getComponentSelector( selector )
		unless existingComponentSelector?
			Ext.Error.raise( msg: "Error removing component selector: no component selector registered for '#{ selector }'." )
		
		existingComponentSelector.destroy()
		delete @registeredComponentSelectors[ selector ]
		
		return
	
	###*
	* Get the component selectorcorresponding to the specified view-relative selector.
	###
	getComponentSelector: ( selector ) ->
		return @registeredComponentSelectors[ selector ]


	# TODO: Check with John. onClassExtended() is private. But then, so is onExtended(). We may just have to come to terms with it?
	onClassExtended: ( clazz, config ) ->
		clazz.override(
			constructor: Deft.mvc.ViewController.mergeSubclassInterceptor()
		)
		return true


	statics:

		mergeSubclassInterceptor: () ->
			return ( config = {} ) ->

				controlPropertyName = "control"
				behaviorPropertyName = "behaviors"
				if not @[ controlPropertyName ]? then @[ controlPropertyName ] = {}
				if not @[ behaviorPropertyName ]? then @[ behaviorPropertyName ] = []

				# TODO: Add in a check for a completed flag to prevent re-processing a class?
				if( Ext.Object.getSize( @[ controlPropertyName ] ) > 0 )
					Deft.util.DeftMixinUtils.mergeSuperclassProperty( @, controlPropertyName, Deft.mvc.ViewController.controlMergeHandler )
					Deft.util.DeftMixinUtils.mergeSuperclassProperty( @, behaviorPropertyName, Deft.mvc.ViewController.behaviorMergeHandler )

					# TODO: These calls based on Ext JS version can revert to @callParent() if we end up dropping 4.0.x support...
					@[ Deft.util.DeftMixinUtils.parentConstructorForVersion( @ ) ]( arguments )

					return @

				return @[ Deft.util.DeftMixinUtils.parentConstructorForVersion( @ ) ]( arguments )

		controlMergeHandler: ( originalParentControl, originalChildControl ) ->
			# Make sure we aren't modifying the original objects, particularly for the parent object, since it may be a CLASS-LEVEL object.
			if not Ext.isObject( originalParentControl )
				parentControl = {}
			else
				parentControl = Ext.clone( originalParentControl )

			if not Ext.isObject( originalChildControl )
				childControl = {}
			else
				childControl = Ext.clone( originalChildControl )

			# First, apply child config onto parent config
			parentControl = Ext.merge( parentControl, childControl )

			# Now, check for any parent control elements that were overridden.
			for originalParentControlTarget, originalParentControlConfig of originalParentControl

				# If the merged parent has a matching control target...
				if parentControl[ originalParentControlTarget ]?
					matchedPostMergeParentTargetConfig = parentControl[ originalParentControlTarget ]

					# And it has no selector specified, or the selectors match...
					if originalParentControlConfig.selector is undefined or matchedPostMergeParentTargetConfig.selector is originalParentControlConfig.selector

						# TODO: What about a case where the child merged in uses ".listeners", but original parent is "simple"?
						# If we are dealing with complex listener configs, merge in any missing parent listeners...
						if Ext.isObject( matchedPostMergeParentTargetConfig.listeners ) and Ext.isObject( originalParentControlConfig.listeners )
							matchedPostMergeListeners = matchedPostMergeParentTargetConfig.listeners
							originalListeners = originalParentControlConfig.listeners

							Deft.mvc.ViewController.applyReplacedListeners( originalListeners, matchedPostMergeListeners, ( listenerArray, eventConfig ) ->
								listenerArray.push( Ext.clone( eventConfig ) )
								return
							)

							###
							# TODO: Could this for loop become a separate method, reused by .listener, simple, or mixed configs?
							#We've got a match, so loop over the original listeners to see if any match...
							for thisEvent, eventConfig of originalListeners

								# Is there a matching event in the post-merge listeners?
								if matchedPostMergeListeners[ thisEvent ]

									# Ensure that the matching post-merge listeners is an array.
									if not Ext.isArray( matchedPostMergeListeners[ thisEvent ] )
										matchedPostMergeListeners[ thisEvent ] = [ matchedPostMergeListeners[ thisEvent ] ]

									# Ensure that the matched listener does not already exist in the post-merge listeners.
									isDuplicateListener = false
									for dupeCheckListener in matchedPostMergeListeners[ thisEvent ]

										# TODO: If extracting method, keep in mind that .fn === .fn will return true if both are undefined! So need to check if undefined first?
										if dupeCheckListener is eventConfig or dupeCheckListener.fn is eventConfig.fn
											isDuplicateListener = true
											break

									# If it does not already exist, clone the original listener config and append it to the post-merge listeners.
									if not isDuplicateListener
										matchedPostMergeListeners[ thisEvent ].push( Ext.clone( eventConfig ) )

								###

						# Otherwise, this is a "simple" control config
						else

							Deft.mvc.ViewController.applyReplacedListeners( originalParentControlConfig, matchedPostMergeParentTargetConfig, ( listenerArray, eventConfig ) ->
								listenerArray.push( Ext.clone( eventConfig ) )
								return Ext.Array.unique( listenerArray )
							)

							###
							#We've got a match, so loop over the original control events to see if any match...
							for thisEvent, eventConfig of originalParentControlConfig

								# Is there a matching event in the post-merge listeners?
								if matchedPostMergeParentTargetConfig[ thisEvent ]

									# Ensure that the matching post-merge event config is an array.
									if not Ext.isArray( matchedPostMergeParentTargetConfig[ thisEvent ] )
										matchedPostMergeParentTargetConfig[ thisEvent ] = [ matchedPostMergeParentTargetConfig[ thisEvent ] ]

										# Append the event handler then ensure uniqueness...
										matchedPostMergeParentTargetConfig[ thisEvent ].push( eventConfig )
										matchedPostMergeParentTargetConfig[ thisEvent ] = Ext.Array.unique( matchedPostMergeParentTargetConfig[ thisEvent ] )

							###

			return parentControl

		applyReplacedListeners: ( originalListeners, matchedPostMergeListeners, applyFn ) ->
			for thisEvent, eventConfig of originalListeners

				# Is there a matching event in the post-merge listeners?
				if matchedPostMergeListeners[ thisEvent ]

					# Ensure that the matching post-merge listeners is an array.
					if not Ext.isArray( matchedPostMergeListeners[ thisEvent ] )
						matchedPostMergeListeners[ thisEvent ] = [ matchedPostMergeListeners[ thisEvent ] ]

					# Ensure that the matched listener does not already exist in the post-merge listeners.
					isDuplicateListener = false
					for dupeCheckListener in matchedPostMergeListeners[ thisEvent ]

						if dupeCheckListener is eventConfig or ( ( dupeCheckListener.fn isnt undefined or eventConfig.fn isnt undefined ) and dupeCheckListener.fn is eventConfig.fn )
							isDuplicateListener = true
							break

					# If it does not already exist, clone the original listener config and append it to the post-merge listeners.
					if not isDuplicateListener
						applyResult = applyFn( matchedPostMergeListeners[ thisEvent ], eventConfig )
						matchedPostMergeListeners[ thisEvent ] = applyResult if applyResult isnt undefined

			return

		behaviorMergeHandler: ( parentBehaviors, childBehaviors ) ->
			return Ext.Array.merge( parentBehaviors, childBehaviors )
)
