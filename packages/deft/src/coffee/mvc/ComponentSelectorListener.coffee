###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* Manages live events attached to component selectors. Used by Deft.mvc.ComponentSelector.
* @private
###
Ext.define( 'Deft.mvc.ComponentSelectorListener',
	requires: [
		'Deft.event.LiveEventBus'
	]
	
	constructor: ( config ) ->
		Ext.apply( @, config )
		
		if @componentSelector.live
			Deft.LiveEventBus.addListener( @componentSelector.view, @componentSelector.selector, @eventName, @fn, @scope, @options )
		else
			for component in @componentSelector.components
				component.on( @eventName, @fn, @scope, @options )
		return @
	
	destroy: ->
		if @componentSelector.live
			Deft.LiveEventBus.removeListener( @componentSelector.view, @componentSelector.selector, @eventName, @fn, @scope )
		else
			for component in @componentSelector.components
				component.un( @eventName, @fn, @scope )
		return
)