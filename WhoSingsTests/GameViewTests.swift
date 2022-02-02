//
//  GameViewTests.swift
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
import SnapshotTesting

class GameViewTests: XCTestCase {
	func testBootstrap() {
		let initialValue: GameViewState = .empty
		
		let artist: Artist = .mock(id: 1, name: "bob")
		
		let response: [Track] = [
			.init(id: 1, name: "song", playerId: 1, artistName: "Bob", lyrics: "")
		]
		
		let gameSessionEnvironment: GameBootstrapEnvironment =
			.mock(
				getTopSongs: { () -> Effect<Result<[Track], GenericError>> in
					.just(.success(response))
				},
				getLyrics: { track in
					.just(.success(trackLyricsLens.set("some song", track)))
				},
				getArtists: { () -> Effect<Result<[Artist], GenericError>> in
					.just(.success([artist]))
				}
			)
		
		let environment: GameViewEnvironment = .init(
			bootstrap: gameSessionEnvironment,
			game: GameEnvironment(),
			login: .mock()
		)
		
		assert(
			initialValue: initialValue,
			reducer: gameSessionViewReducer,
			environment: environment,
			steps: Step(.send, .bootstrap(.bootstrap), { state in
				state.bootstrap.isLoading = true
			}),
			Step(.receive, .bootstrap(.getTracksResponse(.success([.init(id: 1, name: "song", playerId: 1, artistName: "Bob", lyrics: "")]))), { state in
				state.bootstrap.tracksCount = 1
			}),
			Step(.receive, .bootstrap(.getArtistsResponse(.success([artist]))), { state in
				state.artists = [
					artist
				]
			}),
			Step(.receive, .bootstrap(.getLyricsResponse(.success(.init(id: 1, name: "song", playerId: 1, artistName: "Bob", lyrics: "some song")))), { state in
				state.isLoading = false
				state.tracks = [
					.init(id: 1, name: "song", playerId: 1, artistName: "Bob", lyrics: "some song")
				]
				
				state.bootstrapCompleted = true
			})
		)
		
	}
	
	/**
	
	As a Player:
	When
	
	- select bob (correct)
	then
	points = 10
	
	- select nothing and next
	then
	points = 10
	
	- select bob (correct)
	then
	points = 20
	*/
	
	func testGameSession() {
		let track = Track(id: 1, name: "song", playerId: 1, artistName: "bob", lyrics: "")
		let track_1 = Track(id: 2, name: "song 2", playerId: 2, artistName: "bob 2", lyrics: "")
		let track_2 = Track(id: 3, name: "song 1", playerId: 1, artistName: "bob", lyrics: "")
		
		let initialValue: GameViewState = .init(
			artists: [
				.mock(id: 1, name: "bob"),
				.mock(id: 2, name: "ted"),
				.mock(id: 3, name: "alex")
			],
			tracks: [
				track,
				track_1,
				track_2
			],
			isLoading: false,
			tracksCount: 2,
			bootstrapCompleted: false,
			quizCard: [],
			currentIndex: 0,
			points: 0,
			playerSelection: 0,
			gameSessionCompleted: false,
			isPlaying: false,
			username: "bob",
			loggedIn: true,
			sessions: []
		)
		
		let environment: GameViewEnvironment = .init(
			bootstrap: .mock(),
			game: .mock(),
			login: .mock()
		)
		
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
		
		assert(
			initialValue: initialValue,
			reducer: gameSessionViewReducer,
			environment: environment,
			steps: Step(.send, .game(.start(false)), { state in
				state.isPlaying = true
				
				state.quizCard = [
					quizCard_0,
					quizCard_1,
					quizCard_2
				]
				
				state.currentQuizCard = quizCard_0
			}),
			Step(.send, .game(.selectId(1)), { state in
				state.playerSelection = 1 // artist Id
			}),
			Step(.send, .game(.next), { state in
				state.points = 10
				state.playerSelection = 0 // artist Id erased
				
				state.currentIndex = 1
				
				state.currentQuizCard = quizCard_1
			}),
			Step(.send, .game(.next), { state in
				state.points = 10
				state.playerSelection = 0 // artist Id
				
				state.currentIndex = 2
				
				state.currentQuizCard = quizCard_2
			}),
			Step(.send, .game(.selectId(1)), { state in
				state.playerSelection = 1 // artist Id
			}),
			Step(.send, .game(.next), { state in
				state.isPlaying = false
				
				state.points = 20
				state.playerSelection = 0 // artist Id
				
				state.currentIndex = 0 // reset -> completed quiz
				
				state.currentQuizCard = nil
				state.quizCard = []
				
				state.gameSessionCompleted = true
				state.sessions = [
					UserSession.mock(
						username: "bob",
						score: 20
					)
				]
			}),
			Step(.send, .game(.start(false)), { state in
				state.isPlaying = true
				
				state.points = 0
				
				state.gameSessionCompleted = false
				
				state.quizCard = [
					quizCard_0,
					quizCard_1,
					quizCard_2
				]
				
				state.currentQuizCard = quizCard_0
			})
		)
		
	}
	
	
	/**
	
	As a Player:
	When
	
	- select (wrong)
	then
	points = 0
	
	- select nothing and next
	then
	points = 0
	
	- select  (wrong)
	then
	points = 0
	*/
	
