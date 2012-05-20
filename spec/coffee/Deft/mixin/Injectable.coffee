###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.mixin.Injectable
###
describe( 'Deft.mixin.Injectable', ->
	
	it( 'should trigger injection before the target class constructor is executed', ->
		Ext.define( 'ExampleClass',
			mixins: [ 'Deft.mixin.Injectable' ]
			inject: [ 'identifier' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				return @
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleClass' )
		
		return
	)
)