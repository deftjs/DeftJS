# @private
Ext.define( 'Deft.core.Class', 
	alternateClassName: [ 'Deft.Class' ]
	
	statics:
		###*
		Register a new pre-processor to be used during the class creation process.
		(Normalizes API differences between the various Sencha frameworks and versions.)
		###
		registerPreprocessor: ( name, fn, position, relativeTo ) ->
			if Ext.getVersion( 'extjs' ) and Ext.getVersion( 'core' ).isLessThan( '4.1.0' )
				# Ext JS 4.0
				Ext.Class.registerPreprocessor( 
					name
					( Class, data, callback ) ->
						return fn.call( @, Class, data, data, callback )
				
				).setDefaultPreprocessorPosition( name, position, relativeTo )
			else
				# Sencha Touch 2.0+, Ext JS 4.1+
				Ext.Class.registerPreprocessor( 
					name
					( Class, data, hooks, callback ) ->
						return fn.call( @, Class, data, hooks, callback )
					[ name ]
					position
					relativeTo
				)
			return
			
		hookOnClassCreated: ( hooks, fn ) ->
			if Ext.getVersion( 'extjs' ) and Ext.getVersion( 'core' ).isLessThan( '4.1.0' )
				# Ext JS 4.0
				Ext.Function.interceptBefore( hooks, 'onClassCreated', fn )
			else
				# Sencha Touch 2.0+, Ext JS 4.1+
				Ext.Function.interceptBefore( hooks, 'onCreated', fn )
			return
		
		hookOnClassExtended: ( data, fn ) ->
			if Ext.getVersion( 'extjs' ) and Ext.getVersion( 'core' ).isLessThan( '4.1.0' )
				# Ext JS 4.0
				onClassExtended = ( Class, data ) ->
					return fn.call( @, Class, data, data )
			else
				# Sencha Touch 2.0+, Ext JS 4.1+
				onClassExtended = fn
			
			if data.onClassExtended?
				Ext.Function.interceptBefore( data, 'onClassExtended', onClassExtended )
			else
				data.onClassExtended = onClassExtended
			return
)