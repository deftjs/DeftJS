###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

describe( 'Deft.mixin.Injectable', ->

	specify( 'should trigger injection before the target class constructor is executed', ->
		injectStub = sinon.stub( Deft.Injector, 'inject' )

		Ext.define( 'ExampleClass',
			inject: [ 'identifier' ]

			constructor: ->
				expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
				expect( @inject ).to.be.eql(
					identifier: 'identifier'
				)
				return @callParent()
		)

		exampleInstance = Ext.create( 'ExampleClass' )

		Deft.Injector.inject.restore()

		delete ExampleClass

		return
	)

	specify( 'should should merge subclass injections with parent class injections', ->
		injectStub = sinon.stub( Deft.Injector, 'inject' )

		Ext.define( 'ExampleClass',
			inject: [ 'identifier1' ]
		)

		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
			inject: [ 'identifier2' ]

			constructor: ->
				expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
				expect( @inject ).to.be.eql(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
				)
				return @callParent()
		)

		exampleInstance = Ext.create( 'ExampleSubclass' )

		expect( injectStub ).to.be.calledOnce

		Deft.Injector.inject.restore()

		delete ExampleClass
		delete ExampleSubclass

		return
	)

	specify( 'should should merge multiple levels of inherited injections', ->
		injectStub = sinon.stub( Deft.Injector, 'inject' )

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
				expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
				expect( @inject ).to.be.eql(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
					identifier3: 'identifier3'
					identifier4: 'identifier4'
				)
				return @callParent()
		)

		exampleInstance = Ext.create( 'ExampleSubclass2' )

		expect( injectStub ).to.be.calledOnce

		Deft.Injector.inject.restore()

		delete ExampleClass
		delete ExampleSubclass
		delete ExampleSubclass2

		return
	)

	specify( 'should should merge multiple levels of inherited injections when only the root class in the class hierarchy has injections', ->
		injectStub = sinon.stub( Deft.Injector, 'inject' )

		Ext.define( 'ExampleClass',
			inject: [ 'identifier1', 'identifier2' ]
		)

		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
		)

		Ext.define( 'ExampleSubclass2',
			extend: 'ExampleSubclass'

			constructor: ->
				expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
				expect( @inject ).to.be.eql(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
				)
				return @callParent()
		)

		exampleInstance = Ext.create( 'ExampleSubclass2' )

		expect( injectStub ).to.be.calledOnce

		Deft.Injector.inject.restore()

		delete ExampleClass
		delete ExampleSubclass
		delete ExampleSubclass2

		return
	)

	specify( 'should should merge multiple levels of inherited injections when an intermediate class in the class hierarchy has no injections', ->
		injectStub = sinon.stub( Deft.Injector, 'inject' )

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
				expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
				expect( @inject ).to.be.eql(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
					identifier3: 'identifier3'
				)
				return @callParent()
		)

		exampleInstance = Ext.create( 'ExampleSubclass2' )

		expect( injectStub ).to.be.calledOnce

		Deft.Injector.inject.restore()

		delete ExampleClass
		delete ExampleSubclass
		delete ExampleSubclass2

		return
	)

	specify( 'should should merge multiple levels of inherited injections when only the intermediate class in the class hierarchy has injections', ->
		injectStub = sinon.stub( Deft.Injector, 'inject' )

		Ext.define( 'ExampleClass', {} )

		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
			inject: [ 'identifier1', 'identifier2' ]
		)

		Ext.define( 'ExampleSubclass2',
			extend: 'ExampleSubclass'

			constructor: ->
				expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
				expect( @inject ).to.be.eql(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
				)
				return @callParent()
		)

		exampleInstance = Ext.create( 'ExampleSubclass2' )

		expect( injectStub ).to.be.calledOnce

		Deft.Injector.inject.restore()

		delete ExampleClass
		delete ExampleSubclass
		delete ExampleSubclass2

		return
	)

	specify( 'should should merge multiple levels of inherited injections when only the leaf class in the class hierarchy has injections', ->
		injectStub = sinon.stub( Deft.Injector, 'inject' )

		Ext.define( 'ExampleClass', {} )

		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
		)

		Ext.define( 'ExampleSubclass2',
			extend: 'ExampleSubclass'
			inject: [ 'identifier1', 'identifier2' ]

			constructor: ->
				expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
				expect( @inject ).to.be.eql(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
				)
				return @callParent()
		)

		exampleInstance = Ext.create( 'ExampleSubclass2' )

		expect( injectStub ).to.be.calledOnce

		Deft.Injector.inject.restore()

		delete ExampleClass
		delete ExampleSubclass
		delete ExampleSubclass2

		return
	)

	specify( 'should should merge inherited injections when some injections are specified as Strings', ->
		injectStub = sinon.stub( Deft.Injector, 'inject' )

		Ext.define( 'ExampleClass',
			inject: [ 'identifier1', 'identifier2' ]
		)

		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
			inject: 'identifier3'

			constructor: ->
				expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
				expect( @inject ).to.be.eql(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
					identifier3: 'identifier3'
				)
				return @callParent()
		)

		exampleInstance = Ext.create( 'ExampleSubclass' )

		expect( injectStub ).to.be.calledOnce

		Deft.Injector.inject.restore()

		delete ExampleClass
		delete ExampleSubclass

		return
	)

	specify( 'should should merge inherited injections when some injections are specified as Objects', ->
		injectStub = sinon.stub( Deft.Injector, 'inject' )

		Ext.define( 'ExampleClass',
			inject: [ 'identifier1' ]
		)

		Ext.define( 'ExampleSubclass',
			extend: 'ExampleClass'
			inject:
				identifier2: 'identifier2'
				identifier3: 'identifier3'

			constructor: ->
				expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
				expect( @inject ).to.be.eql(
					identifier1: 'identifier1'
					identifier2: 'identifier2'
					identifier3: 'identifier3'
				)
				return @callParent()
		)

		exampleInstance = Ext.create( 'ExampleSubclass' )

		expect( injectStub ).to.be.calledOnce

		Deft.Injector.inject.restore()

		delete ExampleClass
		delete ExampleSubclass

		return
	)

	specify( 'should should allow child injections into a property to override parent injections into that property', ->
		injectStub = sinon.stub( Deft.Injector, 'inject' )

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
				expect( injectStub ).to.be.calledWith( @inject, @, arguments, false )
				expect( @inject ).to.be.eql(
					identifier1: 'overriddenIdentifier1'
					identifier2: 'overriddenIdentifier2'
					identifier3: 'identifier3'
					identifier4: 'identifier4'
				)
				return @callParent()
		)

		exampleInstance = Ext.create( 'ExampleSubclass2' )

		expect( injectStub ).to.be.calledOnce

		Deft.Injector.inject.restore()

		delete ExampleClass
		delete ExampleSubclass
		delete ExampleSubclass2

		return
	)

	return
)
