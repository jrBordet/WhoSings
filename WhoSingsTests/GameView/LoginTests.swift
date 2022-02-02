//
//  LoginTests.swift
//  WhoSingsTests
//
//  Created by Jean Raphael Bordet on 01/10/21.
//

import XCTest
@testable import WhoSings
import Difference
import RxComposableArchitecture
import RxComposableArchitectureTests
import RxSwift
import RxCocoa

class LoginTests: XCTestCase {

	func testLogin_success() {
		let initialValue: GameViewState = .empty
		
		let loginSuccess: LoginEnvironment = .mock { username in
			Effect.just(.success(username))
		}
		
		let environment: GameViewEnvironment = .init(
			bootstrap: .mock(),
			game: GameEnvironment(),
			login: loginSuccess
		)
		
		assert(
			initialValue: initialValue,
			reducer: gameSessionViewReducer,
			environment: environment,
			steps: Step(.send, .login(.username("ted")), { state in
				state.username = "ted"
				state.loggedIn = false
			}),
			Step(.receive, .login(.login), { state in
				state.username = "ted"
				state.loggedIn = false
			}),
			Step(.receive, .login(.loginResponse(.success("ted"))), { state in
				state.username = "ted"
				state.loggedIn = true
			})
		)
	}
	
	func testLoginEmptyUsername_success() {
		let initialValue: GameViewState = .empty
		
		let loginSuccess: LoginEnvironment = .mock { username in
			Effect.just(.success(username))
		}
		
		let environment: GameViewEnvironment = .init(
			bootstrap: .mock(),
			game: GameEnvironment(),
			login: loginSuccess
		)
		
		assert(
			initialValue: initialValue,
			reducer: gameSessionViewReducer,
			environment: environment,
			steps: Step(.send, .login(.username("")), { state in
				state.username = "bob"
				state.loggedIn = false
			}),
			Step(.receive, .login(.login), { state in
				state.username = "bob"
				state.loggedIn = false
			}),
			Step(.receive, .login(.loginResponse(.success("bob"))), { state in
				state.username = "bob"
				state.loggedIn = true
			})
		)
	}
	
	func testLogin_failure() {
		let initialValue: GameViewState = .empty
		
		let environment: GameViewEnvironment = .init(
			bootstrap: .mock(),
			game: .init(),
			login: .error
		)
		
		assert(
			initialValue: initialValue,
			reducer: gameSessionViewReducer,
			environment: environment,
			steps: Step(.send, .login(.username("ted")), { state in
				state.username = "ted"
				state.loggedIn = false
			}),
			Step(.receive, .login(.login), { state in
				state.username = "ted"
				state.loggedIn = false
			}),
			Step(.receive, .login(.loginResponse(.failure(.loginError))), { state in
				state.username = ""
				state.loggedIn = false
			})
		)
	}
	
	func testLogout_success() {
		let initialValue: GameViewState = .loggedIn
		
		let environment: GameViewEnvironment = .init(
			bootstrap: .mock(),
			game: .init(),
			login: .mock()
		)
		
		assert(
			initialValue: initialValue,
			reducer: gameSessionViewReducer,
			environment: environment,
			steps: Step(.send, .login(.username("teddy")), { state in
				state.username = "teddy"
				state.loggedIn = true
			}),
			Step(.receive, .login(.login), { state in
				state.username = ""
				state.loggedIn = false
			})
		)
	}
}
