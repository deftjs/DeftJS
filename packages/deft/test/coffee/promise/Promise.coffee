###
Copyright (c) 2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

describe( 'Deft.promise.Promise', ->
	# Format values displayed by the test runner to make them human readable
	# and consistent across platforms.
	formatValue = ( value ) ->
		# Promises and Deferreds
		if value instanceof Deft.promise.Promise
			return 'Deft.Promise'
		if value instanceof Deft.promise.Deferred
			return 'Deft.Deferred'
		# All other Ext JS or Sencha Touch Class instances
		if value instanceof Ext.ClassManager.get( 'Ext.Base' )
			return Ext.ClassManager.getName( value )
		# Array
		if Ext.isArray( value )
			formattedValues = Ext.Array.map( value, formatValue )
			return "[#{ formattedValues.join(', ') }]"
		# Object
		if Ext.isObject( value )
			return 'Object'
		# String
		if Ext.isString( value )
			return "\"#{ value }\""
		return '' + value
	
	describe( 'when()', ->
		values = [ undefined, null, false, 0, 1, 'expected value', [ 1, 2, 3 ], {}, new Error( 'error message' ) ]
		
		describe( 'returns a Promise that will resolve with the specified value', ->
			for value in values
				do ( value ) ->
					specify( formatValue( value ), ->
						promise = Deft.Promise.when( value )
						
						promise.should.be.an.instanceof( Deft.Promise )
						return promise.should.eventually.equal( value )
					)
			return
		)
		
		describe( 'returns a Promise that will resolve with the resolved value for the specified Promise when it resolves', ->
			for value in values
				do( value ) ->
					specify( formatValue( value ), ->
						deferred = Ext.create( 'Deft.Deferred' )
						deferred.resolve( value )
						
						promise = Deft.Promise.when( deferred.promise )
						
						promise.should.not.be.equal( deferred.promise )
						promise.should.be.an.instanceof( Deft.Promise )
						return promise.should.eventually.equal( value )
					)
			return
		)
		
		describe( 'returns a Promise that will reject with the error associated with the specified Promise when it rejects', ->
			specify( 'Error: error message', ->
				deferred = Ext.create( 'Deft.Deferred' )
				deferred.reject( new Error( 'error message' ) )
				
				promise = Deft.Promise.when( deferred.promise )
				
				promise.should.not.be.equal( deferred.promise )
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will adapt the specified untrusted (aka third-party) then-able', ->
			class MockThirdPartyPromise
				then: ( @successCallback, @failureCallback ) ->
					switch @state
						when 'resolved'
							@successCallback( @value )
						when 'rejected'
							@failureCallback( @value )
					return
				resolve: ( @value ) ->
					@state = 'resolved'
					@successCallback( @value ) if @successCallback?
					return
				reject: ( @value ) ->
					@state = 'rejected'
					@failureCallback( @value ) if @failureCallback?
					return

			specify( 'resolves when resolved', ->
				mockThirdPartyPromise = new MockThirdPartyPromise()
				mockThirdPartyPromise.resolve( 'expected value' )

				promise = Deft.Promise.when( mockThirdPartyPromise )

				promise.should.not.be.equal( mockThirdPartyPromise )
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'rejects when rejected', ->
				mockThirdPartyPromise = new MockThirdPartyPromise()
				mockThirdPartyPromise.resolve( 'expected value' )

				promise = Deft.Promise.when( mockThirdPartyPromise )

				promise.should.not.be.equal( mockThirdPartyPromise )
				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			return
		)

		return
	)

	describe( 'isPromise()', ->
		describe( 'returns true for a Deft.Promise or then()-able', ->
			specify( 'Deft.Promise', ->
				promise = Ext.create( 'Deft.Deferred' ).promise

				expect( Deft.Promise.isPromise( promise ) ).to.be.true
				return
			)

			specify( 'returns true for any then()-able', ->
				promise = { then: -> return }

				expect( Deft.Promise.isPromise( promise ) ).to.be.true
				return
			)

			return
		)

		describe( 'returns false for non-promises', ->
			values = [ undefined, null, false, 0, 1, 'value', [ 1, 2, 3 ], {}, new Error( 'error message' ) ]
			for value in values
				do ( value ) ->
					specify( formatValue( value ), ->
						expect( Deft.Promise.isPromise( value ) ).to.be.false
						return
					)

			return
		)

		return
	)

	describe( 'all()', ->
		describe( 'returns a new Promise that will resolve with the resolved values for the specified Array of Promises(s) or values.', ->
			specify( 'Empty Array', ->
				promise = Deft.Promise.all( [] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)

			specify( 'Array with one value', ->
				promise = Deft.Promise.all( [ 'expected value' ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Array of values', ->
				promise = Deft.Promise.all( [ 1, 2, 3 ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)

			specify( 'Sparse Array', ->
				promise = Deft.Promise.all( `[,2,,4,5]` )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( `[,2,,4,5]` )
			)

			specify( 'Array with one resolved Promise', ->
				promise = Deft.Promise.all( [ Deft.Deferred.resolve( 'expected value' ) ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Array of resolved Promises', ->
				promise = Deft.Promise.all( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)

			return
		)

		describe( 'returns a new Promise that will resolve with the resolved values for the specified resolved Promise of an Array of Promises(s) or values.', ->
			specify( 'Promise of an empty Array', ->
				promise = Deft.Promise.all(
					Deft.Deferred.resolve(
						[]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)

			specify( 'Promise of an Array with one value', ->
				promise = Deft.Promise.all(
					Deft.Deferred.resolve(
						[ 'expected value' ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Promise of an Array of values', ->
				promise = Deft.Promise.all(
					Deft.Deferred.resolve(
						[ 1, 2, 3 ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)

			specify( 'Promise of a sparse Array', ->
				promise = Deft.Promise.all(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( `[,2,,4,5]` )
			)

			specify( 'Promise of an Array with one resolved Promise', ->
				promise = Deft.Promise.all(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 'expected value' ) ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Promise of an Array of resolved Promises', ->
				promise = Deft.Promise.all(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 1, 2, 3 ] )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the first Promise in the specified Array of Promise(s) or value(s) that rejects', ->
			specify( 'Array with one rejected Promise', ->
				promise = Deft.Promise.all( [ Deft.Deferred.reject( new Error( 'error message' ) ) ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.all( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 3 ) ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of values, pending and resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.all( [ 1, 2, Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 4 ), Ext.create( 'Deft.Deferred' ).promise ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the first Promise in the specified resolved Promise of an Array of Promise(s) or value(s) that rejects', ->
			specify( 'Promise of an Array with one rejected Promise', ->
				promise = Deft.Promise.all(
					Deft.Deferred.resolve(
						[ Deft.Deferred.reject( new Error( 'error message' ) ) ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.all(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 3 ) ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of values, pending and resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.all(
					Deft.Deferred.resolve(
						[ 1, 2, Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 4 ), Ext.create( 'Deft.Deferred' ).promise ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the rejected Promise of an Array of Promise(s) or value(s)', ->
			specify( 'Error: error message', ->
				promise = Deft.Promise.all(
					Deft.Deferred.reject(
						new Error( 'error message' )
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'throws an Error if anything other than Array or Promise of an Array is specified', ->
			specify( 'no parameters', ->
				expect( -> Deft.Promise.all() ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'a single non-Array parameter', ->
				expect( -> Deft.Promise.all( 1 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'multiple non-Array parameters', ->
				expect( -> Deft.Promise.all( 1, 2, 3 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			return
		)

		return
	)

	describe( 'any()', ->
		describe( 'returns a new Promise that will resolve once any one of the specified Array of Promises(s) or values have resolved.', ->
			specify( 'Array with one value', ->
				promise = Deft.Promise.any( [ 'expected value' ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'Array of values', ->
				promise = Deft.Promise.any( [ 1, 2, 3 ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.be.a.memberOf( [ 1, 2, 3 ] )
			)

			specify( 'Sparse Array', ->
				promise = Deft.Promise.any( `[,2,,4,5]` )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.be.a.memberOf( [ 2, 4, 5 ] )
			)

			specify( 'Array with one resolved Promise', ->
				promise = Deft.Promise.any( [ Deft.Deferred.resolve( 'expected value' ) ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'Array of resolved Promises', ->
				promise = Deft.Promise.any( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.be.a.memberOf( [ 1, 2, 3 ] )
			)

			specify( 'Array of rejected Promises and one resolved Promise', ->
				promise = Deft.Promise.any( [ Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 'expected value' ), Deft.Deferred.reject( 'error message' ) ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'Array of pending and rejected Promises and one resolved Promise', ->
				promise = Deft.Promise.any( [ Ext.create( 'Deft.Deferred' ).promise, Deft.Deferred.resolve( 'expected value' ), Deft.Deferred.reject( 'error message' ) ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'Array of pending and rejected Promises and multiple resolved Promises', ->
				promise = Deft.Promise.any( [ Ext.create( 'Deft.Deferred' ).promise, Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 2 ) ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.be.a.memberOf( [ 1, 2 ] )
			)

			return
		)

		describe( 'returns a new Promise that will resolve once any one of the specified resolved Promise of an Array of Promises(s) or values have resolved.', ->
			specify( 'Promise of an Array with one value', ->
				promise = Deft.Promise.any(
					Deft.Deferred.resolve(
						[ 'expected value' ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'Promise of an Array of values', ->
				promise = Deft.Promise.any(
					Deft.Deferred.resolve(
						[ 1, 2, 3 ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.be.a.memberOf( [ 1, 2, 3 ] )
			)

			specify( 'Promise of a sparse Array', ->
				promise = Deft.Promise.any(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.be.a.memberOf( [ 2, 4, 5 ] )
			)

			specify( 'Promise of an Array with one resolved Promise', ->
				promise = Deft.Promise.any(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 'expected value' ) ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'Promise of an Array of resolved Promise', ->
				promise = Deft.Promise.any(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.to.be.a.memberOf( [ 1, 2, 3 ] )
			)

			specify( 'Promise of an Array of rejected Promises and one resolved Promise', ->
				promise = Deft.Promise.any(
					Deft.Deferred.resolve(
						[ Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 'expected value' ), Deft.Deferred.reject( 'error message' ) ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'Promise of an Array of pending and rejected Promises and one resolved Promise', ->
				promise = Deft.Promise.any(
					Deft.Deferred.resolve(
						[ Ext.create( 'Deft.Deferred' ).promise, Deft.Deferred.resolve( 'expected value' ), Deft.Deferred.reject( 'error message' ) ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'Promise of an Array of pending and rejected Promises and multiple resolved Promises', ->
				promise = Deft.Promise.any(
					Deft.Deferred.resolve(
						[ Ext.create( 'Deft.Deferred' ).promise, Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 2 ) ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.be.a.memberOf( [ 1, 2 ] )
			)

			return
		)

		describe( 'returns a new Promise that will reject if none of the specified Array of Promises(s) or values resolves.', ->
			specify( 'Empty Array', ->
				promise = Deft.Promise.any( [] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'No Promises were resolved.' )
			)

			specify( 'Array with one rejected Promise', ->
				promise = Deft.Promise.any( [ Deft.Deferred.reject( 'error message' ) ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'No Promises were resolved.' )
			)

			specify( 'Array of rejected Promises', ->
				promise = Deft.Promise.any( [ Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ) ] )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'No Promises were resolved.' )
			)

			return
		)

		describe( 'returns a new Promise that will reject if none of the specified resolved Promise of an Array of Promises(s) or values resolves.', ->
			specify( 'Promise of an empty Array', ->
				promise = Deft.Promise.any(
					Deft.Deferred.resolve( [] )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'No Promises were resolved.' )
			)

			specify( 'Promise of an Array with one rejected Promise', ->
				promise = Deft.Promise.any(
					Deft.Deferred.resolve(
						[ Deft.Deferred.reject( 'error message' ) ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'No Promises were resolved.' )
			)

			specify( 'Promise of an Array of rejected Promises', ->
				promise = Deft.Promise.any(
					Deft.Deferred.resolve(
						[ Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ) ]
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'No Promises were resolved.' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the rejected Promise of an Array of Promise(s) or value(s)', ->
			specify( 'Error: error message', ->
				promise = Deft.Promise.any(
					Deft.Deferred.reject(
						new Error( 'error message' )
					)
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'throws an Error if anything other than Array or Promise of an Array is specified', ->
			specify( 'no parameters', ->
				expect( -> Deft.Promise.any() ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'a single non-Array parameter', ->
				expect( -> Deft.Promise.any( 1 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'multiple non-Array parameters', ->
				expect( -> Deft.Promise.any( 1, 2, 3 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			return
		)

		return
	)

	describe( 'some()', ->
		describe( 'returns a new Promise that will resolve once the specified number of the specified Array of Promises(s) or values have resolved.', ->
			specify( 'Array with one value', ->
				promise = Deft.Promise.some( [ 'expected value' ], 1 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Array of values', ->
				promise = Deft.Promise.some( [ 1, 2, 3 ], 2 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.have.a.lengthOf( 2 ).and.be.membersOf( [ 1, 2, 3 ] )
			)

			specify( 'Sparse Array', ->
				promise = Deft.Promise.some( `[,2,,4,5]`, 2 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.have.a.lengthOf( 2 ).and.be.membersOf( [ 2, 4, 5 ] )
			)

			specify( 'Array with one resolved Promise', ->
				promise = Deft.Promise.some( [ Deft.Deferred.resolve( 'expected value' ) ], 1 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Array of resolved Promises', ->
				promise = Deft.Promise.some( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ], 2 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.have.a.lengthOf( 2 ).and.be.membersOf( [ 1, 2, 3 ] )
			)

			specify( 'Array of rejected Promises and one resolved Promise', ->
				promise = Deft.Promise.some( [ Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 'expected value' ), Deft.Deferred.reject( 'error message' ) ], 1 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Array of pending and rejected Promises and one resolved Promise', ->
				promise = Deft.Promise.some( [ Ext.create( 'Deft.Deferred' ).promise, Deft.Deferred.resolve( 'expected value' ), Deft.Deferred.reject( 'error message' ) ], 1 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Array of rejected Promises and multiple resolved Promises', ->
				promise = Deft.Promise.some( [ Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 2 ) ], 2 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.have.a.lengthOf( 2 ).and.be.membersOf( [ 1, 2 ] )
			)

			specify( 'Array of pending and rejected Promises and multiple resolved Promises', ->
				promise = Deft.Promise.some( [ Ext.create( 'Deft.Deferred' ).promise, Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 2 ) ], 2 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.have.a.lengthOf( 2 ).and.be.membersOf( [ 1, 2 ] )
			)

			return
		)

		describe( 'returns a new Promise that will resolve once the specified number of the specified resolved Promise of an Array of Promises(s) or values have resolved.', ->
			specify( 'Promise of an Array with one value', ->
				promise = Deft.Promise.some(
					Deft.Promise.when(
						[ 'expected value' ]
					)
					1
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Promise of an Array of values', ->
				promise = Deft.Promise.some(
					Deft.Promise.when(
						[ 1, 2, 3 ]
					)
					2
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.have.a.lengthOf( 2 ).and.be.membersOf( [ 1, 2, 3 ] )
			)

			specify( 'Promise of a sparse Array', ->
				promise = Deft.Promise.some(
					Deft.Promise.when(
						`[,2,,4,5]`
					)
					2
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.have.a.lengthOf( 2 ).and.be.membersOf( [ 2, 4, 5 ] )
			)

			specify( 'Promise of an Array with one resolved Promise', ->
				promise = Deft.Promise.some(
					Deft.Promise.when(
						[ Deft.Deferred.resolve( 'expected value' ) ]
					)
					1
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Promise of an Array of resolved Promises', ->
				promise = Deft.Promise.some(
					Deft.Promise.when(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
					2
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.have.a.lengthOf( 2 ).and.be.membersOf( [ 1, 2, 3 ] )
			)

			specify( 'Promise of an Array of rejected Promises and one resolved Promise', ->
				promise = Deft.Promise.some(
					Deft.Promise.when(
						[ Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 'expected value' ), Deft.Deferred.reject( 'error message' ) ]
					)
					1
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Promise of an Array of pending and rejected Promises and one resolved Promise', ->
				promise = Deft.Promise.some(
					Deft.Promise.when(
						[ Ext.create( 'Deft.Deferred' ).promise, Deft.Deferred.resolve( 'expected value' ), Deft.Deferred.reject( 'error message' ) ]
					)
					1
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 'expected value' ] )
			)

			specify( 'Promise of an Array of rejected Promises and multiple resolved Promises', ->
				promise = Deft.Promise.some(
					Deft.Promise.when(
						[ Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 2 ) ]
					)
					2
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.have.a.lengthOf( 2 ).and.be.membersOf( [ 1, 2 ] )
			)

			specify( 'Promise of an Array of pending and rejected Promises and multiple resolved Promises', ->
				promise = Deft.Promise.some(
					Deft.Promise.when(
						[ Ext.create( 'Deft.Deferred' ).promise, Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.resolve( 2 ) ]
					)
					2
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.have.a.lengthOf( 2 ).and.be.membersOf( [ 1, 2 ] )
			)

			return
		)

		describe( 'returns a new Promise that will reject if too few of the specified Array of Promises(s) or values resolves.', ->
			specify( 'Empty Array with one resolved value requested', ->
				promise = Deft.Promise.some( [], 1 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			specify( 'Empty Array with multiple resolved values requested', ->
				promise = Deft.Promise.some( [], 2 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			specify( 'Array with one rejected Promise with one resolved value requested', ->
				promise = Deft.Promise.some( [ Deft.Deferred.reject( 'error message' ) ], 1 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			specify( 'Array with one rejected Promise with multiple resolved values requested', ->
				promise = Deft.Promise.some( [ Deft.Deferred.reject( 'error message' ) ], 2 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			specify( 'Array of rejected Promises with one resolved value requested', ->
				promise = Deft.Promise.some( [ Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ) ], 1 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			specify( 'Array of rejected Promises with multiple resolved values requested', ->
				promise = Deft.Promise.some( [ Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ) ], 2 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			return
		)

		describe( 'returns a new Promise that will reject if too few of the specified resolved Promise of an Array of Promises(s) or values resolves.', ->
			specify( 'Promise of an empty Array with one resolved value requested', ->
				promise = Deft.Promise.some(
					Deft.Deferred.resolve(
						[]
					)
					1
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			specify( 'Promise of an empty Array with multiple resolved values requested', ->
				promise = Deft.Promise.some(
					Deft.Deferred.resolve(
						[]
					)
					2
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			specify( 'Promise of an Array with one rejected Promise with one resolved value requested', ->
				promise = Deft.Promise.some(
					Deft.Deferred.resolve(
						[ Deft.Deferred.reject( 'error message' ) ]
					)
					1
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			specify( 'Promise of an Array with one rejected Promise with multiple resolved values requested', ->
				promise = Deft.Promise.some(
					Deft.Deferred.resolve(
						[ Deft.Deferred.reject( 'error message' ) ]
					)
					2
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			specify( 'Promise of an Array of rejected Promises with one resolved value requested', ->
				promise = Deft.Promise.some(
					Deft.Deferred.resolve(
						[ Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ) ]
					)
					1
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			specify( 'Promise of an Array of rejected Promises with multiple resolved values requested', ->
				promise = Deft.Promise.some(
					Deft.Deferred.resolve(
						[ Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ), Deft.Deferred.reject( 'error message' ) ]
					)
					2
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Too few Promises were resolved.' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the rejected Promise of an Array of Promise(s) or value(s)', ->
			specify( 'Error: error message', ->
				promise = Deft.Promise.some(
					Deft.Deferred.reject(
						new Error( 'error message' )
					)
					2
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'throws an Error if anything other than Array or Promise of an Array is specified', ->
			specify( 'no parameters', ->
				expect( -> Deft.Promise.some() ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'a single non-Array parameter', ->
				expect( -> Deft.Promise.some( 1 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'multiple non-Array parameters', ->
				expect( -> Deft.Promise.some( 1, 2, 3 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'a single Array parameter', ->
				expect( -> Deft.Promise.some( [ 1, 2, 3 ] ) ).to.throw( Error, 'Invalid parameter: expected a positive integer.' )
				return
			)

			specify( 'a single Array parameter and a non-numeric value', ->
				expect( -> Deft.Promise.some( [ 1, 2, 3 ], 'value' ) ).to.throw( Error, 'Invalid parameter: expected a positive integer.' )
				return
			)

			return
		)

		return
	)

	describe( 'delay()', ->
		now = -> new Date().getTime()

		describe( 'returns a new Promise that will resolve after the specified delay', ->
			specify( '0 ms delay', ->
				promise = Deft.Promise.delay( 0 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( undefined )
			)

			specify( 'value with 100 ms delay', ->
				@slow( 250 )

				promise = Deft.Promise.delay( 100 )

				start = now()

				promise.should.be.an.instanceof( Deft.Promise )
				promise = promise.then(
					( value ) ->
						expect( now() - start ).to.be.closeTo( 100, 100 )
						return value
				)
				return promise.should.eventually.equal( undefined )
			)

			return
		)

		describe( 'returns a new Promise that will resolve with the specified Promise or value after the specified delay', ->
			specify( 'value with 0 ms delay', ->
				promise = Deft.Promise.delay( 'expected value', 0 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'resolved Promise with 0 delay', ->
				promise = Deft.Promise.delay( Deft.Deferred.resolve( 'expected value' ), 0 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'value with 100 ms delay', ->
				@slow( 250 )

				promise = Deft.Promise.delay( 'expected value', 100 )

				start = now()

				promise.should.be.an.instanceof( Deft.Promise )
				promise = promise.then(
					( value ) ->
						expect( now() - start ).to.be.closeTo( 100, 50 )
						return value
				)
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'resolved Promise with 100 ms delay', ->
				@slow( 250 )

				promise = Deft.Promise.delay( Deft.Deferred.resolve( 'expected value' ), 100 )

				start = now()

				promise.should.be.an.instanceof( Deft.Promise )
				promise = promise.then(
					( value ) ->
						expect( now() - start ).to.be.closeTo( 100, 50 )
						return value
				)
				return promise.should.eventually.equal( 'expected value' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the specified rejected Promise after the specified delay', ->
			specify( 'rejected Promise with 100 ms delay', ->
				@slow( 250 )

				promise = Deft.Promise.delay( Deft.Deferred.reject( new Error( 'error message' ) ), 100 )

				start = now()

				promise.should.be.an.instanceof( Deft.Promise )
				promise = promise.then(
					( value ) ->
						return value
					( error ) ->
						expect( now() - start ).to.be.closeTo( 100, 50 )
						throw error
				)
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		return
	)

	describe( 'timeout()', ->
		describe( 'returns a new Promise that will resolve with the specified Promise or value if it resolves before the specified timeout', ->
			specify( 'value with 100 ms timeout', ->
				@slow( 250 )

				promise = Deft.Promise.timeout(
					'expected value'
					100
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			specify( 'Promise that resolves in 50 ms with a 100 ms timeout', ->
				@slow( 250 )

				promise = Deft.Promise.timeout(
					Deft.Promise.delay( 'expected value', 50 )
					100
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'expected value' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the specified rejected Promise if it rejects before the specified timeout', ->
			specify( 'Promise that rejects in 50 ms with a 100 ms timeout', ->
				@slow( 250 )

				promise = Deft.Promise.timeout(
					Deft.Promise.delay( Deft.Deferred.reject( new Error( 'error message' ) ), 50 )
					100
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject after the specified timeout if the specified Promise or value has not yet resolved or rejected', ->
			specify( 'Promise that resolves in 100 ms with a 50 ms timeout', ->
				@slow( 250 )

				promise = Deft.Promise.timeout(
					Deft.Promise.delay( 'expected value', 100 )
					50
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Promise timed out.' )
			)

			specify( 'Promise that rejects in 50 ms with a 100 ms timeout', ->
				@slow( 250 )

				promise = Deft.Promise.timeout(
					Deft.Promise.delay( Deft.Deferred.reject( new Error( 'error message' ) ), 100 )
					50
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'Promise timed out.' )
			)

			return
		)

		return
	)

	describe( 'memoize()', ->
		fibonacci = ( n ) ->
			( if n < 2 then n else fibonacci( n - 1 ) + fibonacci( n - 2 ) )

		describe( 'returns a new function that wraps the specified function, caching results for previously processed inputs, and returns a Promise that will resolve with the result value', ->
			specify( 'value', ->
				targetFunction = sinon.spy( fibonacci )

				memoFunction = Deft.Promise.memoize( targetFunction )
				promise = Deft.Promise.all(
					[
						memoFunction( 12 )
						memoFunction( 12 )
					]
				).then(
					( value ) ->
						expect( targetFunction ).to.be.calledOnce
						return value
					( error ) ->
						throw error
				)

				return promise.should.eventually.deep.equal( [ fibonacci( 12 ), fibonacci( 12 ) ] )
			)

			specify( 'resolved Promise', ->
				targetFunction = sinon.spy( fibonacci )

				memoFunction = Deft.Promise.memoize( targetFunction )
				promise = Deft.Promise.all(
					[
						memoFunction( Deft.Deferred.resolve( 12 ) )
						memoFunction( Deft.Deferred.resolve( 12 ) )
					]
				).then(
					( value ) ->
						expect( targetFunction ).to.be.calledOnce
						return value
					( error ) ->
						throw error
				)

				return promise.should.eventually.deep.equal( [ fibonacci( 12 ), fibonacci( 12 ) ] )
			)

			return
		)

		describe( 'executes the wrapped function in the optionally specified scope', ->
			specify( 'optional scope omitted', ->
				targetFunction = sinon.spy( fibonacci )

				memoFunction = Deft.Promise.memoize( targetFunction )
				promise = memoFunction( 12 ).then(
					( value ) ->
						expect( targetFunction ).to.be.calledOnce.and.calledOn( window )
						return value
					( error ) ->
						throw error
				)

				return promise.should.eventually.equal( fibonacci( 12 ) )
			)

			specify( 'scope specified', ->
				targetScope = {}
				targetFunction = sinon.spy( fibonacci )

				memoFunction = Deft.Promise.memoize( targetFunction, targetScope )
				promise = memoFunction( 12 ).then(
					( value ) ->
						expect( targetFunction ).to.be.calledOnce.and.calledOn( targetScope )
						return value
					( error ) ->
						throw error
				)

				return promise.should.eventually.equal( fibonacci( 12 ) )
			)

			return
		)

		describe( 'returns a new function that wraps the specified function and returns a Promise that will reject with the associated error when the wrapper function is called with a rejected Promise', ->
			specify( 'rejected Promise', ->
				targetFunction = sinon.spy( fibonacci )

				memoFunction = Deft.Promise.memoize( targetFunction )
				promise = memoFunction( Deft.Deferred.reject( new Error( 'error message' ) ) )

				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		return
	)

	describe( 'map()', ->
		doubleFunction = ( value, index, array ) ->
			expect( arguments ).to.have.lengthOf( 3 )
			expect( array ).to.be.instanceof( Array )
			expect( index ).to.be.at.least( 0 ).and.lessThan( array.length )
			return value * 2

		doublePromiseFunction = ( value, index, array ) ->
			expect( arguments ).to.have.lengthOf( 3 )
			expect( array ).to.be.instanceof( Array )
			expect( index ).to.be.at.least( 0 ).and.lessThan( array.length )
			return Deft.Deferred.resolve( value * 2 )

		rejectFunction = ( value, index, array ) ->
			expect( arguments ).to.have.lengthOf( 3 )
			expect( array ).to.be.instanceof( Array )
			expect( index ).to.be.at.least( 0 ).and.lessThan( array.length )
			return Deft.Deferred.reject( new Error( 'error message' ) )

		describe( 'returns a new Promise that will resolve with an Array of the mapped values for the specified Array of Promise(s) or value(s)', ->
			specify( 'Empty Array', ->
				promise = Deft.Promise.map( [], doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)

			specify( 'Array with one value', ->
				promise = Deft.Promise.map( [ 1 ], doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2 ] )
			)

			specify( 'Array of values', ->
				promise = Deft.Promise.map( [ 1, 2, 3 ], doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6 ] )
			)

			specify( 'Sparse Array', ->
				promise = Deft.Promise.map( `[,2,,4,5]`, doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( `[,4,,8,10]` )
			)

			specify( 'Array with one resolved Promise', ->
				promise = Deft.Promise.map( [ Deft.Deferred.resolve( 1 ) ], doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2 ] )
			)

			specify( 'Array of resolved Promises', ->
				promise = Deft.Promise.map( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ], doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6 ] )
			)

			specify( 'Array of values and resolved Promises', ->
				promise = Deft.Promise.map( [ 1, Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ), 4 ], doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6, 8 ] )
			)

			return
		)

		describe( 'returns a new Promise that will resolve with an Array of the mapped values for the specified resolved Promise of an Array of Promise(s) or value(s)', ->
			specify( 'Promise of an empty Array', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[]
					)
					doubleFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)

			specify( 'Promise of an Array with one value', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ 1 ]
					)
					doubleFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2 ] )
			)

			specify( 'Promise of an Array of values', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ 1, 2, 3 ]
					)
					doubleFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6 ] )
			)

			specify( 'Promise of a sparse Array', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
					doubleFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( `[,4,,8,10]` )
			)

			specify( 'Promise of an Array with one resolved Promise', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ) ]
					)
					doubleFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2 ] )
			)

			specify( 'Promise of an Array of resolved Promises', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
					doubleFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6 ] )
			)

			specify( 'Promise of an Array of values and resolved Promises', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ), 4 ]
					)
					doubleFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6, 8 ] )
			)

			return
		)

		describe( 'returns a new Promise that will resolve with an Array of the resolved mapped Promises values for the specified Array of Promise(s) or value(s)', ->
			specify( 'Empty Array', ->
				promise = Deft.Promise.map( [], doublePromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)

			specify( 'Array with one value', ->
				promise = Deft.Promise.map( [ 1 ], doublePromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2 ] )
			)

			specify( 'Array of values', ->
				promise = Deft.Promise.map( [ 1, 2, 3 ], doublePromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6 ] )
			)

			specify( 'Sparse Array', ->
				promise = Deft.Promise.map( `[,2,,4,5]`, doublePromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( `[,4,,8,10]` )
			)

			specify( 'Array with one resolved Promise', ->
				promise = Deft.Promise.map( [ Deft.Deferred.resolve( 1 ) ], doublePromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2 ] )
			)

			specify( 'Array of resolved Promises', ->
				promise = Deft.Promise.map( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ], doublePromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6 ] )
			)

			specify( 'Array of values and resolved Promises', ->
				promise = Deft.Promise.map( [ 1, Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ), 4 ], doublePromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6, 8 ] )
			)

			return
		)

		describe( 'returns a new Promise that will resolve with an Array of the resolved mapped Promises values for the specified resolved Promise of an Array of Promise(s) or value(s)', ->
			specify( 'Promise of an empty Array', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[]
					)
					doublePromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [] )
			)

			specify( 'Promise of an Array with one value', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ 1 ]
					)
					doublePromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2 ] )
			)

			specify( 'Promise of an Array of values', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ 1, 2, 3 ]
					)
					doublePromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6 ] )
			)

			specify( 'Promise of a sparse Array', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
					doublePromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( `[,4,,8,10]` )
			)

			specify( 'Promise of an Array with one resolved Promise', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ) ]
					)
					doublePromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2 ] )
			)

			specify( 'Promise of an Array of resolved Promises', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
					doublePromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6 ] )
			)

			specify( 'Promise of an Array of values and resolved Promises', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ), 4 ]
					)
					doublePromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.deep.equal( [ 2, 4, 6, 8 ] )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the first Promise in the specified Array of Promise(s) or value(s) that rejects', ->
			specify( 'Array with one rejected Promise', ->
				promise = Deft.Promise.map( [ Deft.Deferred.reject( new Error( 'error message' ) ) ], doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of values and a rejected Promise', ->
				promise = Deft.Promise.map( [ 1, Deft.Deferred.reject( new Error( 'error message' ) ), 3 ], doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.map( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 3 ) ], doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of values, pending and resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.map( [ 1, 2, Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 4 ), Ext.create( 'Deft.Deferred' ).promise ], doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the first Promise in the specified resolved Promise of an Array of Promise(s) or value(s) that rejects', ->
			specify( 'Promise of an Array with one rejected Promise', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ Deft.Deferred.reject( new Error( 'error message' ) ) ]
					)
					doubleFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of values and a rejected Promise', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.reject( new Error( 'error message' ) ), 3 ]
					)
					doubleFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 3 ) ]
					)
					doubleFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of values, pending and resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ 1, 2, Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 4 ), Ext.create( 'Deft.Deferred' ).promise ]
					)
					doubleFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the first mapped Promise value in the specified Array of Promise(s) or value(s) that rejects', ->
			specify( 'Array with one value', ->
				promise = Deft.Promise.map( [ 1 ], rejectFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of values', ->
				promise = Deft.Promise.map( [ 1, 2, 3 ], rejectFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Sparse Array', ->
				promise = Deft.Promise.map(`[,2,,4,5]`, rejectFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array with one resolved Promise', ->
				promise = Deft.Promise.map( [ Deft.Deferred.resolve( 1 ) ], rejectFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of resolved Promises', ->
				promise = Deft.Promise.map( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ], rejectFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of values and resolved Promises', ->
				promise = Deft.Promise.map( [ 1, Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ), 4 ], rejectFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the first mapped Promise value in the specified resolved Promise of an Array of Promise(s) or value(s) that rejects', ->
			specify( 'Promise of an Array with one value', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ 1 ]
					)
					rejectFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of values', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ 1, 2, 3 ]
					)
					rejectFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of a sparse Array', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
					rejectFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array with one resolved Promise', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ) ]
					)
					rejectFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of resolved Promises', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
					rejectFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of values and resolved Promises', ->
				promise = Deft.Promise.map(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ), 4 ]
					)
					rejectFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the rejected Promise of an Array of Promise(s) or value(s)', ->
			specify( 'Error: error message', ->
				promise = Deft.Promise.map( Deft.Deferred.reject( new Error( 'error message' ) ), doubleFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'throws an Error if anything other than an Array or Promise of an Array and a function are specified', ->
			specify( 'no parameters', ->
				expect( -> Deft.Promise.map() ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'a single non-Array parameter', ->
				expect( -> Deft.Promise.map( 1 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'multiple non-Array parameters', ->
				expect( -> Deft.Promise.map( 1, 2, 3 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'an Array and no function', ->
				expect( -> Deft.Promise.map( [ 1, 2, 3 ] ) ).to.throw( Error, 'Invalid parameter: expected a function.' )
				return
			)

			specify( 'a Promise of an Array and no function', ->
				expect( -> Deft.Promise.map( Deft.Deferred.resolve( [ 1, 2, 3 ] ) ) ).to.throw( Error, 'Invalid parameter: expected a function.' )
				return
			)

			specify( 'an Array and a non-function parameter', ->
				expect( -> Deft.Promise.map( [ 1, 2, 3 ], 'not a function' ) ).to.throw( Error, 'Invalid parameter: expected a function.' )
				return
			)

			specify( 'a Promise of a non-function parameter', ->
				expect( -> Deft.Promise.map( Deft.Deferred.resolve( [ 1, 2, 3 ], 'not a function' ) ) ).to.throw( Error, 'Invalid parameter: expected a function.' )
				return
			)

			return
		)

		return
	)

	describe( 'reduce()', ->
		sumFunction = ( previousValue, currentValue, index, array ) ->
			expect( arguments ).to.have.lengthOf( 4 )
			expect( array ).to.be.instanceof( Array )
			expect( index ).to.be.at.least( 0 ).and.lessThan( array.length )
			return previousValue + currentValue

		sumPromiseFunction = ( previousValue, currentValue, index, array ) ->
			expect( arguments ).to.have.lengthOf( 4 )
			expect( array ).to.be.instanceof( Array )
			expect( index ).to.be.at.least( 0 ).and.lessThan( array.length )
			return Deft.Deferred.resolve( previousValue + currentValue )

		rejectFunction = ( previousValue, currentValue, index, array ) ->
			expect( arguments ).to.have.lengthOf( 4 )
			expect( array ).to.be.instanceof( Array )
			expect( index ).to.be.at.least( 0 ).and.lessThan( array.length )
			return Deft.Deferred.reject( new Error( 'error message' ) )

		describe( 'returns a Promise that will resolve with the value obtained by reducing the specified Array of Promise(s) or value(s) using the specified function and initial value', ->
			specify( 'Empty Array and an initial value', ->
				promise = Deft.Promise.reduce( [], sumFunction, 0 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 0 )
			)

			specify( 'Empty Array and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [], sumFunction, Deft.Deferred.resolve( 0 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 0 )
			)

			specify( 'Array with one value', ->
				promise = Deft.Promise.reduce( [ 1 ], sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 1 )
			)

			specify( 'Array with one value and an initial value', ->
				promise = Deft.Promise.reduce( [ 1 ], sumFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Array with one value and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [ 1 ], sumFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Array of values', ->
				promise = Deft.Promise.reduce( [ 1, 2, 3, 4 ], sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 10 )
			)

			specify( 'Array of values and an initial value', ->
				promise = Deft.Promise.reduce( [ 1, 2, 3, 4 ], sumFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Array of values and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [ 1, 2, 3, 4 ], sumFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Sparse Array', ->
				promise = Deft.Promise.reduce( `[,2,,4,5]`, sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Sparse Array and an initial value', ->
				promise = Deft.Promise.reduce( `[,2,,4,5]`, sumFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 21 )
			)

			specify( 'Sparse Array and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( `[,2,,4,5]`, sumFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 21 )
			)

			specify( 'Array with one resolved Promise', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ) ], sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 1 )
			)

			specify( 'Array with one resolved Promise and an initial value', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ) ], sumFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Array with one resolved Promise and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ) ], sumFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Array of resolved Promises', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ], sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 6 )
			)

			specify( 'Array of resolved Promises and an initial value', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ], sumFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 16 )
			)

			specify( 'Array of resolved Promises and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ], sumFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 16 )
			)

			specify( 'Array of values and resolved Promises', ->
				promise = Deft.Promise.reduce( [ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ], sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 10 )
			)

			specify( 'Array of values and resolved Promises and an initial value', ->
				promise = Deft.Promise.reduce( [ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ], sumFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Array of values and resolved Promises and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ], sumFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			return
		)

		describe( 'returns a Promise that will resolve with the value obtained by reducing the specified resolved Promise of an Array of Promise(s) or value(s) using the specified function and initial value', ->
			specify( 'Promise of an empty Array and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[]
					)
					sumFunction
					0
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 0 )
			)

			specify( 'Promise of an empty Array and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[]
					)
					sumFunction
					Deft.Deferred.resolve( 0 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 0 )
			)

			specify( 'Promise of an Array with one value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1 ]
					)
					sumFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 1 )
			)

			specify( 'Promise of an Array with one value and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1 ]
					)
					sumFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Promise of an Array with one value and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1 ]
					)
					sumFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Promise of an Array of values', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, 2, 3, 4 ]
					)
					sumFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 10 )
			)

			specify( 'Promise of an Array of values and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, 2, 3, 4 ]
					)
					sumFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Promise of an Array of values and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, 2, 3, 4 ]
					)
					sumFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Promise of a sparse Array', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
					sumFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Promise of a sparse Array and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
					sumFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 21 )
			)

			specify( 'Promise of a sparse Array and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
					sumFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 21 )
			)

			specify( 'Promise of an Array with one resolved Promise', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ) ]
					)
					sumFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 1 )
			)

			specify( 'Promise of an Array with one resolved Promise and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ) ]
					)
					sumFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Promise of an Array with one resolved Promise and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ) ]
					)
					sumFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Promise of an Array of resolved Promises', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
					sumFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 6 )
			)

			specify( 'Promise of an Array of resolved Promises and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
					sumFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 16 )
			)

			specify( 'Promise of an Array of resolved Promises and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
					sumFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 16 )
			)

			specify( 'Promise of an Array of values and resolved Promises', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ]
					)
					sumFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 10 )
			)

			specify( 'Promise of an Array of values and resolved Promises and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ]
					)
					sumFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Promise of an Array of values and resolved Promises and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ]
					)
					sumFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			return
		)

		describe( 'returns a Promise that will resolve with the resolved Promise value obtained by reducing the specified Array of Promise(s) or value(s) using the specified function and initial value', ->
			specify( 'Empty Array and an initial value', ->
				promise = Deft.Promise.reduce( [], sumPromiseFunction, 0 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 0 )
			)

			specify( 'Empty Array and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [], sumPromiseFunction, Deft.Deferred.resolve( 0 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 0 )
			)

			specify( 'Array with one value', ->
				promise = Deft.Promise.reduce( [ 1 ], sumPromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 1 )
			)

			specify( 'Array with one value and an initial value', ->
				promise = Deft.Promise.reduce( [ 1 ], sumPromiseFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Array with one value and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [ 1 ], sumPromiseFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Array of values', ->
				promise = Deft.Promise.reduce( [ 1, 2, 3, 4 ], sumPromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 10 )
			)

			specify( 'Array of values and an initial value', ->
				promise = Deft.Promise.reduce( [ 1, 2, 3, 4 ], sumPromiseFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Array of values and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [ 1, 2, 3, 4 ], sumPromiseFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Sparse Array', ->
				promise = Deft.Promise.reduce( `[,2,,4,5]`, sumPromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Sparse Array and an initial value', ->
				promise = Deft.Promise.reduce( `[,2,,4,5]`, sumPromiseFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 21 )
			)

			specify( 'Sparse Array and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( `[,2,,4,5]`, sumPromiseFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 21 )
			)

			specify( 'Array with one resolved Promise', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ) ], sumPromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 1 )
			)

			specify( 'Array with one resolved Promise and an initial value', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ) ], sumPromiseFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Array with one resolved Promise and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ) ], sumPromiseFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Array of resolved Promises', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ], sumPromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 6 )
			)

			specify( 'Array of resolved Promises and an initial value', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ], sumPromiseFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 16 )
			)

			specify( 'Array of resolved Promises and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ], sumPromiseFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 16 )
			)

			specify( 'Array of values and resolved Promises', ->
				promise = Deft.Promise.reduce( [ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ], sumPromiseFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 10 )
			)

			specify( 'Array of values and resolved Promises and an initial value', ->
				promise = Deft.Promise.reduce( [ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ], sumPromiseFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Array of values and resolved Promises and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce( [ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ], sumPromiseFunction, Deft.Deferred.resolve( 10 ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			return
		)

		describe( 'returns a Promise that will resolve with the resolved Promise value obtained by reducing the specified resolved Promise of an Array of Promise(s) or value(s) using the specified function and initial value', ->
			specify( 'Promise of an empty Array and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[]
					)
					sumPromiseFunction
					0
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 0 )
			)

			specify( 'Promise of an empty Array and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[]
					)
					sumPromiseFunction
					Deft.Deferred.resolve( 0 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 0 )
			)

			specify( 'Promise of an Array with one value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1 ]
					)
					sumPromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 1 )
			)

			specify( 'Promise of an Array with one value and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1 ]
					)
					sumPromiseFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Promise of an Array with one value and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1 ]
					)
					sumPromiseFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Promise of an Array of values', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, 2, 3, 4 ]
					)
					sumPromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 10 )
			)

			specify( 'Promise of an Array of values and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, 2, 3, 4 ]
					)
					sumPromiseFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Promise of an Array of values and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, 2, 3, 4 ]
					)
					sumPromiseFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Promise of a sparse Array', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
					sumPromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Promise of a sparse Array and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
					sumPromiseFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 21 )
			)

			specify( 'Promise of a sparse Array and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
					sumPromiseFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 21 )
			)

			specify( 'Promise of an Array with one resolved Promise', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ) ]
					)
					sumPromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 1 )
			)

			specify( 'Promise of an Array with one resolved Promise and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ) ]
					)
					sumPromiseFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Promise of an Array with one resolved Promise and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ) ]
					)
					sumPromiseFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 11 )
			)

			specify( 'Promise of an Array of resolved Promises', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
					sumPromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 6 )
			)

			specify( 'Promise of an Array of resolved Promises and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
					sumPromiseFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 16 )
			)

			specify( 'Promise of an Array of resolved Promises and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
					sumPromiseFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 16 )
			)

			specify( 'Promise of an Array of values and resolved Promises', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ]
					)
					sumPromiseFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 10 )
			)

			specify( 'Promise of an Array of values and resolved Promises and an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ]
					)
					sumPromiseFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			specify( 'Promise of an Array of values and resolved Promises and a resolved Promise of an initial value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.resolve( 2 ), 3, Deft.Deferred.resolve( 4 ) ]
					)
					sumPromiseFunction
					Deft.Deferred.resolve( 10 )
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 20 )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the first Promise in the specified Array of Promise(s) or value(s) that rejects', ->
			specify( 'Array with one rejected Promise', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.reject( new Error( 'error message' ) ) ], sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of values and a rejected Promise', ->
				promise = Deft.Promise.reduce( [ 1, Deft.Deferred.reject( new Error( 'error message' ) ), 3 ], sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 3 ) ], sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of values, pending and resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.reduce( [ 1, 2, Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 4 ), Ext.create( 'Deft.Deferred' ).promise ], sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the first Promise in the specified resolved Promise of an Array of Promise(s) or value(s) that rejects', ->
			specify( 'Promise of an Array with one rejected Promise', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.reject( new Error( 'error message' ) ) ]
					)
					sumFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of values and a rejected Promise', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.reject( new Error( 'error message' ) ), 3 ]
					)
					sumFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 3 ) ]
					)
					sumFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of values, pending and resolved Promises and a rejected Promise', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, 2, Deft.Deferred.reject( new Error( 'error message' ) ), Deft.Deferred.resolve( 4 ), Ext.create( 'Deft.Deferred' ).promise ]
					)
					sumFunction
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the rejected Promise of an Array of Promise(s) or value(s)', ->
			specify( 'Error: error message', ->
				promise = Deft.Promise.reduce( Deft.Deferred.reject( new Error( 'error message' ) ), sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the first rejected Promise returned by the specified function for the the specified Array of Promise(s) or value(s)', ->
			specify( 'Array with one value', ->
				promise = Deft.Promise.reduce( [ 1 ], rejectFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of values', ->
				promise = Deft.Promise.reduce( [ 1, 2, 3 ], rejectFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Sparse Array', ->
				promise = Deft.Promise.reduce(`[,2,,4,5]`, rejectFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array with one resolved Promise', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ) ], rejectFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of resolved Promises', ->
				promise = Deft.Promise.reduce( [ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ], rejectFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Array of values and resolved Promises', ->
				promise = Deft.Promise.reduce( [ 1, Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ), 4 ], rejectFunction, 10 )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the first rejected Promise returned by the specified function for the the specified resolved Promise of an Array of Promise(s) or value(s)', ->
			specify( 'Promise of an Array with one value', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1 ]
					)
					rejectFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of values', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, 2, 3 ]
					)
					rejectFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of a sparse Array', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						`[,2,,4,5]`
					)
					rejectFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array with one resolved Promise', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ) ]
					)
					rejectFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of resolved Promises', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ Deft.Deferred.resolve( 1 ), Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ) ]
					)
					rejectFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			specify( 'Promise of an Array of values and resolved Promises', ->
				promise = Deft.Promise.reduce(
					Deft.Deferred.resolve(
						[ 1, Deft.Deferred.resolve( 2 ), Deft.Deferred.resolve( 3 ), 4 ]
					)
					rejectFunction
					10
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject with the error associated with the rejected Promise of an initial value', ->
			specify( 'Error: error message', ->
				promise = Deft.Promise.reduce( [ 1, 2, 3 ], sumFunction, Deft.Deferred.reject( new Error( 'error message' ) ) )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'error message' )
			)

			return
		)

		describe( 'returns a new Promise that will reject if reduce is attempted on an empty Array with no initial value specified', ->
			specify( 'Empty Array', ->
				promise = Deft.Promise.reduce( [], sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( TypeError )
			)

			specify( 'Promise of an empty Array', ->
				promise = Deft.Promise.reduce( Deft.Deferred.resolve( [] ), sumFunction )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( TypeError )
			)

			return
		)

		describe( 'throws an Error if anything other than an Array or Promise of an Array and a function are specified as the first two parameters', ->
			specify( 'no parameters', ->
				expect( -> Deft.Promise.reduce() ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'a single non-Array parameter', ->
				expect( -> Deft.Promise.reduce( 1 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'multiple non-Array parameters', ->
				expect( -> Deft.Promise.reduce( 1, 2, 3 ) ).to.throw( Error, 'Invalid parameter: expected an Array or Promise of an Array.' )
				return
			)

			specify( 'an Array and no function', ->
				expect( -> Deft.Promise.reduce( [ 1, 2, 3 ] ) ).to.throw( Error, 'Invalid parameter: expected a function.' )
				return
			)

			specify( 'a Promise of an Array and no function', ->
				expect( -> Deft.Promise.reduce( Deft.Deferred.resolve( [ 1, 2, 3 ] ) ) ).to.throw( Error, 'Invalid parameter: expected a function.' )
				return
			)

			specify( 'an Array and a non-function parameter', ->
				expect( -> Deft.Promise.reduce( [ 1, 2, 3 ], 'not a function' ) ).to.throw( Error, 'Invalid parameter: expected a function.' )
				return
			)

			specify( 'a Promise of a non-function parameter', ->
				expect( -> Deft.Promise.reduce( Deft.Deferred.resolve( [ 1, 2, 3 ], 'not a function' ) ) ).to.throw( Error, 'Invalid parameter: expected a function.' )
				return
			)

			return
		)

		return
	)

	describe( 'then()', ->
		# NOTE: We are relying on the standard Promises/A+ Compliance Suite to perform the bulk of the tests for this method.
		describe( 'with a progress handler', ->
			describe( 'attaches a progress handler that will be called on progress updates', ->
				specify( 'called with progress update when updated', ( done ) ->
					progressHandler = sinon.spy()

					deferred = Ext.create( 'Deft.Deferred' )
					promise = deferred.promise

					promise.then( null, null, progressHandler )

					Deft.Function.nextTick( ->
						deferred.update( 'progress' )

						expect( progressHandler ).to.be.calledOnce.and.calledWith( 'progress' )

						done()
						return
					)
					return
				)

				specify( 'called with progress update in specified scope when updated', ( done ) ->
					targetScope = {}
					progressHandler = sinon.spy()

					deferred = Ext.create( 'Deft.Deferred' )
					promise = deferred.promise

					promise.then( null, null, progressHandler, targetScope )

					Deft.Function.nextTick( ->
						deferred.update( 'progress' )

						expect( progressHandler ).to.be.calledOnce.and.calledWith( 'progress' ).and.calledOn( targetScope )

						done()
						return
					)
					return
				)

				return
			)

			describe( 'propagates transformed progress updates that originate from this Promise', ->
				specify( 'propagates progress updates to subsequent Promises in the chain if a progress handler is omitted', ( done ) ->
					progressHandler = sinon.spy()

					deferred = Ext.create( 'Deft.Deferred' )
					promise = deferred.promise

					promise.then().then( null, null, progressHandler )

					Deft.Function.nextTick( ->
						deferred.update( 'progress' )

						expect( progressHandler ).to.be.calledOnce.and.calledWith( 'progress' )

						done()
						return
					)
					return
				)

				specify( 'propagates transformed progress updates to subsequent Promises in the chain if a progress handler transforms the progress update', ( done ) ->
					progressHandler = sinon.stub().returns( 'transformed progress' )
					transformedProgressHandler = sinon.stub().returns( 'transformed transformed progress' )
					transformedTransformedProgressHandler = sinon.spy()

					deferred = Ext.create( 'Deft.Deferred' )
					promise = deferred.promise

					promise
						.then( null, null, progressHandler )
						.then( null, null, transformedProgressHandler )
						.then( null, null, transformedTransformedProgressHandler )

					Deft.Function.nextTick( ->
						deferred.update( 'progress' )

						expect( progressHandler ).to.be.calledOnce.and.calledWith( 'progress' )
						expect( transformedProgressHandler ).to.be.calledOnce.and.calledWith( 'transformed progress' )
						expect( transformedTransformedProgressHandler ).to.be.calledOnce.and.calledWith( 'transformed transformed progress' )

						done()
						return
					)
					return
				)

				return
			)

			return
		)

		describe( 'with parameters specified via a configuration object', ->
			describe( 'attaches an onResolved callback to this Promise that will be called when it resolves', ->
				describe( 'when only a success handler is specified', ->
					specify( 'called with resolved value when resolved', ( done ) ->
						onResolved = sinon.spy()

						promise = Deft.Deferred.resolve( 'resolved value' )

						promise.then(
							success: onResolved
						)

						Deft.Function.nextTick( ->
							expect( onResolved ).to.be.calledOnce.and.calledWith( 'resolved value' )

							done()
							return
						)
						return
					)

					specify( 'called with resolved value in the specified scope when resolved', ( done ) ->
						targetScope = {}
						onResolved = sinon.spy()

						promise = Deft.Deferred.resolve( 'resolved value' )

						promise.then(
							success: onResolved
							scope: targetScope
						)

						Deft.Function.nextTick( ->
							expect( onResolved ).to.be.calledOnce.and.calledWith( 'resolved value' ).and.calledOn( targetScope )

							done()
							return
						)
						return
					)

					return
				)

				describe( 'when success, failure and progress handlers are specified', ->
					specify( 'called with resolved value when resolved', ( done ) ->
						onResolved = sinon.spy()
						onRejected = sinon.spy()
						onProgress = sinon.spy()

						promise = Deft.Deferred.resolve( 'resolved value' )

						promise.then(
							success: onResolved
							failure: onRejected
							progress: onProgress
						)

						Deft.Function.nextTick( ->
							expect( onResolved ).to.be.calledOnce.and.calledWith( 'resolved value' )
							expect( onRejected ).to.not.be.called
							expect( onProgress ).to.not.be.called

							done()
							return
						)
						return
					)

					specify( 'called with resolved value in the specified scope when resolved', ( done ) ->
						targetScope = {}
						onResolved = sinon.spy()
						onRejected = sinon.spy()
						onProgress = sinon.spy()

						promise = Deft.Deferred.resolve( 'resolved value' )

						promise.then(
							success: onResolved
							failure: onRejected
							progress: onProgress
							scope: targetScope
						)

						Deft.Function.nextTick( ->
							expect( onResolved ).to.be.calledOnce.and.calledWith( 'resolved value' ).and.calledOn( targetScope )
							expect( onRejected ).to.not.be.called
							expect( onProgress ).to.not.be.called

							done()
							return
						)
						return
					)

					return
				)

				return
			)

			describe( 'attaches an onRejected callback to this Promise that will be called when it rejects', ->
				describe( 'when only a failure handler is specified', ->
					specify( 'called with rejection reason when rejected', ( done ) ->
						onRejected = sinon.spy()

						promise = Deft.Deferred.reject( 'rejection reason' )

						promise.then(
							failure: onRejected
						)

						Deft.Function.nextTick( ->
							expect( onRejected ).to.be.calledOnce.and.calledWith( 'rejection reason' )

							done()
							return
						)
						return
					)

					specify( 'called with rejection reason in specified scope when rejected', ( done ) ->
						targetScope = {}
						onRejected = sinon.spy()

						promise = Deft.Deferred.reject( 'rejection reason' )

						promise.then(
							failure: onRejected
							scope: targetScope
						)

						Deft.Function.nextTick( ->
							expect( onRejected ).to.be.calledOnce.and.calledWith( 'rejection reason' ).and.calledOn( targetScope )

							done()
							return
						)
						return
					)

					return
				)

				describe( 'when success, failure and progress handlers are specified', ->
					specify( 'called with rejection reason when rejected', ( done ) ->
						onResolved = sinon.spy()
						onRejected = sinon.spy()
						onProgress = sinon.spy()

						promise = Deft.Deferred.reject( 'rejection reason' )

						promise.then(
							success: onResolved
							failure: onRejected
							progress: onProgress
						)

						Deft.Function.nextTick( ->
							expect( onResolved ).to.not.be.called
							expect( onRejected ).to.be.calledOnce.and.calledWith( 'rejection reason' )
							expect( onProgress ).to.not.be.called

							done()
							return
						)
						return
					)

					specify( 'called with rejection reason in specified scope when rejected', ( done ) ->
						targetScope = {}
						onResolved = sinon.spy()
						onRejected = sinon.spy()
						onProgress = sinon.spy()

						promise = Deft.Deferred.reject( 'rejection reason' )

						promise.then(
							success: onResolved
							failure: onRejected
							progress: onProgress
							scope: targetScope
						)

						Deft.Function.nextTick( ->
							expect( onResolved ).to.not.be.called
							expect( onRejected ).to.be.calledOnce.and.calledWith( 'rejection reason' ).and.calledOn( targetScope )
							expect( onProgress ).to.not.be.called

							done()
							return
						)
						return
					)

					return
				)

				return
			)

			describe( 'attaches an onProgress callback to this Promise that will be called when it resolves', ->
				describe( 'when only a progress handler is specified', ->
					specify( 'called with progress update when updated', ( done ) ->
						onProgress = sinon.spy()

						deferred = Ext.create( 'Deft.Deferred' )
						promise = deferred.promise

						promise.then(
							progress: onProgress
						)

						Deft.Function.nextTick( ->
							deferred.update( 'progress' )

							expect( onProgress ).to.be.calledOnce.and.calledWith( 'progress' )

							done()
							return
						)
						return
					)

					specify( 'called with progress update in specified scope when updated', ( done ) ->
						targetScope = {}
						onProgress = sinon.spy()

						deferred = Ext.create( 'Deft.Deferred' )
						promise = deferred.promise

						promise.then(
							progress: onProgress
							scope: targetScope
						)

						Deft.Function.nextTick( ->
							deferred.update( 'progress' )

							expect( onProgress ).to.be.calledOnce.and.calledWith( 'progress' ).and.calledOn( targetScope )

							done()
							return
						)
						return
					)

					return
				)

				describe( 'when success, failure and progress handlers are specified', ->
					specify( 'called with progress update when updated', ( done ) ->
						onResolved = sinon.spy()
						onRejected = sinon.spy()
						onProgress = sinon.spy()

						deferred = Ext.create( 'Deft.Deferred' )
						promise = deferred.promise

						promise.then(
							success: onResolved
							failure: onRejected
							progress: onProgress
						)

						Deft.Function.nextTick( ->
							deferred.update( 'progress' )

							expect( onResolved ).to.not.be.called
							expect( onRejected ).to.not.be.called
							expect( onProgress ).to.be.calledOnce.and.calledWith( 'progress' )

							done()
							return
						)
						return
					)

					specify( 'called with progress update in specified scope when updated', ( done ) ->
						targetScope = {}
						onResolved = sinon.spy()
						onRejected = sinon.spy()
						onProgress = sinon.spy()

						deferred = Ext.create( 'Deft.Deferred' )
						promise = deferred.promise

						promise.then(
							success: onResolved
							failure: onRejected
							progress: onProgress
							scope: targetScope
						)

						Deft.Function.nextTick( ->
							deferred.update( 'progress' )

							expect( onResolved ).to.not.be.called
							expect( onRejected ).to.not.be.called
							expect( onProgress ).to.be.calledOnce.and.calledWith( 'progress' ).and.calledOn( targetScope )

							done()
							return
						)
						return
					)

					return
				)

				return
			)

			return
		)

		return
	)

	describe( 'otherwise()', ->
		describe( 'attaches a callback that will be called if this Promise is rejected', ->
			describe( 'with parameters specified via function arguments', ->
				specify( 'called if rejected', ( done ) ->
					onRejected = sinon.spy()
					error = new Error( 'error message' )

					promise = Deft.Deferred.reject( error )
					promise.otherwise( onRejected )

					promise.then(
						null
						->
							try
								expect( onRejected ).to.be.calledOnce.and.calledWith( error )
								done()
							catch error
								done( error )
					)
					return
				)

				specify( 'called in specified scope if rejected', ( done ) ->
					targetScope = {}
					onRejected = sinon.spy()
					error = new Error( 'error message' )

					promise = Deft.Deferred.reject( error )
					promise.otherwise( onRejected, targetScope )

					promise.then(
						null
						->
							try
								expect( onRejected ).to.be.calledOnce.and.calledWith( error ).and.calledOn( targetScope )
								done()
							catch error
								done( error )
					)
					return
				)

				specify( 'not called if resolved', ( done ) ->
					onRejected = sinon.spy()

					promise = Deft.Deferred.resolve( 'value' )
					promise.otherwise( onRejected )

					promise.then(
						->
							try
								expect( onRejected ).not.to.be.called
								done()
							catch error
								done( error )
					)
					return
				)

				return
			)

			describe( 'with parameters specified via a configuration object', ->
				specify( 'called if rejected', ( done ) ->
					onRejected = sinon.spy()
					error = new Error( 'error message' )

					promise = Deft.Deferred.reject( error )
					promise.otherwise(
						fn: onRejected
					)

					promise.then(
						null
						->
							try
								expect( onRejected ).to.be.calledOnce.and.calledWith( error )
								done()
							catch error
								done( error )
					)
					return
				)

				specify( 'called in specified scope if rejected', ( done ) ->
					targetScope = {}
					onRejected = sinon.spy()
					error = new Error( 'error message' )

					promise = Deft.Deferred.reject( error )
					promise.otherwise(
						fn: onRejected
						scope: targetScope
					)

					promise.then(
						null
						->
							try
								expect( onRejected ).to.be.calledOnce.and.calledWith( error ).and.calledOn( targetScope )
								done()
							catch error
								done( error )
					)
					return
				)

				specify( 'not called if resolved', ( done ) ->
					onRejected = sinon.spy()

					promise = Deft.Deferred.resolve( 'value' )
					promise.otherwise(
						fn: onRejected
					)

					promise.then(
						->
							try
								expect( onRejected ).not.to.be.called
								done()
							catch error
								done( error )
					)
					return
				)

				return
			)

			return
		)

		describe( 'returns a Promise of the transformed future value', ->
			specify( 'resolves with the returned value if callback returns a value', ->
				onRejected = ->
					return 'returned value'

				promise = Deft.Deferred.reject( new Error( 'error message' ) ).otherwise( onRejected )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'returned value' )
			)

			specify( 'resolves with the resolved value if callback returns a Promise that resolves with value', ->
				onRejected = ->
					return Deft.Deferred.resolve( 'resolved value' )

				promise = Deft.Deferred.reject( new Error( 'error message' ) ).otherwise( onRejected )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'resolved value' )
			)

			specify( 'rejects with the thrown Error if callback throws an Error', ->
				onRejected = ->
					throw new Error( 'thrown error message' )

				promise = Deft.Deferred.reject( new Error( 'error message' ) ).otherwise( onRejected )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'thrown error message' )
			)

			specify( 'rejects with the rejection reason if callback returns a Promise that rejects with a reason', ->
				onRejected = ->
					return Deft.Deferred.reject( new Error( 'rejection reason' ) )

				promise = Deft.Deferred.reject( new Error( 'original error message' ) ).otherwise( onRejected )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'rejection reason' )
			)

			return
		)

		return
	)

	describe( 'always()', ->
		describe( 'attaches a callback to this Promise that will be called when it resolves or rejects', ->
			describe( 'with parameters specified via function arguments', ->
				specify( 'called with no parameters when resolved', ( done ) ->
					onComplete = sinon.spy()

					promise = Deft.Deferred.resolve( 'value' )
					promise.always( onComplete )

					promise.then(
						->
							try
								expect( onComplete ).to.be.called
								done()
							catch error
								done( error )
					)
					return
				)

				specify( 'called with no parameters in the specified scope when resolved', ( done ) ->
					targetScope = {}
					onComplete = sinon.spy()

					promise = Deft.Deferred.resolve( 'value' )
					promise.always( onComplete, targetScope )

					promise.then(
						->
							try
								expect( onComplete ).to.be.called
								done()
							catch error
								done( error )
					)
					return
				)

				specify( 'called with no parameters when rejected', ( done ) ->
					onComplete = sinon.spy()

					promise = Deft.Deferred.reject( new Error( 'error message' ) )
					promise.always( onComplete )

					promise.then(
						null
						->
							try
								expect( onComplete ).to.be.called
								done()
							catch error
								done( error )
					)
					return
				)

				specify( 'called with no parameters in the specified scope when rejected', ( done ) ->
					targetScope = {}
					onComplete = sinon.spy()

					promise = Deft.Deferred.reject( new Error( 'error message' ) )
					promise.always( onComplete, targetScope )

					promise.then(
						null
						->
							try
								expect( onComplete ).to.be.called
								done()
							catch error
								done( error )
					)
					return
				)

				return
			)

			describe( 'with parameters specified via a configuration object', ->
				specify( 'called with no parameters when resolved', ( done ) ->
					onComplete = sinon.spy()

					promise = Deft.Deferred.resolve( 'value' )
					promise.always(
						fn: onComplete
					)

					promise.then(
						->
							try
								expect( onComplete ).to.be.called
								done()
							catch error
								done( error )
					)
					return
				)

				specify( 'called with no parameters in the specified scope when resolved', ( done ) ->
					targetScope = {}
					onComplete = sinon.spy()

					promise = Deft.Deferred.resolve( 'value' )
					promise.always(
						fn: onComplete
						scope: targetScope
					)

					promise.then(
						->
							try
								expect( onComplete ).to.be.called
								done()
							catch error
								done( error )
					)
					return
				)

				specify( 'called with no parameters when rejected', ( done ) ->
					onComplete = sinon.spy()

					promise = Deft.Deferred.reject( new Error( 'error message' ) )
					promise.always(
						fn: onComplete
					)

					promise.then(
						null
						->
							try
								expect( onComplete ).to.be.called
								done()
							catch error
								done( error )
					)
					return
				)

				specify( 'called with no parameters in the specified scope when rejected', ( done ) ->
					targetScope = {}
					onComplete = sinon.spy()

					promise = Deft.Deferred.reject( new Error( 'error message' ) )
					promise.always(
						fn: onComplete
						scope: targetScope
					)

					promise.then(
						null
						->
							try
								expect( onComplete ).to.be.called
								done()
							catch error
								done( error )
					)
					return
				)

				return
			)

			return
		)

		describe( 'return a new "pass-through" Promise that resolves with the original value or rejects with the original reason', ->
			specify( 'if the originating Promise resolves, ignores value returned by callback', ->
				onComplete = ->
					return 'callback return value'

				promise = Deft.Deferred.resolve( 'resolved value' ).always( onComplete )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'resolved value' )
			)

			specify( 'if the originating Promise resolves, ignores and later rethrows Error thrown by callback', ( done ) ->
				onComplete = ->
					throw new Error( 'callback error message' )

				promise = Deft.Deferred.resolve( 'resolved value' ).always( onComplete )

				assert.eventuallyThrows(
					new Error( 'callback error message' )
					( error ) ->
						if error
							throw error

						promise.should.eventually.equal( 'resolved value' ).then(
							( value ) ->
								done()
							( reason ) ->
								done( reason )
						)
					100
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return
			)

			specify( 'if the originating Promise rejects, ignores value returned by callback', ->
				onComplete = ->
					return 'callback return value'

				promise = Deft.Deferred.reject( new Error( 'rejection reason' ) ).always( onComplete )

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'rejection reason' )
			)

			specify( 'if the originating Promise rejects, ignores and later rethrows Error thrown by callback', ( done ) ->
				onComplete = ->
					throw new Error( 'callback error message' )

				promise = Deft.Deferred.reject( new Error( 'rejection reason' ) ).always( onComplete )

				assert.eventuallyThrows(
					new Error( 'callback error message' )
					( error ) ->
						if error
							throw error
						promise.should.be.rejectedWith( Error, 'rejection reason' ).then(
							( value ) ->
								done()
							( reason ) ->
								done( reason )
						)
					100
				)

				promise.should.be.an.instanceof( Deft.Promise )
				return
			)

			return
		)

		return
	)

	describe( 'done()', ->
		describe( 'terminates a Promise chain, ensuring that unhandled rejections will be thrown as Errors', ->

			specify( 'rethrows the rejection as an error if the originating Promise rejects', ( done ) ->
				@slow( 250 )
				promise = Deft.Deferred.reject( new Error( 'rejection reason' ) ).done()

				assert.eventuallyThrows( new Error( 'rejection reason' ), done, 100 )
				return
			)

			specify( 'rethrows the rejection as an error if an ancestor Promise rejects and that rejection is unhandled', ( done ) ->
				@slow( 250 )
				promise = Deft.Deferred.reject( new Error( 'rejection reason' ) ).then( ( value ) -> return value ).done()

				assert.eventuallyThrows( new Error( 'rejection reason' ), done, 100 )
				return
			)

			return
		)

		return
	)

	describe( 'cancel()', ->
		describe( 'cancels a Promise if it is still pending, triggering a rejection with a CancellationError that will propagate to any Promises originating from that Promise', ->

			specify( 'rejects a pending Promise with a CancellationError', ->
				promise = Ext.create( 'Deft.Deferred' ).promise

				promise.cancel()

				return promise.should.be.rejectedWith( CancellationError )
			)

			specify( 'rejects a pending Promise with a CancellationError with a reason', ->
				promise = Ext.create( 'Deft.Deferred' ).promise

				promise.cancel( 'cancellation reason' )

				return promise.should.be.rejectedWith( CancellationError, 'cancellation reason' )
			)

			specify( 'ignores attempts to cancel a fulfilled Promise', ->
				promise = Deft.Deferred.resolve( 'resolved value' )

				promise.cancel()

				return promise.should.eventually.equal( 'resolved value' )
			)

			specify( 'ignores attempts to cancel a rejected Promise', ->
				promise = Deft.Deferred.reject( new Error( 'rejection reason' ) )

				promise.cancel()

				return promise.should.be.rejectedWith( Error, 'rejection reason' )
			)

			specify( 'propagates rejection with that CancellationError to Promises that originate from the cancelled Promise', ->
				promise = Ext.create( 'Deft.Deferred' ).promise

				promise.cancel( 'cancellation reason' )

				return promise.then().should.be.rejectedWith( CancellationError, 'cancellation reason' )
			)

			return
		)

		return
	)

	describe( 'log()', ->
		describe( 'logs the resolution or rejection of this Promise using Deft.Logger.log()', ->
			beforeEach( ->
				sinon.spy( Deft.Logger, 'log' )
			)

			afterEach( ->
				Deft.Logger.log.restore()
			)

			specify( 'logs a fulfilled promise', ( done ) ->
				value = 'resolved value'
				promise = Deft.Deferred.resolve( value ).log()

				promise.should.be.an.instanceof( Deft.Promise )
				promise.always( ->
					try
						expect( Deft.Logger.log ).to.be.calledOnce.and.calledWith( "Promise resolved with value: #{ value }" )
						done()
					catch error
						done( error )
					return
				)
				return
			)

			specify( 'logs a fulfilled promise, with the optional name specified', ( done ) ->
				value = 'resolved value'
				promise = Deft.Deferred.resolve( value ).log( 'Test Promise' )

				promise.should.be.an.instanceof( Deft.Promise )
				promise.always( ->
					try
						expect( Deft.Logger.log ).to.be.calledOnce.and.calledWith( "Test Promise resolved with value: #{ value }" )
						done()
					catch error
						done( error )
					return
				)
				return
			)

			specify( 'logs a rejected promise', ( done ) ->
				reason = new Error( 'rejection reason' )
				promise = Deft.Deferred.reject( reason ).log()

				promise.should.be.an.instanceof( Deft.Promise )
				promise.always( ->
					try
						expect( Deft.Logger.log ).to.be.calledOnce.and.calledWith( "Promise rejected with reason: #{ reason }" )
						done()
					catch error
						done( error )
					return
				)
				return
			)

			specify( 'logs a rejected promise, with the optional name specified', ( done ) ->
				reason = new Error( 'rejection reason' )
				promise = Deft.Deferred.reject( reason ).log( 'Test Promise' )

				promise.should.be.an.instanceof( Deft.Promise )
				promise.always( ->
					try
						expect( Deft.Logger.log ).to.be.calledOnce.and.calledWith( "Test Promise rejected with reason: #{ reason }" )
						done()
					catch error
						done( error )
					return
				)
				return
			)

			return
		)

		describe( 'return a new "pass-through" Promise that resolves with the original value or rejects with the original reason', ->
			specify( 'resolves if the originating Promise resolves', ->
				promise = Deft.Deferred.resolve( 'resolved value' ).log()

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.eventually.equal( 'resolved value' )
			)

			specify( 'rejects if the originating Promise rejects', ->
				promise = Deft.Deferred.reject( new Error( 'rejection reason' ) ).log()

				promise.should.be.an.instanceof( Deft.Promise )
				return promise.should.be.rejectedWith( Error, 'rejection reason' )
			)
			
			return
		)
		
		return
	)
)