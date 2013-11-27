Ext.define( "Deft.util.DeftMixinUtils",

	statics:

		mergeSuperclassProperty: ( target, propertyName, mergeFn=Ext.merge, currentResult ) ->
			wasMerged = false
			isRecursionStart = false

			if( !currentResult? )
				currentResult = {}
				isRecursionStart = true

			if( target?.superclass? )
				wasMerged = @mergeSuperclassProperty( target.superclass, propertyName, mergeFn, currentResult )

			if( target?[ propertyName ]? )
				currentResult = mergeFn( currentResult, target[ propertyName ] )
				wasMerged = true

			if( wasMerged and isRecursionStart )
				target[ propertyName ] = currentResult

			return currentResult

)