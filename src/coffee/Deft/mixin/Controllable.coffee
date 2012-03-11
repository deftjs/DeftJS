###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
A mixin that creates and attaches the specified view controller(s) to the target view.

Used in conjunction with {@link Deft.mvc.ViewController}.
###
Ext.define( 'Deft.mixin.Controllable',
	requires: [ 'Deft.mvc.ViewController' ]
	
	###*
	@private
	###  
	onClassMixedIn: ( targetClass ) ->
		targetClass::constructor = Ext.Function.createInterceptor( targetClass::constructor, ->
			controllers = if Ext.isArray( @controller ) then @controller else [ @controller ]
			Ext.create( controllerClass, @ ) for controllerClass in controllers
		)
		return
)