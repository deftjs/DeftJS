###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.mvc.Application
###
describe( 'Deft.mvc.Application', ->

  beforeEach( ->
    Deft.Injector.reset()
    return
  )

  it( 'should run beforeInit and afterInit template methods', ->

    Ext.define( 'MyApplication',
      extend: 'Deft.mvc.Application'
    )

    spyOn( MyApplication.prototype, 'beforeInit' ).andCallThrough()
    spyOn( MyApplication.prototype, 'afterInit' ).andCallThrough()
    myApplication = Ext.create( 'MyApplication' )

    waitsFor( ( -> myApplication.initialized ), "Application never initialized.", 500 )
    waitsFor( ( -> myApplication.beforeInit.wasCalled ), "beforeInit() was not called.", 500 )
    waitsFor( ( -> myApplication.afterInit.wasCalled ), "afterInit() was not called.", 500 )

    return
  )

  it( 'should use results of buildInjectorConfig() to initialize Injector', ->

    Ext.define( 'MyApplication',
      extend: 'Deft.mvc.Application'

      buildInjectorConfig: ->
        return result =
          store1: "Ext.data.Store"
          store2: "Ext.data.Store"

    )

    myApplication = Ext.create( 'MyApplication' )
    expect( myApplication.initialized ).toBe( true )
    expect( Deft.Injector.canResolve( 'store1' ) ).toBe( true )
    expect( Deft.Injector.canResolve( 'store2' ) ).toBe( true )
    expect( Deft.Injector.canResolve( '_some$unknown$identifier' ) ).toBe( false )

    return
  )

  it( 'should not automatically configure Injector if no injector config is created', ->

    Ext.define( 'MyApplication',
      extend: 'Deft.mvc.Application'
    )

    spyOn( Deft.Injector, 'configure' ).andCallThrough()
    spyOn( MyApplication.prototype, 'afterInit' ).andCallThrough()
    myApplication = Ext.create( 'MyApplication' )

    waitsFor( ( -> myApplication.afterInit.wasCalled ), "afterInit() was not called.", 500 )

    runs( ->
      expect( Deft.Injector.configure.wasCalled ).toBe( false )
    )

    return
  )

  it( 'should allow subclasses to alter results of buildInjectorConfig()', ->

    Ext.define( 'MyApplication',
      extend: 'Deft.mvc.Application'

      buildInjectorConfig: ->
        return result =
          store1: "Ext.data.Store"
          store2: "Ext.data.Store"

    )

    Ext.define( 'MySubApplication',
      extend: 'MyApplication'

      buildInjectorConfig: ->
        result = @callParent()
        delete result.store1
        result.store3 = "Ext.data.Store"
        console.log( result )
        return result

    )

    mySubApplication = Ext.create( 'MySubApplication' )
    expect( Deft.Injector.canResolve( 'store1' ) ).toBe( false )
    expect( Deft.Injector.canResolve( 'store2' ) ).toBe( true )
    expect( Deft.Injector.canResolve( 'store3' ) ).toBe( true )
    expect( Deft.Injector.canResolve( '_some$unknown$identifier' ) ).toBe( false )

    return
  )

)