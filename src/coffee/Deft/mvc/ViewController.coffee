###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
A lightweight MVC view controller.

Used in conjunction with {@link Deft.mixin.Controllable}.
###
Ext.define( 'Deft.mvc.ViewController',
  alternateClassName: [ 'Deft.ViewController' ]

  constructor: (view) ->
    @components = view: view
    view.on 'initialize', @.configure, @
    @

  ###*
  Configure the ViewController.
  ###
  configure: ->
    Ext.Logger.log 'Configuring view controller.'

    view = @getView()
    view.un 'initialize', @configure, @
    view.on 'beforedestroy', @destroy, @

    if Ext.isObject(@control)
      for key, config of @control
        component = @locateComponent()
        @setComponent(key, component)

        if Ext.isObject(config)
          listeners = (if Ext.isObject(config.listeners) then config.listeners else config)

          for event,handler of listeners
            Ext.Logger.log 'adding component ' + component + ' event ' + event + ' listener to ' + handler

            component.on event, @[handler], @

    @setup() if Ext.isFunction(@setup)
    @

  ###*
  Destroy the ViewController
  ###
  destroy: (e) ->
    Ext.Logger.log 'Destroying view controller.'

    view = getView()
    view.un 'beforedestroy', @destroy, @

    return false if Ext.isFunction(@tearDown) and @tearDown() is false

    if Ext.isObject(@control)
      for key, config of @control
        component = @getComponent key

        if Ext.isObject(config)
          listeners = (if Ext.isObject(config.listeners) then config.listeners else config)

          for event, handler in listeners
            Ext.Logger.log 'removing component ' + component + ' event ' + event + ' listener to ' + handler

            component.un event, @[handler], @

          getterName = 'get' + Ext.String.capitalize(key)
          @[getterName] = null


    @components = null
    true

  locateComponent: (key, config) ->
    view = getView()

    return view if key == 'view'
    return view.query(config)[0] if Ext.isString(config)
    return view.query(config.selector)[0] if Ext.isString(config.selector)
    return view.query('#' + key)[0]

  getComponent: (key) ->
    @components[key]

  setComponent: (key, value) ->
    getterName = 'get' + Ext.String.capitalize(key)
    @[getterName] = Ext.Function.pass(@getComponent, [ key ], @) unless @[getterName]
    @components[key] = value

  getView: ->
    @components.view
)