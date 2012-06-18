###
Copyright (c) 2012 [DeftJS Framework Contributors](http://deftjs.org)
Open source under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
###

###
Jasmine test suite for Deft.ioc.Injector
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
	
	beforeEach( ->
		@addMatchers(
			toBeInstanceOf: ( className ) ->
				return @actual instanceof Ext.ClassManager.get( className )
		)
		
		return
	)
	
	describe( 'Configuration', ->
		
		describe( 'Configuration with a class name as a String', ->
			
			it( 'should be configurable with a class name as a String', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameAsString: 'ExampleClass'
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameAsString' )
				).toBe( true )
				
				return
			)
			
			describe( 'Resolution of a dependency configured with a class name as a String', ->
				
				it( "should resolve a dependency configured with a class name as a String with the corresponding singleton class instance", ->
					expect(
						classNameAsStringInstance = Deft.Injector.resolve( 'classNameAsString' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						Deft.Injector.resolve( 'classNameAsString' )
					).toBe( classNameAsStringInstance )
					
					return
				)
				
				return
			)
			
			return
		)
		
		describe( 'Configuration with a class name', ->
			
			expectedClassNameEagerlyInstance = null
			expectedClassNameAsSingletonEagerlyInstance = null
			
			it( 'should be configurable with a class name', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					className:
						className: 'ExampleClass'
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'className' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name, eagerly', ->
				constructorSpy = spyOn( ExampleClass.prototype, 'constructor' ).andCallFake( ->
					expectedClassNameEagerlyInstance = @
					return constructorSpy.originalValue.apply( @, arguments )
				)
				
				Deft.Injector.configure(
					classNameEagerly:
						className: 'ExampleClass'
						eager: true
				)
				
				expect( ExampleClass.prototype.constructor ).toHaveBeenCalled()
				
				expect(
					expectedClassNameEagerlyInstance
				).toBeInstanceOf( 'ExampleClass' )
				
				expect(
					Deft.Injector.canResolve( 'classNameEagerly' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name, (explicity) lazily', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameLazily:
						className: 'ExampleClass'
						eager: false
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameLazily' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name, (explicitly) as a singleton', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameAsSingleton:
						className: 'ExampleClass'
						singleton: true
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameAsSingleton' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name, (explicitly) as a singleton, eagerly', ->
				constructorSpy = spyOn( ExampleClass.prototype, 'constructor' ).andCallFake( ->
					expectedClassNameAsSingletonEagerlyInstance = @
					return constructorSpy.originalValue.apply( @, arguments )
				)
				
				Deft.Injector.configure(
					classNameAsSingletonEagerly:
						className: 'ExampleClass'
						singleton: true
						eager: true
				)
				
				expect( ExampleClass.prototype.constructor ).toHaveBeenCalled()
				
				expect(
					expectedClassNameAsSingletonEagerlyInstance
				).toBeInstanceOf( 'ExampleClass' )
				
				expect(
					Deft.Injector.canResolve( 'classNameAsSingletonEagerly' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name, (explicitly) as a singleton, (explicitly) lazily', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameAsSingletonLazily:
						className: 'ExampleClass'
						singleton: true
						eager: false
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameAsSingletonLazily' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name, as a prototype', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameAsPrototype:
						className: 'ExampleClass'
						singleton: false
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameAsPrototype' )
				).toBe( true )
				
				return
			)
			
			it( 'should not be configurable with a class name, as a prototype, eagerly', ->
				expect( ->
					Deft.Injector.configure(
						classNameAsPrototypeEagerly:
							className: 'ExampleClass'
							singleton: false
							eager: true
					)
					return
				).toThrow( new Error( "Error while configuring 'classNameAsPrototypeEagerly': only singletons can be created eagerly." ) )
				
				return
			)
			
			it( 'should be configurable with a class name, as a prototype, (explicitly) lazily', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameAsPrototypeLazily:
						className: 'ExampleClass'
						singleton: false
						eager: false
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameAsPrototypeLazily' )
				).toBe( true )
				
				return
			)
			
			describe( 'Resolution of a dependency configured with a class name', ->
				
				it( 'should resolve a dependency configured with a class name with the corresponding singleton class instance', ->
					expect(
						classNameInstance = Deft.Injector.resolve( 'className' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						Deft.Injector.resolve( 'className' )
					).toBe( classNameInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name, eagerly, with the corresponding singleton class instance', ->
					expect(
						Deft.Injector.resolve( 'classNameEagerly' )
					).toBe( expectedClassNameEagerlyInstance )
					
					expect(
						Deft.Injector.resolve( 'classNameEagerly' )
					).toBe( expectedClassNameEagerlyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameLazilyInstance = Deft.Injector.resolve( 'classNameLazily' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						Deft.Injector.resolve( 'classNameLazily' )
					).toBe( classNameLazilyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name, (explicitly) as a singleton, with the corresponding singleton class instance', ->
					expect(
						classNameAsSingletonInstance = Deft.Injector.resolve( 'classNameAsSingleton' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						Deft.Injector.resolve( 'classNameAsSingleton' )
					).toBe( classNameAsSingletonInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name, (explicitly) as a singleton, eagerly, with the corresponding singleton class instance', ->
					expect(
						Deft.Injector.resolve( 'classNameAsSingletonEagerly' )
					).toBe( expectedClassNameAsSingletonEagerlyInstance )
					
					expect(
						Deft.Injector.resolve( 'classNameAsSingletonEagerly' )
					).toBe( expectedClassNameAsSingletonEagerlyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name, (explicitly) as a singleton, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameAsSingletonLazilyInstance = Deft.Injector.resolve( 'classNameAsSingletonLazily' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						Deft.Injector.resolve( 'classNameAsSingletonLazily' )
					).toBe( classNameAsSingletonLazilyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name, as a prototype, with the corresponding prototype class instance', ->
					classNameAsPrototypeInstance1 = Deft.Injector.resolve( 'classNameAsPrototype' )
					classNameAsPrototypeInstance2 = Deft.Injector.resolve( 'classNameAsPrototype' )
					
					expect(
						classNameAsPrototypeInstance1
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						classNameAsPrototypeInstance2
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						classNameAsPrototypeInstance1
					).not.toBe( classNameAsPrototypeInstance2 )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name, as a prototype, (explicitly) lazily, with the corresponding prototype class instance', ->
					classNameAsPrototypeLazilyInstance1 = Deft.Injector.resolve( 'classNameAsPrototypeLazily' )
					classNameAsPrototypeLazilyInstance2 = Deft.Injector.resolve( 'classNameAsPrototypeLazily' )
					
					expect(
						classNameAsPrototypeLazilyInstance1
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						classNameAsPrototypeLazilyInstance2
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						classNameAsPrototypeLazilyInstance1
					).not.toBe( classNameAsPrototypeLazilyInstance2 )
					
					return
				)
				
				return
			)
			
			return
		)
		
		describe( 'Configuration with a class name and constructor parameters', ->
			
			expectedClassNameWithParametersEagerlyInstance = null
			expectedClassNameWithParametersAsSingletonEagerlyInstance = null
			
			it( 'should be configurable with a class name and constructor parameters', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameWithParameters:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameWithParameters' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name and constructor parameters, eagerly', ->
				constructorSpy = spyOn( ExampleClass.prototype, 'constructor' ).andCallFake( ->
					expectedClassNameWithParametersEagerlyInstance = @
					return constructorSpy.originalValue.apply( @, arguments )
				)
				
				Deft.Injector.configure(
					classNameWithParametersEagerly:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						eager: true
				)
				
				expect( ExampleClass.prototype.constructor ).toHaveBeenCalled()
				
				expect(
					expectedClassNameWithParametersEagerlyInstance
				).toBeInstanceOf( 'ExampleClass' )
				expect(
					expectedClassNameWithParametersEagerlyInstance.getParameter()
				).toEqual( 'expected value' )
				
				expect(
					Deft.Injector.canResolve( 'classNameWithParametersEagerly' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name and constructor parameters, (explicitly) lazily', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameWithParametersLazily:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						eager: false
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameWithParametersLazily' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name and constructor parameters, (explicitly) as a singleton', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameWithParametersAsSingleton:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						singleton: true
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameWithParametersAsSingleton' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name and constructor parameters, as a singleton, eagerly', ->
				constructorSpy = spyOn( ExampleClass.prototype, 'constructor' ).andCallFake( ->
					expectedClassNameWithParametersAsSingletonEagerlyInstance = @
					return constructorSpy.originalValue.apply( @, arguments )
				)
				
				Deft.Injector.configure(
					classNameWithParametersAsSingletonEagerly:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						singleton: true
						eager: true
				)
				
				expect( ExampleClass.prototype.constructor ).toHaveBeenCalled()
				
				expect(
					expectedClassNameWithParametersAsSingletonEagerlyInstance
				).toBeInstanceOf( 'ExampleClass' )
				expect(
					expectedClassNameWithParametersAsSingletonEagerlyInstance.getParameter()
				).toEqual( 'expected value' )
				
				expect(
					Deft.Injector.canResolve( 'classNameWithParametersAsSingletonEagerly' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name and constructor parameters, (explicitly) as a singleton, (explicitly) lazily', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameWithParametersAsSingletonLazily:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						singleton: true
						eager: false
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameWithParametersAsSingletonLazily' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name and constructor parameters, as a prototype', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameWithParametersAsPrototype:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						singleton: false
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameWithParametersAsPrototype' )
				).toBe( true )
				
				return
			)
			
			it( 'should not be configurable with a class name and constructor parameters, as a prototype, eagerly', ->
				expect( ->
					Deft.Injector.configure(
						classNameWithParametersAsPrototypeEagerly:
							className: 'ExampleClass'
							parameters: [ { parameter: 'expected value' } ]
							singleton: false
							eager: true
					)
					return
				).toThrow( new Error( "Error while configuring 'classNameWithParametersAsPrototypeEagerly': only singletons can be created eagerly." ) )
				
				return
			)
			
			it( 'should be configurable with a class name and constructor parameters, as a prototype, (explicitly) lazily', ->
				spyOn( ExampleClass.prototype, 'constructor' ).andCallThrough()
				
				Deft.Injector.configure(
					classNameWithParametersAsPrototypeLazily:
						className: 'ExampleClass'
						parameters: [ { parameter: 'expected value' } ]
						singleton: false
				)
				
				expect( ExampleClass.prototype.constructor ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'classNameWithParametersAsPrototypeLazily' )
				).toBe( true )
				
				return
			)
			
			describe( 'Resolution of a dependency configured with a class name and constructor parameters', ->
				
				it( 'should resolve a dependency configured with a class name and constructor parameters with the corresponding singleton class instance', ->
					expect(
						classNameWithParametersInstance = Deft.Injector.resolve( 'classNameWithParameters' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						classNameWithParametersInstance.getParameter()
					).toEqual( 'expected value' )
					
					expect(
						Deft.Injector.resolve( 'classNameWithParameters' )
					).toBe( classNameWithParametersInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name and constructor parameters, eagerly, with the corresponding singleton class instance', ->
					expect(
						Deft.Injector.resolve( 'classNameWithParametersEagerly' )
					).toBe( expectedClassNameWithParametersEagerlyInstance )
					
					expect(
						Deft.Injector.resolve( 'classNameWithParametersEagerly' )
					).toBe( expectedClassNameWithParametersEagerlyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name and constructor parameters, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameWithParametersLazilyInstance = Deft.Injector.resolve( 'classNameWithParametersLazily' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						classNameWithParametersLazilyInstance.getParameter()
					).toEqual( 'expected value' )
					
					expect(
						Deft.Injector.resolve( 'classNameWithParametersLazily' )
					).toBe( classNameWithParametersLazilyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name and constructor parameters, (explicitly) as a singleton, with the corresponding singleton class instance', ->
					expect(
						classNameWithParametersAsSingletonInstance = Deft.Injector.resolve( 'classNameWithParametersAsSingleton' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						classNameWithParametersAsSingletonInstance.getParameter()
					).toEqual( 'expected value' )
					
					expect(
						Deft.Injector.resolve( 'classNameWithParametersAsSingleton' )
					).toBe( classNameWithParametersAsSingletonInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name and constructor parameters, (explicitly) as a singleton, eagerly, with the corresponding singleton class instance', ->
					expect(
						Deft.Injector.resolve( 'classNameWithParametersAsSingletonEagerly' )
					).toBe( expectedClassNameWithParametersAsSingletonEagerlyInstance )
					
					expect(
						Deft.Injector.resolve( 'classNameWithParametersAsSingletonEagerly' )
					).toBe( expectedClassNameWithParametersAsSingletonEagerlyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name and constructor parameters, (explicitly) as a singleton, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameWithParametersAsSingletonLazilyInstance = Deft.Injector.resolve( 'classNameWithParametersAsSingletonLazily' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						classNameWithParametersAsSingletonLazilyInstance.getParameter()
					).toEqual( 'expected value' )
					
					expect(
						Deft.Injector.resolve( 'classNameWithParametersAsSingletonLazily' )
					).toBe( classNameWithParametersAsSingletonLazilyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name and constructor parameters, as a prototype, with the corresponding prototype class instance', ->
					classNameWithParametersAsPrototypeInstance1 = Deft.Injector.resolve( 'classNameWithParametersAsPrototype' )
					classNameWithParametersAsPrototypeInstance2 = Deft.Injector.resolve( 'classNameWithParametersAsPrototype' )
					
					expect(
						classNameWithParametersAsPrototypeInstance1
					).toBeInstanceOf( 'ExampleClass' )
					expect(
						classNameWithParametersAsPrototypeInstance1.getParameter()
					).toEqual( 'expected value' )
					
					expect(
						classNameWithParametersAsPrototypeInstance2
					).toBeInstanceOf( 'ExampleClass' )
					expect(
						classNameWithParametersAsPrototypeInstance2.getParameter()
					).toEqual( 'expected value' )
					
					expect(
						classNameWithParametersAsPrototypeInstance1
					).not.toBe( classNameWithParametersAsPrototypeInstance2 )
					
					return
				)
				
				it( 'should resolve a dependency configured with a class name and constructor parameters, as a prototype, (explicitly) lazily, with the corresponding prototype class instance', ->
					classNameWithParametersAsPrototypeLazilyInstance1 = Deft.Injector.resolve( 'classNameWithParametersAsPrototypeLazily' )
					classNameWithParametersAsPrototypeLazilyInstance2 = Deft.Injector.resolve( 'classNameWithParametersAsPrototypeLazily' )
					
					expect(
						classNameWithParametersAsPrototypeLazilyInstance1
					).toBeInstanceOf( 'ExampleClass' )
					expect(
						classNameWithParametersAsPrototypeLazilyInstance1.getParameter()
					).toEqual( 'expected value' )
					
					expect(
						classNameWithParametersAsPrototypeLazilyInstance2
					).toBeInstanceOf( 'ExampleClass' )
					expect(
						classNameWithParametersAsPrototypeLazilyInstance2.getParameter()
					).toEqual( 'expected value' )
					
					expect(
						classNameWithParametersAsPrototypeLazilyInstance1
					).not.toBe( classNameWithParametersAsPrototypeLazilyInstance2 )
					
					return
				)
				
				return
			)
			
			return
		)

		describe( 'Configuration with a class name for a singleton class', ->
			
			it( 'should be configurable with a class name for a singleton class', ->
				Deft.Injector.configure(
					classNameForSingletonClass:
						className: 'ExampleSingletonClass'
				)
				
				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClass' )
				).toBe( true )
				
				return
			)
			
			it( 'should not be configurable with a class name for a singleton class and constructor parameters', ->
				expect( ->
					Deft.Injector.configure(
						classNameForSingletonClassWithParameters:
							className: 'ExampleSingletonClass'
							parameters: [ { parameter: 'expected value' } ]
					)
					return
				).toThrow( new Error( "Error while configuring rule for 'classNameForSingletonClassWithParameters': parameters cannot be applied to singleton classes. Consider removing 'singleton: true' from the class definition." ) )
					
				return
			)
			
			it( 'should be configurable with a class name for a singleton class, eagerly', ->
				Deft.Injector.configure(
					classNameForSingletonClassEagerly:
						className: 'ExampleSingletonClass'
						eager: true
				)
				
				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClassEagerly' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name for a singleton class, (explicitly) lazily', ->
				Deft.Injector.configure(
					classNameForSingletonClassLazily:
						className: 'ExampleSingletonClass'
						eager: false
				)
				
				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClassLazily' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name for a singleton class, (explicitly) as a singleton', ->
				Deft.Injector.configure(
					classNameForSingletonClassAsSingleton:
						className: 'ExampleSingletonClass'
						singleton: true
				)
				
				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClassAsSingleton' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name for a singleton class, (explicitly) as a singleton, eagerly', ->
				Deft.Injector.configure(
					classNameForSingletonClassAsSingletonEagerly:
						className: 'ExampleSingletonClass'
						singleton: true
						eager: true
				)
				
				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClassAsSingletonEagerly' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a class name for a singleton class, (explicitly) as a singleton, (explicitly) lazily', ->
				Deft.Injector.configure(
					classNameForSingletonClassAsSingletonLazily:
						className: 'ExampleSingletonClass'
						singleton: true
						eager: false
				)
				
				expect(
					Deft.Injector.canResolve( 'classNameForSingletonClassAsSingletonLazily' )
				).toBe( true )
				
				return
			)
			
			it( 'should not be configurable with a class name for a singleton class, as a prototype', ->
				expect( ->
					Deft.Injector.configure(
						classNameForSingletonClassAsPrototype:
							className: 'ExampleSingletonClass'
							singleton: false
					)
					return
				).toThrow( new Error( "Error while configuring rule for 'classNameForSingletonClassAsPrototype': singleton classes cannot be configured for injection as a prototype. Consider removing 'singleton: true' from the class definition." ) )
					
				return
			)
			
			it( 'should not be configurable with a class name for a singleton class, as a prototype, eagerly', ->
				expect( ->
					Deft.Injector.configure(
						classNameForSingletonClassAsPrototypeEagerly:
							className: 'ExampleSingletonClass'
							singleton: false
							eager: true
					)
					return
				).toThrow( new Error( "Error while configuring 'classNameForSingletonClassAsPrototypeEagerly': only singletons can be created eagerly." ) )
					
				return
			)
			
			it( 'should not be configurable with a class name for a singleton class, as a prototype, (explicitly) lazily', ->
				expect( ->
					Deft.Injector.configure(
						classNameForSingletonClassAsPrototypeLazily:
							className: 'ExampleSingletonClass'
							singleton: false
							eager: false
					)
					return
				).toThrow( new Error( "Error while configuring rule for 'classNameForSingletonClassAsPrototypeLazily': singleton classes cannot be configured for injection as a prototype. Consider removing 'singleton: true' from the class definition." ) )
					
				return
			)
			
			describe( 'Resolution of a dependency configured with a class name for a singleton class', ->
				
				it( 'should resolve a dependency configured with a class name for a singleton class with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassInstance = Deft.Injector.resolve( 'classNameForSingletonClass' )
					).toBe( ExampleSingletonClass )
					
					expect(
						Deft.Injector.resolve( 'classNameForSingletonClass' )
					).toBe( classNameForSingletonClassInstance )
						
					return
				)
				
				it( 'should resolve a dependency configured with a class name for a singleton class, eagerly, with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassEagerlyInstance = Deft.Injector.resolve( 'classNameForSingletonClassEagerly' )
					).toBe( ExampleSingletonClass )
					
					expect(
						Deft.Injector.resolve( 'classNameForSingletonClassEagerly' )
					).toBe( classNameForSingletonClassEagerlyInstance )
						
					return
				)
				
				it( 'should resolve a dependency configured with a class name for a singleton class, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassEagerlyInstance = Deft.Injector.resolve( 'classNameForSingletonClassLazily' )
					).toBe( ExampleSingletonClass )
					
					expect(
						Deft.Injector.resolve( 'classNameForSingletonClassLazily' )
					).toBe( classNameForSingletonClassEagerlyInstance )
						
					return
				)
				
				it( 'should resolve a dependency configured with a class name for a singleton class, (explicitly) as a singleton, with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassAsSingletonInstance = Deft.Injector.resolve( 'classNameForSingletonClassAsSingleton' )
					).toBe( ExampleSingletonClass )
					
					expect(
						Deft.Injector.resolve( 'classNameForSingletonClassAsSingleton' )
					).toBe( classNameForSingletonClassAsSingletonInstance )
						
					return
				)
				
				it( 'should resolve a dependency configured with a class name for a singleton class, (explicitly) as a singleton, eagerly, with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassAsSingletonEagerlyInstance = Deft.Injector.resolve( 'classNameForSingletonClassAsSingletonEagerly' )
					).toBe( ExampleSingletonClass )
					
					expect(
						Deft.Injector.resolve( 'classNameForSingletonClassAsSingletonEagerly' )
					).toBe( classNameForSingletonClassAsSingletonEagerlyInstance )
						
					return
				)
				
				it( 'should resolve a dependency configured with a class name for a singleton class, (explicitly) as a singleton, (explicitly) lazily, with the corresponding singleton class instance', ->
					expect(
						classNameForSingletonClassAsSingletonLazilyInstance = Deft.Injector.resolve( 'classNameForSingletonClassAsSingletonLazily' )
					).toBe( ExampleSingletonClass )
					
					expect(
						Deft.Injector.resolve( 'classNameForSingletonClassAsSingletonLazily' )
					).toBe( classNameForSingletonClassAsSingletonLazilyInstance )
						
					return
				)
			)
			
			return
		)
		
		describe( 'Configuration with a factory function', ->
			
			factoryFunction = -> return Ext.create( 'ExampleClass' )
			
			expectedFnEagerlyInstance = null
			expectedFnAsSingletonEagerlyInstance = null
			
			it( 'should be configurable with a factory function', ->
				factoryFunctionSpy = jasmine.createSpy().andCallFake( factoryFunction )
				
				Deft.Injector.configure(
					fn:
						fn: factoryFunctionSpy
				)
				
				expect( factoryFunctionSpy ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'fn' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a factory function, eagerly', ->
				factoryFunctionSpy = jasmine.createSpy().andCallFake( ->
					return expectedFnEagerlyInstance = factoryFunction.apply( @, arguments )
				)
				
				Deft.Injector.configure(
					fnEagerly:
						fn: factoryFunctionSpy
						eager: true
				)
				
				expect( factoryFunctionSpy ).toHaveBeenCalled()
				
				expect(
					expectedFnEagerlyInstance
				).toBeInstanceOf( 'ExampleClass' )
				
				expect(
					Deft.Injector.canResolve( 'fnEagerly' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a factory function, (explicitly) lazily', ->
				factoryFunctionSpy = jasmine.createSpy().andCallFake( factoryFunction )
				
				Deft.Injector.configure(
					fnLazily:
						fn: factoryFunctionSpy
						eager: false
				)
				
				expect( factoryFunctionSpy ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'fnLazily' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a factory function, (explicitly) as a singleton', ->
				factoryFunctionSpy = jasmine.createSpy().andCallFake( factoryFunction )
				
				Deft.Injector.configure(
					fnAsSingleton:
						fn: factoryFunctionSpy
						singleton: true
				)
				
				expect( factoryFunctionSpy ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'fnAsSingleton' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a factory function, (explicitly) as a singleton, eagerly', ->
				factoryFunctionSpy = jasmine.createSpy().andCallFake( ->
					return expectedFnAsSingletonEagerlyInstance = factoryFunction.apply( @, arguments )
				)
				
				Deft.Injector.configure(
					fnAsSingletonEagerly:
						fn: factoryFunctionSpy
						singleton: true
						eager: true
				)
				
				expect( factoryFunctionSpy ).toHaveBeenCalled()
				
				expect(
					expectedFnAsSingletonEagerlyInstance
				).toBeInstanceOf( 'ExampleClass' )
				
				expect(
					Deft.Injector.canResolve( 'fnAsSingletonEagerly' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a factory function, (explicitly) as a singleton, (explicitly) lazily', ->
				factoryFunctionSpy = jasmine.createSpy().andCallFake( factoryFunction )
				
				Deft.Injector.configure(
					fnAsSingletonLazily:
						fn: factoryFunctionSpy
						singleton: true
						eager: false
				)
				
				expect( factoryFunctionSpy ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'fnAsSingletonLazily' )
				).toBe( true )
				
				return
			)
			
			it( 'should be configurable with a factory function, as a prototype', ->
				factoryFunctionSpy = jasmine.createSpy().andCallFake( factoryFunction )
				
				Deft.Injector.configure(
					fnAsPrototype:
						fn: factoryFunctionSpy
						singleton: false
				)
				
				expect( factoryFunctionSpy ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'fnAsPrototype' )
				).toBe( true )
				
				return
			)
			
			it( 'should not be configurable with a factory function, as a prototype, eagerly', ->
				expect( ->
					Deft.Injector.configure(
						fnAsPrototypeEagerly:
							fn: factoryFunction
							singleton: false
							eager: true
					)
					return
				).toThrow( new Error( "Error while configuring 'fnAsPrototypeEagerly': only singletons can be created eagerly." ) )
				
				return
			)
			
			it( 'should be configurable with a factory function, as a prototype, (explicitly) lazily', ->
				factoryFunctionSpy = jasmine.createSpy().andCallFake( factoryFunction )
				
				Deft.Injector.configure(
					fnAsPrototypeLazily:
						fn: factoryFunctionSpy
						singleton: false
						eager: false
				)
				
				expect( factoryFunctionSpy ).not.toHaveBeenCalled()
				
				expect(
					Deft.Injector.canResolve( 'fnAsPrototypeLazily' )
				).toBe( true )
				
				return
			)
			
			describe( 'Resolution of a dependency configured with a factory function', ->
				
				it( 'should resolve a dependency configured with a factory function with the corresponding singleton return value', ->
					expect(
						fnInstance = Deft.Injector.resolve( 'fn' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						Deft.Injector.resolve( 'fn' )
					).toBe( fnInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a factory function, eagerly, with the corresponding singleton return value', ->
					expect(
						Deft.Injector.resolve( 'fnEagerly' )
					).toBe( expectedFnEagerlyInstance )
					
					expect(
						Deft.Injector.resolve( 'fnEagerly' )
					).toBe( expectedFnEagerlyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a factory function, (explicitly) lazily, with the corresponding singleton return value', ->
					expect(
						fnLazilyInstance = Deft.Injector.resolve( 'fnLazily' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						Deft.Injector.resolve( 'fnLazily' )
					).toBe( fnLazilyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a factory function, (explicitly) as a singleton, with the corresponding singleton return value', ->
					expect(
						fnAsSingletonInstance = Deft.Injector.resolve( 'fnAsSingleton' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						Deft.Injector.resolve( 'fnAsSingleton' )
					).toBe( fnAsSingletonInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a factory function, (explicitly) as a singleton, eagerly, with the corresponding singleton return value', ->
					expect(
						Deft.Injector.resolve( 'fnAsSingletonEagerly' )
					).toBe( expectedFnAsSingletonEagerlyInstance )
					
					expect(
						Deft.Injector.resolve( 'fnAsSingletonEagerly' )
					).toBe( expectedFnAsSingletonEagerlyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a factory function, (explicitly) as a singleton, (explicitly) lazily, with the corresponding singleton return value', ->
					expect(
						fnAsSingletonLazilyInstance = Deft.Injector.resolve( 'fnAsSingletonLazily' )
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						Deft.Injector.resolve( 'fnAsSingletonLazily' )
					).toBe( fnAsSingletonLazilyInstance )
					
					return
				)
				
				it( 'should resolve a dependency configured with a factory function, as a prototype, with the corresponding prototype return value', ->
					fnAsPrototypeInstance1 = Deft.Injector.resolve( 'fnAsPrototype' )
					fnAsPrototypeInstance2 = Deft.Injector.resolve( 'fnAsPrototype' )
					
					expect(
						fnAsPrototypeInstance1
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						fnAsPrototypeInstance2
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						fnAsPrototypeInstance1
					).not.toBe( fnAsPrototypeInstance2 )
					
					return
				)
				
				it( 'should resolve a dependency configured with a factory function, as a prototype, (explicitly) lazily, with the corresponding prototype return value', ->
					fnAsPrototypeLazilyInstance1 = Deft.Injector.resolve( 'fnAsPrototypeLazily' )
					fnAsPrototypeLazilyInstance2 = Deft.Injector.resolve( 'fnAsPrototypeLazily' )
					
					expect(
						fnAsPrototypeLazilyInstance1
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						fnAsPrototypeLazilyInstance2
					).toBeInstanceOf( 'ExampleClass' )
					
					expect(
						fnAsPrototypeLazilyInstance1
					).not.toBe( fnAsPrototypeLazilyInstance2 )
					
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
					
				it( "should be configurable with a #{ type } value", ->
					identifier = prefix
					
					Deft.Injector.configure(
						createIdentifiedConfiguration( identifier,
							value: value
						)
					)
					
					expect(
						Deft.Injector.canResolve( identifier )
					).toBe( true )
					
					return
				)
				
				it( "should not be configurable with a #{ type } value, eagerly", ->
					identifier = prefix + 'Eagerly'
					
					expect( ->
						Deft.Injector.configure(
							createIdentifiedConfiguration( identifier,
								value: value
								eager: true
							)
						)
						return
					).toThrow( new Error( "Error while configuring '#{ identifier }': a 'value' cannot be created eagerly." ) )
					
					return
				)
				
				it( "should be configurable with a #{ type } value, (explicitly) lazily", ->
					identifier = prefix + 'Lazily'
					
					Deft.Injector.configure(
						createIdentifiedConfiguration( identifier,
							value: value
							eager: false
						)
					)
					
					expect(
						Deft.Injector.canResolve( identifier )
					).toBe( true )
					
					return
				)
				
				it( "should be configurable with a #{ type } value, (explicitly) as a singleton", ->
					identifier = prefix + 'AsSingleton'
					
					Deft.Injector.configure(
						createIdentifiedConfiguration( identifier,
							value: value
							singleton: true
						)
					)
					
					expect(
						Deft.Injector.canResolve( identifier )
					).toBe( true )
					
					return
				)
				
				it( "should not be configurable with a #{ type } value, (explicitly) as a singleton, eagerly", ->
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
					).toThrow( new Error( "Error while configuring '#{ identifier }': a 'value' cannot be created eagerly." ) )
					
					return
				)
				
				it( "should be configurable with a #{ type } value, (explicitly) as a singleton, (explicitly) lazily", ->
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
					).toBe( true )
					
					return
				)
				
				it( "should not be configurable with a #{ type } value, as a prototype", ->
					identifier = prefix + 'AsPrototype'
					
					expect( ->
						Deft.Injector.configure(
							createIdentifiedConfiguration( identifier,
								value: value
								singleton: false
							)
						)
						return
					).toThrow( new Error( "Error while configuring '#{ identifier }': a 'value' can only be configured as a singleton." ) )
				
					return
				)
				
				it( "should not be configurable with a #{ type } value, as a prototype, eagerly", ->
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
					).toThrow( new Error( "Error while configuring '#{ identifier }': a 'value' cannot be created eagerly." ) )
					
					return
				)
			
				it( "should not be configurable with a #{ type } value, as a prototype, (explicitly) lazily", ->
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
					).toThrow( new Error( "Error while configuring '#{ identifier }': a 'value' can only be configured as a singleton." ) )
					
					return
				)
				
				describe( "Resolution of a dependency configured with a #{ type } value", ->
				
					it( "should resolve a dependency configured with a #{ type } value with the corresponding value", ->
						identifier = prefix
						
						expect(
							Deft.Injector.resolve( identifier )
						).toBe( value )
						
						return
					)
					
					it( "should resolve a dependency configured with a #{ type } value with the corresponding value, (explicitly) lazily", ->
						identifier = prefix + 'Lazily'
						
						expect(
							Deft.Injector.resolve( identifier )
						).toBe( value )
						
						return
					)
					
					it( "should resolve a dependency configured with a #{ type } value, (explicitly) as a singleton, with the corresponding value", ->
						identifier = prefix + 'AsSingleton'
						
						expect(
							Deft.Injector.resolve( identifier )
						).toBe( value )
						
						return
					)
					
					it( "should resolve a dependency configured with a #{ type } value, (explicitly) as a singleton, (explicitly) lazily, with the corresponding value", ->
						identifier = prefix + 'AsSingletonLazily'
						
						expect(
							Deft.Injector.resolve( identifier )
						).toBe( value )
						
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
				value: ->
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
			
			it( 'should resolve a value for configured identifiers', ->
				
				for configuredIdentifier in configuredIdentifiers
					expect(
						Deft.Injector.resolve( configuredIdentifier )
					).not.toBeNull()
					
				return
			)
			
			it( 'should throw an error if asked to resolve an unconfigured identifier', ->
				expect( ->
					Deft.Injector.resolve( 'unconfiguredIdentifier' )
					return
				).toThrow( new Error( "Error while resolving value to inject: no dependency provider found for 'unconfiguredIdentifier'." ) )
				
				return
			)
			
			it( 'should pass the instance specified for resolution when lazily resolving a dependency with a factory function', ->
				
				factoryFunction = -> return 'expected value'
				
				exampleClassInstance = Ext.create( 'ExampleClass' )
				
				fnResolvePassedInstanceFactoryFunction                  = jasmine.createSpy().andCallFake( factoryFunction )
				fnResolvePassedInstanceLazilyFactoryFunction            = jasmine.createSpy().andCallFake( factoryFunction )
				fnResolvePassedInstanceAsSingletonFactoryFunction       = jasmine.createSpy().andCallFake( factoryFunction )
				fnResolvePassedInstanceAsSingletonLazilyFactoryFunction = jasmine.createSpy().andCallFake( factoryFunction )
				fnResolvePassedInstanceAsPrototypeFactoryFunction       = jasmine.createSpy().andCallFake( factoryFunction )
				fnResolvePassedInstanceAsPrototypeLazilyFactoryFunction = jasmine.createSpy().andCallFake( factoryFunction )
				
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
				
				expect( fnResolvePassedInstanceFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				expect( fnResolvePassedInstanceLazilyFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				expect( fnResolvePassedInstanceAsSingletonFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				expect( fnResolvePassedInstanceAsSingletonLazilyFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				expect( fnResolvePassedInstanceAsPrototypeFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				expect( fnResolvePassedInstanceAsPrototypeLazilyFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				
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
			
			it( 'should inject configured dependencies into properties for a given class instance', ->
				simpleClassInstance = Ext.create( 'SimpleClass' )
				
				Deft.Injector.inject( configuredIdentifiers, simpleClassInstance )
				
				for configuredIdentifier in configuredIdentifiers
					expect(
						simpleClassInstance[ configuredIdentifier ]
					).toBeDefined()
					
					expect(
						simpleClassInstance[ configuredIdentifier ]
					).not.toBeNull()
					
					resolvedValue = Deft.Injector.resolve( configuredIdentifier )
					
					if configuredIdentifier.indexOf( 'Prototype' ) is -1
						expect(
							simpleClassInstance[ configuredIdentifier ]
						).toBe( resolvedValue )
					else
						expect(
							simpleClassInstance[ configuredIdentifier ]
						).toBeInstanceOf( Ext.ClassManager.getClass( resolvedValue ).getName() )
				
				return
			)
			
			it( 'should inject configured dependencies into configs for a given class instance', ->
				complexClassInstance = Ext.create( 'ComplexClass' )
				
				Deft.Injector.inject( configuredIdentifiers, complexClassInstance )
				
				for configuredIdentifier in configuredIdentifiers
					getterFunctionName = 'get' + Ext.String.capitalize( configuredIdentifier )
					
					expect(
						complexClassInstance[ getterFunctionName ]()
					).not.toBeNull()
					
					resolvedValue = Deft.Injector.resolve( configuredIdentifier )
					
					if configuredIdentifier.indexOf( 'Prototype' ) is -1
						expect(
							complexClassInstance[ getterFunctionName ]()
						).toBe( resolvedValue )
					else
						expect(
							complexClassInstance[ getterFunctionName ]()
						).toBeInstanceOf( Ext.ClassManager.getClass( resolvedValue ).getName() )
					
				return
			)
			
			it( 'should automatically inject configured dependencies into properties for a given Injectable class instance', ->
				simpleInjectableClassInstance = Ext.create( 'InjectableSimpleClass' )
				
				for configuredIdentifier in configuredIdentifiers
					expect(
						simpleInjectableClassInstance[ configuredIdentifier ]
					).toBeDefined()
					
					expect(
						simpleInjectableClassInstance[ configuredIdentifier ]
					).not.toBeNull()
					
					resolvedValue = Deft.Injector.resolve( configuredIdentifier )
					
					if configuredIdentifier.indexOf( 'Prototype' ) is -1
						expect(
							simpleInjectableClassInstance[ configuredIdentifier ]
						).toBe( resolvedValue )
					else
						expect(
							simpleInjectableClassInstance[ configuredIdentifier ]
						).toBeInstanceOf( Ext.ClassManager.getClass( resolvedValue ).getName() )
				
				return
			)
			
			it( 'should automatically inject configured dependencies into configs for a given Injectable class instance', ->
				injectableComplexClassInstance = Ext.create( 'InjectableComplexClass' )
				
				for configuredIdentifier in configuredIdentifiers
					getterFunctionName = 'get' + Ext.String.capitalize( configuredIdentifier )
					
					expect(
						injectableComplexClassInstance[ getterFunctionName ]()
					).not.toBeNull()
					
					resolvedValue = Deft.Injector.resolve( configuredIdentifier )
					
					if configuredIdentifier.indexOf( 'Prototype' ) is -1
						if configuredIdentifier.indexOf( 'objectValue' ) is -1
							expect(
								injectableComplexClassInstance[ getterFunctionName ]()
							).toBe( resolvedValue )
						else
							# NOTE: Object configs are cloned/merged and will not be the exact same instance.
							expect(
								injectableComplexClassInstance[ getterFunctionName ]()
							).not.toBeNull()
					else
						expect(
							injectableComplexClassInstance[ getterFunctionName ]()
						).toBeInstanceOf( Ext.ClassManager.getClass( resolvedValue ).getName() )
						
				return
			)
			
			
			it( 'should automatically inject configured dependencies into configs for a given Injectable \`Ext.Component\` subclass instance', ->
				injectableComponentSubclassInstance = Ext.create( 'InjectableComponentSubclass' )
				
				for configuredIdentifier in configuredIdentifiers
					getterFunctionName = 'get' + Ext.String.capitalize( configuredIdentifier )
					
					expect(
						injectableComponentSubclassInstance[ getterFunctionName ]()
					).not.toBeNull()
					
					resolvedValue = Deft.Injector.resolve( configuredIdentifier )
					
					if configuredIdentifier.indexOf( 'Prototype' ) is -1
						if configuredIdentifier.indexOf( 'objectValue' ) is -1
							expect(
								injectableComponentSubclassInstance[ getterFunctionName ]()
							).toBe( resolvedValue )
						else
							# NOTE: Object configs are cloned/merged and will not be the exact same instance.
							expect(
								injectableComponentSubclassInstance[ getterFunctionName ]()
							).not.toBeNull()
					else
						expect(
							injectableComponentSubclassInstance[ getterFunctionName ]()
						).toBeInstanceOf( Ext.ClassManager.getClass( resolvedValue ).getName() )
						
				return
			)
			
			it( 'should throw an error if asked to inject an unconfigured identifier', ->
				simpleClassInstance = Ext.create( 'SimpleClass' )
				
				expect( ->
					Deft.Injector.inject( 'unconfiguredIdentifier', simpleClassInstance )
					return
				).toThrow( new Error( "Error while resolving value to inject: no dependency provider found for 'unconfiguredIdentifier'." ) )
				
				return
			)
			
			it( 'should pass the instance being injected when lazily resolving a dependency with a factory function', ->
				
				factoryFunction = -> return 'expected value'
				
				exampleClassInstance = Ext.create( 'ExampleClass' )
				
				fnInjectPassedInstanceFactoryFunction                  = jasmine.createSpy().andCallFake( factoryFunction )
				fnInjectPassedInstanceLazilyFactoryFunction            = jasmine.createSpy().andCallFake( factoryFunction )
				fnInjectPassedInstanceAsSingletonFactoryFunction       = jasmine.createSpy().andCallFake( factoryFunction )
				fnInjectPassedInstanceAsSingletonLazilyFactoryFunction = jasmine.createSpy().andCallFake( factoryFunction )
				fnInjectPassedInstanceAsPrototypeFactoryFunction       = jasmine.createSpy().andCallFake( factoryFunction )
				fnInjectPassedInstanceAsPrototypeLazilyFactoryFunction = jasmine.createSpy().andCallFake( factoryFunction )
				
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
				
				expect( fnInjectPassedInstanceFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				expect( fnInjectPassedInstanceLazilyFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				expect( fnInjectPassedInstanceAsSingletonFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				expect( fnInjectPassedInstanceAsSingletonLazilyFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				expect( fnInjectPassedInstanceAsPrototypeFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				expect( fnInjectPassedInstanceAsPrototypeLazilyFactoryFunction ).toHaveBeenCalledWith( exampleClassInstance )
				
				return
			)
			
			return
		)
		
		describe( 'Runtime configuration changes', ->
			
			beforeEach( ->
				Deft.Injector.reset()
				
				return
			)
			
			it( 'should clear out configured identifiers when the reset method is called', ->
				Deft.Injector.configure(
					identifier:
						value: 'expected value'
				)
				
				expect(
					Deft.Injector.resolve( 'identifier' )
				).toEqual( 'expected value' )
				
				Deft.Injector.reset()
				
				expect( ->
					Deft.Injector.resolve( 'identifier' )
					return
				).toThrow( new Error( "Error while resolving value to inject: no dependency provider found for 'identifier'." ) )
				
				return
			)
			
			it( 'should aggregate providers across multiple calls to configure', ->
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
				).toEqual( 'value #1' )
				
				expect(
					Deft.Injector.resolve( 'identifier2' )
				).toEqual( 'value #2' )
				
				return
			)
			
			it( 'should resolve using the last provider to be configured for a given identifier (i.e. configuration for the same identifier overwrites the previous configuration)', ->
				Deft.Injector.configure(
					existingIdentifier:
						value: 'original value'
				)
				
				expect(
					Deft.Injector.resolve( 'existingIdentifier' )
				).toEqual( 'original value' )
				
				Deft.Injector.configure(
					existingIdentifier:
						value: 'new value'
				)
				
				expect(
					Deft.Injector.resolve( 'existingIdentifier' )
				).toEqual( 'new value' )
				
				return
			)
			
			it( 'should instantiate eager providers when they are initially configured, and not reinstantiate them on subsequent calls to configure for other identifiers', ->
				factoryFn = jasmine.createSpy( 'factory function' ).andCallFake( -> return 'expected value' )
				
				Deft.Injector.configure(
					eagerIdentifier:
						fn: factoryFn
						eager: true
				)
				
				expect( factoryFn ).toHaveBeenCalled()
				
				factoryFn.reset()
				
				Deft.Injector.configure(
					anyOtherIdentifier: 
						value: 'value'
				)
				
				expect( factoryFn ).not.toHaveBeenCalled()
				
				return
			)
			
			return
		)
			
		return
	)
	
	return
)