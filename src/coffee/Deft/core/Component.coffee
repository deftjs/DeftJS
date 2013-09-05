Ext.define( 'Deft.core.Component',
  override: 'Ext.Component'
  alternateClassName: [ 'Deft.Component' ]
  
  constructor : do () ->
    if Ext.getVersion( 'extjs' ) and Ext.getVersion( 'core' ).isLessThan( '4.1.0' )
      return ( config ) -> 
        if( config isnt undefined and not @$injected and config.inject? )
          Deft.Injector.inject( config.inject, @, false )
          @$injected = true
        return @callOverridden( arguments )
    else
      return ( config ) ->
        if( config isnt undefined and not @$injected and config.inject? )
          Deft.Injector.inject( config.inject, @, false )
          @$injected = true
        return @callParent( arguments )
  
  setParent: ( newParent ) ->
    if Ext.getVersion( 'touch' )?
      oldParent = @getParent() || null
          
      result = @callParent( arguments )
          
      if oldParent is null and newParent isnt null
        @fireEvent( 'added', @, newParent )
      else if oldParent isnt null and newParent isnt null
        @fireEvent( 'removed', @, oldParent )
        @fireEvent( 'added', @, newParent )
      else if oldParent isnt null and newParent is null
        @fireEvent( 'removed', @, oldParent )

      return result
    else
      return @callParent( arguments )

  is: ( selector ) ->
    return Ext.ComponentQuery.is( @, selector )
        
  isDescendantOf: ( container ) ->
    if Ext.getVersion( 'touch' )?
      ancestor = @getParent()
      while ancestor?
        if ancestor is container
          return true
        ancestor = ancestor.getParent()
      return false
    else
      return @callParent( arguments )
)