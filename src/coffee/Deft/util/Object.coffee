###*
* Common utility functions used by DeftJS.
###
Ext.define( 'Deft.util.Object',
	alternateClassName: [ 'Deft.Object' ]

	statics:
		###*
		* Retrieves value for specified key and deletes the pair
		###
		extract: ( object, key ) ->
			value = object[key]
			delete object[key]
			return value
)