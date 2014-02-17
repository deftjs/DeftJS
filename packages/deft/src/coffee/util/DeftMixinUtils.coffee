###*
* Utility class to support Deft JS mixins.
###
Ext.define( "Deft.util.DeftMixinUtils",

	statics:

		###*
		* Uses the passed mergeFn to recursively merge the specified propertyName up the class hierarchy of the target.
		###
		mergeSuperclassProperty: ( target, propertyName, mergeFn=Ext.merge, currentResult=null ) ->
			wasMerged = false
			isRecursionStart = false

			if( !currentResult? )
				currentResult = {}
				isRecursionStart = true

			if( target?.superclass? )
				currentResult = @mergeSuperclassProperty( target.superclass, propertyName, mergeFn, currentResult )

			if( target?[ propertyName ]? )
				currentResult = mergeFn( currentResult, target[ propertyName ], Ext.getClassName( target ) )
				wasMerged = true

			if( wasMerged and isRecursionStart )
				target[ propertyName ] = Ext.clone( currentResult )

			return currentResult


		###*
		* Returns the proper method name to call the superclass constructor, based on platform and version.
		###
		parentConstructorForVersion: ->
			if Ext.getVersion( 'extjs' ) and Ext.getVersion( 'core' ).isLessThan( '4.1.0' )
				return "callOverridden"
			else
				return "callParent"


)

