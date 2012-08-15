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
				
			values = [ undefined, null, false, 0, 1, 'expected value', [], {} ]
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
			)
			
			it( 'should return a resolved Promise when an Array containing any combination of values, resolved Deferreds and/or resolved Promises, and a pending Deferred or Promise is specified, and that pending Deferred or Promise is resolved', ->
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
				
				placeholder = {}
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingDeferredParameter =
							input: pendingDeferred
							output: 'expected value'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferredParameter
						
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
						
						pendingDeferred.resolve( 'expected value' )
						
						expect( promise.getState() ).toBe( 'resolved' )
						expect( successCallback ).toHaveBeenCalledWith( getOutputParameters( permutation ) )
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).not.toHaveBeenCalled()
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 'expected value'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
						
						pendingDeferred.resolve( 'expected value' )
						
						expect( promise.getState() ).toBe( 'resolved' )
						expect( successCallback ).toHaveBeenCalledWith( getOutputParameters( permutation ) )
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).not.toHaveBeenCalled()
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
				return
			)
			
			it( 'should return a rejected Promise when an Array containing any combination of values, resolved Deferreds and/or resolved Promises, and a pending Deferred or Promise is specified, and that pending Deferred or Promise is rejected', ->
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
				
				placeholder = {}
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingDeferredParameter =
							input: pendingDeferred
							output: 'error message'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferredParameter
						
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
						
						pendingDeferred.reject( 'error message' )
						
						expect( promise.getState() ).toBe( 'rejected' )
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).not.toHaveBeenCalled()
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 'error message'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
						
						pendingDeferred.reject( 'error message' )
						
						expect( promise.getState() ).toBe( 'rejected' )
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).not.toHaveBeenCalled()
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
				return
			)
			
			it( 'should return a pending (and later updated) when an Array containing any combination of values, resolved Deferreds and/or resolved Promises, and a pending Deferred or Promise is specified, and that pending Deferred is updated', ->
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
				
				placeholder = {}
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingDeferredParameter =
							input: pendingDeferred
							output: 'error message'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferredParameter
						
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
						
						pendingDeferred.update( 'progress' )
						
						expect( promise.getState() ).toBe( 'pending' )
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
						expect( cancelCallback ).not.toHaveBeenCalled()
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 'error message'
							
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
						
						pendingDeferred.update( 'progress' )
						
						expect( promise.getState() ).toBe( 'pending' )
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
						expect( cancelCallback ).not.toHaveBeenCalled()
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
				return
			)
			
			it( 'should return a cancelled Promise when an Array containing any combination of values, resolved Deferreds and/or resolved Promises, and a pending Deferred or Promise is specified, and that pending Deferred or Promise is cancelled', ->
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
				
				placeholder = {}
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingDeferredParameter =
							input: pendingDeferred
							output: 'reason'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferredParameter
						
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
						
						pendingDeferred.cancel( 'reason' )
						
						expect( promise.getState() ).toBe( 'cancelled' )
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 'error message'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
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
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
						
						pendingDeferred.cancel( 'reason' )
						
						expect( promise.getState() ).toBe( 'cancelled' )
						expect( successCallback ).not.toHaveBeenCalled()
						expect( failureCallback ).not.toHaveBeenCalled()
						expect( progressCallback ).not.toHaveBeenCalled()
						expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
						
						successCallback.reset()
						failureCallback.reset()
						progressCallback.reset()
						cancelCallback.reset()
				
				return
			)
			
			return
		)
		
		return
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
		
		fibonacci = ( n ) ->
			( if n < 2 then n else fibonacci( n - 1 ) + fibonacci( n - 2 ) )
		
		createSpecsForScope = ( expectedScope ) ->
			
			createTargetFunction = ->
				return jasmine.createSpy( 'target function' ).andCallFake(
					->
						if expectedScope?
							expect( @ ).toBe( expectedScope )
						else
							expect( @ ).toBe( window )
						return fibonacci.apply( @, arguments )
				)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a resolved Promise when the input is a value', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				result = null
				promise = memoFunction( 12 )
				promise.then(
					success: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).toHaveBeenCalled()
				
				targetFunction.reset()
				
				result = null
				promise = memoFunction( 12 )
				promise.then(
					success: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a resolved Promise when the input is a resolved Deferred or Promise', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				resolvedDeferred = new Ext.create( 'Deft.promise.Deferred' )
				resolvedDeferred.resolve( 12 )
				
				result = null
				promise = memoFunction( resolvedDeferred )
				promise.then(
					success:  ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).toHaveBeenCalled()
				
				targetFunction.reset()
				
				result = null
				promise = memoFunction( resolvedDeferred )
				promise.then(
					success: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				result = null
				promise = memoFunction( 12 )
				promise.then(
					success: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				resolvedPromise = resolvedDeferred.getPromise()
				
				result = null
				promise = memoFunction( resolvedPromise )
				promise.then(
					success: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).toHaveBeenCalled()
				
				targetFunction.reset()
				
				resolvedPromise = resolvedDeferred.getPromise()
				
				result = null
				promise = memoFunction( resolvedPromise )
				promise.then(
					success: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				result = null
				promise = memoFunction( 12 )
				promise.then(
					success: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a rejected Promise when the input is a rejected Deferred or Promise', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				rejectedDeferred = new Ext.create( 'Deft.promise.Deferred' )
				rejectedDeferred.reject( 'error message' )
				
				result = null
				promise = memoFunction( rejectedDeferred )
				promise.then(
					failure: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'rejected' )
				expect( result ).toBe( 'error message' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				rejectedPromise = rejectedDeferred.getPromise()
				
				result = null
				promise = memoFunction( rejectedPromise )
				promise.then(
					failure: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'rejected' )
				expect( result ).toBe( 'error message' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a pending (and immediately updated) Promise when the input is a pending (and updated) Deferred or Promise', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingDeferred.update( 'progress' )
				
				result = null
				promise = memoFunction( pendingDeferred )
				promise.then(
					progress: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				expect( result ).toBe( 'progress' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingPromise = pendingDeferred.getPromise()
				
				result = null
				promise = memoFunction( pendingPromise )
				promise.then(
					progress: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				expect( result ).toBe( 'progress' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a cancelled Promise when the input is a cancelled Deferred or Promise', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				cancelledDeferred = new Ext.create( 'Deft.promise.Deferred' )
				cancelledDeferred.cancel( 'reason' )
				
				result = null
				promise = memoFunction( cancelledDeferred )
				promise.then(
					cancel: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'cancelled' )
				expect( result ).toBe( 'reason' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				cancelledPromise = cancelledDeferred.getPromise()
				
				result = null
				promise = memoFunction( cancelledPromise )
				promise.then(
					cancel: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'cancelled' )
				expect( result ).toBe( 'reason' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a pending Promise when the input is a pending Deferred or Promise, and where that pending Promise resolves when the specified Deferred or Promise is resolved', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				
				result = null
				promise = memoFunction( pendingDeferred )
				promise.then(
					( value ) ->
						result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.resolve( 12 )
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).toHaveBeenCalled()
				
				targetFunction.reset()
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				
				result = null
				promise = memoFunction( pendingDeferred )
				promise.then(
					( value ) ->
						result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.resolve( 12 )
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingPromise = pendingDeferred.getPromise()
				
				result = null
				promise = memoFunction( pendingPromise )
				promise.then(
					success: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.resolve( 12 )
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).toHaveBeenCalled()
				
				targetFunction.reset()
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingPromise = pendingDeferred.getPromise()
				
				result = null
				promise = memoFunction( pendingPromise )
				promise.then(
					success: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.resolve( 12 )
				
				expect( promise.getState() ).toBe( 'resolved' )
				expect( result ).toBe( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a pending Promise when the input is a pending Deferred or Promise, and where that pending Promise rejects when the specified Deferred or Promise is rejected', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				
				result = null
				promise = memoFunction( pendingDeferred )
				promise.then(
					failure: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.reject( 'error message' )
				
				expect( promise.getState() ).toBe( 'rejected' )
				expect( result ).toBe( 'error message' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingPromise = pendingDeferred.getPromise()
				
				result = null
				promise = memoFunction( pendingPromise )
				promise.then(
					failure: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.reject( 'error message' )
				
				expect( promise.getState() ).toBe( 'rejected' )
				expect( result ).toBe( 'error message' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a pending Promise when the input is a pending Deferred or Promise, and where that pending Promise updates when the specified Deferred or Promise is updated', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				
				result = null
				promise = memoFunction( pendingDeferred )
				promise.then(
					progress: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.update( 'progress' )
				
				expect( promise.getState() ).toBe( 'pending' )
				expect( result ).toBe( 'progress' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingPromise = pendingDeferred.getPromise()
				
				result = null
				promise = memoFunction( pendingPromise )
				promise.then(
					progress: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.update( 'progress' )
				
				expect( promise.getState() ).toBe( 'pending' )
				expect( result ).toBe( 'progress' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a pending Promise when the input is a pending Deferred or Promise, and where that pending Promise cancels when the specified Deferred or Promise is cancelled', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				
				result = null
				promise = memoFunction( pendingDeferred )
				promise.then(
					cancel: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.cancel( 'reason' )
				
				expect( promise.getState() ).toBe( 'cancelled' )
				expect( result ).toBe( 'reason' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingPromise = pendingDeferred.getPromise()
				
				result = null
				promise = memoFunction( pendingPromise )
				promise.then(
					cancel: ( value ) -> result = value
				)
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.cancel( 'reason' )
				
				expect( promise.getState() ).toBe( 'cancelled' )
				expect( result ).toBe( 'reason' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			return
		
		describe( '(omitting the optional scope and hash function parameters)', ->
			createSpecsForScope()
			
			return
		)
		
		describe( '(specifying the scope to execute the memoized function in via the optional scope parameter)', ->
			expectedScope = {}
			createSpecsForScope( expectedScope )
			
			return
		)
		
		return
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
		
		successCallback = failureCallback = progressCallback = cancelCallback = scope = null
		
		beforeEach( ->
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			scope = {}
			
			return
		)
		
		it( 'should call through to the underlying Deferred\'s then() method with the same specified parameters and return the same result', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			promise = deferred.getPromise()
			
			expectedReturnValue = {}
			spyOn( deferred, 'then' ).andReturn( expectedReturnValue )
			
			expect( promise.then( successCallback, failureCallback, progressCallback, cancelCallback, scope ) ).toBe( expectedReturnValue )
			expect( deferred.then ).toHaveBeenCalledWith( successCallback, failureCallback, progressCallback, cancelCallback, scope )
			
			expect( promise.then( { success: successCallback, failure: failureCallback, progress: progressCallback, cancel: cancelCallback, scope: scope } ) ).toBe( expectedReturnValue )
			expect( deferred.then ).toHaveBeenCalledWith( { success: successCallback, failure: failureCallback, progress: progressCallback, cancel: cancelCallback, scope: scope } )
			
			return
		)
	)
	
	describe( 'otherwise()', ->
		
		otherwiseCallback = scope = null
		
		beforeEach( ->
			otherwiseCallback = jasmine.createSpy( 'otherwise callback' )
			scope = {}
			
			return
		)
		
		it( 'should call through to the underlying Deferred\'s otherwise() method with the same specified parameters and return the same result', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			promise = deferred.getPromise()
			
			expectedReturnValue = {}
			spyOn( deferred, 'otherwise' ).andReturn( expectedReturnValue )
			
			expect( promise.otherwise( otherwiseCallback, scope ) ).toBe( expectedReturnValue )
			expect( deferred.otherwise ).toHaveBeenCalledWith( otherwiseCallback, scope )
			
			expect( promise.otherwise( { fn: otherwiseCallback, scope: scope } ) ).toBe( expectedReturnValue )
			expect( deferred.otherwise ).toHaveBeenCalledWith( { fn: otherwiseCallback, scope: scope } )
			
			return
		)
	)
	
	describe( 'always()', ->
		
		alwaysCallback = scope = null
		
		beforeEach( ->
			alwaysCallback = jasmine.createSpy( 'always callback' )
			scope= {}
			
			return
		)
		
		it( 'should call through to the underlying Deferred\'s otherwise() method with the same specified parameters and return the same result', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			promise = deferred.getPromise()
			
			expectedReturnValue = {}
			spyOn( deferred, 'always' ).andReturn( expectedReturnValue )
			
			expect( promise.always( alwaysCallback, scope ) ).toBe( expectedReturnValue )
			expect( deferred.always ).toHaveBeenCalledWith( alwaysCallback, scope )
			
			expect( promise.always( { fn: alwaysCallback, scope: scope } ) ).toBe( expectedReturnValue )
			expect( deferred.always ).toHaveBeenCalledWith( { fn: alwaysCallback, scope: scope } )
			
			return
		)
	)
	
	describe( 'cancel()', ->
		
		it( 'should call through to the underlying Deferred\'s cancel() method with the same specified parameters and return the same result', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			promise = deferred.getPromise()
			
			expectedReturnValue = {}
			spyOn( deferred, 'cancel' ).andReturn( expectedReturnValue )
			
			expect( promise.cancel( 'reason' ) ).toBe( expectedReturnValue )
			expect( deferred.cancel ).toHaveBeenCalledWith( 'reason' )
			
			return
		)
	)
)