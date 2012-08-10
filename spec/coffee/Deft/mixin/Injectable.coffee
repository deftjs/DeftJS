###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.mixin.Injectable
###
describe( 'Deft.mixin.Injectable', ->
	
	it( 'should trigger injection before the target class constructor is executed', ->
		Ext.define( 'ExampleClass',
			inject: [ 'identifier' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( @inject ).toEqual(
					identifier: 'identifier'
				)
				return @callParent()
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleClass' )
		
		return
	)
	
	it( 'should should merge subclass injections with parent class injections', ->
		Ext.define( 'ExampleClass',
			inject: [ 'identifier1' ]
		)
		
		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
			inject: [ 'identifier2' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( @inject ).toEqual(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
				)
				return @callParent()
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubclass' )
		
		expect( Deft.Injector.inject.callCount ).toBe( 1 )
		
		return
	)
	
	it( 'should should merge multiple levels of inherited injections', ->
		Ext.define( 'ExampleClass',
			inject: [ 'identifier1' ]
		)
		
		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
			inject: [ 'identifier2' ]
		)
		
		Ext.define( 'ExampleSubclass2',
			extend: 'ExampleSubclass'
			inject: [ 'identifier3', 'identifier4' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( @inject ).toEqual(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
					identifier3: 'identifier3'
					identifier4: 'identifier4'
				)
				return @callParent()
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubclass2' )
		
		expect( Deft.Injector.inject.callCount ).toBe( 1 )
		
		return
	)
	
	
	it( 'should should merge multiple levels of inherited injections when only the root class in the class hierarchy has injections', ->
		Ext.define( 'ExampleClass',
			inject: [ 'identifier1', 'identifier2' ]
		)
		
		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
		)
		
		Ext.define( 'ExampleSubclass2',
			extend: 'ExampleSubclass'
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( @inject ).toEqual(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
				)
				return @callParent()
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubclass2' )
		
		expect( Deft.Injector.inject.callCount ).toBe( 1 )
		
		return
	)
	
	it( 'should should merge multiple levels of inherited injections when an intermediate class in the class hierarchy has no injections', ->
		Ext.define( 'ExampleClass',
			inject: [ 'identifier1' ]
		)
		
		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
		)
		
		Ext.define( 'ExampleSubclass2',
			extend: 'ExampleSubclass'
			inject: [ 'identifier2', 'identifier3' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( @inject ).toEqual(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
					identifier3: 'identifier3'
				)
				return @callParent()
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubclass2' )
		
		expect( Deft.Injector.inject.callCount ).toBe( 1 )
		
		return
	)
	
	it( 'should should merge multiple levels of inherited injections when only the intermediate class in the class hierarchy has injections', ->
		Ext.define( 'ExampleClass', {} )
		
		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
			inject: [ 'identifier1', 'identifier2' ]
		)
		
		Ext.define( 'ExampleSubclass2',
			extend: 'ExampleSubclass'
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( @inject ).toEqual(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
				)
				return @callParent()
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubclass2' )
		
		expect( Deft.Injector.inject.callCount ).toBe( 1 )
		
		return
	)
	
	it( 'should should merge multiple levels of inherited injections when only the leaf class in the class hierarchy has injections', ->
		Ext.define( 'ExampleClass', {} )
		
		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
		)
		
		Ext.define( 'ExampleSubclass2',
			extend: 'ExampleSubclass'
			inject: [ 'identifier1', 'identifier2' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( @inject ).toEqual(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
				)
				return @callParent()
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubclass2' )
		
		expect( Deft.Injector.inject.callCount ).toBe( 1 )
		
		return
	)
	
	it( 'should should merge inherited injections when some injections are specified as Strings', ->
		Ext.define( 'ExampleClass',
			inject: [ 'identifier1', 'identifier2' ]
		)
		
		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
			inject: 'identifier3'
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( @inject ).toEqual(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
					identifier3: 'identifier3'
				)
				return @callParent()
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubclass' )
		
		expect( Deft.Injector.inject.callCount ).toBe( 1 )
		
		return
	)
	
	it( 'should should merge inherited injections when some injections are specified as Objects', ->
		Ext.define( 'ExampleClass',
			inject: [ 'identifier1' ]
		)
		
		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
			inject:
				identifier2: 'identifier2'
				identifier3: 'identifier3'
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( @inject ).toEqual(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
					identifier3: 'identifier3'
				)
				return @callParent()
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubclass' )
		
		expect( Deft.Injector.inject.callCount ).toBe( 1 )
		
		return
	)
	
	it( 'should should allow child injections into a property to override parent injections into that property', ->
		Ext.define( 'ExampleClass',
			inject: [ 'identifier1', 'identifier2', 'identifier3' ]
		)
		
		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
		)
		
		Ext.define( 'ExampleSubclass2',
			extend: 'ExampleSubclass'
			inject:
				identifier1: 'overriddenIdentifier1'
				identifier2: 'overriddenIdentifier2'
				identifier4: 'identifier4'
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( @inject ).toEqual(
					identifier1: 'overriddenIdentifier1'
					identifier2: 'overriddenIdentifier2'
					identifier3: 'identifier3'
					identifier4: 'identifier4'
				)
				return @callParent()
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubclass2' )
		
		expect( Deft.Injector.inject.callCount ).toBe( 1 )
		
		return
	)
	
	return
)