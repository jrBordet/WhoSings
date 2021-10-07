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

	func testLogin() {
		let initialValue: GameViewState = .empty
		
		let environment: GameViewEnvironment = .init(
			bootstrap: .mock(),
			game: GameEnvironment(),
			login: .init()
		)
		
		assert(
			initialValue: initialValue,
			reducer: gameSessionViewReducer,
			environment: environment,
			steps: Step(.send, .login(.username("ted")), { state in
				state.username = "ted"
				state.loggedIn = true
			}),
			Step(.send, .login(.login), { state in
				state.username = ""
				state.loggedIn = false
			}),
			Step(.send, .login(.username("")), { state in
				state.username = "bob"
				state.loggedIn = true
			})
		)
		
	}
}
