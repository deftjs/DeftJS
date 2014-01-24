###
Copyright (c) 2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

describe( 'Custom Assertions', ->

	specify( 'memberOf', ->
		expect( 1 ).to.be.a.memberOf( [ 1, 2, 3 ] )
		expect( 0 ).not.to.be.a.memberOf( [ 1, 2, 3 ] )
		return
	)

	specify( 'membersOf', ->
		expect( [ 1 ] ).to.be.membersOf( [ 1, 2, 3 ] )
		expect( [ 1, 2 ] ).to.be.membersOf( [ 1, 2, 3 ] )
		expect( [ 0 ] ).not.to.be.membersOf( [ 1, 2, 3 ] )
		expect( [ 0, 5 ] ).not.to.be.membersOf( [ 1, 2, 3 ] )
		return
	)

	specify( 'unique', ->
		expect( [ 1, 2, 3 ] ).to.be.unique
		expect( [ 1, 2, 1 ] ).not.to.be.unique
		return
	)

	specify( 'eventuallyThrow', ( done ) ->
		@slow( 250 )
		setTimeout(
			->
				throw new Error( 'error message' )
			0
		)
		assert.eventuallyThrows( new Error( 'error message' ), done, 100 )
		return
	)

	return
)