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
			mixins: [ 'Deft.mixin.Injectable' ]
			inject: [ 'identifier' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				return @
		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleClass' )
		
		return
	)
	
	
	it( 'should should merge subclass injections with parent class injections', ->
		Ext.define( 'ExampleClass',
			mixins: [ 'Deft.mixin.Injectable' ]
			inject: [ 'identifier1' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( Ext.Object.getValues( @inject ) ).toEqual( [ "identifier2", "identifier1" ] )
		)
		
		Ext.define( 'ExampleSubClass',
			extend: 'ExampleClass'
			inject: [ 'identifier2' ]

		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubClass' )
		
		return
	)
	
	it( 'should should merge 3 levels of inherited injections', ->
		Ext.define( 'ExampleClass',
			mixins: [ 'Deft.mixin.Injectable' ]
			inject: [ 'identifier1' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( Ext.Object.getValues( @inject ) ).toEqual( [ "identifier3", "identifier4", "identifier2", "identifier1" ] )
		)
		
		Ext.define( 'ExampleSubClass',
			extend: 'ExampleClass'
			inject: [ 'identifier2' ]

		)
		
		Ext.define( 'ExampleSubClass2',
			extend: 'ExampleSubClass'
			inject: [ 'identifier3', 'identifier4' ]

		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubClass2' )
		
		return
	)
	
	it( 'should should merge 3 levels of inherited injections when 2nd level object has no injections', ->
		Ext.define( 'ExampleClass',
			mixins: [ 'Deft.mixin.Injectable' ]
			inject: [ 'identifier1' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( Ext.Object.getValues( @inject ) ).toEqual( [ "identifier2", "identifier3", "identifier1" ] )
		)
		
		Ext.define( 'ExampleSubClass',
			extend: 'ExampleClass'
			
		)
		
		Ext.define( 'ExampleSubClass2',
			extend: 'ExampleSubClass'
			inject: [ 'identifier2', 'identifier3' ]

		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubClass2' )
		
		return
	)
	
	it( 'should should merge 3 levels of inherited injections when only 3nd level object has injections', ->
		Ext.define( 'ExampleClass',
			mixins: [ 'Deft.mixin.Injectable' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( Ext.Object.getValues( @inject ) ).toEqual( [ "identifier1", "identifier2" ] )
		)
		
		Ext.define( 'ExampleSubClass',
			extend: 'ExampleClass'
			
		)
		
		Ext.define( 'ExampleSubClass2',
			extend: 'ExampleSubClass'
			inject: [ 'identifier1', 'identifier2' ]

		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubClass2' )
		
		return
	)
	
	it( 'should should merge 3 levels of inherited injections when only top level object has injections', ->
		Ext.define( 'ExampleClass',
			mixins: [ 'Deft.mixin.Injectable' ]
			inject: [ 'identifier1', 'identifier2' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( Ext.Object.getValues( @inject ) ).toEqual( [ "identifier1", "identifier2" ] )
		)
		
		Ext.define( 'ExampleSubClass',
			extend: 'ExampleClass'
			
		)
		
		Ext.define( 'ExampleSubClass2',
			extend: 'ExampleSubClass'
			

		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubClass2' )
		
		return
	)
	
	it( 'should should merge inherited injections when some injections are string lists', ->
		Ext.define( 'ExampleClass',
			mixins: [ 'Deft.mixin.Injectable' ]
			inject: [ 'identifier1' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( Ext.Object.getValues( @inject ) ).toEqual( [ "identifier2", "identifier3", "identifier1" ] )
		)
		
		Ext.define( 'ExampleSubClass',
			extend: 'ExampleClass'
			
		)
		
		Ext.define( 'ExampleSubClass2',
			extend: 'ExampleSubClass'
			inject: 'identifier2,identifier3'

		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubClass2' )
		
		return
	)
	
	it( 'should should merge inherited injections when some injections are objects', ->
		Ext.define( 'ExampleClass',
			mixins: [ 'Deft.mixin.Injectable' ]
			inject: [ 'identifier1' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( Ext.Object.getValues( @inject ) ).toEqual( [ "identifier2", "identifier3", "identifier1" ] )
		)
		
		Ext.define( 'ExampleSubClass',
			extend: 'ExampleClass'
			
		)
		
		Ext.define( 'ExampleSubClass2',
			extend: 'ExampleSubClass'
			inject:
				identifier2: 'identifier2'
				identifier3: 'identifier3'

		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubClass2' )
		
		return
	)
	
	it( 'should should allow child injections into a property to override parent injections into that property', ->
		Ext.define( 'ExampleClass',
			mixins: [ 'Deft.mixin.Injectable' ]
			inject: [ 'identifier1', 'identifier2', 'identifier3' ]
			
			constructor: ->
				expect( Deft.Injector.inject ).toHaveBeenCalledWith( @inject, @, false )
				expect( Ext.Object.getValues( @inject ) ).toEqual( [ "overriddenIdentifier1", "overriddenIdentifier2", "identifier4", "identifier3" ] )
		)
		
		Ext.define( 'ExampleSubClass',
			extend: 'ExampleClass'
			
		)
		
		Ext.define( 'ExampleSubClass2',
			extend: 'ExampleSubClass'
			inject:
				identifier1: 'overriddenIdentifier1'
				identifier2: 'overriddenIdentifier2'
				identifier4: 'identifier4'

		)
		
		spyOn( Deft.Injector, 'inject' ).andCallFake( -> return )
		
		exampleInstance = Ext.create( 'ExampleSubClass2' )
		
		return
	)
	
	return
	
)