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
	
	wasSpyCalled = ( spy ) ->
		return spy.callCount != 0
	
	wasSpyCalledWith = ( spy, value ) ->
		return jasmine.getEnv().contains_( spy.argsForCall, [ value ] )
	
	beforeEach( ->
		@addMatchers(
			toBeInstanceOf: ( className ) ->
				return @actual instanceof Ext.ClassManager.get( className )
			
			toResolveWith: ( value ) ->
				successCallback  = jasmine.createSpy( 'success callback' )
				failureCallback  = jasmine.createSpy( 'failure callback' )
				progressCallback = jasmine.createSpy( 'progress callback' )
				cancelCallback   = jasmine.createSpy( 'cancel callback' )
				
				@actual.then(
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				return @actual.getState() is 'resolved' and wasSpyCalledWith( successCallback, value ) and not wasSpyCalled( failureCallback ) and not wasSpyCalled( progressCallback ) and not wasSpyCalled( cancelCallback )
			
			toRejectWith: ( message ) ->
				successCallback  = jasmine.createSpy( 'success callback' )
				failureCallback  = jasmine.createSpy( 'failure callback' )
				progressCallback = jasmine.createSpy( 'progress callback' )
				cancelCallback   = jasmine.createSpy( 'cancel callback' )
				
				@actual.then(
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				return @actual.getState() is 'rejected' and not wasSpyCalled( successCallback ) and wasSpyCalledWith( failureCallback, message ) and not wasSpyCalled( progressCallback ) and not wasSpyCalled( cancelCallback )
			
			toUpdateWith: ( progress ) ->
				successCallback  = jasmine.createSpy( 'success callback' )
				failureCallback  = jasmine.createSpy( 'failure callback' )
				progressCallback = jasmine.createSpy( 'progress callback' )
				cancelCallback   = jasmine.createSpy( 'cancel callback' )
					
				@actual.then(
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				return @actual.getState() is 'pending' and not wasSpyCalled( successCallback ) and not wasSpyCalled( failureCallback ) and wasSpyCalledWith( progressCallback, progress ) and not wasSpyCalled( cancelCallback )
			
			toCancelWith: ( reason ) ->
				successCallback  = jasmine.createSpy( 'success callback' )
				failureCallback  = jasmine.createSpy( 'failure callback' )
				progressCallback = jasmine.createSpy( 'progress callback' )
				cancelCallback   = jasmine.createSpy( 'cancel callback' )
				
				@actual.then(
					success: successCallback
					failure: failureCallback
					progress: progressCallback
					cancel: cancelCallback
				)
				
				return @actual.getState() is 'cancelled' and not wasSpyCalled( successCallback ) and not wasSpyCalled( failureCallback ) and not wasSpyCalled( progressCallback, reason ) and wasSpyCalledWith( cancelCallback, reason )
		)
		
		return
	)
	
	describe( 'when()', ->
		
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
		
		it( 'should return an immediately resolved Promise when a value specified', ->
			promise = Deft.promise.Promise.when( 'expected value' )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).toResolveWith( 'expected value' )
			
			return
		)
		
		it( 'should return a new resolved Promise when a resolved Promise is specified', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			deferred.resolve( 'expected value' )
			
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).toResolveWith( 'expected value' )
			
			return
		)
		
		it( 'should return a new rejected Promise when a rejected Promise is specified', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			deferred.reject( 'error message' )
			
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).toRejectWith( 'error message' )
			
			return
		)
		
		it( 'should return a new pending (and immediately updated) Promise when a pending (and updated) Promise is specified', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			deferred.update( 'progress' )
			
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).toUpdateWith( 'progress' )
			
			return
		)
		
		it( 'should return a new cancelled Promise when a cancelled Promise specified', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			deferred.cancel( 'reason' )
			
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).toCancelWith( 'reason' )
			
			return
		)
		
		it( 'should return a new pending Promise that resolves when the pending Promise specified is resolved', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			
			deferred.resolve( 'expected value' ) 
			
			expect( promise ).toResolveWith( 'expected value' )
			
			return
		)
	
		it( 'should return a new pending Promise that rejects when the pending Promise specified is rejected', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			
			deferred.reject( 'error message' )
			
			expect( promise ).toRejectWith( 'error message' )
			
			return
		)
	
		it( 'should return a new pending Promise that updates when the pending Promise specified is updated', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			
			deferred.update( 'progress' )
			
			expect( promise ).toUpdateWith( 'progress' )
			
			return
		)
	
		it( 'should return a new pending Promise that cancels when the pending Promise specified is cancelled', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			promise = Deft.promise.Promise.when( deferred.getPromise() )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			
			deferred.cancel( 'reason' )
			
			expect( promise ).toCancelWith( 'reason' )
			
			return
		)
		
		it( 'should return a new resolved Promise when a resolved untrusted Promise is specified', ->
			mockThirdPartyPromise = new MockThirdPartyPromise()
			mockThirdPartyPromise.resolve( 'expected value' )
			
			promise = Deft.promise.Promise.when( mockThirdPartyPromise )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( mockThirdPartyPromise )
			expect( promise ).toResolveWith( 'expected value' )
			
			return
		)
		
		it( 'should return a new rejected Promise when a rejected untrusted Promise is specified', ->
			mockThirdPartyPromise = new MockThirdPartyPromise()
			mockThirdPartyPromise.reject( 'error message' )
			
			promise = Deft.promise.Promise.when( mockThirdPartyPromise )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).not.toBe( mockThirdPartyPromise )
			expect( promise ).toRejectWith( 'error message' )
			
			return
		)
		
		it( 'should return a new Promise that resolves when the specified untrusted Promise is resolved', ->
			mockThirdPartyPromise = new MockThirdPartyPromise()
			
			promise = Deft.promise.Promise.when( mockThirdPartyPromise )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			expect( promise ).not.toBe( mockThirdPartyPromise )
			
			mockThirdPartyPromise.resolve( 'expected value' )
			
			expect( promise ).toResolveWith( 'expected value' )
			
			return
		)
		
		it( 'should return a new Promise that rejects when the specified untrusted Promise is rejected', ->
			mockThirdPartyPromise = new MockThirdPartyPromise()
			
			promise = Deft.promise.Promise.when( mockThirdPartyPromise )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			expect( promise ).not.toBe( mockThirdPartyPromise )
			
			mockThirdPartyPromise.reject( 'error message' )
			
			expect( promise ).toRejectWith( 'error message' )
			
			return
		)
	)
	
	describe( 'all()', ->
		
		describe( 'with an Array containing a single value', ->
			itShouldResolveForValue = ( value ) ->
				it( "should return an immediately resolved Promise when an Array containing '#{ value }' is specified", ->
					promise = Deft.promise.Promise.all( [ value ] )
					
					expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
					expect( promise ).toResolveWith( [ value ] )
					
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
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toResolveWith( [ 'expected value' ] )
				
				return
			)
			
			it( 'should return a rejected Promise completed with the originating error when an Array containing a single rejected Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.reject( 'error message' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a pending (and immediately updated) Promise when an Array containing a single pending (and updated) Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.update( 'progress' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a cancelled Promise completed with the originating reason when an Array containing a single cancelled Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.cancel( 'reason' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toCancelWith( 'reason' )
				
				return
			)
			
			it( 'should return a Promise that resolves when an Array containing a single Deferred is specified and that Deferred is resolved', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.resolve( 'expected value' )
				
				expect( promise ).toResolveWith( [ 'expected value' ] )
				
				return
			)
			
			it( 'should return a Promise that rejects when an Array containing a single Deferred is specified and that Deferred is rejected', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.reject( 'error message' )
				
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a Promise that updates when an Array containing a single Deferred is specified and that Deferred is updated', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.update( 'progress' )
				
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a Promise that cancels when an Array containing a single Deferred is specified and that Deferred is cancelled', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.cancel( 'reason' )
				
				expect( promise ).toCancelWith( 'reason' )
				
				return
			)
		)
		
		describe( 'with an Array containing a single Promise', ->
			
			it( 'should return a resolved Promise when an Array containing a single resolved Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.resolve( 'expected value' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toResolveWith( [ 'expected value' ] )
				
				return
			)
			
			it( 'should return a rejected Promise completed with the originating error when an Array containing a single rejected Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.reject( 'error message' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a pending (and immediately updated) Promise when an Array containing a single pending (and updated) Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.update( 'progress' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a cancelled Promise completed with the originating reason when an Array containing a single cancelled Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.cancel( 'reason' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toCancelWith( 'reason' )
				
				return
			)
			
			it( 'should return a Promise that resolves when an Array containing a single Promise is specified and that Promise is resolved', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.resolve( 'expected value' )
				
				expect( promise ).toResolveWith( [ 'expected value' ] )
				
				return
			)
			
			it( 'should return a Promise that rejects when an Array containing a single Promise is specified and that Promise is rejected', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.reject( 'error message' )
				
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a Promise that updates when an Array containing a single Promise is specified and that Promise is updated', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.update( 'progress' )
				
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a Promise that cancels when an Array containing a single Promise is specified and that Promise is cancelled', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.all( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.cancel( 'reason' )
				
				expect( promise ).toCancelWith( 'reason' )
				
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
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toResolveWith( getOutputParameters( permutation ) )
				
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
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toRejectWith( 'error message' )
				
				rejectedPromiseParameter =
					input: rejectedDeferred.getPromise()
					output: 'error message'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( rejectedPromiseParameter ) )
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toRejectWith( 'error message' )
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
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toUpdateWith( 'progress' )
				
				updatedPromiseParameter =
					input: updatedDeferred.getPromise()
					output: 'progress'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( updatedPromiseParameter ) )
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toUpdateWith( 'progress' )
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
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toCancelWith( 'reason' )
				
				cancelledPromiseParameter =
					input: cancelledDeferred.getPromise()
					output: 'reason'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( cancelledPromiseParameter ) )
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toCancelWith( 'reason' )
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
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.resolve( 'expected value' )
						
						expect( promise ).toResolveWith( getOutputParameters( permutation ) )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 'expected value'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.resolve( 'expected value' )
						
						expect( promise ).toResolveWith( getOutputParameters( permutation ) )
				
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
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.reject( 'error message' )
						
						expect( promise ).toRejectWith( 'error message' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 'error message'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.reject( 'error message' )
						
						expect( promise ).toRejectWith( 'error message' )
				
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
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.update( 'progress' )
						
						expect( promise ).toUpdateWith( 'progress' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 'error message'
							
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.update( 'progress' )
						
						expect( promise ).toUpdateWith( 'progress' )
				
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
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.cancel( 'reason' )
						
						expect( promise ).toCancelWith( 'reason' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 'error message'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
						promise = Deft.promise.Promise.all( getInputParameters( permutation ) )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.cancel( 'reason' )
						
						expect( promise ).toCancelWith( 'reason' )
				
				return
			)
			
			return
		)
		
		return
	)
	
	describe( 'any()', ->
		
		describe( 'with an Array containing a single value', ->
			itShouldResolveForValue = ( value ) ->
				it( "should return an immediately resolved Promise when an Array containing '#{ value }' is specified", ->
					promise = Deft.promise.Promise.any( [ value ] )
					
					expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
					expect( promise ).toResolveWith( value )
					
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
				
				promise = Deft.promise.Promise.any( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toResolveWith( 'expected value' )
				
				return
			)
			
			it( 'should return a rejected Promise completed with the originating error when an Array containing a single rejected Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.reject( 'error message' )
				
				promise = Deft.promise.Promise.any( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a pending (and immediately updated) Promise when an Array containing a single pending (and updated) Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.update( 'progress' )
				
				promise = Deft.promise.Promise.any( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a cancelled Promise completed with the originating reason when an Array containing a single cancelled Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.cancel( 'reason' )
				
				promise = Deft.promise.Promise.any( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toCancelWith( 'reason' )
				
				return
			)
			
			it( 'should return a Promise that resolves when an Array containing a single Deferred is specified and that Deferred is resolved', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.any( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.resolve( 'expected value' )
				
				expect( promise ).toResolveWith( 'expected value' )
				
				return
			)
			
			it( 'should return a Promise that rejects when an Array containing a single Deferred is specified and that Deferred is rejected', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.any( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.reject( 'error message' )
				
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a Promise that updates when an Array containing a single Deferred is specified and that Deferred is updated', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.any( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.update( 'progress' )
				
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a Promise that cancels when an Array containing a single Deferred is specified and that Deferred is cancelled', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.any( [ deferred ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.cancel( 'reason' )
				
				expect( promise ).toCancelWith( 'reason' )
				
				return
			)
		)
		
		describe( 'with an Array containing a single Promise', ->
			
			it( 'should return a resolved Promise when an Array containing a single resolved Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.resolve( 'expected value' )
				
				promise = Deft.promise.Promise.any( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toResolveWith( 'expected value' )
				
				return
			)
			
			it( 'should return a rejected Promise completed with the originating error when an Array containing a single rejected Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.reject( 'error message' )
				
				promise = Deft.promise.Promise.any( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a pending (and immediately updated) Promise when an Array containing a single pending (and updated) Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.update( 'progress' )
				
				promise = Deft.promise.Promise.any( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a cancelled Promise completed with the originating reason when an Array containing a single cancelled Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.cancel( 'reason' )
				
				promise = Deft.promise.Promise.any( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toCancelWith( 'reason' )
				
				return
			)
			
			it( 'should return a Promise that resolves when an Array containing a single Promise is specified and that Promise is resolved', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.any( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.resolve( 'expected value' )
				
				expect( promise ).toResolveWith( 'expected value' )
				
				return
			)
			
			it( 'should return a Promise that rejects when an Array containing a single Promise is specified and that Promise is rejected', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.any( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.reject( 'error message' )
				
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a Promise that updates when an Array containing a single Promise is specified and that Promise is updated', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.any( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.update( 'progress' )
				
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a Promise that cancels when an Array containing a single Promise is specified and that Promise is cancelled', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.any( [ deferred.getPromise() ] )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.cancel( 'reason' )
				
				expect( promise ).toCancelWith( 'reason' )
				
				return
			)
			
			return
		)
		
		describe( 'with multiple items specified', ->
			
			it( 'should return a resolved Promise when an Array containing any combination of pending Deferreds and/or pending Promises and a resolved Deferred or Promise is specified', ->
				parameters = [ Ext.create( 'Deft.promise.Deferred' ), Ext.create( 'Deft.promise.Deferred' ).getPromise() ]
				resolvedDeferred = Ext.create( 'Deft.promise.Deferred' )
				resolvedDeferred.resolve( 'expected result' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( resolvedDeferred ) )
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toResolveWith( 'expected result' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( resolvedDeferred.getPromise() ) )
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toResolveWith( 'expected result' )
						
				return
			)
			
			it( 'should return a rejected Promise when an Array containing any combination of pending Deferreds, and/or pending Promises, and a rejected Deferred or Promise is specified', ->
				parameters = [ Ext.create( 'Deft.promise.Deferred' ), Ext.create( 'Deft.promise.Deferred' ).getPromise() ]
				rejectedDeferred = Ext.create( 'Deft.promise.Deferred' )
				rejectedDeferred.reject( 'error message' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( rejectedDeferred ) )
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toRejectWith( 'error message' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( rejectedDeferred.getPromise() ) )
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toRejectWith( 'error message' )
			)
			
			it( 'should return a pending (and immediately updated) Promise when an Array containing any combination of pending Deferreds, and/or pending Promises, and pending (and updated) Deferred or Promise is specified', ->
				parameters = [ Ext.create( 'Deft.promise.Deferred' ), Ext.create( 'Deft.promise.Deferred' ).getPromise() ]
				updatedDeferred = Ext.create( 'Deft.promise.Deferred' )
				updatedDeferred.update( 'progress' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( updatedDeferred ) )
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toUpdateWith( 'progress' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( updatedDeferred.getPromise() ) )
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toUpdateWith( 'progress' )
			)
			
			it( 'should return a cancelled Promise when an Array containing any combination of pending Deferreds, and/or pending Promises, and a cancelled Deferred or Promise is specified', ->
				parameters = [ Ext.create( 'Deft.promise.Deferred' ), Ext.create( 'Deft.promise.Deferred' ).getPromise() ]
				cancelledDeferred = Ext.create( 'Deft.promise.Deferred' )
				cancelledDeferred.cancel( 'reason' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( cancelledDeferred ) )
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toCancelWith( 'reason' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( cancelledDeferred.getPromise() ) )
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toCancelWith( 'reason' )
			)
			
			it( 'should return a resolved Promise when an Array containing any combination of pending Deferreds and/or pending Promises, and a pending Deferred or Promise is specified that is later resolved', ->
				parameters = [ Ext.create( 'Deft.promise.Deferred' ), Ext.create( 'Deft.promise.Deferred' ).getPromise() ]
				placeholder = {}
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferred
						
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.resolve( 'expected value' )
						
						expect( promise ).toResolveWith( 'expected value' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferred.getPromise()
						
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.resolve( 'expected value' )
						
						expect( promise ).toResolveWith( 'expected value' )
				
				return
			)
			
			it( 'should return a rejected Promise when an Array containing any combination of pending Deferreds and/or pending Promises, and a pending Deferred or Promise is specified that is later rejected', ->
				parameters = [ Ext.create( 'Deft.promise.Deferred' ), Ext.create( 'Deft.promise.Deferred' ).getPromise() ]
				placeholder = {}
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferred
						
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.reject( 'error message' )
						
						expect( promise ).toRejectWith( 'error message' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferred.getPromise()
						
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.reject( 'error message' )
						
						expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a pending (and later updated) when an Array containing any combination of pending Deferreds and/or pending Promises, and a pending Deferred or Promise is specified that is later updated', ->
				parameters = [ Ext.create( 'Deft.promise.Deferred' ), Ext.create( 'Deft.promise.Deferred' ).getPromise() ]
				placeholder = {}
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferred
						
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.update( 'progress' )
						
						expect( promise ).toUpdateWith( 'progress' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferred.getPromise()
						
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.update( 'progress' )
						
						expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a cancelled Promise when an Array containing any combination of pending Deferreds and/or pending Promises, and a pending Deferred or Promise is specified that is later cancelled', ->
				parameters = [ Ext.create( 'Deft.promise.Deferred' ), Ext.create( 'Deft.promise.Deferred' ).getPromise() ]
				placeholder = {}
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferred
						
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.cancel( 'reason' )
						
						expect( promise ).toCancelWith( 'reason' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferred.getPromise()
						
						promise = Deft.promise.Promise.any( permutation )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.cancel( 'reason' )
						
						expect( promise ).toCancelWith( 'reason' )
				
				return
			)
			
			return
		)
		
		return
	)
	
	describe( 'memoize()', ->
		
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
				
				promise = memoFunction( 12 )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).toHaveBeenCalled()
				
				targetFunction.reset()
				
				promise = memoFunction( 12 )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a resolved Promise when the input is a resolved Deferred or Promise', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				resolvedDeferred = new Ext.create( 'Deft.promise.Deferred' )
				resolvedDeferred.resolve( 12 )
				
				promise = memoFunction( resolvedDeferred )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).toHaveBeenCalled()
				
				targetFunction.reset()
				
				promise = memoFunction( resolvedDeferred )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				promise = memoFunction( 12 )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				resolvedPromise = resolvedDeferred.getPromise()
				
				promise = memoFunction( resolvedPromise )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).toHaveBeenCalled()
				
				targetFunction.reset()
				
				resolvedPromise = resolvedDeferred.getPromise()
				
				promise = memoFunction( resolvedPromise )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				promise = memoFunction( 12 )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a rejected Promise when the input is a rejected Deferred or Promise', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				rejectedDeferred = new Ext.create( 'Deft.promise.Deferred' )
				rejectedDeferred.reject( 'error message' )
				
				promise = memoFunction( rejectedDeferred )
				
				expect( promise ).toRejectWith( 'error message' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				rejectedPromise = rejectedDeferred.getPromise()
				
				promise = memoFunction( rejectedPromise )
				
				expect( promise ).toRejectWith( 'error message' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a pending (and immediately updated) Promise when the input is a pending (and updated) Deferred or Promise', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingDeferred.update( 'progress' )
				
				promise = memoFunction( pendingDeferred )
				
				expect( promise ).toUpdateWith( 'progress' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingPromise = pendingDeferred.getPromise()
				
				promise = memoFunction( pendingPromise )
				
				expect( promise ).toUpdateWith( 'progress' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a cancelled Promise when the input is a cancelled Deferred or Promise', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				cancelledDeferred = new Ext.create( 'Deft.promise.Deferred' )
				cancelledDeferred.cancel( 'reason' )
				
				promise = memoFunction( cancelledDeferred )
				
				expect( promise ).toCancelWith( 'reason' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				cancelledPromise = cancelledDeferred.getPromise()
				
				promise = memoFunction( cancelledPromise )
				
				expect( promise ).toCancelWith( 'reason' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a pending Promise when the input is a pending Deferred or Promise, and where that pending Promise resolves when the specified Deferred or Promise is resolved', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				
				promise = memoFunction( pendingDeferred )
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.resolve( 12 )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).toHaveBeenCalled()
				
				targetFunction.reset()
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				
				promise = memoFunction( pendingDeferred )
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.resolve( 12 )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingPromise = pendingDeferred.getPromise()
				
				promise = memoFunction( pendingPromise )
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.resolve( 12 )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).toHaveBeenCalled()
				
				targetFunction.reset()
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingPromise = pendingDeferred.getPromise()
				
				promise = memoFunction( pendingPromise )
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.resolve( 12 )
				
				expect( promise ).toResolveWith( fibonacci( 12 ) )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a pending Promise when the input is a pending Deferred or Promise, and where that pending Promise rejects when the specified Deferred or Promise is rejected', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				
				promise = memoFunction( pendingDeferred )
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.reject( 'error message' )
				
				expect( promise ).toRejectWith( 'error message' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingPromise = pendingDeferred.getPromise()
				
				promise = memoFunction( pendingPromise )
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.reject( 'error message' )
				
				expect( promise ).toRejectWith( 'error message' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a pending Promise when the input is a pending Deferred or Promise, and where that pending Promise updates when the specified Deferred or Promise is updated', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				
				promise = memoFunction( pendingDeferred )
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.update( 'progress' )
				
				expect( promise ).toUpdateWith( 'progress' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingPromise = pendingDeferred.getPromise()
				
				promise = memoFunction( pendingPromise )
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.update( 'progress' )
				
				expect( promise ).toUpdateWith( 'progress' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				return
			)
			
			it( 'should return a new function that wraps the specified function and caches the results for previously processed inputs, and returns a pending Promise when the input is a pending Deferred or Promise, and where that pending Promise cancels when the specified Deferred or Promise is cancelled', ->
				targetFunction = createTargetFunction()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				
				promise = memoFunction( pendingDeferred )
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.cancel( 'reason' )
				
				expect( promise ).toCancelWith( 'reason' )
				expect( targetFunction ).not.toHaveBeenCalled()
				
				memoFunction = Deft.promise.Promise.memoize( targetFunction, expectedScope )
				
				pendingDeferred = new Ext.create( 'Deft.promise.Deferred' )
				pendingPromise = pendingDeferred.getPromise()
				
				promise = memoFunction( pendingPromise )
				
				expect( promise.getState() ).toBe( 'pending' )
				
				pendingDeferred.cancel( 'reason' )
				
				expect( promise ).toCancelWith( 'reason' )
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
		
		identityFunction = ( value ) -> value
		
		doubleFunction = ( value ) -> value * 2
		
		getInputParameters = ( parameters ) ->
			inputs = parameter.input for parameter in parameters
		
		getOutputParameters = ( parameters ) ->
			outputs = parameter.output for parameter in parameters
		
		describe( 'with an Array of values specified', ->
			
			it( 'should map input values of any type to corresponding output values using a mapping function', ->
				values = [ undefined, null, false, 0, 1, 'expected value', [], {} ]
				
				promise = Deft.promise.Promise.map( values, identityFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toResolveWith( values )
			)
			
			it( 'should map input values to corresponding output values using a mapping function', ->
				parameters = [
					{
						input: 1
						output: 2
					}
					{
						input: 2
						output: 4
					}
					{
						input: 3
						output: 6
					}
				]
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination )
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toResolveWith( getOutputParameters( permutation ) )
			)
		)
		
		describe( 'with an Array containing a single Deferred', ->
			
			it( 'should return a resolved Promise when an Array containing a single resolved Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.resolve( 1 )
				
				promise = Deft.promise.Promise.map( [ deferred ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toResolveWith( [ 2 ] )
				
				return
			)
			
			it( 'should return a rejected Promise completed with the originating error when an Array containing a single rejected Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.reject( 'error message' )
				
				promise = Deft.promise.Promise.map( [ deferred ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a pending (and immediately updated) Promise when an Array containing a single pending (and updated) Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.update( 'progress' )
				
				promise = Deft.promise.Promise.map( [ deferred ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a cancelled Promise completed with the originating reason when an Array containing a single cancelled Deferred is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.cancel( 'reason' )
				
				promise = Deft.promise.Promise.map( [ deferred ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toCancelWith( 'reason' )
				
				return
			)
			
			it( 'should return a Promise that resolves when an Array containing a single Deferred is specified and that Deferred is resolved', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.map( [ deferred ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.resolve( 1 )
				
				expect( promise ).toResolveWith( [ 2 ] )
				
				return
			)
			
			it( 'should return a Promise that rejects when an Array containing a single Deferred is specified and that Deferred is rejected', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.map( [ deferred ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.reject( 'error message' )
				
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a Promise that updates when an Array containing a single Deferred is specified and that Deferred is updated', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.map( [ deferred ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.update( 'progress' )
				
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a Promise that cancels when an Array containing a single Deferred is specified and that Deferred is cancelled', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.map( [ deferred ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.cancel( 'reason' )
				
				expect( promise ).toCancelWith( 'reason' )
				
				return
			)
		)
		
		describe( 'with an Array containing a single Promise', ->
			
			it( 'should return a resolved Promise when an Array containing a single resolved Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.resolve( 1 )
				
				promise = Deft.promise.Promise.map( [ deferred.getPromise() ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toResolveWith( [ 2 ] )
				
				return
			)
			
			it( 'should return a rejected Promise completed with the originating error when an Array containing a single rejected Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.reject( 'error message' )
				
				promise = Deft.promise.Promise.map( [ deferred.getPromise() ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a pending (and immediately updated) Promise when an Array containing a single pending (and updated) Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.update( 'progress' )
				
				promise = Deft.promise.Promise.map( [ deferred.getPromise() ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a cancelled Promise completed with the originating reason when an Array containing a single cancelled Promise is specified', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				deferred.cancel( 'reason' )
				
				promise = Deft.promise.Promise.map( [ deferred.getPromise() ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise ).toCancelWith( 'reason' )
				
				return
			)
			
			it( 'should return a Promise that resolves when an Array containing a single Promise is specified and that Promise is resolved', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.map( [ deferred.getPromise() ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.resolve( 1 )
				
				expect( promise ).toResolveWith( [ 2 ] )
				
				return
			)
			
			it( 'should return a Promise that rejects when an Array containing a single Promise is specified and that Promise is rejected', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.map( [ deferred.getPromise() ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.reject( 'error message' )
				
				expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a Promise that updates when an Array containing a single Promise is specified and that Promise is updated', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.map( [ deferred.getPromise() ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.update( 'progress' )
				
				expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a Promise that cancels when an Array containing a single Promise is specified and that Promise is cancelled', ->
				deferred = Ext.create( 'Deft.promise.Deferred' )
				
				promise = Deft.promise.Promise.map( [ deferred.getPromise() ], doubleFunction )
				
				expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
				expect( promise.getState() ).toBe( 'pending' )
				
				deferred.cancel( 'reason' )
				
				expect( promise ).toCancelWith( 'reason' )
				
				return
			)
		)
		
		describe( 'with multiple items specified', ->
			
			getInputParameters = ( parameters ) ->
				inputs = parameter.input for parameter in parameters
			
			getOutputParameters = ( parameters ) ->
				outputs = parameter.output for parameter in parameters
			
			it( 'should return a resolved Promise when an Array containing any combination of values, resolved Deferreds and/or resolved Promises is specified', ->
				deferred2 = Ext.create( 'Deft.promise.Deferred' )
				deferred2.resolve( 2 )
				
				deferred3 = Ext.create( 'Deft.promise.Deferred' )
				deferred3.resolve( 3 )
				promise3 = deferred3.getPromise()
				
				parameters = [
					{
						input: 1
						output: 2
					}
					{
						input: deferred2
						output: 4
					}
					{
						input: promise3
						output: 6
					}
				]
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination )
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toResolveWith( getOutputParameters( permutation ) )
				
				return
			)
			
			it( 'should return a rejected Promise when an Array containing any combination of values, resolved Deferreds, and/or resolved Promises, and a rejected Deferred or Promise is specified', ->
				deferred2 = Ext.create( 'Deft.promise.Deferred' )
				deferred2.resolve( 2 )
				
				deferred3 = Ext.create( 'Deft.promise.Deferred' )
				deferred3.resolve( 3 )
				promise3 = deferred3.getPromise()
				
				parameters = [
					{
						input: 1
						output: 2
					}
					{
						input: deferred2
						output: 4
					}
					{
						input: promise3
						output: 6
					}
				]
				
				rejectedDeferred = Ext.create( 'Deft.promise.Deferred' )
				rejectedDeferred.reject( 'error message' )
				
				rejectedDeferredParameter =
					input: rejectedDeferred
					output: 'error message'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( rejectedDeferredParameter ) )
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toRejectWith( 'error message' )
				
				rejectedPromiseParameter =
					input: rejectedDeferred.getPromise()
					output: 'error message'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( rejectedPromiseParameter ) )
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toRejectWith( 'error message' )
			)
			
			it( 'should return a pending (and immediately updated) Promise when an Array containing any combination of values, resolved Deferreds, and/or resolved Promises, and pending (and updated) Deferred or Promise is specified', ->
				deferred2 = Ext.create( 'Deft.promise.Deferred' )
				deferred2.resolve( 2 )
				
				deferred3 = Ext.create( 'Deft.promise.Deferred' )
				deferred3.resolve( 3 )
				promise3 = deferred3.getPromise()
				
				parameters = [
					{
						input: 1
						output: 2
					}
					{
						input: deferred2
						output: 4
					}
					{
						input: promise3
						output: 6
					}
				]
				
				updatedDeferred = Ext.create( 'Deft.promise.Deferred' )
				updatedDeferred.update( 'progress' )
				
				updatedDeferredParameter =
					input: updatedDeferred
					output: 'progress'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( updatedDeferredParameter ) )
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toUpdateWith( 'progress' )
				
				updatedPromiseParameter =
					input: updatedDeferred.getPromise()
					output: 'progress'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( updatedPromiseParameter ) )
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toUpdateWith( 'progress' )
			)
			
			it( 'should return a cancelled Promise when an Array containing any combination of values, resolved Deferreds, and/or resolved Promises, and a cancelled Deferred or Promise is specified', ->
				deferred2 = Ext.create( 'Deft.promise.Deferred' )
				deferred2.resolve( 2 )
				
				deferred3 = Ext.create( 'Deft.promise.Deferred' )
				deferred3.resolve( 3 )
				promise3 = deferred3.getPromise()
				
				parameters = [
					{
						input: 1
						output: 2
					}
					{
						input: deferred2
						output: 4
					}
					{
						input: promise3
						output: 6
					}
				]
				
				cancelledDeferred = Ext.create( 'Deft.promise.Deferred' )
				cancelledDeferred.cancel( 'reason' )
				
				cancelledDeferredParameter =
					input: cancelledDeferred
					output: 'reason'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( cancelledDeferredParameter ) )
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toCancelWith( 'reason' )
				
				cancelledPromiseParameter =
					input: cancelledDeferred.getPromise()
					output: 'reason'
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( cancelledPromiseParameter ) )
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise ).toCancelWith( 'reason' )
			)
			
			it( 'should return a resolved Promise when an Array containing any combination of values, resolved Deferreds and/or resolved Promises, and a pending Deferred or Promise is specified, and that pending Deferred or Promise is resolved', ->
				deferred2 = Ext.create( 'Deft.promise.Deferred' )
				deferred2.resolve( 2 )
				
				deferred3 = Ext.create( 'Deft.promise.Deferred' )
				deferred3.resolve( 3 )
				promise3 = deferred3.getPromise()
				
				parameters = [
					{
						input: 1
						output: 2
					}
					{
						input: deferred2
						output: 4
					}
					{
						input: promise3
						output: 6
					}
				]
				
				placeholder = {}
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingDeferredParameter =
							input: pendingDeferred
							output: 8
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingDeferredParameter
						
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.resolve( 4 )
						
						expect( promise ).toResolveWith( getOutputParameters( permutation ) )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 8
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.resolve( 4 )
						
						expect( promise ).toResolveWith( getOutputParameters( permutation ) )
				
				return
			)
			
			it( 'should return a rejected Promise when an Array containing any combination of values, resolved Deferreds and/or resolved Promises, and a pending Deferred or Promise is specified, and that pending Deferred or Promise is rejected', ->
				deferred2 = Ext.create( 'Deft.promise.Deferred' )
				deferred2.resolve( 2 )
				
				deferred3 = Ext.create( 'Deft.promise.Deferred' )
				deferred3.resolve( 3 )
				promise3 = deferred3.getPromise()
				
				parameters = [
					{
						input: 1
						output: 2
					}
					{
						input: deferred2
						output: 4
					}
					{
						input: promise3
						output: 6
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
						
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.reject( 'error message' )
						
						expect( promise ).toRejectWith( 'error message' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 'error message'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.reject( 'error message' )
						
						expect( promise ).toRejectWith( 'error message' )
				
				return
			)
			
			it( 'should return a pending (and later updated) when an Array containing any combination of values, resolved Deferreds and/or resolved Promises, and a pending Deferred or Promise is specified, and that pending Deferred is updated', ->
				deferred2 = Ext.create( 'Deft.promise.Deferred' )
				deferred2.resolve( 2 )
				
				deferred3 = Ext.create( 'Deft.promise.Deferred' )
				deferred3.resolve( 3 )
				promise3 = deferred3.getPromise()
				
				parameters = [
					{
						input: 1
						output: 2
					}
					{
						input: deferred2
						output: 4
					}
					{
						input: promise3
						output: 6
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
						
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.update( 'progress' )
						
						expect( promise ).toUpdateWith( 'progress' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 'error message'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.update( 'progress' )
						
						expect( promise ).toUpdateWith( 'progress' )
				
				return
			)
			
			it( 'should return a cancelled Promise when an Array containing any combination of values, resolved Deferreds and/or resolved Promises, and a pending Deferred or Promise is specified, and that pending Deferred or Promise is cancelled', ->
				deferred2 = Ext.create( 'Deft.promise.Deferred' )
				deferred2.resolve( 2 )
				
				deferred3 = Ext.create( 'Deft.promise.Deferred' )
				deferred3.resolve( 3 )
				promise3 = deferred3.getPromise()
				
				parameters = [
					{
						input: 1
						output: 2
					}
					{
						input: deferred2
						output: 4
					}
					{
						input: promise3
						output: 6
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
						
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.cancel( 'reason' )
						
						expect( promise ).toCancelWith( 'reason' )
				
				for combination in generateCombinations( parameters )
					for permutation in generatePermutations( combination.concat( placeholder ) )
						pendingDeferred = Ext.create( 'Deft.promise.Deferred' )
						
						pendingPromiseParameter =
							input: pendingDeferred.getPromise()
							output: 'error message'
						
						permutation[ Ext.Array.indexOf( permutation, placeholder ) ] = pendingPromiseParameter
						
						promise = Deft.promise.Promise.map( getInputParameters( permutation ), doubleFunction )
						
						expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
						expect( promise.getState() ).toBe( 'pending' )
						
						pendingDeferred.cancel( 'reason' )
						
						expect( promise ).toCancelWith( 'reason' )
				
				return
			)
			
			return
		)
	)
	
	describe( 'reduce()', ->
		
		sumFunction = ( previousValue, currentValue, index, array ) -> previousValue + currentValue
		
		it( 'should reduce input values to a corresponding output value using a reduce function (with no initial value specified)', ->
			values = [ 0, 1, 2, 3, 4 ]
			
			promise = Deft.promise.Promise.reduce( values, sumFunction )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).toResolveWith( 10 )
		)
		
		it( 'should reduce input values to a corresponding output value using a reduce function (with an initial value specified)', ->
			values = [ 0, 1, 2, 3, 4 ]
			
			promise = Deft.promise.Promise.reduce( values, sumFunction, 10 )
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise ).toResolveWith( 20 )
		)
		
		# TODO: Add tests for reduce function that returns a Promise.
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