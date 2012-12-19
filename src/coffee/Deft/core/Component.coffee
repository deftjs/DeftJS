Ext.define( 'Deft.core.Component',
  override: 'Ext.Component'
  alternateClassName: [ 'Deft.Component' ]
    
  setParent: ( newParent ) ->
    if Ext.getVersion( 'touch' )?
      oldParent = @getParent()
          
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