###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.util.Deferred
###
describe( 'Deft.util.Deferred', ->
	
	describe( 'then()', ->
		
		createSpecsForThen = ( thenFunction, callbacksFactoryFunction ) ->
			
			deferred = null
			successCallback = failureCallback = progressCallback = cancelCallback = null
			
			beforeEach( ->
				deferred = Ext.create( 'Deft.util.Deferred' )
				
				{ success: successCallback, failure: failureCallback, progress: progressCallback, cancel: cancelCallback } = callbacksFactoryFunction()
			)
			
			it( 'should call success callback (if specified) when resolved', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.resolve( 'expected result' )
				
				expect( successCallback ).toHaveBeenCalledWith( 'expected result' ) if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should call failure callback (if specified) when rejected', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.reject( 'error message' )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).toHaveBeenCalledWith( 'error message' ) if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should call progress callback (if specified) when updated', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.update( 'progress' )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).toHaveBeenCalledWith( 'progress' ) if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should call cancel callback (if specified) when cancelled', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.cancel( 'reason' )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).toHaveBeenCalledWith( 'reason' ) if cancelCallback?
			)
			
			it( 'should allow resolution after update', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				expect( ->
					deferred.update( 'progress' )
					deferred.resolve( 'expected result' )
				).not.toThrow()
				
				expect( successCallback ).toHaveBeenCalledWith( 'expected result' ) if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).toHaveBeenCalledWith( 'progress' ) if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should allow rejection after update', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				expect( ->
					deferred.update( 'progress' )
					deferred.reject( 'error message' )
				).not.toThrow()
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).toHaveBeenCalledWith( 'error message' ) if failureCallback?
				expect( progressCallback ).toHaveBeenCalledWith( 'progress' ) if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should allow cancellation after update', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				expect( ->
					deferred.update( 'progress' )
					deferred.cancel( 'reason' )
				).not.toThrow()
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).toHaveBeenCalledWith( 'progress' ) if progressCallback?
				expect( cancelCallback ).toHaveBeenCalledWith( 'reason' ) if cancelCallback?
			)
			
			it( 'should not allow resolution after resolution', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.resolve( 'expected result' )
				
				successCallback.reset() if successCallback?
				
				expect( ->
					deferred.resolve( 'expected result' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should not allow rejection after resolution', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.resolve( 'expected result' )
				
				successCallback.reset() if successCallback?
				
				expect( ->
					deferred.reject( 'error message' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should not allow update after resolution', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.resolve( 'expected result' )
				
				successCallback.reset() if successCallback?
				
				expect( ->
					deferred.update( 'progress' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should not allow cancellation after resolution', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.resolve( 'expected result' )
				
				successCallback.reset() if successCallback?
				
				expect( ->
					deferred.cancel( 'reason' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should not allow resolution after rejection', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.reject( 'error message' )
				
				failureCallback.reset() if failureCallback?
				
				expect( ->
					deferred.resolve( 'expected result' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should not allow rejection after rejection', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.reject( 'error message' )
				
				failureCallback.reset() if failureCallback?
				
				expect( ->
					deferred.reject( 'error message' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should not allow update after rejection', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.reject( 'error message' )
				
				failureCallback.reset() if failureCallback?
				
				expect( ->
					deferred.update( 'progress' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should not allow cancellation after rejection', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.reject( 'error message' )
				
				failureCallback.reset() if failureCallback?
				
				expect( ->
					deferred.cancel( 'reason' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should not allow resolution after cancellation', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.cancel( 'reason' )
				
				cancelCallback.reset() if cancelCallback?
				
				expect( ->
					deferred.resolve( 'expected result' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should not allow rejection after cancellation', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.cancel( 'reason' )
				
				cancelCallback.reset() if cancelCallback?
				
				expect( ->
					deferred.reject( 'error message' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should not allow update after cancellation', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.cancel( 'reason' )
				
				cancelCallback.reset() if cancelCallback?
				
				expect( ->
					deferred.update( 'progress' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should not allow cancellation after cancellation', ->
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				deferred.cancel( 'reason' )
				
				cancelCallback.reset() if cancelCallback?
				
				expect( ->
					deferred.cancel( 'reason' ) 
				).toThrow( new Error( 'Error: this Deferred has already been completed and cannot be modified.' ) )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should immediately call newly added success callback (if specified) when already resolved', ->
				deferred.resolve( 'expected result' )
				
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				expect( successCallback ).toHaveBeenCalledWith( 'expected result' ) if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should immediately call newly added failure callback (if specified) when already rejected', ->
				deferred.reject( 'error message' )
				
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).toHaveBeenCalledWith( 'error message' ) if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should immediately call newly added progress callback (if specified) when already updated', ->
				deferred.update( 'progress' )
				
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).toHaveBeenCalledWith( 'progress' ) if progressCallback?
				expect( cancelCallback ).not.toHaveBeenCalled() if cancelCallback?
			)
			
			it( 'should immediately call newly added cancel callback (if specified) when already cancelled', ->
				deferred.cancel( 'reason' )
				
				thenFunction( deferred, successCallback, failureCallback, progressCallback, cancelCallback )
				
				expect( successCallback ).not.toHaveBeenCalled() if successCallback?
				expect( failureCallback ).not.toHaveBeenCalled() if failureCallback?
				expect( progressCallback ).not.toHaveBeenCalled() if progressCallback?
				expect( cancelCallback ).toHaveBeenCalledWith( 'reason' ) if cancelCallback?
			)
			
			return
		
		describe( 'with callbacks specified via method parameters', ->
			
			thenFunction = ( deferred, successCallback, failureCallback, progressCallback, cancelCallback ) ->
				deferred.then( successCallback, failureCallback, progressCallback, cancelCallback )
			
			callbacksFactoryFunction = ->
				{
					success: jasmine.createSpy()
					failure: jasmine.createSpy()
					progress: jasmine.createSpy()
					cancel: jasmine.createSpy()
				}
			
			createSpecsForThen( thenFunction, callbacksFactoryFunction )
		)
		
		describe( 'with callbacks specified via method parameters, with omitted callbacks', ->
			
			thenFunction = ( deferred, successCallback, failureCallback, progressCallback, cancelCallback ) ->
				deferred.then( successCallback, failureCallback, progressCallback, cancelCallback )
			
			createCallbacksFactoryFunction = ( startIndex, endIndex ) ->
				callbacksFactoryFunction = ->
					callbacks = {}
				
					callbacks.success  = jasmine.createSpy() unless index is 0
					callbacks.failure  = jasmine.createSpy() unless index is 1
					callbacks.progress = jasmine.createSpy() unless index is 2
					callbacks.cancel   = jasmine.createSpy() unless index is 3
				
					return callbacks
				
				return callbacksFactoryFunction
			
			callbackNames = [ 'success', 'failure', 'progress', 'cancel' ]
			for index in [ 0..3 ]
				describe( "omitting #{ callbackNames[ index ] } callback", ->
					createSpecsForThen( thenFunction, createCallbacksFactoryFunction( index ) )
				)
		)
		
		describe( 'with callbacks specified via configuration Object', ->
			
			thenFunction = ( deferred, successCallback, failureCallback, progressCallback, cancelCallback ) ->
					deferred.then( 
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			callbacksFactoryFunction = ->
				{
					success: jasmine.createSpy()
					failure: jasmine.createSpy()
					progress: jasmine.createSpy()
					cancel: jasmine.createSpy()
				}
			
			createSpecsForThen( thenFunction, callbacksFactoryFunction )
		)
		
		describe( 'with callbacks specified via configuration Object, with omitted callbacks', ->
			
			thenFunction = ( deferred, successCallback, failureCallback, progressCallback, cancelCallback ) ->
					deferred.then( 
						success: successCallback
						failure: failureCallback
						progress: progressCallback
						cancel: cancelCallback
					)
			
			createCallbacksFactoryFunction = ( startIndex, endIndex ) ->
				callbacksFactoryFunction = ->
					callbacks = {}
				
					callbacks.success  = jasmine.createSpy() unless index is 0
					callbacks.failure  = jasmine.createSpy() unless index is 1
					callbacks.progress = jasmine.createSpy() unless index is 2
					callbacks.cancel   = jasmine.createSpy() unless index is 3
					
					return callbacks
				
				return callbacksFactoryFunction
			
			callbackNames = [ 'success', 'failure', 'progress', 'cancel' ]
			for index in [ 0..3 ]
				describe( "omitting #{ callbackNames[ index ] } callback", ->
					createSpecsForThen( thenFunction, createCallbacksFactoryFunction( index ) )
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