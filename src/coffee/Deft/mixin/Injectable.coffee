###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
A mixin that marks a class as participating in dependency injection.

Used in conjunction with {@link Deft.ioc.Injector}.
###
Ext.define( 'Deft.mixin.Injectable',
	requires: [ 
		'Deft.ioc.Injector'
	]
	
	###*
	@private
	###
	onClassMixedIn: ( targetClass ) ->
		targetClass::constructor = Ext.Function.createInterceptor( targetClass::constructor, ->
			Deft.Injector.inject( @inject, @, false )
		)
		return
)

###*
Preprocessor to merge inherited injections into class instead of overwriting superclass injections.
###
Ext.Class.registerPreprocessor( 'inject', ( Class, data, hooks, callback ) ->

  # Workaround: Ext JS 4.0 passes the callback as the third parameter, Sencha Touch 2.0.1 and Ext JS 4.1 passes it as the fourth parameter
  if arguments.length is 3
    # NOTE: Altering a parameter also modifies arguments, so clone it to a true Array first.
    parameters = Ext.toArray( arguments )
    hooks = parameters[ 1 ]
    callback = parameters[ 2 ]

  if Class?.superclass and Class.superclass?.inject
    data.inject = {} if not data?.inject

    # Convert a string list or array of strings for data.inject into an object.
    data.inject = data.inject.split( ',' ) if Ext.isString( data.inject )
    if Ext.isArray( data.inject )
      dataInjectObject = {}
      for thisInjection in data.inject
        dataInjectObject[ thisInjection ] = thisInjection
      data.inject = dataInjectObject

    # Convert a string list or array of strings for superclass.inject into an object.
    Class.superclass.inject = Class.superclass.inject.split( ',' ) if Ext.isString( Class.superclass.inject )
    if Ext.isArray( Class.superclass.inject )
      superclassInjectObject = {}
      for thisInjection in Class.superclass.inject
        superclassInjectObject[ thisInjection ] = thisInjection
      Class.superclass.inject = superclassInjectObject

    # Merge injections, ensuring that injections in data overwrite injections in superclass.
    Ext.applyIf( data.inject, Class.superclass.inject )

  return
)

Ext.Class.setDefaultPreprocessorPosition( 'inject', 'before', 'extend' )
