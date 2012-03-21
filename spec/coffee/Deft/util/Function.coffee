###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.util.Function
###
describe( 'Deft.util.Function', ->
	
	describe( 'spread()', ->
		
		it( 'should create a new wrapper function that spreads the passed Array as the target function arguments', ->
			targetFunction = jasmine.createSpy( 'target function' )
			
			wrapperFunction = Deft.util.Function.spread( targetFunction )
			expect( Ext.isFunction( wrapperFunction ) ).toBe( true )
			
			wrapperFunction( [ 'a', 'b','c' ] )
			expect( targetFunction ).toHaveBeenCalledWith( 'a', 'b', 'c' )
		)
		
		it( 'should create a new wrapper that fails when passed a non-Array', ->
			targetFunction = jasmine.createSpy( 'target function' )
			
			wrapperFunction = Deft.util.Function.spread( targetFunction )
			expect( Ext.isFunction( wrapperFunction ) ).toBe( true )
			
			expect( ->
				wrapperFunction( 'value' )
			).toThrow( new Error( 'Error spreading passed Array to target function arguments: passed a non-Array.' ) )
			
			expect( targetFunction ).not.toHaveBeenCalled()
		)
	)
)