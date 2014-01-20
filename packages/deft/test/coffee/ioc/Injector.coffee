###
Copyright (c) 2013 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

describe( 'Deft.ioc.Injector', ->

	Ext.define( 'ExampleClass',
		config:
			parameter: null

		constructor: ( config ) ->
			@initConfig( config )
			return @
	)

	Ext.define( 'ExampleSingletonClass',
		singleton: true

		constructor: ( config ) ->
			@initConfig( config )
			return @
	)

	describe( 'Configuration', ->

		describe( 'Configuration with a class name as a String', ->
			before(->
				Deft.Injector.configure(
					classNameAsString: 'ExampleClass'
				)

				return
			)

			specify( 'should be configurable with a class name as a String', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameAsString' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			describe( 'Resolution of a dependency configured with a class name as a String', ->

				specify( 'should resolve a dependency configured with a class name as a String with the corresponding singleton class instance', ->
					expect(
						classNameAsStringInstance = Deft.Injector.resolve( 'classNameAsString' )
					).to.be.instanceof( ExampleClass )

					expect(
						Deft.Injector.resolve( 'classNameAsString' )
					).to.be.equal( classNameAsStringInstance )

					return
				)

				return
			)

			return
		)

		describe( 'Configuration with a class name', ->

			expectedClassNameEagerlyInstance = null
			expectedClassNameAsSingletonEagerlyInstance = null

			specify( 'should be configurable with a class name', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					className:
						className: 'ExampleClass'
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'className' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name, eagerly', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameEagerly:
						className: 'ExampleClass'
						eager: true
				)

				expectedClassNameEagerlyInstance = constructorSpy.thisValues[0]

				expect( constructorSpy ).to.be.calledOnce

				expect( expectedClassNameEagerlyInstance ).to.be.instanceof( ExampleClass )

				expect(
					Deft.Injector.canResolve( 'classNameEagerly' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name, (explicitly) lazily', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameLazily:
						className: 'ExampleClass'
						eager: false
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameLazily' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name, (explicitly) as a singleton', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameAsSingleton:
						className: 'ExampleClass'
						singleton: true
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameAsSingleton' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name, (explicitly) as a singleton, eagerly', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameAsSingletonEagerly:
						className: 'ExampleClass'
						singleton: true
						eager: true
				)

				expectedClassNameAsSingletonEagerlyInstance = constructorSpy.thisValues[0]

				expect( constructorSpy ).to.be.calledOnce

				expect( expectedClassNameAsSingletonEagerlyInstance ).to.be.instanceof( ExampleClass )

				expect(
					Deft.Injector.canResolve( 'classNameAsSingletonEagerly' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name, (explicitly) as a singleton, (explicitly) lazily', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor')

				Deft.Injector.configure(
					classNameAsSingletonLazily:
						className: 'ExampleClass'
						singleton: true
						eager: false
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameAsSingletonLazily' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name, as a prototype', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameAsPrototype:
						className: 'ExampleClass'
						singleton: false
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameAsPrototype' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should not be configurable with a class name, as a prototype, eagerly', ->
				expect( ->
					Deft.Injector.configure(
						classNameAsPrototypeEagerly:
							className: 'ExampleClass'
							singleton: false
							eager: true
					)
				).to.throw( Error, "Error while configuring 'classNameAsPrototypeEagerly': only singletons can be created eagerly." )

				return
			)

			specify( 'should be configurable with a class name, as a prototype, (explicitly) lazily', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameAsPrototypeLazily:
						className: 'ExampleClass'
						singleton: false
						eager: false
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameAsPrototypeLazily' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			describe( 'Resolution of a dependency configured with a class name', ->

				specify( 'should resolve a dependency configured with a class name with the corresponding singleton class instance', ->
					expect(
						classNameInstance = Deft.Injector.resolve( 'className' )
					).to.be.instanceof( ExampleClass )

					expect(
						Deft.Injector.resolve( 'className' )
					).to.be.equal( classNameInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name, eagerly, with the corresponding singleton class instance', ->
					expect(
						Deft.Injector.resolve( 'classNameEagerly' )
					).to.be.equal( expectedClassNameEagerlyInstance )

					expect(
						Deft.Injector.resolve( 'classNameEagerly' )
					).to.be.equal( expectedClassNameEagerlyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameLazilyInstance = Deft.Injector.resolve( 'classNameLazily' )
					).to.be.instanceof( ExampleClass )

					expect(
						Deft.Injector.resolve( 'classNameLazily' )
					).to.to.equal( classNameLazilyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name, (explicitly) as a singleton, with the corresponding singleton class instance', ->
					expect(
						classNameAsSingletonInstance = Deft.Injector.resolve( 'classNameAsSingleton' )
					).to.be.instanceof( ExampleClass )

					expect(
						Deft.Injector.resolve( 'classNameAsSingleton' )
					).to.be.equal( classNameAsSingletonInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name, (explicitly) as a singleton, eagerly, with the corresponding singleton class instance', ->
					expect(
						Deft.Injector.resolve( 'classNameAsSingletonEagerly' )
					).to.be.equal( expectedClassNameAsSingletonEagerlyInstance )

					expect(
						Deft.Injector.resolve( 'classNameAsSingletonEagerly' )
					).to.be.equal( expectedClassNameAsSingletonEagerlyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name, (explicitly) as a singleton, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameAsSingletonLazilyInstance = Deft.Injector.resolve( 'classNameAsSingletonLazily' )
					).to.be.instanceof( ExampleClass )

					expect(
						Deft.Injector.resolve( 'classNameAsSingletonLazily' )
					).to.be.equal( classNameAsSingletonLazilyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name, as a prototype, with the corresponding prototype class instance', ->
					classNameAsPrototypeInstance1 = Deft.Injector.resolve( 'classNameAsPrototype' )
					classNameAsPrototypeInstance2 = Deft.Injector.resolve( 'classNameAsPrototype' )

					expect(
						classNameAsPrototypeInstance1
					).to.be.instanceof( ExampleClass )

					expect(
						classNameAsPrototypeInstance2
					).to.be.instanceof( ExampleClass )

					expect(
						classNameAsPrototypeInstance1
					).not.to.be.equal( classNameAsPrototypeInstance2 )

					return
				)

				specify( 'should resolve a dependency configured with a class name, as a prototype, (explicitly) lazily, with the corresponding prototype class instance', ->
					classNameAsPrototypeLazilyInstance1 = Deft.Injector.resolve( 'classNameAsPrototypeLazily' )
					classNameAsPrototypeLazilyInstance2 = Deft.Injector.resolve( 'classNameAsPrototypeLazily' )

					expect(
						classNameAsPrototypeLazilyInstance1
					).to.be.instanceof( ExampleClass )

					expect(
						classNameAsPrototypeLazilyInstance2
					).to.be.instanceof( ExampleClass )

					expect(
						classNameAsPrototypeLazilyInstance1
					).not.to.be.equal( classNameAsPrototypeLazilyInstance2 )

					return
				)

				return
			)

			return
		)

		describe( 'Configuration with a class name and constructor parameters', ->

			expectedClassNameWithParametersEagerlyInstance = null
			expectedClassNameWithParametersAsSingletonEagerlyInstance = null

			specify( 'should be configurable with a class name and constructor parameters', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameWithParameters:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameWithParameters' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name and constructor parameters, eagerly', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameWithParametersEagerly:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						eager: true
				)

				expectedClassNameWithParametersEagerlyInstance = constructorSpy.thisValues[0]

				expect( constructorSpy ).to.be.called

				expect(
					expectedClassNameWithParametersEagerlyInstance
				).to.be.instanceof( ExampleClass )
				expect(
					expectedClassNameWithParametersEagerlyInstance.getParameter()
				).to.be.equal( 'expected value' )

				expect(
					Deft.Injector.canResolve( 'classNameWithParametersEagerly' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name and constructor parameters, (explicitly) lazily', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameWithParametersLazily:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						eager: false
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameWithParametersLazily' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name and constructor parameters, (explicitly) as a singleton', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameWithParametersAsSingleton:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						singleton: true
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameWithParametersAsSingleton' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name and constructor parameters, as a singleton, eagerly', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameWithParametersAsSingletonEagerly:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						singleton: true
						eager: true
				)

				expectedClassNameWithParametersAsSingletonEagerlyInstance = constructorSpy.thisValues[0]

				expect( constructorSpy ).to.be.called

				expect(
					expectedClassNameWithParametersAsSingletonEagerlyInstance
				).to.be.instanceof( ExampleClass )
				expect(
					expectedClassNameWithParametersAsSingletonEagerlyInstance.getParameter()
				).to.be.equal( 'expected value' )

				expect(
					Deft.Injector.canResolve( 'classNameWithParametersAsSingletonEagerly' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name and constructor parameters, (explicitly) as a singleton, (explicitly) lazily', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameWithParametersAsSingletonLazily:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						singleton: true
						eager: false
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameWithParametersAsSingletonLazily' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should be configurable with a class name and constructor parameters, as a prototype', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameWithParametersAsPrototype:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						singleton: false
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameWithParametersAsPrototype' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			specify( 'should not be configurable with a class name and constructor parameters, as a prototype, eagerly', ->
				expect( ->
					Deft.Injector.configure(
						classNameWithParametersAsPrototypeEagerly:
							className: 'ExampleClass'
							parameters: [ { parameter: 'expected value' } ]
							singleton: false
							eager: true
					)
					return
				).to.throw( Error, "Error while configuring 'classNameWithParametersAsPrototypeEagerly': only singletons can be created eagerly." )

				return
			)

			specify( 'should be configurable with a class name and constructor parameters, as a prototype, (explicitly) lazily', ->
				constructorSpy = sinon.spy( ExampleClass::, 'constructor' )

				Deft.Injector.configure(
					classNameWithParametersAsPrototypeLazily:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						singleton: false
				)

				expect( constructorSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'classNameWithParametersAsPrototypeLazily' )
				).to.be.true

				ExampleClass::constructor.restore()

				return
			)

			describe( 'Resolution of a dependency configured with a class name and constructor parameters', ->

				specify( 'should resolve a dependency configured with a class name and constructor parameters with the corresponding singleton class instance', ->
					expect(
						classNameWithParametersInstance = Deft.Injector.resolve( 'classNameWithParameters' )
					).to.be.instanceof( ExampleClass )

					expect(
						classNameWithParametersInstance.getParameter()
					).to.be.equal( 'expected value' )

					expect(
						Deft.Injector.resolve( 'classNameWithParameters' )
					).to.be.equal( classNameWithParametersInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name and constructor parameters, eagerly, with the corresponding singleton class instance', ->
					expect(
						Deft.Injector.resolve( 'classNameWithParametersEagerly' )
					).to.be.equal( expectedClassNameWithParametersEagerlyInstance )

					expect(
						Deft.Injector.resolve( 'classNameWithParametersEagerly' )
					).to.be.equal( expectedClassNameWithParametersEagerlyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name and constructor parameters, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameWithParametersLazilyInstance = Deft.Injector.resolve( 'classNameWithParametersLazily' )
					).to.be.instanceof( ExampleClass )

					expect(
						classNameWithParametersLazilyInstance.getParameter()
					).to.be.equal( 'expected value' )

					expect(
						Deft.Injector.resolve( 'classNameWithParametersLazily' )
					).to.be.equal( classNameWithParametersLazilyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name and constructor parameters, (explicitly) as a singleton, with the corresponding singleton class instance', ->
					expect(
						classNameWithParametersAsSingletonInstance = Deft.Injector.resolve( 'classNameWithParametersAsSingleton' )
					).to.be.instanceof( ExampleClass )

					expect(
						classNameWithParametersAsSingletonInstance.getParameter()
					).to.be.equal( 'expected value' )

					expect(
						Deft.Injector.resolve( 'classNameWithParametersAsSingleton' )
					).to.be.equal( classNameWithParametersAsSingletonInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name and constructor parameters, (explicitly) as a singleton, eagerly, with the corresponding singleton class instance', ->
					expect(
						Deft.Injector.resolve( 'classNameWithParametersAsSingletonEagerly' )
					).to.be.equal( expectedClassNameWithParametersAsSingletonEagerlyInstance )

					expect(
						Deft.Injector.resolve( 'classNameWithParametersAsSingletonEagerly' )
					).to.be.equal( expectedClassNameWithParametersAsSingletonEagerlyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name and constructor parameters, (explicitly) as a singleton, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameWithParametersAsSingletonLazilyInstance = Deft.Injector.resolve( 'classNameWithParametersAsSingletonLazily' )
					).to.be.instanceof( ExampleClass )

					expect(
						classNameWithParametersAsSingletonLazilyInstance.getParameter()
					).to.be.equal( 'expected value' )

					expect(
						Deft.Injector.resolve( 'classNameWithParametersAsSingletonLazily' )
					).to.be.equal( classNameWithParametersAsSingletonLazilyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name and constructor parameters, as a prototype, with the corresponding prototype class instance', ->
					classNameWithParametersAsPrototypeInstance1 = Deft.Injector.resolve( 'classNameWithParametersAsPrototype' )
					classNameWithParametersAsPrototypeInstance2 = Deft.Injector.resolve( 'classNameWithParametersAsPrototype' )

					expect(
						classNameWithParametersAsPrototypeInstance1
					).to.be.instanceof( ExampleClass )
					expect(
						classNameWithParametersAsPrototypeInstance1.getParameter()
					).to.be.equal( 'expected value' )

					expect(
						classNameWithParametersAsPrototypeInstance2
					).to.be.instanceof( ExampleClass )
					expect(
						classNameWithParametersAsPrototypeInstance2.getParameter()
					).to.be.equal( 'expected value' )

					expect(
						classNameWithParametersAsPrototypeInstance1
					).not.to.be.equal( classNameWithParametersAsPrototypeInstance2 )

					return
				)

				specify( 'should resolve a dependency configured with a class name and constructor parameters, as a prototype, (explicitly) lazily, with the corresponding prototype class instance', ->
					classNameWithParametersAsPrototypeLazilyInstance1 = Deft.Injector.resolve( 'classNameWithParametersAsPrototypeLazily' )
					classNameWithParametersAsPrototypeLazilyInstance2 = Deft.Injector.resolve( 'classNameWithParametersAsPrototypeLazily' )

					expect(
						classNameWithParametersAsPrototypeLazilyInstance1
					).to.be.instanceof( ExampleClass )
					expect(
						classNameWithParametersAsPrototypeLazilyInstance1.getParameter()
					).to.be.equal( 'expected value' )

					expect(
						classNameWithParametersAsPrototypeLazilyInstance2
					).to.be.instanceof( ExampleClass )
					expect(
						classNameWithParametersAsPrototypeLazilyInstance2.getParameter()
					).to.be.equal( 'expected value' )

					expect(
						classNameWithParametersAsPrototypeLazilyInstance1
					).not.to.be.equal( classNameWithParametersAsPrototypeLazilyInstance2 )

					return
				)

				return
			)

			return
		)

		describe( 'Configuration with a class name for a singleton class', ->

			specify( 'should be configurable with a class name for a singleton class', ->
				Deft.Injector.configure(
					classNameForSingletonClass:
						className: 'ExampleSingletonClass'
				)

				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClass' )
				).to.be.true

				return
			)

			specify( 'should not be configurable with a class name for a singleton class and constructor parameters', ->
				expect( ->
					Deft.Injector.configure(
						classNameForSingletonClassWithParameters:
							className: 'ExampleSingletonClass'
							parameters: [ { parameter: 'expected value' } ]
					)
					return
				).to.throw( Error, "Error while configuring rule for 'classNameForSingletonClassWithParameters': parameters cannot be applied to singleton classes. Consider removing 'singleton: true' from the class definition." )

				return
			)

			specify( 'should be configurable with a class name for a singleton class, eagerly', ->
				Deft.Injector.configure(
					classNameForSingletonClassEagerly:
						className: 'ExampleSingletonClass'
						eager: true
				)

				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClassEagerly' )
				).to.be.true

				return
			)

			specify( 'should be configurable with a class name for a singleton class, (explicitly) lazily', ->
				Deft.Injector.configure(
					classNameForSingletonClassLazily:
						className: 'ExampleSingletonClass'
						eager: false
				)

				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClassLazily' )
				).to.be.true

				return
			)

			specify( 'should be configurable with a class name for a singleton class, (explicitly) as a singleton', ->
				Deft.Injector.configure(
					classNameForSingletonClassAsSingleton:
						className: 'ExampleSingletonClass'
						singleton: true
				)

				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClassAsSingleton' )
				).to.be.true

				return
			)

			specify( 'should be configurable with a class name for a singleton class, (explicitly) as a singleton, eagerly', ->
				Deft.Injector.configure(
					classNameForSingletonClassAsSingletonEagerly:
						className: 'ExampleSingletonClass'
						singleton: true
						eager: true
				)

				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClassAsSingletonEagerly' )
				).to.be.true

				return
			)

			specify( 'should be configurable with a class name for a singleton class, (explicitly) as a singleton, (explicitly) lazily', ->
				Deft.Injector.configure(
					classNameForSingletonClassAsSingletonLazily:
						className: 'ExampleSingletonClass'
						singleton: true
						eager: false
				)

				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClassAsSingletonLazily' )
				).to.be.true

				return
			)

			specify( 'should not be configurable with a class name for a singleton class, as a prototype', ->
				expect( ->
					Deft.Injector.configure(
						classNameForSingletonClassAsPrototype:
							className: 'ExampleSingletonClass'
							singleton: false
					)
					return
				).to.throw( Error, "Error while configuring rule for 'classNameForSingletonClassAsPrototype': singleton classes cannot be configured for injection as a prototype. Consider removing 'singleton: true' from the class definition." )

				return
			)

			specify( 'should not be configurable with a class name for a singleton class, as a prototype, eagerly', ->
				expect( ->
					Deft.Injector.configure(
						classNameForSingletonClassAsPrototypeEagerly:
							className: 'ExampleSingletonClass'
							singleton: false
							eager: true
					)
					return
				).to.throw( Error, "Error while configuring 'classNameForSingletonClassAsPrototypeEagerly': only singletons can be created eagerly." )

				return
			)

			specify( 'should not be configurable with a class name for a singleton class, as a prototype, (explicitly) lazily', ->
				expect( ->
					Deft.Injector.configure(
						classNameForSingletonClassAsPrototypeLazily:
							className: 'ExampleSingletonClass'
							singleton: false
							eager: false
					)
					return
				).to.throw( Error, "Error while configuring rule for 'classNameForSingletonClassAsPrototypeLazily': singleton classes cannot be configured for injection as a prototype. Consider removing 'singleton: true' from the class definition." )

				return
			)

			describe( 'Resolution of a dependency configured with a class name for a singleton class', ->

				specify( 'should resolve a dependency configured with a class name for a singleton class with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassInstance = Deft.Injector.resolve( 'classNameForSingletonClass' )
					).to.be.equal( ExampleSingletonClass )

					expect(
						Deft.Injector.resolve( 'classNameForSingletonClass' )
					).to.be.equal( classNameForSingletonClassInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name for a singleton class, eagerly, with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassEagerlyInstance = Deft.Injector.resolve( 'classNameForSingletonClassEagerly' )
					).to.be.equal( ExampleSingletonClass )

					expect(
						Deft.Injector.resolve( 'classNameForSingletonClassEagerly' )
					).to.be.equal( classNameForSingletonClassEagerlyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name for a singleton class, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassEagerlyInstance = Deft.Injector.resolve( 'classNameForSingletonClassLazily' )
					).to.be.equal( ExampleSingletonClass )

					expect(
						Deft.Injector.resolve( 'classNameForSingletonClassLazily' )
					).to.be.equal( classNameForSingletonClassEagerlyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name for a singleton class, (explicitly) as a singleton, with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassAsSingletonInstance = Deft.Injector.resolve( 'classNameForSingletonClassAsSingleton' )
					).to.be.equal( ExampleSingletonClass )

					expect(
						Deft.Injector.resolve( 'classNameForSingletonClassAsSingleton' )
					).to.be.equal( classNameForSingletonClassAsSingletonInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name for a singleton class, (explicitly) as a singleton, eagerly, with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassAsSingletonEagerlyInstance = Deft.Injector.resolve( 'classNameForSingletonClassAsSingletonEagerly' )
					).to.be.equal( ExampleSingletonClass )

					expect(
						Deft.Injector.resolve( 'classNameForSingletonClassAsSingletonEagerly' )
					).to.be.equal( classNameForSingletonClassAsSingletonEagerlyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a class name for a singleton class, (explicitly) as a singleton, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassAsSingletonLazilyInstance = Deft.Injector.resolve( 'classNameForSingletonClassAsSingletonLazily' )
					).to.be.equal( ExampleSingletonClass )

					expect(
						Deft.Injector.resolve( 'classNameForSingletonClassAsSingletonLazily' )
					).to.be.equal( classNameForSingletonClassAsSingletonLazilyInstance )

					return
				)

				return
			)

			return
		)

		describe( 'Configuration with a factory function', ->

			factoryFunction = -> return Ext.create( 'ExampleClass' )

			expectedFnEagerlyInstance = null
			expectedFnAsSingletonEagerlyInstance = null

			specify( 'should be configurable with a factory function', ->
				factoryFunctionSpy = sinon.spy( factoryFunction )

				Deft.Injector.configure(
					fn:
						fn: factoryFunctionSpy
				)

				expect( factoryFunctionSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'fn' )
				).to.be.true

				return
			)

			specify( 'should be configurable with a factory function, eagerly', ->
				factoryFunctionSpy = sinon.spy( factoryFunction )

				Deft.Injector.configure(
					fnEagerly:
						fn: factoryFunctionSpy
						eager: true
				)

				expectedFnEagerlyInstance = factoryFunctionSpy.returnValues[0]

				expect( factoryFunctionSpy ).to.be.calledOnce

				expect(
					expectedFnEagerlyInstance
				).to.be.instanceof( ExampleClass )

				expect(
					Deft.Injector.canResolve( 'fnEagerly' )
				).to.be.true

				return
			)

			specify( 'should be configurable with a factory function, (explicitly) lazily', ->
				factoryFunctionSpy = sinon.spy( factoryFunction )

				Deft.Injector.configure(
					fnLazily:
						fn: factoryFunctionSpy
						eager: false
				)

				expect( factoryFunctionSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'fnLazily' )
				).to.be.true

				return
			)

			specify( 'should be configurable with a factory function, (explicitly) as a singleton', ->
				factoryFunctionSpy = sinon.spy( factoryFunction )

				Deft.Injector.configure(
					fnAsSingleton:
						fn: factoryFunctionSpy
						singleton: true
				)

				expect( factoryFunctionSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'fnAsSingleton' )
				).to.be.true

				return
			)

			specify( 'should be configurable with a factory function, (explicitly) as a singleton, eagerly', ->
				factoryFunctionSpy = sinon.spy( factoryFunction )

				Deft.Injector.configure(
					fnAsSingletonEagerly:
						fn: factoryFunctionSpy
						singleton: true
						eager: true
				)

				expectedFnAsSingletonEagerlyInstance = factoryFunctionSpy.returnValues[0]

				expect( factoryFunctionSpy ).to.be.called

				expect(
					expectedFnAsSingletonEagerlyInstance
				).to.be.instanceof( ExampleClass )

				expect(
					Deft.Injector.canResolve( 'fnAsSingletonEagerly' )
				).to.be.true

				return
			)

			specify( 'should be configurable with a factory function, (explicitly) as a singleton, (explicitly) lazily', ->
				factoryFunctionSpy = sinon.spy( factoryFunction )

				Deft.Injector.configure(
					fnAsSingletonLazily:
						fn: factoryFunctionSpy
						singleton: true
						eager: false
				)

				expect( factoryFunctionSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'fnAsSingletonLazily' )
				).to.be.true

				return
			)

			specify( 'should be configurable with a factory function, as a prototype', ->
				factoryFunctionSpy = sinon.spy( factoryFunction )

				Deft.Injector.configure(
					fnAsPrototype:
						fn: factoryFunctionSpy
						singleton: false
				)

				expect( factoryFunctionSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'fnAsPrototype' )
				).to.be.true

				return
			)

			specify( 'should not be configurable with a factory function, as a prototype, eagerly', ->
				expect( ->
					Deft.Injector.configure(
						fnAsPrototypeEagerly:
							fn: factoryFunction
							singleton: false
							eager: true
					)
					return
				).to.throw( Error, "Error while configuring 'fnAsPrototypeEagerly': only singletons can be created eagerly." )

				return
			)

			specify( 'should be configurable with a factory function, as a prototype, (explicitly) lazily', ->
				factoryFunctionSpy = sinon.spy( factoryFunction )

				Deft.Injector.configure(
					fnAsPrototypeLazily:
						fn: factoryFunctionSpy
						singleton: false
						eager: false
				)

				expect( factoryFunctionSpy ).not.to.be.called

				expect(
					Deft.Injector.canResolve( 'fnAsPrototypeLazily' )
				).to.be.true

				return
			)

			describe( 'Resolution of a dependency configured with a factory function', ->

				specify( 'should resolve a dependency configured with a factory function with the corresponding singleton return value', ->
					expect(
						fnInstance = Deft.Injector.resolve( 'fn' )
					).to.be.instanceof( ExampleClass )

					expect(
						Deft.Injector.resolve( 'fn' )
					).to.be.equal( fnInstance )

					return
				)

				specify( 'should resolve a dependency configured with a factory function, eagerly, with the corresponding singleton return value', ->
					expect(
						Deft.Injector.resolve( 'fnEagerly' )
					).to.be.equal( expectedFnEagerlyInstance )

					expect(
						Deft.Injector.resolve( 'fnEagerly' )
					).to.be.equal( expectedFnEagerlyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a factory function, (explicitly) lazily, with the corresponding singleton return value', ->
					expect(
						fnLazilyInstance = Deft.Injector.resolve( 'fnLazily' )
					).to.be.instanceof( ExampleClass )

					expect(
						Deft.Injector.resolve( 'fnLazily' )
					).to.be.equal( fnLazilyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a factory function, (explicitly) as a singleton, with the corresponding singleton return value', ->
					expect(
						fnAsSingletonInstance = Deft.Injector.resolve( 'fnAsSingleton' )
					).to.be.instanceof( ExampleClass )

					expect(
						Deft.Injector.resolve( 'fnAsSingleton' )
					).to.be.equal( fnAsSingletonInstance )

					return
				)

				specify( 'should resolve a dependency configured with a factory function, (explicitly) as a singleton, eagerly, with the corresponding singleton return value', ->
					expect(
						Deft.Injector.resolve( 'fnAsSingletonEagerly' )
					).to.be.equal( expectedFnAsSingletonEagerlyInstance )

					expect(
						Deft.Injector.resolve( 'fnAsSingletonEagerly' )
					).to.be.equal( expectedFnAsSingletonEagerlyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a factory function, (explicitly) as a singleton, (explicitly) lazily, with the corresponding singleton return value', ->
					expect(
						fnAsSingletonLazilyInstance = Deft.Injector.resolve( 'fnAsSingletonLazily' )
					).to.be.instanceof( ExampleClass )

					expect(
						Deft.Injector.resolve( 'fnAsSingletonLazily' )
					).to.be.equal( fnAsSingletonLazilyInstance )

					return
				)

				specify( 'should resolve a dependency configured with a factory function, as a prototype, with the corresponding prototype return value', ->
					fnAsPrototypeInstance1 = Deft.Injector.resolve( 'fnAsPrototype' )
					fnAsPrototypeInstance2 = Deft.Injector.resolve( 'fnAsPrototype' )

					expect(
						fnAsPrototypeInstance1
					).to.be.instanceof( ExampleClass )

					expect(
						fnAsPrototypeInstance2
					).to.be.instanceof( ExampleClass )

					expect(
						fnAsPrototypeInstance1
					).not.to.be.equal( fnAsPrototypeInstance2 )

					return
				)

				specify( 'should resolve a dependency configured with a factory function, as a prototype, (explicitly) lazily, with the corresponding prototype return value', ->
					fnAsPrototypeLazilyInstance1 = Deft.Injector.resolve( 'fnAsPrototypeLazily' )
					fnAsPrototypeLazilyInstance2 = Deft.Injector.resolve( 'fnAsPrototypeLazily' )

					expect(
						fnAsPrototypeLazilyInstance1
					).to.be.instanceof( ExampleClass )

					expect(
						fnAsPrototypeLazilyInstance2
					).to.be.instanceof( ExampleClass )

					expect(
						fnAsPrototypeLazilyInstance1
					).not.to.be.equal( fnAsPrototypeLazilyInstance2 )

					return
				)

				return
			)

			return
		)

		describeConfigurationByValueOfType = ( typeDescriptor ) ->
			type = typeDescriptor.type
			value = typeDescriptor.value
			prefix = typeDescriptor.type.toLowerCase() + 'Value'

			describe( "Configuration with a #{ type } value", ->

				createIdentifiedConfiguration = ( identifier, configuration ) ->
					identifiedConfiguration = {}
					identifiedConfiguration[ identifier ] = configuration
					return identifiedConfiguration

				specify( "should be configurable with a #{ type } value", ->
					identifier = prefix

					Deft.Injector.configure(
						createIdentifiedConfiguration( identifier,
							value: value
						)
					)

					expect(
						Deft.Injector.canResolve( identifier )
					).to.be.true

					return
				)

				specify( "should not be configurable with a #{ type } value, eagerly", ->
					identifier = prefix + 'Eagerly'

					expect( ->
						Deft.Injector.configure(
							createIdentifiedConfiguration( identifier,
								value: value
								eager: true
							)
						)
						return
					).to.throw( Error, "Error while configuring '#{ identifier }': a 'value' cannot be created eagerly." )

					return
				)

				specify( "should be configurable with a #{ type } value, (explicitly) lazily", ->
					identifier = prefix + 'Lazily'

					Deft.Injector.configure(
						createIdentifiedConfiguration( identifier,
							value: value
							eager: false
						)
					)

					expect(
						Deft.Injector.canResolve( identifier )
					).to.be.true

					return
				)

				specify( "should be configurable with a #{ type } value, (explicitly) as a singleton", ->
					identifier = prefix + 'AsSingleton'

					Deft.Injector.configure(
						createIdentifiedConfiguration( identifier,
							value: value
							singleton: true
						)
					)

					expect(
						Deft.Injector.canResolve( identifier )
					).to.be.true

					return
				)

				specify( "should not be configurable with a #{ type } value, (explicitly) as a singleton, eagerly", ->
					identifier = prefix + 'AsSingletonEagerly'

					expect( ->
						Deft.Injector.configure(
							createIdentifiedConfiguration( identifier,
								value: value
								singleton: true
								eager: true
							)
						)
						return
					).to.throw( Error, "Error while configuring '#{ identifier }': a 'value' cannot be created eagerly." )

					return
				)

				specify( "should be configurable with a #{ type } value, (explicitly) as a singleton, (explicitly) lazily", ->
					identifier = prefix + 'AsSingletonLazily'

					Deft.Injector.configure(
						createIdentifiedConfiguration( identifier,
							value: value
							singleton: true
							eager: false
						)
					)

					expect(
						Deft.Injector.canResolve( identifier )
					).to.be.true

					return
				)

				specify( "should not be configurable with a #{ type } value, as a prototype", ->
					identifier = prefix + 'AsPrototype'

					expect( ->
						Deft.Injector.configure(
							createIdentifiedConfiguration( identifier,
								value: value
								singleton: false
							)
						)
						return
					).to.throw( Error, "Error while configuring '#{ identifier }': a 'value' can only be configured as a singleton." )

					return
				)

				specify( "should not be configurable with a #{ type } value, as a prototype, eagerly", ->
					identifier = prefix + 'AsPrototypeEagerly'

					expect( ->
						Deft.Injector.configure(
							createIdentifiedConfiguration( identifier,
								value: value
								singleton: false
								eager: true
							)
						)
						return
					).to.throw( Error, "Error while configuring '#{ identifier }': a 'value' cannot be created eagerly." )

					return
				)

				specify( "should not be configurable with a #{ type } value, as a prototype, (explicitly) lazily", ->
					identifier = prefix + 'AsPrototypeLazily'

					expect( ->
						Deft.Injector.configure(
							createIdentifiedConfiguration( identifier,
								value: value
								singleton: false
								eager: false
							)
						)
						return
					).to.throw( Error, "Error while configuring '#{ identifier }': a 'value' can only be configured as a singleton." )

					return
				)

				describe( "Resolution of a dependency configured with a #{ type } value", ->

					specify( "should resolve a dependency configured with a #{ type } value with the corresponding value", ->
						identifier = prefix

						expect(
							Deft.Injector.resolve( identifier )
						).to.be.equal( value )

						return
					)

					specify( "should resolve a dependency configured with a #{ type } value with the corresponding value, (explicitly) lazily", ->
						identifier = prefix + 'Lazily'

						expect(
							Deft.Injector.resolve( identifier )
						).to.be.equal( value )

						return
					)

					specify( "should resolve a dependency configured with a #{ type } value, (explicitly) as a singleton, with the corresponding value", ->
						identifier = prefix + 'AsSingleton'

						expect(
							Deft.Injector.resolve( identifier )
						).to.be.equal( value )

						return
					)

					specify( "should resolve a dependency configured with a #{ type } value, (explicitly) as a singleton, (explicitly) lazily, with the corresponding value", ->
						identifier = prefix + 'AsSingletonLazily'

						expect(
							Deft.Injector.resolve( identifier )
						).to.be.equal( value )

						return
					)

					return
				)

				return
			)

			return

		typeDescriptors = [
			{
				type: 'Boolean'
				value: true
			}
			{
				type: 'String'
				value: 'expected value'
			}
			{
				type: 'Number'
				value: 3.14
			}
			{
				type: 'Date'
				value: new Date()
			}
			{
				type: 'Array'
				value: []
			}
			{
				type: 'Object'
				value: {}
			}
			{
				type: 'Class'
				value: Ext.create( 'ExampleClass' )
			}
			{
				type: 'Function'
				value: -> return
			}
		]

		for typeDescriptor in typeDescriptors
			describeConfigurationByValueOfType.call( this, typeDescriptor )

		configuredIdentifiers = [
			'classNameAsString'
			'className'
			'classNameEagerly'
			'classNameLazily'
			'classNameAsSingleton'
			'classNameAsSingletonEagerly'
			'classNameAsSingletonLazily'
			'classNameAsPrototype'
			'classNameAsPrototypeLazily'
			'classNameWithParameters'
			'classNameWithParametersEagerly'
			'classNameWithParametersLazily'
			'classNameWithParametersAsSingleton'
			'classNameWithParametersAsSingletonEagerly'
			'classNameWithParametersAsSingletonLazily'
			'classNameWithParametersAsPrototype'
			'classNameWithParametersAsPrototypeLazily'
			'classNameForSingletonClass'
			'classNameForSingletonClassEagerly'
			'classNameForSingletonClassLazily'
			'classNameForSingletonClassAsSingleton'
			'classNameForSingletonClassAsSingletonEagerly'
			'classNameForSingletonClassAsSingletonLazily'
			'fn'
			'fnEagerly'
			'fnLazily'
			'fnAsSingleton'
			'fnAsSingletonEagerly'
			'fnAsSingletonLazily'
			'fnAsPrototype'
			'fnAsPrototypeLazily'
			'booleanValue'
			'booleanValueLazily'
			'booleanValueAsSingleton'
			'booleanValueAsSingletonLazily'
			'stringValue'
			'stringValueLazily'
			'stringValueAsSingleton'
			'stringValueAsSingletonLazily'
			'numberValue'
			'numberValueLazily'
			'numberValueAsSingleton'
			'numberValueAsSingletonLazily'
			'dateValue'
			'dateValueLazily'
			'dateValueAsSingleton'
			'dateValueAsSingletonLazily'
			'arrayValue'
			'arrayValueLazily'
			'arrayValueAsSingleton'
			'arrayValueAsSingletonLazily'
			'objectValue'
			'objectValueLazily'
			'objectValueAsSingleton'
			'objectValueAsSingletonLazily'
			'classValue'
			'classValueLazily'
			'classValueAsSingleton'
			'classValueAsSingletonLazily'
			'functionValue'
			'functionValueLazily'
			'functionValueAsSingleton'
			'functionValueAsSingletonLazily'
		]

		describe( 'Resolution', ->

			specify( 'should resolve a value for configured identifiers', ->

				for configuredIdentifier in configuredIdentifiers
					expect(
						Deft.Injector.resolve( configuredIdentifier )
					).not.to.be.null

				return
			)

			specify( 'should throw an error if asked to resolve an unconfigured identifier', ->
				expect( ->
					Deft.Injector.resolve( 'unconfiguredIdentifier' )
					return
				).to.throw( Error, "Error while resolving value to inject: no dependency provider found for 'unconfiguredIdentifier'." )

				return
			)

			specify( 'should pass the instance specified for resolution when lazily resolving a dependency with a factory function', ->

				factoryFunction = -> return 'expected value'

				exampleConfig =
					prop1: 42
					config:
						example: true

				exampleClassInstance = Ext.create( 'ExampleClass', exampleConfig )

				fnResolvePassedInstanceFactoryFunction                  = sinon.spy( factoryFunction )
				fnResolvePassedInstanceLazilyFactoryFunction            = sinon.spy( factoryFunction )
				fnResolvePassedInstanceAsSingletonFactoryFunction       = sinon.spy( factoryFunction )
				fnResolvePassedInstanceAsSingletonLazilyFactoryFunction = sinon.spy( factoryFunction )
				fnResolvePassedInstanceAsPrototypeFactoryFunction       = sinon.spy( factoryFunction )
				fnResolvePassedInstanceAsPrototypeLazilyFactoryFunction = sinon.spy( factoryFunction )

				Deft.Injector.configure(
					fnResolvePassedInstance: {
						fn: fnResolvePassedInstanceFactoryFunction
					}
					fnResolvePassedInstanceLazily: {
						fn: fnResolvePassedInstanceLazilyFactoryFunction
						eager: false
					}
					fnResolvePassedInstanceAsSingleton: {
						fn: fnResolvePassedInstanceAsSingletonFactoryFunction
						singleton: true
					}
					fnResolvePassedInstanceAsSingletonLazily: {
						fn: fnResolvePassedInstanceAsSingletonLazilyFactoryFunction
						singleton: true
						eager: false
					}
					fnResolvePassedInstanceAsPrototype: {
						fn: fnResolvePassedInstanceAsPrototypeFactoryFunction
						singleton: false
					}
					fnResolvePassedInstanceAsPrototypeLazily: {
						fn: fnResolvePassedInstanceAsPrototypeLazilyFactoryFunction
						singleton: false
						eager: false
					}
				)

				factoryFunctionIdentifiers = [
					'fnResolvePassedInstance'
					'fnResolvePassedInstanceLazily'
					'fnResolvePassedInstanceAsSingleton'
					'fnResolvePassedInstanceAsSingletonLazily'
					'fnResolvePassedInstanceAsPrototype'
					'fnResolvePassedInstanceAsPrototypeLazily'
				]

				for factoryFunctionIdentifier in factoryFunctionIdentifiers
					Deft.Injector.resolve( factoryFunctionIdentifier, exampleClassInstance )

				expect( fnResolvePassedInstanceFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnResolvePassedInstanceLazilyFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnResolvePassedInstanceAsSingletonFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnResolvePassedInstanceAsSingletonLazilyFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnResolvePassedInstanceAsPrototypeFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnResolvePassedInstanceAsPrototypeLazilyFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )

				expect( fnResolvePassedInstanceFactoryFunction ).to.be.calledWith( exampleClassInstance )
				expect( fnResolvePassedInstanceLazilyFactoryFunction ).to.be.calledWith( exampleClassInstance )
				expect( fnResolvePassedInstanceAsSingletonFactoryFunction ).to.be.calledWith( exampleClassInstance )
				expect( fnResolvePassedInstanceAsSingletonLazilyFactoryFunction ).to.be.calledWith( exampleClassInstance )
				expect( fnResolvePassedInstanceAsPrototypeFactoryFunction ).to.be.calledWith( exampleClassInstance )
				expect( fnResolvePassedInstanceAsPrototypeLazilyFactoryFunction ).to.be.calledWith( exampleClassInstance )

				return
			)

			return
		)

		describe( 'Injection', ->

			Ext.define( 'SimpleClass',

				constructor: ->
					return @
			)

			Ext.define( 'ComplexBaseClass',
				config:
					classNameAsString: null
					className: null
					classNameEagerly: null
					classNameLazily: null
					classNameAsSingleton: null
					classNameAsSingletonEagerly: null
					classNameAsSingletonLazily: null
					classNameAsPrototype: null
					classNameAsPrototypeLazily: null
					classNameWithParameters: null
					classNameWithParametersEagerly: null
					classNameWithParametersLazily: null
					classNameWithParametersAsSingleton: null
					classNameWithParametersAsSingletonEagerly: null
					classNameWithParametersAsSingletonLazily: null
					classNameWithParametersAsPrototype: null
					classNameWithParametersAsPrototypeLazily: null
					classNameForSingletonClass: null
					classNameForSingletonClassEagerly: null
					classNameForSingletonClassLazily: null
					classNameForSingletonClassAsSingleton: null
					classNameForSingletonClassAsSingletonEagerly: null
					classNameForSingletonClassAsSingletonLazily: null
					fn: null
					fnEagerly: null
					fnLazily: null
					fnAsSingleton: null
					fnAsSingletonEagerly: null
					fnAsSingletonLazily: null
					fnAsPrototype: null
					fnAsPrototypeLazily: null
					booleanValue: null
					booleanValueLazily: null
					booleanValueAsSingleton: null
					booleanValueAsSingletonLazily: null
					stringValue: null
					stringValueLazily: null
					stringValueAsSingleton: null
					stringValueAsSingletonLazily: null
					numberValue: null
					numberValueLazily: null
					numberValueAsSingleton: null
					numberValueAsSingletonLazily: null
					dateValue: null
					dateValueLazily: null
					dateValueAsSingleton: null
					dateValueAsSingletonLazily: null
					arrayValue: null
					arrayValueLazily: null
					arrayValueAsSingleton: null
					arrayValueAsSingletonLazily: null
					objectValue: null
					objectValueLazily: null
					objectValueAsSingleton: null
					objectValueAsSingletonLazily: null
					classValue: null
					classValueLazily: null
					classValueAsSingleton: null
					classValueAsSingletonLazily: null
					functionValue: null
					functionValueLazily: null
					functionValueAsSingleton: null
					functionValueAsSingletonLazily: null

				constructor: ( config ) ->
					@initConfig( config )
					return @
			)

			Ext.define( 'ComplexClass',
				extend: 'ComplexBaseClass'

				constructor: ( config ) ->
					return @callParent( arguments )
			)

			Ext.define( 'InjectableSimpleClass',
				extend: 'SimpleClass'
				mixins: [ 'Deft.mixin.Injectable' ]
				inject: configuredIdentifiers

				constructor: ( config ) ->
					return @callParent( arguments )
			)

			Ext.define( 'InjectableComplexClass',
				extend: 'ComplexBaseClass'
				mixins: [ 'Deft.mixin.Injectable' ]
				inject: configuredIdentifiers

				constructor: ( config ) ->
					return @callParent( arguments )
			)

			Ext.define( 'InjectableComponentSubclass',
				extend: 'Ext.Component'
				mixins: [ 'Deft.mixin.Injectable' ]
				inject: configuredIdentifiers

				config:
					classNameAsString: null
					className: null
					classNameEagerly: null
					classNameLazily: null
					classNameAsSingleton: null
					classNameAsSingletonEagerly: null
					classNameAsSingletonLazily: null
					classNameAsPrototype: null
					classNameAsPrototypeLazily: null
					classNameWithParameters: null
					classNameWithParametersEagerly: null
					classNameWithParametersLazily: null
					classNameWithParametersAsSingleton: null
					classNameWithParametersAsSingletonEagerly: null
					classNameWithParametersAsSingletonLazily: null
					classNameWithParametersAsPrototype: null
					classNameWithParametersAsPrototypeLazily: null
					classNameForSingletonClass: null
					classNameForSingletonClassEagerly: null
					classNameForSingletonClassLazily: null
					classNameForSingletonClassAsSingleton: null
					classNameForSingletonClassAsSingletonEagerly: null
					classNameForSingletonClassAsSingletonLazily: null
					fn: null
					fnEagerly: null
					fnLazily: null
					fnAsSingleton: null
					fnAsSingletonEagerly: null
					fnAsSingletonLazily: null
					fnAsPrototype: null
					fnAsPrototypeLazily: null
					booleanValue: null
					booleanValueLazily: null
					booleanValueAsSingleton: null
					booleanValueAsSingletonLazily: null
					stringValue: null
					stringValueLazily: null
					stringValueAsSingleton: null
					stringValueAsSingletonLazily: null
					numberValue: null
					numberValueLazily: null
					numberValueAsSingleton: null
					numberValueAsSingletonLazily: null
					dateValue: null
					dateValueLazily: null
					dateValueAsSingleton: null
					dateValueAsSingletonLazily: null
					arrayValue: null
					arrayValueLazily: null
					arrayValueAsSingleton: null
					arrayValueAsSingletonLazily: null
					objectValue: null
					objectValueLazily: null
					objectValueAsSingleton: null
					objectValueAsSingletonLazily: null
					classValue: null
					classValueLazily: null
					classValueAsSingleton: null
					classValueAsSingletonLazily: null
					functionValue: null
					functionValueLazily: null
					functionValueAsSingleton: null
					functionValueAsSingletonLazily: null

				constructor: ( config ) ->
					return @callParent( arguments )
			)

			Ext.define( 'InjectableCircularDependencyClass1',
				extend: 'SimpleClass'
				inject: [ 'simpleClass', 'injectableCircularDependencyClass2' ]

				constructor: ( config ) ->
					return @callParent( arguments )
			)

			Ext.define( 'InjectableCircularDependencyClass2',
				extend: 'SimpleClass'
				inject: [ 'injectableCircularDependencyClass3', 'simpleClass' ]

				constructor: ( config ) ->
					return @callParent( arguments )
			)

			Ext.define( 'InjectableCircularDependencyClass3Parent',
				extend: 'SimpleClass'
				inject: [ 'injectableCircularDependencyClass1' ]

				constructor: ( config ) ->
					return @callParent( arguments )
			)

			Ext.define( 'InjectableCircularDependencyClass3',
				extend: 'InjectableCircularDependencyClass3Parent'
				inject: [ 'simpleClass' ]

				constructor: ( config ) ->
					return @callParent( arguments )
			)

			specify( 'should throw an error when injecting configured circular dependencies into properties for a given class instance', ->
				Deft.Injector.configure(
					simpleClass: 'SimpleClass'
					injectableCircularDependencyClass1: 'InjectableCircularDependencyClass1'
					injectableCircularDependencyClass2: 'InjectableCircularDependencyClass2'
					injectableCircularDependencyClass3: 'InjectableCircularDependencyClass3'
				)

				Ext.define( 'InjectableTargetClassForCircularDependencies',
					extend: 'SimpleClass'
					mixins: [ 'Deft.mixin.Injectable' ]
					inject: [ 'simpleClass', 'injectableCircularDependencyClass1' ]

					constructor: ( config ) ->
						return @callParent( arguments )
				)

				try
					injectableSimpleClassForCircularDependencies = Ext.create( 'InjectableTargetClassForCircularDependencies' )
				catch error
					expect( error.message.lastIndexOf( 'circular dependency' ) ).to.be.greaterThan( -1 )

				delete InjectableTargetClassForCircularDependencies

				return
			)

			specify( 'should inject configured dependencies into properties for a given class instance', ->
				simpleClassInstance = Ext.create( 'SimpleClass' )

				Deft.Injector.inject( configuredIdentifiers, simpleClassInstance )

				for configuredIdentifier in configuredIdentifiers
					expect(
						simpleClassInstance[ configuredIdentifier ]
					).to.exist

					expect(
						simpleClassInstance[ configuredIdentifier ]
					).not.to.be.null

					resolvedValue = Deft.Injector.resolve( configuredIdentifier )

					if configuredIdentifier.indexOf( 'Prototype' ) is -1
						expect(
							simpleClassInstance[ configuredIdentifier ]
						).to.be.equal( resolvedValue )
					else
						expect(
							simpleClassInstance[ configuredIdentifier ]
						).to.be.instanceof( Ext.ClassManager.getClass( resolvedValue ) )

				return
			)

			specify( 'should inject configured dependencies into configs for a given class instance', ->
				complexClassInstance = Ext.create( 'ComplexClass' )

				Deft.Injector.inject( configuredIdentifiers, complexClassInstance )

				for configuredIdentifier in configuredIdentifiers
					getterFunctionName = 'get' + Ext.String.capitalize( configuredIdentifier )

					expect(
						complexClassInstance[ getterFunctionName ]()
					).not.to.be.null

					resolvedValue = Deft.Injector.resolve( configuredIdentifier )

					if configuredIdentifier.indexOf( 'Prototype' ) is -1
						expect(
							complexClassInstance[ getterFunctionName ]()
						).to.be.equal( resolvedValue )
					else
						expect(
							complexClassInstance[ getterFunctionName ]()
						).to.be.instanceof( Ext.ClassManager.getClass( resolvedValue ) )

				return
			)

			specify( 'should automatically inject configured dependencies into properties for a given Injectable class instance', ->
				simpleInjectableClassInstance = Ext.create( 'InjectableSimpleClass' )

				for configuredIdentifier in configuredIdentifiers
					expect(
						simpleInjectableClassInstance[ configuredIdentifier ]
					).to.exist

					expect(
						simpleInjectableClassInstance[ configuredIdentifier ]
					).not.to.be.null

					resolvedValue = Deft.Injector.resolve( configuredIdentifier )

					if configuredIdentifier.indexOf( 'Prototype' ) is -1
						expect(
							simpleInjectableClassInstance[ configuredIdentifier ]
						).to.be.equal( resolvedValue )
					else
						expect(
							simpleInjectableClassInstance[ configuredIdentifier ]
						).to.be.instanceof( Ext.ClassManager.getClass( resolvedValue ) )

				return
			)

			specify( 'should automatically inject configured dependencies into configs for a given Injectable class instance', ->
				injectableComplexClassInstance = Ext.create( 'InjectableComplexClass' )

				for configuredIdentifier in configuredIdentifiers
					getterFunctionName = 'get' + Ext.String.capitalize( configuredIdentifier )

					expect(
						injectableComplexClassInstance[ getterFunctionName ]()
					).not.to.be.null

					resolvedValue = Deft.Injector.resolve( configuredIdentifier )

					if configuredIdentifier.indexOf( 'Prototype' ) is -1
						if configuredIdentifier.indexOf( 'objectValue' ) is -1
							expect(
								injectableComplexClassInstance[ getterFunctionName ]()
							).to.be.equal( resolvedValue )
						else
							# NOTE: Object configs are cloned/merged and will not be the exact same instance.
							expect(
								injectableComplexClassInstance[ getterFunctionName ]()
							).not.to.be.null
					else
						expect(
							injectableComplexClassInstance[ getterFunctionName ]()
						).to.be.instanceof( Ext.ClassManager.getClass( resolvedValue ) )

				return
			)


			specify( 'should automatically inject configured dependencies into configs for a given Injectable \`Ext.Component\` subclass instance', ->
				injectableComponentSubclassInstance = Ext.create( 'InjectableComponentSubclass' )

				for configuredIdentifier in configuredIdentifiers
					getterFunctionName = 'get' + Ext.String.capitalize( configuredIdentifier )

					expect(
						injectableComponentSubclassInstance[ getterFunctionName ]()
					).not.to.be.null

					resolvedValue = Deft.Injector.resolve( configuredIdentifier )

					if configuredIdentifier.indexOf( 'Prototype' ) is -1
						if configuredIdentifier.indexOf( 'objectValue' ) is -1
							expect(
								injectableComponentSubclassInstance[ getterFunctionName ]()
							).to.be.equal( resolvedValue )
						else
							# NOTE: Object configs are cloned/merged and will not be the exact same instance.
							expect(
								injectableComponentSubclassInstance[ getterFunctionName ]()
							).not.to.be.null
					else
						expect(
							injectableComponentSubclassInstance[ getterFunctionName ]()
						).to.be.instanceof( Ext.ClassManager.getClass( resolvedValue ) )

				return
			)

			specify( 'should throw an error if asked to inject an unconfigured identifier', ->
				simpleClassInstance = Ext.create( 'SimpleClass' )

				expect( ->
					Deft.Injector.inject( 'unconfiguredIdentifier', simpleClassInstance )
					return
				).to.throw( Error, "Error while resolving value to inject: no dependency provider found for 'unconfiguredIdentifier'." )

				return
			)

			specify( 'should execute in the instance context and pass the constructor parameters of the instance being injected when lazily injecting a dependency with a factory function', ->

				factoryFunction = -> return 'expected value'

				Ext.define( 'ExampleClassWithInject',
					inject: [
						'fnInjectPassedInstance'
						'fnInjectPassedInstanceLazily'
						'fnInjectPassedInstanceAsSingleton'
						'fnInjectPassedInstanceAsSingletonLazily'
						'fnInjectPassedInstanceAsPrototype'
						'fnInjectPassedInstanceAsPrototypeLazily'
					]
				)

				fnInjectPassedInstanceFactoryFunction                  = sinon.spy( factoryFunction )
				fnInjectPassedInstanceLazilyFactoryFunction            = sinon.spy( factoryFunction )
				fnInjectPassedInstanceAsSingletonFactoryFunction       = sinon.spy( factoryFunction )
				fnInjectPassedInstanceAsSingletonLazilyFactoryFunction = sinon.spy( factoryFunction )
				fnInjectPassedInstanceAsPrototypeFactoryFunction       = sinon.spy( factoryFunction )
				fnInjectPassedInstanceAsPrototypeLazilyFactoryFunction = sinon.spy( factoryFunction )

				Deft.Injector.configure(
					fnInjectPassedInstance: {
						fn: fnInjectPassedInstanceFactoryFunction
					}
					fnInjectPassedInstanceLazily: {
						fn: fnInjectPassedInstanceLazilyFactoryFunction
						eager: false
					}
					fnInjectPassedInstanceAsSingleton: {
						fn: fnInjectPassedInstanceAsSingletonFactoryFunction
						singleton: true
					}
					fnInjectPassedInstanceAsSingletonLazily: {
						fn: fnInjectPassedInstanceAsSingletonLazilyFactoryFunction
						singleton: true
						eager: false
					}
					fnInjectPassedInstanceAsPrototype: {
						fn: fnInjectPassedInstanceAsPrototypeFactoryFunction
						singleton: false
					}
					fnInjectPassedInstanceAsPrototypeLazily: {
						fn: fnInjectPassedInstanceAsPrototypeLazilyFactoryFunction
						singleton: false
						eager: false
					}
				)

				exampleConfig =
					prop1: 42
					config:
						example: true

				exampleClassInstance = Ext.create( 'ExampleClassWithInject', exampleConfig, 'second argument', 'third argument' )

				expect( fnInjectPassedInstanceFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnInjectPassedInstanceLazilyFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnInjectPassedInstanceAsSingletonFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnInjectPassedInstanceAsSingletonLazilyFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnInjectPassedInstanceAsPrototypeFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnInjectPassedInstanceAsPrototypeLazilyFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )

				expect( fnInjectPassedInstanceFactoryFunction ).to.be.calledWith( exampleClassInstance, exampleConfig, 'second argument', 'third argument' )
				expect( fnInjectPassedInstanceLazilyFactoryFunction ).to.be.calledWith( exampleClassInstance, exampleConfig, 'second argument', 'third argument' )
				expect( fnInjectPassedInstanceAsSingletonFactoryFunction ).to.be.calledWith( exampleClassInstance, exampleConfig, 'second argument', 'third argument' )
				expect( fnInjectPassedInstanceAsSingletonLazilyFactoryFunction ).to.be.calledWith( exampleClassInstance, exampleConfig, 'second argument', 'third argument' )
				expect( fnInjectPassedInstanceAsPrototypeFactoryFunction ).to.be.calledWith( exampleClassInstance, exampleConfig, 'second argument', 'third argument' )
				expect( fnInjectPassedInstanceAsPrototypeLazilyFactoryFunction ).to.be.calledWith( exampleClassInstance, exampleConfig, 'second argument', 'third argument' )

				delete ExampleClassWithInject

				return
			)

			specify( 'should execute in the instance context and pass the initial config of the instance being injected when lazily resolving a dependency with a factory function', ->

				factoryFunction = -> return 'expected value'

				exampleConfig =
					prop1: 42
					config:
						example: true

				exampleClassInstance = Ext.create( 'ExampleClass', exampleConfig )

				fnInjectPassedInstanceFactoryFunction                  = sinon.spy( factoryFunction )
				fnInjectPassedInstanceLazilyFactoryFunction            = sinon.spy( factoryFunction )
				fnInjectPassedInstanceAsSingletonFactoryFunction       = sinon.spy( factoryFunction )
				fnInjectPassedInstanceAsSingletonLazilyFactoryFunction = sinon.spy( factoryFunction )
				fnInjectPassedInstanceAsPrototypeFactoryFunction       = sinon.spy( factoryFunction )
				fnInjectPassedInstanceAsPrototypeLazilyFactoryFunction = sinon.spy( factoryFunction )

				Deft.Injector.configure(
					fnInjectPassedInstance: {
						fn: fnInjectPassedInstanceFactoryFunction
					}
					fnInjectPassedInstanceLazily: {
						fn: fnInjectPassedInstanceLazilyFactoryFunction
						eager: false
					}
					fnInjectPassedInstanceAsSingleton: {
						fn: fnInjectPassedInstanceAsSingletonFactoryFunction
						singleton: true
					}
					fnInjectPassedInstanceAsSingletonLazily: {
						fn: fnInjectPassedInstanceAsSingletonLazilyFactoryFunction
						singleton: true
						eager: false
					}
					fnInjectPassedInstanceAsPrototype: {
						fn: fnInjectPassedInstanceAsPrototypeFactoryFunction
						singleton: false
					}
					fnInjectPassedInstanceAsPrototypeLazily: {
						fn: fnInjectPassedInstanceAsPrototypeLazilyFactoryFunction
						singleton: false
						eager: false
					}
				)

				factoryFunctionIdentifiers = [
					'fnInjectPassedInstance'
					'fnInjectPassedInstanceLazily'
					'fnInjectPassedInstanceAsSingleton'
					'fnInjectPassedInstanceAsSingletonLazily'
					'fnInjectPassedInstanceAsPrototype'
					'fnInjectPassedInstanceAsPrototypeLazily'
				]

				Deft.Injector.inject( factoryFunctionIdentifiers, exampleClassInstance )

				expect( fnInjectPassedInstanceFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnInjectPassedInstanceLazilyFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnInjectPassedInstanceAsSingletonFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnInjectPassedInstanceAsSingletonLazilyFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnInjectPassedInstanceAsPrototypeFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )
				expect( fnInjectPassedInstanceAsPrototypeLazilyFactoryFunction.thisValues[0] ).to.be.equal( Deft.Injector )

				expect( fnInjectPassedInstanceFactoryFunction ).to.be.calledWith( exampleClassInstance )
				expect( fnInjectPassedInstanceLazilyFactoryFunction ).to.be.calledWith( exampleClassInstance )
				expect( fnInjectPassedInstanceAsSingletonFactoryFunction ).to.be.calledWith( exampleClassInstance )
				expect( fnInjectPassedInstanceAsSingletonLazilyFactoryFunction ).to.be.calledWith( exampleClassInstance )
				expect( fnInjectPassedInstanceAsPrototypeFactoryFunction ).to.be.calledWith( exampleClassInstance )
				expect( fnInjectPassedInstanceAsPrototypeLazilyFactoryFunction ).to.be.calledWith( exampleClassInstance )

				return
			)

			return
		)

		describe( 'Runtime configuration changes', ->

			beforeEach( ->
				Deft.Injector.reset()

				return
			)

			specify( 'should clear out configured identifiers when the reset method is called', ->
				Deft.Injector.configure(
					identifier:
						value: 'expected value'
				)

				expect(
					Deft.Injector.resolve( 'identifier' )
				).to.be.equal( 'expected value' )

				Deft.Injector.reset()

				expect( ->
					Deft.Injector.resolve( 'identifier' )
					return
				).to.throw( Error, "Error while resolving value to inject: no dependency provider found for 'identifier'." )

				return
			)

			specify( 'should aggregate providers across multiple calls to configure', ->
				Deft.Injector.configure(
					identifier1:
						value: 'value #1'
				)

				Deft.Injector.configure(
					identifier2:
						value: 'value #2'
				)

				expect(
					Deft.Injector.resolve( 'identifier1' )
				).to.be.equal( 'value #1' )

				expect(
					Deft.Injector.resolve( 'identifier2' )
				).to.be.equal( 'value #2' )

				return
			)

			specify( 'should resolve using the last provider to be configured for a given identifier (i.e. configuration for the same identifier overwrites the previous configuration)', ->
				Deft.Injector.configure(
					existingIdentifier:
						value: 'original value'
				)

				expect(
					Deft.Injector.resolve( 'existingIdentifier' )
				).to.be.equal( 'original value' )

				Deft.Injector.configure(
					existingIdentifier:
						value: 'new value'
				)

				expect(
					Deft.Injector.resolve( 'existingIdentifier' )
				).to.be.equal( 'new value' )

				return
			)

			specify( 'should instantiate eager providers when they are initially configured, and not reinstantiate them on subsequent calls to configure for other identifiers', ->
				factoryFn = sinon.spy( -> return 'expected value' )

				Deft.Injector.configure(
					eagerIdentifier:
						fn: factoryFn
						eager: true
				)

				expect( factoryFn ).to.be.calledOnce

				Deft.Injector.configure(
					anyOtherIdentifier:
						value: 'value'
				)

				expect( factoryFn ).to.be.calledOnce

				return
			)

			return
		)

		return
	)

	return
)
