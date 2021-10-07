//
//  GameStateTests.swift
//  WhoSingsTests
//
//  Created by Jean Raphael Bordet on 30/09/21.
//

import XCTest
@testable import WhoSings
import Difference
import RxComposableArchitecture
import RxComposableArchitectureTests
import RxSwift
import RxCocoa

class GameStateTests: XCTestCase {

	func testGameReducer() {
		let initialValue: GameState = .empty
		
		let environment: GameEnvironment = .init()
		
		assert(
			initialValue: initialValue,
			reducer: gameReducer,
			environment: environment,
			steps: Step(.send, .start(false), { state in
				state.isPlaying = true
			}),
			Step(.send, GameAction.reset, { state in
				state.isPlaying = false
				state.gameSessionCompleted = false
			})
		)
		
	}
	
}

