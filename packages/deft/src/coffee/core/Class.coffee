###
Copyright (c) 2012-2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
* A collection of useful static methods for interacting with (and normalizing differences between) the Sencha Touch and Ext JS class systems.
* @private
###
Ext.define( 'Deft.core.Class', 
	alternateClassName: [ 'Deft.Class' ]
	
	statics:
		###*
		* Register a new pre-processor to be used during the class creation process.
		* 
		* (Normalizes API differences between the various Sencha frameworks and versions.)
		*
		* @param {String} name The pre-processor's name.
		* @param {Function} fn The callback function to be executed.
		* @param {String} position Optional insertion position for this pre-processor - valid options: 'first', 'last', 'before' or 'after'.
		* @param {String} relativeTo Optional name of a previously registered pre-processor, for 'before' and 'after' relative positioning.
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
		
		###*
		* Intercept class creation.
		*
		* (Normalizes API differences between the various Sencha frameworks and versions.)
		###
		hookOnClassCreated: ( hooks, fn ) ->
			if Ext.getVersion( 'extjs' ) and Ext.getVersion( 'core' ).isLessThan( '4.1.0' )
				# Ext JS 4.0
				Ext.Function.interceptBefore( hooks, 'onClassCreated', fn )
			else
				# Sencha Touch 2.0+, Ext JS 4.1+
				Ext.Function.interceptBefore( hooks, 'onCreated', fn )
			return
		
		###*
		* Intercept class extension.
		*
		* (Normalizes API differences between the various Sencha frameworks and versions.)
		###
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

		###*
		* Determines whether the passed Class reference is or extends the specified Class (by name).
		*
		* @return {Boolean} A Boolean indicating whether the specified Class reference is or extends the specified Class (by name)
		###
		extendsClass: ( targetClass, className ) ->
			try
				return true if Ext.getClassName( targetClass ) is className
				if targetClass?.superclass
					if Ext.getClassName( targetClass.superclass ) is className
						return true
					else
						return Deft.Class.extendsClass( Ext.getClass( targetClass.superclass ), className )
				else return false
			catch error
				return false
)