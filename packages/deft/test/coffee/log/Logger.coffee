###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

describe( 'Deft.log.Logger', ->
	
	describe( 'log()', ->
		
		if Ext.getVersion( 'extjs' )?
			# Ext JS
			
			describe( 'logs a message with the specified priority', ->
				logFunction = null
				
				beforeEach( ->
					logFunction = sinon.stub( Ext, 'log' )
					return
				)
				
				afterEach( ->
					logFunction.restore()
					return
				)
				
				specify( 'no priority specified', ->
					Deft.Logger.log( 'message', 'info' )
					
					expect( logFunction ).to.be.calledOnce.and.calledWith( { level: 'info', msg: 'message' } )
					return
				)
				
				specify( 'verbose', ->
					Deft.Logger.log( 'message', 'verbose' )
					
					expect( logFunction ).to.be.calledOnce.and.calledWith( { level: 'info', msg: 'message' } )
					return
				)
				
				specify( 'deprecate', ->
					Deft.Logger.log( 'message', 'deprecate' )
					
					expect( logFunction ).to.be.calledOnce.and.calledWith( { level: 'warn', msg: 'message' } )
					return
				)
				
				specify( 'warn', ->
					Deft.Logger.log( 'message', 'warn' )
					
					expect( logFunction ).to.be.calledOnce.and.calledWith( { level: 'warn', msg: 'message' } )
					return
				)
				
				specify( 'error', ->
					Deft.Logger.log( 'message', 'error' )
					
					expect( logFunction ).to.be.calledOnce.and.calledWith( { level: 'error', msg: 'message' } )
					return
				)
				
				return
			)
		
		else
			# Sencha Touch
			
			describe( 'logs a message with the specified priority, when Ext.Logger is available', ->
				logFunction = null
				
				beforeEach( ->
					if not Ext.Logger?
						Ext.define( 'Ext.Logger', 
							singleton: true
							log: Ext.emptyFn
							isMock: true
						)
					logFunction = sinon.stub( Ext.Logger, 'log' )
				)
				
				afterEach( ->
					logFunction.restore()
					if Ext.Logger.isMock
						Ext.Logger = null
				)
				
				specify( 'no priority specified', ->
					Deft.Logger.log( 'message', 'info' )
					
					expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'info' )
					return
				)
				
				specify( 'verbose', ->
					Deft.Logger.log( 'message', 'verbose' )
					
					expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'verbose' )
					return
				)
				
				specify( 'info', ->
					Deft.Logger.log( 'message', 'info' )
					
					expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'info' )
					return
				)
				
				specify( 'deprecate', ->
					Deft.Logger.log( 'message', 'deprecate' )
					
					expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'deprecate' )
					return
				)
				
				specify( 'warn', ->
					Deft.Logger.log( 'message', 'warn' )
					
					expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'warn' )
					return
				)
				
				specify( 'error', ->
					Deft.Logger.log( 'message', 'error' )
					
					expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'error' )
					return
				)
				
				return
			)
			
			describe( 'silently ignores messages when Ext.Logger is unavailable', ->
				logger = null
				
				beforeEach( ->
					logger = Ext.Logger
					Ext.Logger = null
					return
				)
				
				afterEach( ->
					Ext.Logger = logger
					return
				)
				
				specify( 'no priority specified', ->
					expect( -> Deft.Logger.log( 'message', 'info' ) ).to.not.throw( Error )
					return
				)
				
				specify( 'verbose', ->
					expect( -> Deft.Logger.log( 'message', 'verbose' ) ).to.not.throw( Error )
					return
				)
				
				specify( 'deprecate', ->
					expect( -> Deft.Logger.log( 'message', 'deprecate' ) ).to.not.throw( Error )
					return
				)
				
				specify( 'warn', ->
					expect( -> Deft.Logger.log( 'message', 'warn' ) ).to.not.throw( Error )
					return
				)
				
				specify( 'error', ->
					expect( -> Deft.Logger.log( 'message', 'error' ) ).to.not.throw( Error )
					return
				)
				
				return
			)
	)
	
	describe( 'verbose()', ->
		logFunction = null
		
		beforeEach( ->
			logFunction = sinon.stub( Deft.Logger, 'log' )
		)
		
		afterEach( ->
			logFunction.restore()
		)
		
		specify( 'calls log() with specified message with verbose priority', ->
			Deft.Logger.verbose( 'message' )
			
			expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'verbose' )
			return
		)
		
		return
	)
	
	describe( 'info()', ->
		logFunction = null
		
		beforeEach( ->
			logFunction = sinon.stub( Deft.Logger, 'log' )
		)
		
		afterEach( ->
			logFunction.restore()
		)
		
		specify( 'calls log() with specified message with info priority', ->
			Deft.Logger.info( 'message' )
			
			expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'info' )
			return
		)
		
		return
	)
	
	describe( 'deprecate()', ->
		logFunction = null
		
		beforeEach( ->
			logFunction = sinon.stub( Deft.Logger, 'log' )
		)
		
		afterEach( ->
			logFunction.restore()
		)
		
		specify( 'calls log() with specified message with deprecate priority', ->
			Deft.Logger.deprecate( 'message' )
			
			expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'deprecate' )
			return
		)
		
		return
	)
	
	describe( 'warn()', ->
		logFunction = null
		
		beforeEach( ->
			logFunction = sinon.stub( Deft.Logger, 'log' )
		)
		
		afterEach( ->
			logFunction.restore()
		)
		
		specify( 'calls log() with specified message with warn priority', ->
			Deft.Logger.warn( 'message' )
			
			expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'warn' )
			return
		)
		
		return
	)
	
	describe( 'error()', ->
		logFunction = null
		
		beforeEach( ->
			logFunction = sinon.stub( Deft.Logger, 'log' )
		)
		
		afterEach( ->
			logFunction.restore()
		)
		
		specify( 'calls log() with specified message with error priority', ->
			Deft.Logger.error( 'message' )
			
			expect( logFunction ).to.be.calledOnce.and.calledWith( 'message', 'error' )
			return
		)
		
		return
	)
	
	return
)