###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###*
A mixin that creates and attaches the specified view controller(s) to the target view.

Used in conjunction with {@link Deft.mvc.ViewController}.
###
Ext.define( 'Deft.mixin.Controllable',
	requires: [ 'Deft.mvc.ViewController' ]

	###*
	@private
	###
	onClassMixedIn: ( targetClass ) ->
		if @controller?
			controllers = if Ext.isArray( @controller ) then @controller else [ @controller ]
			for controllerClass in controllers
				Ext.require( controllerClass )
		
		targetClass::constructor = Ext.Function.createSequence( targetClass::constructor, ->
			if not @controller?
				Ext.Error.raise( msg: 'Error initializing Controllable instance: \`controller\` was not specified.' )
			controllers = if Ext.isArray( @controller ) then @controller else [ @controller ]
			for controllerClass in controllers
				if Ext.ClassManager.isCreated( controllerClass )
					try
						Ext.create( controllerClass,
							view: @
						)
					catch error
						Deft.Logger.log( "Error initializing Controllable instance: an error occurred while creating an instance of the specified controller: '#{ @controller }'." )
						throw error
				else
					Ext.Error.raise( msg: "Error initializing Controllable instance: an error occurred while creating an instance of the specified controller: '#{ @controller }' does not exist." )
			return
		)
		return
)
