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

## Attach companion view controllers using the <u>[`companions` property](https://github.com/deftjs/DeftJS/wiki/ViewController-Companion-Configuration)</u>:

		Ext.define("DeftQuickStart.controller.MainController", {
			extend: "Deft.mvc.ViewController",
			inject: ["companyStore"],

			config: {
				companyStore: null
			},

			companions: {
				// Create companion view controllers which can also manage the original view
				// This allows a view controller to leverage common behavior provided by other view controllers.
				shoppingCart: "DeftQuickStart.controller.ShoppingCartController"
			},

			init: function() {
				return this.callParent(arguments);
			}

		});

###
Ext.define( 'Deft.mvc.ViewController',
	alternateClassName: [ 'Deft.ViewController' ]
	mixins: [ 'Deft.mixin.Injectable', 'Deft.mixin.Observer' ]
	requires: [
		'Deft.core.Class'
		'Deft.log.Logger'
		'Deft.mvc.ComponentSelector'
		'Deft.mixin.Injectable'
		'Deft.mixin.Observer'
		'Deft.mvc.Observer'
		'Deft.util.DeftMixinUtils'
	]


	config:
		###*
		* View controlled by this ViewController.
		###
		view: null

		###*
		* @private
		* Companion ViewController instances.
		###
		companionInstances: null


	constructor: ( config = {} ) ->
		if Ext.isObject( config.companions )
			@companions = Ext.merge( @companions, config.companions )
			delete config.companions

		if config.view
			@controlView( config.view )

		@initConfig( config ) # Ensure any config values are set before creating observers.
		@createObservers()
		return @


	###*
	* Initialize the ViewController
	###
	init: ->
		return


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

			@createCompanions()

		else
			Ext.Error.raise( msg: 'Error constructing ViewController: the configured \'view\' is not an Ext.Component.' )
		return


	###*
	* @protected
	###
	createCompanions: ->
		@companionInstances = {}

		for alias, clazz of @companions
			@addCompanion( alias, clazz )


	###*
	* @protected
	###
	destroyCompanions: ->
		for alias, instance of @companionInstances
			@removeCompanion( alias )


	###*
	* Add a new companion view controller to this view controller.
	* @param {String} alias The alias for the new companion.
	* @param {String} class The class name of the companion view controller.
	###
	addCompanion: ( alias, clazz ) ->

		if( @companionInstances[ alias ]? )
			Deft.Logger.warn( "The specified companion alias '#{ alias }' already exists." )
			return

		isRecursionStart = false
		if( Deft.mvc.ViewController.companionCreationStack.length is 0 )
			isRecursionStart = true

		try

			# Prevent circular dependencies during companion creation
			if( not Ext.Array.contains( Deft.mvc.ViewController.companionCreationStack, Ext.getClassName( @ ) ) )
				Deft.mvc.ViewController.companionCreationStack.push( Ext.getClassName( @ ) )
			else
				Deft.mvc.ViewController.companionCreationStack.push( Ext.getClassName( @ ) )
				initialClass = Deft.mvc.ViewController.companionCreationStack[ 0 ]
				stackMessage = Deft.mvc.ViewController.companionCreationStack.join( " -> " )
				Deft.mvc.ViewController.companionCreationStack = []
				Ext.Error.raise( msg: "Error creating companions for '#{ initialClass }'. A circular dependency exists in its companions: #{ stackMessage }" )

			newHost = Ext.create( clazz )
			newHost.controlView( @getView() )
			@companionInstances[ alias ] = newHost
			Deft.mvc.ViewController.companionCreationStack = [] if isRecursionStart

		catch error
			# NOTE: Ext.Logger.error() will throw an error, masking the error we intend to rethrow, so warn instead.
			Deft.Logger.warn( "Error initializing associated view controller: an error occurred while creating an instance of the specified controller: '#{ clazz }'." )
			Deft.mvc.ViewController.companionCreationStack = []
			throw error


	###*
	* Removes and destroys a companion view controller from this view controller.
	* @param {String} alias The alias for the companion host to remove
	###
	removeCompanion: ( alias ) ->

		if( not @companionInstances[ alias ]? )
			Deft.Logger.warn( "The specified companion alias '#{ alias }' cannot be removed because the alias does not exist." )

		try
			@companionInstances[ alias ]?.destroy()
			delete @companionInstances[ alias ]

		catch error
			# NOTE: Ext.Logger.error() will throw an error, masking the error we intend to rethrow, so warn instead.
			Deft.Logger.warn( "Error destroying associated view controller: an error occurred while destroying the associated controller with the alias '#{ alias }'." )
			throw error


	###*
	* Locates a companion view controller by alias.
	* @param {String} alias The alias for the desired companion instance
	* @return {Deft.mvc.ViewController} The companion view controller instance.
	###
	getCompanion: ( alias ) ->
		return @companionInstances[ alias ]


	###*
	* Destroy the ViewController
	###
	destroy: ->
		for id of @registeredComponentReferences
			@removeComponentReference( id )
		for selector of @registeredComponentSelectors
			@removeComponentSelector( selector )
		@removeObservers()
		@destroyCompanions()
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

		companionCreationStack: []


		mergeSubclassInterceptor: () ->
			return ( config = {} ) ->

				controlPropertyName = "control"
				companionPropertyName = "companions"
				if not @[ controlPropertyName ]? then @[ controlPropertyName ] = {}
				if not @[ companionPropertyName ]? then @[ companionPropertyName ] = {}

				# TODO: Add in a check for a completed flag to prevent re-processing a class?
				if( Ext.Object.getSize( @[ controlPropertyName ] ) > 0 )
					Deft.util.DeftMixinUtils.mergeSuperclassProperty( @, controlPropertyName, Deft.mvc.ViewController.controlMergeHandler )
					Deft.util.DeftMixinUtils.mergeSuperclassProperty( @, companionPropertyName, Deft.mvc.ViewController.companionMergeHandler )

				@[ Deft.util.DeftMixinUtils.parentConstructorForVersion() ]( arguments )
				return @


		controlMergeHandler: ( originalParentControl, originalChildControl ) ->
			# Make sure we aren't modifying the original objects, particularly for the parent object, since it may be a CLASS-LEVEL object.
			parentControl = if Ext.isObject( originalParentControl ) then Ext.clone( originalParentControl ) else {}
			childControl = if Ext.isObject( originalChildControl ) then Ext.clone( originalChildControl ) else {}

			# First, apply child config onto parent config
			parentControl = Ext.merge( parentControl, childControl )

			# Now, check for any parent control elements that were overridden by the merge.
			for originalParentControlTarget, originalParentControlConfig of originalParentControl

				# If the merged parent has a matching control target from the original parent...
				if parentControl[ originalParentControlTarget ]?
					matchedPostMergeParentTargetConfig = parentControl[ originalParentControlTarget ]

					# And it has no selector specified, or the selectors match...
					if originalParentControlConfig.selector is undefined or matchedPostMergeParentTargetConfig.selector is originalParentControlConfig.selector

						Deft.mvc.ViewController.detectReplacedListeners(
							matchedPostMergeParentTargetConfig,
							originalParentControlConfig,
							originalChildControl,
							originalParentControlTarget
						)

			return parentControl


		detectReplacedListeners: ( matchedPostMergeParentTargetConfig, originalParentControlConfig, originalChildControl, originalParentControlTarget ) ->

			# If we are dealing with an Object-based event config, and the parent and child configs for
			# this target do not mix simple and complex configurations, merge in any missing parent listeners...
			if( Deft.mvc.ViewController.areBothConfigsComplex(
					matchedPostMergeParentTargetConfig,
					originalParentControlConfig,
					originalChildControl,
					originalParentControlTarget ) )

				matchedPostMergeListeners = matchedPostMergeParentTargetConfig.listeners
				originalListeners = originalParentControlConfig.listeners

				Deft.mvc.ViewController.applyReplacedListeners( originalListeners, matchedPostMergeListeners, ( listenerArray, eventConfig ) ->
					listenerArray.push( Ext.clone( eventConfig ) )
					return
				)

			# If original and merged configs use both complex listener config and simple config, we need to
			# transform the simple config into a listener config object so both can be processed as complex listener configs.
			# If we didn't transform the simple config, those targets and event handlers would not be processed into
			# ComponentSelectorListeners!
			else if Deft.mvc.ViewController.hasMixedConfigs( matchedPostMergeParentTargetConfig, originalParentControlConfig )

				normalizedConfig = Deft.mvc.ViewController.normalizeMixedConfigs( originalParentControlConfig, matchedPostMergeParentTargetConfig )

				# Now apply the original listener config onto the merged config. This way, any non-listener
				# targets and event handlers are treated like any other listener config items.
				Deft.mvc.ViewController.applyReplacedListeners(
					normalizedConfig.listeners,
					matchedPostMergeParentTargetConfig.listeners,
					( listenerArray, eventConfig ) ->
						listenerArray.push( Ext.clone( eventConfig ) )
						return
				)

			# Otherwise, this is a "simple" listener config
			else
				Deft.mvc.ViewController.applyReplacedListeners( originalParentControlConfig, matchedPostMergeParentTargetConfig, ( listenerArray, eventConfig ) ->
					listenerArray.push( Ext.clone( eventConfig ) )
					return Ext.Array.unique( listenerArray )
				)

			return


		applyReplacedListeners: ( originalControlConfig, postMergeControlConfig, applyFn ) ->
			for thisEvent, eventConfig of originalControlConfig

				# Is there a matching event in the post-merge listeners?
				if postMergeControlConfig[ thisEvent ]

					# Ensure that the matching post-merge listeners is an array.
					if not Ext.isArray( postMergeControlConfig[ thisEvent ] )
						postMergeControlConfig[ thisEvent ] = [ postMergeControlConfig[ thisEvent ] ]

					# Ensure that the matched listener does not already exist in the post-merge listeners.
					isDuplicateListener = false
					for dupeCheckListener in postMergeControlConfig[ thisEvent ]

						if dupeCheckListener is eventConfig or ( ( dupeCheckListener.fn isnt undefined or eventConfig.fn isnt undefined ) and dupeCheckListener.fn is eventConfig.fn )
							isDuplicateListener = true
							break

					# If it does not already exist, clone the original listener config and append it to the post-merge listeners.
					if not isDuplicateListener
						applyResult = applyFn( postMergeControlConfig[ thisEvent ], eventConfig )
						postMergeControlConfig[ thisEvent ] = applyResult if applyResult isnt undefined

			return


		areBothConfigsComplex: ( matchedPostMergeParentTargetConfig, originalParentControlConfig, originalChildControl, originalParentControlTarget ) ->
			return Ext.isObject( matchedPostMergeParentTargetConfig.listeners ) and
						 Ext.isObject( originalParentControlConfig.listeners ) and
						 ( originalChildControl[ originalParentControlTarget ] is undefined or
							 Ext.isObject( originalChildControl[ originalParentControlTarget ].listeners ) )


		hasMixedConfigs: ( matchedPostMergeParentTargetConfig, originalParentControlConfig ) ->
			return Ext.isObject( matchedPostMergeParentTargetConfig.listeners ) or Ext.isObject( originalParentControlConfig.listeners )


		normalizeMixedConfigs: ( originalParentControlConfig, matchedPostMergeParentTargetConfig ) ->
			normalizedOriginalParentControlConfig = Ext.clone( originalParentControlConfig )

			# If the merged parent config for this target has listener configuration...
			if Ext.isObject( matchedPostMergeParentTargetConfig.listeners )

				# Ensure the original parent config also has listener configuration...
				if not Ext.isObject( normalizedOriginalParentControlConfig.listeners )
					normalizedOriginalParentControlConfig.listeners = {}

				# Loop over the merged parent configuration
				for matchedParentKey, matchedParentValue of matchedPostMergeParentTargetConfig
					if matchedParentKey isnt "listeners"
						# Make sure the normalized listener config now includes mirrored targets and event handlers.
						# The call to applyReplacedListeners() will make sure we don't end up with duplicates.
						normalizedOriginalParentControlConfig.listeners[ matchedParentKey ] = Ext.clone( matchedParentValue )

						# Also, if the merged config also has non-listener targets, move them into the listener config
						if matchedPostMergeParentTargetConfig.listeners[ matchedParentKey ] is undefined
							matchedPostMergeParentTargetConfig.listeners[ matchedParentKey ] = Ext.clone( matchedParentValue )
							delete matchedPostMergeParentTargetConfig[ matchedParentKey ]

			return normalizedOriginalParentControlConfig


		companionMergeHandler: ( parentCompanions, childCompanions ) ->
			return Ext.merge( Ext.clone( parentCompanions ), Ext.clone( childCompanions ) )
)
