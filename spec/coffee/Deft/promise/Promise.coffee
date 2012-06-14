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
		
		it( 'should return an immediately resolved Promise when an Array containing a single value is specified', ->
			promise = 
				Deft.promise.Promise.all( [ 'expected value' ] )
					.then( 
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
		)
		
		it( 'should return a resolved Promise when an Array containing a single resolved Promise is specified', ->
			deferred = Ext.create( 'Deft.promise.Deferred' )
			deferred.resolve( 'expected value' )
			
			promise = 
				Deft.promise.Promise.all( [ deferred ] )
					.then( 
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
		)
		
		it( 'should return a rejected Promise completed with the originating error when an Array containing a single rejected Promise is specified', ->
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
		)
		
		it( 'should return a pending (and immediately updated) Promise when an Array containing a single pending (and updated) Promise is specified', ->
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
		)
		
		it( 'should return a cancelled Promise completed with the originating reason when an Array containing a single cancelled Promise is specified', ->
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
		)
		
		it( 'should return a Promise that resolves when an Array containing a single Promise is specified and that single Promise is resolved', ->
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
		)
		
		it( 'should return a Promise that rejects when an Array containing a single Promise is specified and that single Promise is rejected', ->
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