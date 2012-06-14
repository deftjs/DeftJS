###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.promise.Promise
###
describe( 'Deft.promise.Promise', ->
	
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
					return
			resolve: ( value ) ->
				@successCallback( value )
			reject: ( value ) ->
				@failureCallback( value )
		
		beforeEach( ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			
			successCallback  = jasmine.createSpy( 'success callback' )
			failureCallback  = jasmine.createSpy( 'failure callback' )
			progressCallback = jasmine.createSpy( 'progress callback' )
			cancelCallback   = jasmine.createSpy( 'cancel callback' )
			
			return
		)
		
		it( 'should return an immediately resolved Promise when a value specified', ->
			promise = 
				Deft.promise.Promise.when( 'expected result' )
					.then( 
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'resolved' )
			
			expect( successCallback ).toHaveBeenCalledWith( 'expected result' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should return a new resolved Promise when a resolved Promise is specified', ->
			deferred.resolve( 'expected result' )
		
			promise = 
				Deft.promise.Promise.when( deferred.getPromise() )
					.then(
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'resolved' )
			expect( promise ).not.toBe( deferred.getPromise() )
			expect( successCallback ).toHaveBeenCalledWith( 'expected result' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should return a new rejected Promise when a rejected Promise is specified', ->
			deferred.reject( 'error message' )
			
			promise = 
				Deft.promise.Promise.when( deferred.getPromise() )
					.then(
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'rejected' )
			expect( promise ).not.toBe( deferred.getPromise() )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should return a new pending (and immediately updated) Promise when a pending (and updated) Promise is specified', ->
			deferred.update( 'progress' )
			
			promise = 
				Deft.promise.Promise.when( deferred.getPromise() )
					.then(
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			expect( promise ).not.toBe( deferred.getPromise() )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should return a new cancelled Promise when a cancelled Promise specified', ->
			deferred.cancel( 'reason' )
			
			promise = 
				Deft.promise.Promise.when( deferred.getPromise() )
					.then(
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'cancelled' )
			expect( promise ).not.toBe( deferred.getPromise() )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
		)
		
		it( 'should return a new pending Promise that resolves when the pending Promise specified is resolved', ->
			promise = 
				Deft.promise.Promise.when( deferred.getPromise() )
					.then(
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			deferred.resolve( 'expected result' )
			
			expect( promise.getState() ).toBe( 'resolved' )
			expect( successCallback ).toHaveBeenCalledWith( 'expected result' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
	
		it( 'should return a new pending Promise that rejects when the pending Promise specified is rejected', ->
			promise = 
				Deft.promise.Promise.when( deferred.getPromise() )
					.then(
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
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
		)
	
		it( 'should return a new pending Promise that updates when the pending Promise specified is updated', ->
			promise = 
				Deft.promise.Promise.when( deferred.getPromise() )
					.then(
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
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
		)
	
		it( 'should return a new pending Promise that cancels when the pending Promise specified is cancelled', ->
			promise = 
				Deft.promise.Promise.when( deferred.getPromise() )
					.then(
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			expect( promise ).not.toBe( deferred.getPromise() )
			
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
		)
		
		it( 'should return a new Promise wrapper that resolves when the specified untrusted Promise is resolved', ->
			fakePromise = new MockThirdPartyPromise()
			
			promise = 
				Deft.promise.Promise.when( fakePromise )
					.then(
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			expect( promise ).not.toBe( fakePromise )
			
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			fakePromise.resolve( 'expected value' )
			
			expect( promise.getState() ).toBe( 'resolved' )
			expect( successCallback ).toHaveBeenCalledWith( 'expected value' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should return a new Promise wrapper that rejects when the specified untrusted Promise is rejected', ->
			fakePromise = new MockThirdPartyPromise()
			
			promise = 
				Deft.promise.Promise.when( fakePromise )
					.then(
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'pending' )
			expect( promise ).not.toBe( fakePromise )
			
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
			
			fakePromise.reject( 'error message' )
			
			expect( promise.getState() ).toBe( 'rejected' )
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
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
		
		it( 'should return an immediately resolved Promise when an Array with a single value is specified', ->
			promise = 
				Deft.promise.Promise.all( [ 'expected result' ] )
					.then( 
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			expect( promise ).toBeInstanceOf( 'Deft.promise.Promise' )
			expect( promise.getState() ).toBe( 'resolved' )
			
			expect( successCallback ).toHaveBeenCalledWith( [ 'expected result' ] )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		# TODO
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