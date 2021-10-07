//
//  AppTests.swift
//  WhoSingsTests
//
//  Created by Jean Raphael Bordet on 02/10/21.
//

import XCTest
@testable import WhoSings
import Difference
import RxComposableArchitecture
import RxComposableArchitectureTests
import RxSwift
import RxCocoa

class AppTests: XCTestCase {
	func testGameSessionCompleted() {
		let track = Track(id: 1, name: "song", playerId: 1, artistName: "bob", lyrics: "")
		let track_1 = Track(id: 2, name: "song 2", playerId: 2, artistName: "bob 2", lyrics: "")
		let track_2 = Track(id: 3, name: "song 1", playerId: 1, artistName: "bob", lyrics: "")
		
		let quizCard_0 = QuizCard(
			track: track,
			artists: [
				.mock(id: 1, name: "bob"),
				.mock(id: 2, name: "ted"),
				.mock(id: 3, name: "alex")
			])
		
		let quizCard_1 = QuizCard(
			track: track_1,
			artists: [
				.mock(id: 2, name: "bob 2"),
				.mock(id: 1, name: "bob"),
				.mock(id: 3, name: "alex")
			])
		
		let quizCard_2 = QuizCard(
			track: track_2,
			artists: [
				.mock(id: 1, name: "bob"),
				.mock(id: 2, name: "ted"),
				.mock(id: 3, name: "alex")
			])
		
		
		let gameViewState: GameViewState = .init(
			artists: [
				.mock(id: 1, name: "bob"),
				.mock(id: 2, name: "ted"),
				.mock(id: 3, name: "alex")
			],
			tracks: [
				Track(id: 1, name: "song", playerId: 1, artistName: "bob", lyrics: ""),
				Track(id: 2, name: "song 2", playerId: 2, artistName: "bob 2", lyrics: ""),
				Track(id: 3, name: "song 1", playerId: 1, artistName: "bob", lyrics: "")
			],
			isLoading: false,
			tracksCount: 3,
			bootstrapCompleted: false,
			quizCard: [
				quizCard_0,
				quizCard_1,
				quizCard_2
			],
			currentIndex: 2,
			points: 42,
			currentQuizCard: quizCard_2,
			playerSelection: 0,
			gameSessionCompleted: false,
			isPlaying: false,
			username: "bob",
			loggedIn: true,
			sessions: [
				
			]
		)
		
		let initialValue: AppState = .init(
			appDelegateState: AppDelegateState(),
			gameState: gameViewState,
			userSessions: .empty
		)
		
		let environment: AppEnvironment = .init(
			gameViewEnvironment: .mock()
		)
		
		assert(
			initialValue: initialValue,
			reducer: appReducer,
			environment: environment,
			steps: Step(.send, AppAction.game(GameViewAction.game(GameAction.next)), { state in
				state.userSessions.sessions = [
					UserSession.mock(
						username: "bob",
						score: 42
					)
				]
				
				state.gameState.sessions = [
					UserSession.mock(
						username: "bob",
						score: 42
					)
				]
				
				state.gameState.quizCard = [
				]
				
				state.gameState.currentIndex = 0
				state.gameState.currentQuizCard = nil
				state.gameState.gameSessionCompleted = true
			})
		)
		
	}
	
	func testErrorOnBootstrap() {
		let initialValue: AppState = .init(
			appDelegateState: AppDelegateState(),
			gameState: .empty,
			userSessions: .empty,
			genericError: nil
		)
		
		let error = GenericError(title: "GetTopSongs", message: "generic error", isDismissed: false)
		
		let bootstrapEnv: GameBootstrapEnvironment = .mock { () -> Effect<Result<[Track], GenericError>> in
			.just(
				.failure(error)
			)
		} getLyrics: { _ -> Effect<Result<Track, GenericError>> in fatalError()
		} getArtists: { () -> Effect<Result<[Artist], GenericError>> in
			.just(.success([]))
		}
		
		let environment: AppEnvironment = .init(
			gameViewEnvironment: GameViewEnvironment.mock(
				bootstrap: bootstrapEnv,
				game: .mock(),
				login: LoginEnvironment()
			)
		)
		
		assert(
			initialValue: initialValue,
			reducer: appReducer,
			environment: environment,
			steps: Step(.send, AppAction.game(GameViewAction.bootstrap(GameBootstrapAction.bootstrap)), { state in
				state.gameState.isLoading = true
			}),
			Step(.receive, .game(.bootstrap(.getTracksResponse(.failure(error)))), { state in
				state.genericError = GenericErrorState(
					title: "GetTopSongs",
					message: "generic error",
					isDismissed: false
				)
				
				state.gameState.genericError = .init(title: "GetTopSongs", message: "generic error", isDismissed: false)
			}),
			Step(.receive, AppAction.game(GameViewAction.bootstrap(GameBootstrapAction.getArtistsResponse(.success([])))), { state in

			}),
			Step(.send, .genericError(.dismiss), { state in
				state.gameStateView.genericError = nil
			})
		)
	}
	
	
}
