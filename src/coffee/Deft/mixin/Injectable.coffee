###*
A mixin that marks a class as participating in dependency injection.

Used in conjunction with {@link Deft.ioc.Injector}.
###
Ext.define( 'Deft.mixin.Injectable',
	requires: [ 'Deft.ioc.Injector' ]
	
	###*
	@private
	###
	onClassMixedIn: ( targetClass ) ->
		targetClass.prototype.constructor = Ext.Function.createInterceptor( targetClass.prototype.constructor, ->
			Deft.Injector.inject( @inject, @ )
		)
		return
)
