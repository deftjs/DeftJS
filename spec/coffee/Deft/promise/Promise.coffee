###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.promise.Promise
###
describe( 'Deft.promise.Promise', ->
	
	generatePermutations = ( array ) ->
		
		swap = ( array, indexA, indexB ) ->
			tmp = array[ indexA ]
			array[ indexA ] = array[ indexB ]
			array[ indexB ] = tmp
			return
			
		_generatePermutations = ( array, buffer, start, end ) ->
			if end - start is 1
				buffer.push( array.concat() )
			else
				range = end - start
				index = 0
				while index < range
					swap( array, start, start + index )
					_generatePermutations( array, buffer, start + 1, end )
					swap( array, start, start + index )
					index++
			return buffer
			
		return _generatePermutations( array.concat(), [], 0, array.length )
		
	generateCombinations = ( array ) ->
		
		_generateCombinations = ( start, array, combination, combinations ) ->
			if start is 0
				if combination.length > 0
					combinations[ combinations.length ] = combination 
				return
			end = 0
			while end < array.length
				_generateCombinations( start - 1, array.slice( end + 1 ), combination.concat( [ array[ end ] ] ), combinations )
				end++
			return
			
		combinations = []
		
		index = 0
		while index < array.length
			_generateCombinations( index, array, [], combinations )
			index++
		combinations.push( array )
		
		return combinations
	
	beforeEach( ->
		@addMatchers(
			toBeInstanceOf: ( className ) ->
				return @actual instanceof Ext.ClassManager.get( className )
		)
		
		return
	)
	
	describe( 'when()', ->
		
		deferred = null
		successCallback = failureCallback = progressCallback = cancelCallback = null
		
		class MockThirdPartyPromise
			then: ( @successCallback, @failureCallback ) ->
				switch @state
					when 'resolved'
						@successCallback( @value )
					when 'rejected'
						@failureCallback( @value )
				return
			resolve: ( @value ) ->
				@state = 'resolved'
				if @successCallback?
					@successCallback( @value )
				return
			reject: ( @value ) ->
				@state = 'rejected'
				if @failureCallback?
					@failureCallback( @value )
				return
		
		beforeEach( ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			
			return
		)
		
		it( 'should return an immediately resolved Promise when a value specified', ->
			promise = Deft.promise.Promise.when( 'expected value' )
			promise.then( 
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )

			expect( promise.getState() ).toBe( 'resolved' )			
			expect( successCallback ).toHaveBeenCalledWith( 'expected value' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			return
		)
		
		it( 'should return a new resolved Promise when a resolved Promise is specified', ->
			deferred.resolve( 'expected value' )
		
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
			expect( promise.getState() ).toBe( 'resolved' )
			expect( successCallback ).toHaveBeenCalledWith( 'expected value' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			return
		)
		
		it( 'should return a new rejected Promise when a rejected Promise is specified', ->
			deferred.reject( 'error message' )
			
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
			expect( promise.getState() ).toBe( 'rejected' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			return
		)
		
		it( 'should return a new pending (and immediately updated) Promise when a pending (and updated) Promise is specified', ->
			deferred.update( 'progress' )
			
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
			expect( promise.getState() ).toBe( 'pending' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			return
		)
		
		it( 'should return a new cancelled Promise when a cancelled Promise specified', ->
			deferred.cancel( 'reason' )
			
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
			expect( promise.getState() ).toBe( 'cancelled' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
			
			return
		)
		
		it( 'should return a new pending Promise that resolves when the pending Promise specified is resolved', ->
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
			expect( promise.getState() ).toBe( 'pending' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			deferred.resolve( 'expected value' )
			
			expect( promise.getState() ).toBe( 'resolved' )
			expect( successCallback ).toHaveBeenCalledWith( 'expected value' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			return
		)
	
		it( 'should return a new pending Promise that rejects when the pending Promise specified is rejected', ->
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
			expect( promise.getState() ).toBe( 'pending' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			deferred.reject( 'error message' )
			
			expect( promise.getState() ).toBe( 'rejected' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			return
		)
	
		it( 'should return a new pending Promise that updates when the pending Promise specified is updated', ->
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
			expect( promise.getState() ).toBe( 'pending' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			deferred.update( 'progress' )
			
			expect( promise.getState() ).toBe( 'pending' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			return
		)
	
		it( 'should return a new pending Promise that cancels when the pending Promise specified is cancelled', ->
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
			expect( promise.getState() ).toBe( 'pending' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			deferred.cancel( 'reason' )
			
			expect( promise.getState() ).toBe( 'cancelled' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
			
			return
		)
		
		it( 'should return a new resolved Promise when a resolved untrusted Promise is specified', ->
			mockThirdPartyPromise = new MockThirdPartyPromise()
			mockThirdPartyPromise.resolve( 'expected value' )
			
			promise = Deft.promise.Promise.when( mockThirdPartyPromise )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( mockThirdPartyPromise )
			
			expect( promise.getState() ).toBe( 'resolved' )
			expect( successCallback ).toHaveBeenCalledWith( 'expected value' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			return
		)
		
		it( 'should return a new rejected Promise when a rejected untrusted Promise is specified', ->
			mockThirdPartyPromise = new MockThirdPartyPromise()
			mockThirdPartyPromise.reject( 'error message' )
			
			promise = Deft.promise.Promise.when( mockThirdPartyPromise )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( mockThirdPartyPromise )
			
			expect( promise.getState() ).toBe( 'rejected' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			return
		)
		
		it( 'should return a new Promise that resolves when the specified untrusted Promise is resolved', ->
			mockThirdPartyPromise = new MockThirdPartyPromise()
			
			promise = Deft.promise.Promise.when( mockThirdPartyPromise )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( mockThirdPartyPromise )
			
			expect( promise.getState() ).toBe( 'pending' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			mockThirdPartyPromise.resolve( 'expected value' )
			
			expect( promise.getState() ).toBe( 'resolved' )
			expect( successCallback ).toHaveBeenCalledWith( 'expected value' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			return
		)
		
		it( 'should return a new Promise that rejects when the specified untrusted Promise is rejected', ->
			mockThirdPartyPromise = new MockThirdPartyPromise()
			
			promise = Deft.promise.Promise.when( mockThirdPartyPromise )
			promise.then(
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( mockThirdPartyPromise )
			
			expect( promise.getState() ).toBe( 'pending' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			mockThirdPartyPromise.reject( 'error message' )
			
			expect( promise.getState() ).toBe( 'rejected' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			return
		)
	)
	
	describe( 'all()', ->
		
		successCallback = failureCallback = progressCallback = cancelCallback = null
		
		beforeEach( ->
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			
			return
		)
		
		describe( 'with an Array containing a single value', ->
			itShouldResolveForValue = ( value ) ->
				it( "should return an immediately resolved Promise when an Array containing '#{ value }' is specified", ->
					promise = Deft.promise.Promise.all( [ 'expected value' ] )
					promise.then( 
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
					
					expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
					expect( promise.getState() ).toBe( 'resolved' )
					
					expect( successCallback ).toHaveBeenCalledWith( [ 'expected value' ] )
					expect( failureCallback ).not.toHaveBeenCalled()
					expect( progressCallback ).not.toHaveBeenCalled()
					expect( cancelCallback ).not.toHaveBeenCalled()
					
					return
				)
				return
				
			values = [ undefined, null, false, 0, 1, 'expected value', [ '[Array]' ], {} ]
			for value in values
				itShouldResolveForValue.call( this, value )
				
			return
		)
		
		describe( 'with an Array containing a single Deferred', ->
			
			it( 'should return a resolved Promise when an Array containing a single resolved Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.resolve( 'expected value' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'resolved' )
				
				expect( successCallback ).toHaveBeenCalledWith( [ 'expected value' ] )
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a rejected Promise completed with the originating error when an Array containing a single rejected Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.reject( 'error message' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'rejected' )
				
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a pending (and immediately updated) Promise when an Array containing a single pending (and updated) Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.update( 'progress' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a cancelled Promise completed with the originating reason when an Array containing a single cancelled Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.cancel( 'reason' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'cancelled' )
				
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
				
				return
			)
			
			it( 'should return a Promise that resolves when an Array containing a single Deferred is specified and that Deferred is resolved', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.resolve( 'expected value' )
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( successCallback ).toHaveBeenCalledWith( [ 'expected value' ] )
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a Promise that rejects when an Array containing a single Deferred is specified and that Deferred is rejected', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.reject( 'error message' )
				
				expect( promise.getState() ).toBe( 'rejected' )
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a Promise that updates when an Array containing a single Deferred is specified and that Deferred is updated', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.update( 'progress' )
				
				expect( promise.getState() ).toBe( 'pending' )
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a Promise that cancels when an Array containing a single Deferred is specified and that Deferred is cancelled', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.cancel( 'reason' )
				
				expect( promise.getState() ).toBe( 'cancelled' )
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
				
				return
			)
		)
		
		describe( 'with an Array containing a single Promise', ->
			
			it( 'should return a resolved Promise when an Array containing a single resolved Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.resolve( 'expected value' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'resolved' )
				
				expect( successCallback ).toHaveBeenCalledWith( [ 'expected value' ] )
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a rejected Promise completed with the originating error when an Array containing a single rejected Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.reject( 'error message' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'rejected' )
				
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a pending (and immediately updated) Promise when an Array containing a single pending (and updated) Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.update( 'progress' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a cancelled Promise completed with the originating reason when an Array containing a single cancelled Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.cancel( 'reason' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'cancelled' )
				
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
				
				return
			)
			
			it( 'should return a Promise that resolves when an Array containing a single Promise is specified and that Promise is resolved', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.resolve( 'expected value' )
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( successCallback ).toHaveBeenCalledWith( [ 'expected value' ] )
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a Promise that rejects when an Array containing a single Promise is specified and that Promise is rejected', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.reject( 'error message' )
				
				expect( promise.getState() ).toBe( 'rejected' )
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a Promise that updates when an Array containing a single Promise is specified and that Promise is updated', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.update( 'progress' )
				
				expect( promise.getState() ).toBe( 'pending' )
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a Promise that cancels when an Array containing a single Promise is specified and that Promise is cancelled', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				promise.then( 
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.cancel( 'reason' )
				
				expect( promise.getState() ).toBe( 'cancelled' )
				expect( successCallback ).not.toHaveBeenCalled()
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
				
				return
			)
		)
		
		describe( 'with multiple items specified', ->
			
			# TODO:
			# values = [ undefined, null, false, 0, 1, 'value', [], {} ]
			# for all combinations of values
			# 	for all permutations of combination + resolved / rejected / cancelled / updated promise
			# 		perform test(s)
			# 	for all permutations of combination + deferred that is later resolved / rejected / cancelled / updated promise
			# 		perform test(s)
			
			getInputParameters = ( parameters ) ->
				inputs = parameter.input for parameter in parameters
			
			getOutputParameters = ( parameters ) ->
				outputs = parameter.output for parameter in parameters
			
			it( 'should return a resolved Promise when an Array containing any combination of values, resolved Deferreds and/or resolved Promises is specified', ->
				deferredB = Ext.create( 'Deft.promise.Deferred' )
				deferredB.resolve( 'B' )
				
				deferredC = Ext.create( 'Deft.promise.Deferred' )
				deferredC.resolve( 'C' )
				promiseC = deferredC.getPromise()
				
				parameters = [
					{
						input: 'A'
						output: 'A'
					}
					{
						input: deferredB
						output: 'B'
					}
					{
						input: promiseC
						output: 'C'
					}
				]
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination )
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						promise.then( 
							success: successCallback
							failure: failureCallback
							progress: progressCallback
							cancel: cancelCallback
						)
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'resolved' )
						
						expect( successCallback ).toHaveBeenCalledWith( getOutputParameters( permutation ) )
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a rejected Promise when an Array containing any combination of values, resolved or pending Deferreds, and/or resolved or pending Promises, and a rejected Deferred or Promise is specified', ->
				deferredB = Ext.create( 'Deft.promise.Deferred' )
				deferredB.resolve( 'B' )
				
				deferredC = Ext.create( 'Deft.promise.Deferred' )
				deferredC.resolve( 'C' )
				promiseC = deferredC.getPromise()
				
				pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
				
				parameters = [
					{
						input: 'A'
						output: 'A'
					}
					{
						input: deferredB
						output: 'B'
					}
					{
						input: promiseC
						output: 'C'
					}
					{
						input: pendingDeferred
					}
					{
						input: pendingDeferred.getPromise()
					}
				]
				
				rejectedDeferred = Ext.create( 'Deft.promise.Deferred' )
				rejectedDeferred.reject( 'error message' )
				
				rejectedDeferredParameter =
					input: rejectedDeferred
					output: 'error message'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( rejectedDeferredParameter ) )
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						promise.then( 
							success: successCallback
							failure: failureCallback
							progress: progressCallback
							cancel: cancelCallback
						)
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'rejected' )
						
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).not.toHaveBeenCalled()
				
				rejectedPromiseParameter =
					input: rejectedDeferred.getPromise()
					output: 'error message'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( rejectedPromiseParameter ) )
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						promise.then( 
							success: successCallback
							failure: failureCallback
							progress: progressCallback
							cancel: cancelCallback
						)
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'rejected' )
						
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).not.toHaveBeenCalled()
			)
			
			it( 'should return a pending (and immediately updated) Promise when an Array containing any combination of values, resolved or pending Deferreds, and/or resolved or pending Promises, and pending (and updated) Deferred or Promise is specified', ->
				deferredB = Ext.create( 'Deft.promise.Deferred' )
				deferredB.resolve( 'B' )
				
				deferredC = Ext.create( 'Deft.promise.Deferred' )
				deferredC.resolve( 'C' )
				promiseC = deferredC.getPromise()
				
				pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
				
				parameters = [
					{
						input: 'A'
						output: 'A'
					}
					{
						input: deferredB
						output: 'B'
					}
					{
						input: promiseC
						output: 'C'
					}
					{
						input: pendingDeferred
					}
					{
						input: pendingDeferred.getPromise()
					}
				]
				
				updatedDeferred = Ext.create( 'Deft.promise.Deferred' )
				updatedDeferred.update( 'progress' )
				
				updatedDeferredParameter =
					input: updatedDeferred
					output: 'progress'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( updatedDeferredParameter ) )
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						promise.then( 
							success: successCallback
							failure: failureCallback
							progress: progressCallback
							cancel: cancelCallback
						)
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
						expect( cancelCallback ).not.toHaveBeenCalled()
						
				updatedPromiseParameter =
					input: updatedDeferred.getPromise()
					output: 'progress'
					
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( updatedPromiseParameter ) )
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						promise.then( 
							success: successCallback
							failure: failureCallback
							progress: progressCallback
							cancel: cancelCallback
						)
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
						expect( cancelCallback ).not.toHaveBeenCalled()
			)
			
			it( 'should return a cancelled Promise when an Array containing any combination of values, resolved or pending Deferreds, and/or resolved or pending Promises, and a cancelled Deferred or Promise is specified', ->
				deferredB = Ext.create( 'Deft.promise.Deferred' )
				deferredB.resolve( 'B' )
				
				deferredC = Ext.create( 'Deft.promise.Deferred' )
				deferredC.resolve( 'C' )
				promiseC = deferredC.getPromise()
				
				pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
				
				parameters = [
					{
						input: 'A'
						output: 'A'
					}
					{
						input: deferredB
						output: 'B'
					}
					{
						input: promiseC
						output: 'C'
					}
					{
						input: pendingDeferred
					}
					{
						input: pendingDeferred.getPromise()
					}
				]
				
				cancelledDeferred = Ext.create( 'Deft.promise.Deferred' )
				cancelledDeferred.cancel( 'reason' )
				
				cancelledDeferredParameter =
					input: cancelledDeferred
					output: 'reason'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( cancelledDeferredParameter ) )
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						promise.then( 
							success: successCallback
							failure: failureCallback
							progress: progressCallback
							cancel: cancelCallback
						)
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'cancelled' )
						
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
				
				cancelledPromiseParameter =
					input: cancelledDeferred.getPromise()
					output: 'reason'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( cancelledPromiseParameter ) )
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						promise.then( 
							success: successCallback
							failure: failureCallback
							progress: progressCallback
							cancel: cancelCallback
						)
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'cancelled' )
						
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
			)
			
			it( 'should return a resolved Promise when an Array containing any combination of values, resolved Deferreds and/or resolved Promises, and a pending Deferred or Promise is specified, and that pending Deferred or Promise is resolved', ->
				deferredB = Ext.create( 'Deft.promise.Deferred' )
				deferredB.resolve( 'B' )
				
				deferredC = Ext.create( 'Deft.promise.Deferred' )
				deferredC.resolve( 'C' )
				promiseC = deferredC.getPromise()
				
				pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
				
				parameters = [
					{
						input: 'A'
						output: 'A'
					}
					{
						input: deferredB
						output: 'B'
					}
					{
						input: promiseC
						output: 'C'
					}
					{
						input: pendingDeferred
					}
					{
						input: pendingDeferred.getPromise()
					}
				]
				
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				deferredParameter =
					input: deferred
					output: 'reason'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( deferredParameter ) )
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						promise.then( 
							success: successCallback
							failure: failureCallback
							progress: progressCallback
							cancel: cancelCallback
						)
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						
						expect( promise.getState() ).toBe( 'pending' )
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).not.toHaveBeenCalled()
				
				deferred.resolve( 'expectedValue' )
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( successCallback ).toHaveBeenCalledWith( getOutputParameters( permutation ) )
				expect( failureCallback ).not.toHaveBeenCalled()
				expect( progressCallback ).not.toHaveBeenCalled()
				expect( cancelCallback ).not.toHaveBeenCalled()
				
				return
			)
		)
	)
	
	describe( 'any()', ->
		
		successCallback = failureCallback = progressCallback = cancelCallback = null
		
		beforeEach( ->
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			
			return
		)
		
		# TODO
	)
	
	describe( 'memoize()', ->
		
		successCallback = failureCallback = progressCallback = cancelCallback = null
		
		beforeEach( ->
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			
			return
		)
		
		# TODO
	)
	
	describe( 'map()', ->
		
		successCallback = failureCallback = progressCallback = cancelCallback = null
		
		beforeEach( ->
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			
			return
		)
		
		# TODO
	)
	
	describe( 'reduce()', ->
		
		successCallback = failureCallback = progressCallback = cancelCallback = null
		
		beforeEach( ->
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			
			return
		)
		
		# TODO
	)
	
	describe( 'then()', ->
		
		successCallback = failureCallback = progressCallback = cancelCallback = null
		
		beforeEach( ->
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			
			return
		)
		
		# TODO
	)
	
	describe( 'otherwise()', ->
		
		successCallback = failureCallback = progressCallback = cancelCallback = null
		
		beforeEach( ->
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			
			return
		)
		
		# TODO
	)
	
	describe( 'always()', ->
		
		successCallback = failureCallback = progressCallback = cancelCallback = null
		
		beforeEach( ->
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			
			return
		)
		
		# TODO
	)
	
	describe( 'cancel()', ->
		
		successCallback = failureCallback = progressCallback = cancelCallback = null
		
		beforeEach( ->
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			
			return
		)
		
		# TODO
	)
)