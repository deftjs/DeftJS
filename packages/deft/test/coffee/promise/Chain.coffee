###
Copyright (c) 2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

describe( 'Deft.promise.Chain', ->
	# Format values displayed by the test runner to make them human readable
	# and consistent across platforms.
	formatValue = ( value ) ->
		# Promises and Deferreds
		if value instanceof Deft.promise.Promise
			return 'Deft.Promise'
		if value instanceof Deft.promise.Deferred
			return 'Deft.Deferred'
		# All other Ext JS or Sencha Touch Class instances
		if value instanceof Ext.ClassManager.get( 'Ext.Base' )
			return Ext.ClassManager.getName( value )
		# Array
		if Ext.isArray( value )
			formattedValues = Ext.Array.map( value, formatValue )
			return "[#{ formattedValues.join(', ') }]"
		# Object
		if Ext.isObject( value )
			return 'Object'
		# String
		if Ext.isString( value )
			return "\"#{ value }\""
		return '' + value
	
	targetScope = {}
	
	verifyScope = ( fn, expectedScope ) ->
		return ->
			expect( @ ).to.equal( expectedScope )
			return fn.apply( @, arguments )
	
	verifyArgs = ( fn, expectedArgs ) ->
		return ->
			args = [].slice.call( arguments, 0 )
			expect( args ).to.deep.equal( expectedArgs )
			return fn.apply( @, arguments )
	
	describe( 'sequence()', ->
		fn1 = sinon.spy( -> 
			expect( fn2 ).not.to.have.been.called
			expect( fn3 ).not.to.have.been.called
			return 1
		)
		fn2 = sinon.spy( ->
			expect( fn1 ).to.have.been.calledOnce
			expect( fn3 ).not.to.have.been.called
			return 2
		)
		fn3 = sinon.spy( -> 
			expect( fn1 ).to.have.been.calledOnce
			expect( fn2 ).to.have.been.calledOnce
			return 3
		)
		
		describe( 'returns a new Promise that will resolve with an Array of the results returned by calling the specified functions in sequence order', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			specify( 'Empty Array', ->
				fns = []
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Empty Array with the optional scope specified', ->
				fns = []
				
				promise = Deft.Chain.sequence( fns, targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Empty Array with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = []
				
				promise = Deft.Chain.sequence( fns, targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Array with one function', ->
				fns = [
					fn1
				]
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Array with one function with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
				]
				
				promise = Deft.Chain.sequence( fns, targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Array with one function with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
				]
				
				promise = Deft.Chain.sequence( fns, targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Array of two functions', ->
				fns = [
					fn1
					fn2
				]
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Array of two functions with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
					verifyScope( fn2, targetScope )
				]
				
				promise = Deft.Chain.sequence( fns, targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Array of two functions with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
					verifyArgs( verifyScope( fn2, targetScope ), args )
				]
				
				promise = Deft.Chain.sequence( fns, targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Array of three functions', ->
				fns = [
					fn1
					fn2
					fn3
				]
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			specify( 'Array of three functions with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
					verifyScope( fn2, targetScope )
					verifyScope( fn3, targetScope )
				]
				
				promise = Deft.Chain.sequence( fns, targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			specify( 'Array of three functions with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
					verifyArgs( verifyScope( fn2, targetScope ), args )
					verifyArgs( verifyScope( fn3, targetScope ), args )
				]
				
				promise = Deft.Chain.sequence( fns, targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will resolve with an Array of the results returned by calling the specified resolved Promise of an Array of functions in sequence order', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			specify( 'Promise of an empty Array', ->
				fns = []
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Promise of an empty Array with the optional scope specified', ->
				fns = []
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ), targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Promise of an empty Array with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = []
				
				promise = Deft.Chain.sequence( fns, targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Promise of an Array with one function', ->
				fns = [
					fn1
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Promise of an Array with one function with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ), targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Promise of an Array with one function with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ), targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Promise of an Array of two functions', ->
				fns = [
					fn1
					fn2
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Promise of an Array of two functions with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
					verifyScope( fn2, targetScope )
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ), targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Promise of an Array of two functions with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
					verifyArgs( verifyScope( fn2, targetScope ), args )
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ), targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Promise of an Array of three functions', ->
				fns = [
					fn1
					fn2
					fn3
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			specify( 'Promise of an Array of three functions with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
					verifyScope( fn2, targetScope )
					verifyScope( fn3, targetScope )
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ), targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			specify( 'Promise of an Array of three functions with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
					verifyArgs( verifyScope( fn2, targetScope ), args )
					verifyArgs( verifyScope( fn3, targetScope ), args )
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ), targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the Error associated with the specified rejected Promise of an Array of functions', ->
			specify( 'Error: error message', ->
				promise = Deft.Chain.sequence( Deft.Deferred.reject( new Error( 'error message' ) ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Array of functions throws an Error', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			brokenFn = -> throw new Error( 'Error message' )
			
			specify( 'Array with one function that throws an Error', ->
				fns = [
					brokenFn
				]
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with one function and one function that throws an Error', ->
				fns = [
					fn1
					brokenFn
				]
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with two functions and one function that throws an Error', ->
				fns = [
					fn1
					fn2
					brokenFn
				]
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Promise of an Array of functions throws an Error', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			brokenFn = -> throw new Error( 'Error message' )
			
			specify( 'Promise of an Array with one function that throws an Error', ->
				fns = [
					brokenFn
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Promise of an Array with one function and one function that throws an Error', ->
				fns = [
					fn1
					brokenFn
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Promise of an Array with two functions and one function that throws an Error', ->
				fns = [
					fn1
					fn2
					brokenFn
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Array of functions returns a rejected Promise', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			rejectFn = -> Deft.Deferred.reject( new Error( 'Error message' ) )
			
			specify( 'Array with one function that returns a rejected Promise', ->
				fns = [
					rejectFn
				]
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with one function and one function that returns a rejected Promise', ->
				fns = [
					fn1
					rejectFn
				]
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with two functions and one function that returns a rejected Promise', ->
				fns = [
					fn1
					fn2
					rejectFn
				]
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Promise of an Array of functions returns a rejected Promise', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			rejectFn = -> Deft.Deferred.reject( new Error( 'Error message' ) )
			
			specify( 'Promise of an Array with one function that returns a rejected Promise', ->
				fns = [
					rejectFn
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Promise of an Array with one function and one function that returns a rejected Promise', ->
				fns = [
					fn1
					rejectFn
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Promise of an Array with two functions and one function that returns a rejected Promise', ->
				fns = [
					fn1
					fn2
					rejectFn
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the items in the specified Array is not a function', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			specify( 'Array with one non-function value', ->
				fns = [
					1
				]
			
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Array with one function and one non-function value', ->
				fns = [
					fn1
					1
				]
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Array with two functions and one non-function value', ->
				fns = [
					fn1
					fn2
					1
				]
				
				promise = Deft.Chain.sequence( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the items in the specified resolved Promise of an Array is not a function ', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			specify( 'Promise of an Array with one non-function value', ->
				fns = [
					1
				]
			
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Promise of an Array with one function and one non-function value', ->
				fns = [
					fn1
					1
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Promise of an Array with two functions and one non-function value', ->
				fns = [
					fn1
					fn2
					1
				]
				
				promise = Deft.Chain.sequence( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			return
		)
		
		describe( 'throws an Error if anything other than Array or Promise of an Array is specified as the first parameter', ->
			specify( 'No parameters', ->
				expect( -> Deft.Chain.sequence() ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)
			
			specify( 'A non-Array parameter', ->
				expect( -> Deft.Chain.sequence( 1 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)
			
			return
		)
		
		return
	)
	
	describe( 'parallel()', ->
		fn1 = sinon.spy( -> 1 )
		fn2 = sinon.spy( -> 2 )
		fn3 = sinon.spy( -> 3 )
		
		describe( 'returns a new Promise that will resolve with an Array of the results returned by calling the specified functions in parallel', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			specify( 'Empty Array', ->
				fns = []
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Empty Array with the optional scope specified', ->
				fns = []
				
				promise = Deft.Chain.parallel( fns, targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Empty Array with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = []
				
				promise = Deft.Chain.parallel( fns, targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Array with one function', ->
				fns = [
					fn1
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Array with one function with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
				]
				
				promise = Deft.Chain.parallel( fns, targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Array with one function with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
				]
				
				promise = Deft.Chain.parallel( fns, targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Array of two functions', ->
				fns = [
					fn1
					fn2
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Array of two functions with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
					verifyScope( fn2, targetScope )
				]
				
				promise = Deft.Chain.parallel( fns, targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Array of two functions with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
					verifyArgs( verifyScope( fn2, targetScope ), args )
				]
				
				promise = Deft.Chain.parallel( fns, targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Array of three functions', ->
				fns = [
					fn1
					fn2
					fn3
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			specify( 'Array of three functions with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
					verifyScope( fn2, targetScope )
					verifyScope( fn3, targetScope )
				]
				
				promise = Deft.Chain.parallel( fns, targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			specify( 'Array of three functions with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
					verifyArgs( verifyScope( fn2, targetScope ), args )
					verifyArgs( verifyScope( fn3, targetScope ), args )
				]
				
				promise = Deft.Chain.parallel( fns, targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will resolve with an Array of the results returned by calling the specified resolved Promise of an Array of functions in parallel', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			specify( 'Promise of an empty Array', ->
				fns = []
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Promise of an empty Array with the optional scope specified', ->
				fns = []
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ), targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Promise of an empty Array with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = []
				
				promise = Deft.Chain.parallel( fns, targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)
			
			specify( 'Promise of an Array with one function', ->
				fns = [
					fn1
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Promise of an Array with one function with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ), targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Promise of an Array with one function with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ), targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1 ] )
			)
			
			specify( 'Promise of an Array of two functions', ->
				fns = [
					fn1
					fn2
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Promise of an Array of two functions with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
					verifyScope( fn2, targetScope )
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ), targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Promise of an Array of two functions with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
					verifyArgs( verifyScope( fn2, targetScope ), args )
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ), targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2 ] )
			)
			
			specify( 'Promise of an Array of three functions', ->
				fns = [
					fn1
					fn2
					fn3
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			specify( 'Promise of an Array of three functions with the optional scope specified', ->
				fns = [
					verifyScope( fn1, targetScope )
					verifyScope( fn2, targetScope )
					verifyScope( fn3, targetScope )
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ), targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			specify( 'Promise of an Array of three functions with the optional scope and arguments specified', ->
				args = [ 'a', 'b', 'c' ]
				fns = [
					verifyArgs( verifyScope( fn1, targetScope ), args )
					verifyArgs( verifyScope( fn2, targetScope ), args )
					verifyArgs( verifyScope( fn3, targetScope ), args )
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ), targetScope, 'a', 'b', 'c' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the Error associated with the specified rejected Promise of an Array of functions', ->
			specify( 'Error: error message', ->
				promise = Deft.Chain.parallel( Deft.Deferred.reject( new Error( 'error message' ) ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Array of functions throws an Error', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			brokenFn = -> throw new Error( 'Error message' )
			
			specify( 'Array with one function that throws an Error', ->
				fns = [
					brokenFn
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with one function and one function that throws an Error', ->
				fns = [
					fn1
					brokenFn
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with two functions and one function that throws an Error', ->
				fns = [
					fn1
					fn2
					brokenFn
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Promise of an Array of functions throws an Error', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			brokenFn = -> throw new Error( 'Error message' )
			
			specify( 'Promise of an Array with one function that throws an Error', ->
				fns = [
					brokenFn
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Promise of an Array with one function and one function that throws an Error', ->
				fns = [
					fn1
					brokenFn
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Promise of an Array with two functions and one function that throws an Error', ->
				fns = [
					fn1
					fn2
					brokenFn
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Array of functions returns a rejected Promise', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			rejectFn = -> Deft.Deferred.reject( new Error( 'Error message' ) )
			
			specify( 'Array with one function that returns a rejected Promise', ->
				fns = [
					rejectFn
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with one function and one function that returns a rejected Promise', ->
				fns = [
					fn1
					rejectFn
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with two functions and one function that returns a rejected Promise', ->
				fns = [
					fn1
					fn2
					rejectFn
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Promise of an Array of functions returns a rejected Promise', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			rejectFn = -> Deft.Deferred.reject( new Error( 'Error message' ) )
			
			specify( 'Promise of an Array with one function that returns a rejected Promise', ->
				fns = [
					rejectFn
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Promise of an Array with one function and one function that returns a rejected Promise', ->
				fns = [
					fn1
					rejectFn
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Promise of an Array with two functions and one function that returns a rejected Promise', ->
				fns = [
					fn1
					fn2
					rejectFn
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the items in the specified Array is not a function', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			specify( 'Array with one non-function value', ->
				fns = [
					1
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Array with one function and one non-function value', ->
				fns = [
					fn1
					1
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Array with two functions and one non-function value', ->
				fns = [
					fn1
					fn2
					1
				]
				
				promise = Deft.Chain.parallel( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the items in the specified resolved Promise of an Array is not a function ', ->
			beforeEach( ->
				fn.reset() for fn in [ fn1, fn2, fn3 ]
			)
			
			specify( 'Promise of an Array with one non-function value', ->
				fns = [
					1
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Promise of an Array with one function and one non-function value', ->
				fns = [
					fn1
					1
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Promise of an Array with two functions and one non-function value', ->
				fns = [
					fn1
					fn2
					1
				]
				
				promise = Deft.Chain.parallel( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			return
		)
		
		describe( 'throws an Error if anything other than Array or Promise of an Array is specified as the first parameter', ->
			specify( 'No parameters', ->
				expect( -> Deft.Chain.parallel() ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)
			
			specify( 'A non-Array parameter', ->
				expect( -> Deft.Chain.parallel( 1 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)
			
			return
		)
		
		return
	)
	
	describe( 'pipeline()', ->
		
		createAppenderFn = ( v ) -> ( x ) -> if x then x + v else v
		
		describe( 'returns a new Promise that will resolve with the result returned by calling the specified Array of functions as a pipeline', ->
			specify( 'Empty Array', ->
				fns = []
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( undefined )
			)
			
			specify( 'Empty Array with an initial value', ->
				fns = []
				
				promise = Deft.Chain.pipeline( fns, 'initial value' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'initial value' )
			)
			
			specify( 'Empty Array with an initial value and scope', ->
				fns = []
				
				promise = Deft.Chain.pipeline( fns, 'initial value' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'initial value' )
			)
			
			specify( 'Array with one function', ->
				fns = [
					createAppenderFn( 'a' )
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'a' )
			)
			
			specify( 'Array with one function with an initial value', ->
				fns = [
					createAppenderFn( 'b' )
				]
				
				promise = Deft.Chain.pipeline( fns, 'a' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'ab' )
			)
			
			specify( 'Array with one function with an initial value and scope', ->
				fns = [
					verifyScope( createAppenderFn( 'b' ), targetScope )
				]
				
				promise = Deft.Chain.pipeline( fns, 'a', targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'ab' )
			)
			
			specify( 'Array of two functions', ->
				fns = [
					createAppenderFn( 'a' )
					createAppenderFn( 'b' )
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'ab' )
			)
			
			specify( 'Array of two functions with an initial value', ->
				fns = [
					createAppenderFn( 'b' )
					createAppenderFn( 'c' )
				]
				
				promise = Deft.Chain.pipeline( fns, 'a' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'abc' )
			)
			
			specify( 'Array of two functions with an initial value and scope', ->
				fns = [
					verifyScope( createAppenderFn( 'b' ), targetScope )
					verifyScope( createAppenderFn( 'c' ), targetScope )
				]
				
				promise = Deft.Chain.pipeline( fns, 'a', targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'abc' )
			)
			
			specify( 'Array of three functions', ->
				fns = [
					createAppenderFn( 'a' )
					createAppenderFn( 'b' )
					createAppenderFn( 'c' )
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'abc' )
			)
			
			specify( 'Array of three functions with an initial value', ->
				fns = [
					createAppenderFn( 'b' )
					createAppenderFn( 'c' )
					createAppenderFn( 'd' )
				]
				
				promise = Deft.Chain.pipeline( fns, 'a' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'abcd' )
			)
			
			specify( 'Array of three functions with an initial value', ->
				fns = [
					verifyScope( createAppenderFn( 'b' ), targetScope )
					verifyScope( createAppenderFn( 'c' ), targetScope )
					verifyScope( createAppenderFn( 'd' ), targetScope )
				]
				
				promise = Deft.Chain.pipeline( fns, 'a', targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'abcd' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will resolve with the result returned by calling the specified Promise of an Array of functions as a pipeline', ->
			specify( 'Promise of an empty Array', ->
				fns = []
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( undefined )
			)
			
			specify( 'Promise of an empty Array with an initial value', ->
				fns = []
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ), 'initial value' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'initial value' )
			)
			
			specify( 'Promise of an empty Array with an initial value and scope', ->
				fns = []
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ), 'initial value' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'initial value' )
			)
			
			specify( 'Promise of an Array with one function', ->
				fns = [
					createAppenderFn( 'a' )
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'a' )
			)
			
			specify( 'Promise of an Array with one function with an initial value', ->
				fns = [
					createAppenderFn( 'b' )
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ), 'a' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'ab' )
			)
			
			specify( 'Promise of an Array with one function with an initial value and scope', ->
				fns = [
					verifyScope( createAppenderFn( 'b' ), targetScope )
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ), 'a', targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'ab' )
			)
			
			specify( 'Promise of an Array of two functions', ->
				fns = [
					createAppenderFn( 'a' )
					createAppenderFn( 'b' )
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'ab' )
			)
			
			specify( 'Promise of an Array of two functions with an initial value', ->
				fns = [
					createAppenderFn( 'b' )
					createAppenderFn( 'c' )
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ), 'a' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'abc' )
			)
			
			specify( 'Promise of an Array of two functions with an initial value and scope', ->
				fns = [
					verifyScope( createAppenderFn( 'b' ), targetScope )
					verifyScope( createAppenderFn( 'c' ), targetScope )
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ), 'a', targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'abc' )
			)
			
			specify( 'Promise of an Array of three functions', ->
				fns = [
					createAppenderFn( 'a' )
					createAppenderFn( 'b' )
					createAppenderFn( 'c' )
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'abc' )
			)
			
			specify( 'Promise of an Array of three functions with an initial value', ->
				fns = [
					createAppenderFn( 'b' )
					createAppenderFn( 'c' )
					createAppenderFn( 'd' )
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ), 'a' )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'abcd' )
			)
			
			specify( 'Promise of an Array of three functions with an initial value', ->
				fns = [
					verifyScope( createAppenderFn( 'b' ), targetScope )
					verifyScope( createAppenderFn( 'c' ), targetScope )
					verifyScope( createAppenderFn( 'd' ), targetScope )
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ), 'a', targetScope )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'abcd' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the Error associated with the specified rejected Promise of an Array of functions', ->
			specify( 'Error: error message', ->
				promise = Deft.Chain.pipeline( Deft.Deferred.reject( new Error( 'error message' ) ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Array of functions throws an Error', ->
			brokenFn = -> throw new Error( 'Error message' )
			
			specify( 'Array with one function that throws an Error', ->
				fns = [
					brokenFn
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with one function and one function that throws an Error', ->
				fns = [
					createAppenderFn( 'a' )
					brokenFn
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with two functions and one function that throws an Error', ->
				fns = [
					createAppenderFn( 'a' )
					createAppenderFn( 'b' )
					brokenFn
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Promise of an Array of functions throws an Error', ->
			brokenFn = -> throw new Error( 'Error message' )
			
			specify( 'Promise of an Array with one function that throws an Error', ->
				fns = [
					brokenFn
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Promise of an Array with one function and one function that throws an Error', ->
				fns = [
					createAppenderFn( 'a' )
					brokenFn
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Promise of an Array with two functions and one function that throws an Error', ->
				fns = [
					createAppenderFn( 'a' )
					createAppenderFn( 'b' )
					brokenFn
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Array of functions returns a rejected Promise', ->
			rejectFn = -> Deft.Deferred.reject( new Error( 'Error message' ) )
			
			specify( 'Array with one function that returns a rejected Promise', ->
				fns = [
					rejectFn
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with one function and one function that returns a rejected Promise', ->
				fns = [
					createAppenderFn( 'a' )
					rejectFn
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with two functions and one function that returns a rejected Promise', ->
				fns = [
					createAppenderFn( 'a' )
					createAppenderFn( 'b' )
					rejectFn
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the specified Promise of an Array of functions returns a rejected Promise', ->
			rejectFn = -> Deft.Deferred.reject( new Error( 'Error message' ) )
			
			specify( 'Array with one function that returns a rejected Promise', ->
				fns = [
					rejectFn
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with one function and one function that returns a rejected Promise', ->
				fns = [
					createAppenderFn( 'a' )
					rejectFn
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			specify( 'Array with two functions and one function that returns a rejected Promise', ->
				fns = [
					createAppenderFn( 'a' )
					createAppenderFn( 'b' )
					rejectFn
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Error message' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the items in the specified Array is not a function', ->
			specify( 'Array with one non-function value', ->
				fns = [
					1
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Array with one function and one non-function value', ->
				fns = [
					createAppenderFn( 'a' )
					1
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Array with two functions and one non-function value', ->
				fns = [
					createAppenderFn( 'a' )
					createAppenderFn( 'b' )
					1
				]
				
				promise = Deft.Chain.pipeline( fns )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			return
		)
		
		describe( 'returns a new Promise that will reject with the associated Error if any of the items in the specified resolved Promise of an Array is not a function ', ->
			specify( 'Promise of an Array with one non-function value', ->
				fns = [
					1
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Promise of an Array with one function and one non-function value', ->
				fns = [
					createAppenderFn( 'a' )
					1
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			specify( 'Promise of an Array with two functions and one non-function value', ->
				fns = [
					createAppenderFn( 'a' )
					createAppenderFn( 'b' )
					1
				]
				
				promise = Deft.Chain.pipeline( Deft.Deferred.resolve( fns ) )
				
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Invalid parameter: expected a function.' )
			)
			
			return
		)
		
		describe( 'throws an Error if anything other than Array or Promise of an Array is specified as the first parameter', ->
			specify( 'No parameters', ->
				expect( -> Deft.Chain.pipeline() ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)
			
			specify( 'A non-Array parameter', ->
				expect( -> Deft.Chain.pipeline( 1 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)
			
			return
		)
		
		return
	)
	
	return
)