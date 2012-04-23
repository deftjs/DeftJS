###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.util.Function
###
describe( 'Deft.util.Function', ->
	
	describe( 'spread()', ->
		
		it( 'should create a new wrapper function that spreads the passed Array over the target function arguments', ->
			targetFunction = jasmine.createSpy( 'target function' ).andCallFake( ( a, b, c ) -> "#{a},#{b},#{c}" )
			
			wrapperFunction = Deft.util.Function.spread( targetFunction )
			expect( Ext.isFunction( wrapperFunction ) ).toBe( true )
			
			expect( wrapperFunction( [ 'a', 'b','c' ] ) ).toBe( 'a,b,c' )
			expect( targetFunction ).toHaveBeenCalledWith( 'a', 'b', 'c' )
		)
		
		it( 'should create a new wrapper that fails when passed a non-Array', ->
			targetFunction = jasmine.createSpy( 'target function' )
			
			wrapperFunction = Deft.util.Function.spread( targetFunction )
			expect( Ext.isFunction( wrapperFunction ) ).toBe( true )
			
			expect( ->
				wrapperFunction( 'value' )
			).toThrow( new Error( 'Error spreading passed Array over target function arguments: passed a non-Array.' ) )
			
			expect( targetFunction ).not.toHaveBeenCalled()
		)
	)
	
	describe( 'memoize()', ->
	
		# TODO: Test scope parameter
		
		it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs', ->
			fibonacci = ( n ) ->
				( if n < 2 then n else fibonacci( n - 1 ) + fibonacci( n - 2 ) )
			
			targetFunction = jasmine.createSpy( 'target function' ).andCallFake( fibonacci )
			
			memoFunction = Deft.util.Function.memoize( targetFunction )
			
			expect( memoFunction( 12 ) ).toBe( fibonacci( 12 ) )
			expect( targetFunction ).toHaveBeenCalled()
			
			expect( memoFunction( 12 ) ).toBe( fibonacci( 12 ) )
			expect( targetFunction.callCount ).toBe( 1 )
		)
		
		it( 'should support memoizing functions that take multiple parameters using a hash function (specified via an optional parameter) to produce a unique caching key for those parameters',
			sum = -> 
				Ext.Array.toArray( arguments ).reduce( 
					( total, value ) -> total + value
					0
				)
			
			targetFunction = jasmine.createSpy( 'target function' ).andCallFake( sum )
			hashFunction = jasmine.createSpy( 'hash function' ).andCallFake( ( a, b, c ) -> "#{a}|#{b}|#{c}" )
			
			memoFunction = Deft.util.Function.memoize( targetFunction, hashFunction )
			
			expect( memoFunction( 1, 2, 3 ) ).toBe( 6 )
			expect( targetFunction ).toHaveBeenCalled()
			
			expect( memoFunction( 1, 2, 3 ) ).toBe( 6 )
			expect( targetFunction.callCount ).toBe( 1 )
		)
	)
)