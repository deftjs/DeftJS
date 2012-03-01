Ext.define( 'Deft.util.Promise',
	alternateClassName: [ 'Deft.Promise' ]
	
	constructor: ( deferred ) ->
		@deferred = deferred
		return @
	
	then: ( callbacks ) ->
		return @deferred.then( callbacks )
	
	cancel: ( reason ) ->
		return @deferred.cancel( reason )
)