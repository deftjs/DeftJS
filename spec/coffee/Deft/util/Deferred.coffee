###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.util.Deferred
###
describe( 'Deft.util.Deferred', ->
	
	createSpecsForThen = ( thenFunction ) ->
		
		deferred = null
		successCallback = failureCallback = progressCallback = cancelCallback = null
		
		beforeEach( ->
			deferred = Ext.create( 'Deft.util.Deferred' )
			
			successCallback  = jasmine.createSpy()
			failureCallback  = jasmine.createSpy()
			progressCallback = jasmine.createSpy()
			cancelCallback   = jasmine.createSpy()
		)
		
		it( 'should call success callback when resolved', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.resolve( 'expected result' )
			
			expect( successCallback ).toHaveBeenCalledWith( 'expected result' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should call failure callback when rejected', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.reject( 'error message' )
			
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should call progress callback when updated', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.update( 'progress' )
			
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should call cancel callback when cancelled', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.cancel( 'reason' )
			
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
		)
		
		it( 'should allow resolution after update', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.update( 'progress' )
			deferred.resolve( 'expected result' )
			
			expect( successCallback ).toHaveBeenCalledWith( 'expected result' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should allow rejection after update', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.update( 'progress' )
			deferred.reject( 'error message' )
			
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
			expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should allow cancellation after update', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.update( 'progress' )
			deferred.cancel( 'reason' )
			
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
			expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
		)
		
		it( 'should not allow resolution after resolution', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.resolve( 'expected result' )
			
			expect( ->
				deferred.resolve( 'expected result' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should not allow rejection after resolution', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.resolve( 'expected result' )
			
			expect( ->
				deferred.reject( 'error message' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should not allow update after resolution', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.resolve( 'expected result' )
			
			expect( ->
				deferred.update( 'progress' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should not allow cancellation after resolution', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.resolve( 'expected result' )
			
			expect( ->
				deferred.cancel( 'reason' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should not allow resolution after rejection', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.reject( 'error message' )
			
			expect( ->
				deferred.resolve( 'expected result' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should not allow rejection after rejection', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.reject( 'error message' )
			
			expect( ->
				deferred.reject( 'error message' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should not allow update after rejection', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.reject( 'error message' )
			
			expect( ->
				deferred.update( 'progress' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should not allow cancellation after rejection', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.reject( 'error message' )
			
			expect( ->
				deferred.cancel( 'reason' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should not allow resolution after cancellation', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.cancel( 'reason' )
			
			expect( ->
				deferred.resolve( 'expected result' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should not allow rejection after cancellation', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.cancel( 'reason' )
			
			expect( ->
				deferred.reject( 'error message' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should not allow update after cancellation', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.cancel( 'reason' )
			
			expect( ->
				deferred.update( 'progress' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should not allow cancellation after cancellation', ->
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			deferred.cancel( 'reason' )
			
			expect( ->
				deferred.cancel( 'reason' ) 
			).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
		)
		
		it( 'should immediately call newly success callback when already resolved', ->
			deferred.resolve( 'expected result' )
			
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			expect( successCallback ).toHaveBeenCalledWith( 'expected result' )
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should immediately call newly failure callback when already rejected', ->
			deferred.reject( 'error message' )
			
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).toHaveBeenCalledWith( 'error message' )
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should immediately call newly added progress callback when already updated', ->
			deferred.update( 'progress' )
			
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).toHaveBeenCalledWith( 'progress' )
			expect( cancelCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should immediately call newly added cancel callback when already cancelled', ->
			deferred.cancel( 'reason' )
			
			thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
			
			expect( successCallback ).not.toHaveBeenCalled()
			expect( failureCallback ).not.toHaveBeenCalled()
			expect( progressCallback ).not.toHaveBeenCalled()
			expect( cancelCallback ).toHaveBeenCalledWith( 'reason' )
		)
		
		return
		
	describe( 'then() with callbacks specified via method parameters', ->
		
		createSpecsForThen( ( deferred, successCallback, failureCallback, progressCallback, cancelCallback )->
			deferred.then( successCallback, failureCallback, progressCallback, cancelCallback )
		)
	)
	
	describe( 'then() with callbacks specified via configuration Object', ->
		
		createSpecsForThen( ( deferred, successCallback, failureCallback, progressCallback, cancelCallback )->
			deferred.then( 
				success: successCallback
				failure: failureCallback
				progress: progressCallback
				cancel: cancelCallback
			)
		)
	)
	
	describe( 'always()', ->
		
		deferred = null
		alwaysCallback = null
		
		beforeEach( ->
			deferred = Ext.create( 'Deft.util.Deferred' )
			
			alwaysCallback  = jasmine.createSpy()
		)
		
		it( 'should call always callback when resolved', ->
			deferred.always( alwaysCallback )
			
			deferred.resolve( 'expected value' )
			
			expect( alwaysCallback ).toHaveBeenCalled()
		)
		
		it( 'should call always callback when rejected', ->
			deferred.always( alwaysCallback )
			
			deferred.reject( 'error message' )
			
			expect( alwaysCallback ).toHaveBeenCalled()
		)
		
		it( 'should not call always callback when updated', ->
			deferred.always( alwaysCallback )
			
			deferred.update( 'progress' )
			
			expect( alwaysCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should call always callback when cancelled', ->
			deferred.always( alwaysCallback )
			
			deferred.cancel( 'reason' )
			
			expect( alwaysCallback ).toHaveBeenCalled()
		)
		
		it( 'should immediately call always callback when already resolved', ->
			deferred.resolve( 'expected value' )
			
			deferred.always( alwaysCallback )
			
			expect( alwaysCallback ).toHaveBeenCalled()
		)
		
		it( 'should immediately call always callback when already rejected', ->
			deferred.reject( 'error message' )
			
			deferred.always( alwaysCallback )
			
			expect( alwaysCallback ).toHaveBeenCalled()
		)
		
		it( 'should not immediately call always callback when already updated', ->
			deferred.update( 'progress' )
			
			deferred.always( alwaysCallback )
			
			expect( alwaysCallback ).not.toHaveBeenCalled()
		)
		
		it( 'should immediately call always callback when already cancelled', ->
			deferred.cancel( 'reason' )
			
			deferred.always( alwaysCallback )
			
			expect( alwaysCallback ).toHaveBeenCalled()
		)
	)
)