	func testGameLoseSession() {
		let track = Track(id: 1, name: "song", playerId: 1, artistName: "bob", lyrics: "")
		let track_1 = Track(id: 2, name: "song 2", playerId: 2, artistName: "bob 2", lyrics: "")
		let track_2 = Track(id: 3, name: "song 1", playerId: 1, artistName: "bob", lyrics: "")
		
		let initialValue: GameViewState = .init(
			artists: [
				.mock(id: 1, name: "bob"),
				.mock(id: 2, name: "ted"),
				.mock(id: 3, name: "alex")
			],
			tracks: [
				track,
				track_1,
				track_2
			],
			isLoading: false,
			tracksCount: 2,
			bootstrapCompleted: false,
			quizCard: [],
			currentIndex: 0,
			points: 0,
			playerSelection: 0,
			gameSessionCompleted: false,
			isPlaying: false,
			username: "bob",
			loggedIn: true,
			sessions: []
		)
		
		let environment: GameViewEnvironment = .init(
			bootstrap: .mock(),
			game: .mock(),
			login: .mock()
		)
		
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
		
		assert(
			initialValue: initialValue,
			reducer: gameSessionViewReducer,
			environment: environment,
			steps: Step(.send, .game(.start(false)), { state in
				state.isPlaying = true
				
				state.quizCard = [
					quizCard_0,
					quizCard_1,
					quizCard_2
				]
				
				state.currentQuizCard = quizCard_0
			}),
			Step(.send, .game(.select(1)), { state in
				state.playerSelection = 2 // artist Id
			}),
			Step(.send, .game(.next), { state in
				state.points = 0
				state.playerSelection = 0 // artist Id erased
				
				state.currentIndex = 1
				
				state.currentQuizCard = quizCard_1
			}),
			Step(.send, .game(.next), { state in
				state.points = 0
				state.playerSelection = 0 // artist Id
				
				state.currentIndex = 2
				
				state.currentQuizCard = quizCard_2
			}),
			Step(.send, .game(.select(2)), { state in
				state.playerSelection = 3 // artist Id
			}),
			Step(.send, .game(.next), { state in
				state.isPlaying = false
				
				state.points = 0
				state.playerSelection = 0 // artist Id
				
				state.currentIndex = 0 // reset -> completed quiz
				
				state.currentQuizCard = nil
				state.quizCard = []
				
				state.sessions = [
					UserSession.mock(
						username: "bob",
						score: 0
					)
				]
				
				state.gameSessionCompleted = true
			})
		)
		
	}
}
