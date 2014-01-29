###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

describe( 'Deft.util.Function', ->
	
	describe( 'memoize()', ->
		fibonacci = ( n ) ->
			( if n < 2 then n else fibonacci( n - 1 ) + fibonacci( n - 2 ) )
		
		sum = -> 
			Ext.Array.toArray( arguments ).reduce(
				( total, value ) -> total + value
				0
			)
		
		specify( 'returns a new function that wraps the specified function (omitting the optional scope and hash function parameters) and caches the results for previously processed inputs', ->
			targetFunction = sinon.spy( fibonacci )
			
			memoFunction = Deft.util.Function.memoize( targetFunction )
			
			expect( memoFunction( 12 ) ).to.equal( fibonacci( 12 ) )
			expect( memoFunction( 12 ) ).to.equal( fibonacci( 12 ) )
			expect( targetFunction ).to.be.calledOnce.and.calledOn( window )
			
			return
		)
		
		specify( 'returns a new function that wraps the specified function (to be executed in the scope specified via the scope parameter) and caches the results for previously processed inputs', ->
			targetScope = {}
			targetFunction = sinon.spy( fibonacci )
			
			memoFunction = Deft.util.Function.memoize( targetFunction, targetScope )
			
			expect( memoFunction( 12 ) ).to.equal( fibonacci( 12 ) )
			expect( memoFunction( 12 ) ).to.equal( fibonacci( 12 ) )
			expect( targetFunction ).to.be.calledOnce.and.calledOn( targetScope )
			
			return
		)
		
		specify( 'supports memoizing functions that take multiple parameters using a hash function (specified via an optional parameter) to produce a unique caching key for those parameters', ->
			targetScope = {}
			targetFunction = sinon.spy( sum )
			hashFunction = sinon.spy( ( a, b, c ) -> Ext.Array.toArray( arguments ).join( '|' ) )
			
			memoFunction = Deft.util.Function.memoize( targetFunction, targetScope, hashFunction )
			
			expect( memoFunction( 1, 2, 3 ) ).to.equal( sum( 1, 2, 3 ) )
			expect( memoFunction( 1, 2, 3 ) ).to.equal( sum( 1, 2, 3 ) )
			expect( hashFunction ).to.be.calledTwice.and.calledOn( targetScope )
			expect( targetFunction ).to.be.calledOnce.and.calledOn( targetScope )
			
			return
		)
		
		return
	)
	
	describe( 'nextTick()', ->
		
		specify( 'schedules the specified function to be executed in the next turn of the event loop', ( done ) ->
			targetFunction = sinon.stub()
			
			Deft.util.Function.nextTick( targetFunction )
			
			setTimeout(
				->
					expect( targetFunction ).to.be.calledOnce
					done()
					return
				0
			)
			return
		)

		specify( 'schedules the specified functionto be executed in the specified scope in the next turn of the event loop', ( done ) ->
			targetScope = {}
			targetFunction = sinon.stub()
			
			Deft.util.Function.nextTick( targetFunction, targetScope )
			
			setTimeout(
				->
					expect( targetFunction ).to.be.calledOnce.and.calledOn( targetScope )
					done()
					return
				0
			)
			return
		)

		specify( 'schedules the specified functionto be executed in the specified scope with the specified parameters in the next turn of the event loop', ( done ) ->
			targetScope = {}
			targetFunction = sinon.stub()

			Deft.util.Function.nextTick( targetFunction, targetScope, [ 'a', 'b','c' ] )

			setTimeout(
				->
					expect( targetFunction ).to.be.calledOnce.and.calledOn( targetScope )
					expect( targetFunction ).to.be.calledOnce.and.calledWith( 'a', 'b','c' )
					done()
					return
				0
			)
			return
		)
		
		return
	)
	
	describe( 'spread()', ->
		
		specify( 'creates a new wrapper function that spreads the passed Array over the target function arguments', ->
			targetFunction = sinon.spy( ( a, b, c ) -> "#{a},#{b},#{c}" )
			
			wrapperFunction = Deft.util.Function.spread( targetFunction )
			
			expect( Ext.isFunction( wrapperFunction ) ).to.be.true
			expect( wrapperFunction( [ 'a', 'b','c' ] ) ).to.equal( 'a,b,c' )
			expect( targetFunction ).to.be.calledOnce.and.calledWith( 'a', 'b', 'c' )
			
			return
		)
		
		specify( 'creates a new wrapper that fails when passed a non-Array', ->
			targetFunction = sinon.stub()
			
			wrapperFunction = Deft.util.Function.spread( targetFunction )
			
			expect( Ext.isFunction( wrapperFunction ) ).to.be.true
			expect( -> wrapperFunction( 'value' ) ).to.throw( Error, 'Error spreading passed Array over target function arguments: passed a non-Array.' )
			expect( targetFunction ).not.to.be.called
			
			return
		)
		
		return
	)
	
	return
)