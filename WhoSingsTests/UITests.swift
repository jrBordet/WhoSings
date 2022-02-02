//
//  UITests.swift
//  WhoSingsTests
//
//  Created by Jean Raphael Bordet on 06/10/21.
//

import XCTest
@testable import WhoSings
import Difference
import RxComposableArchitecture
import RxComposableArchitectureTests
import RxSwift
import RxCocoa
import SnapshotTesting

class UITests: XCTestCase {
	let record = false

	func testSessions() {
		let testStore = Store(
			initialValue: SessionsState(
				sessions: [
					UserSession(username: "bob", score: 3),
					.init(username: "margot", score: 10),
					.init(username: "jean", score: 7),
					.init(username: "grosjean", score: 7),
					.init(username: "BOBO", score: 7),
					.init(username: "DaVid", score: 7)
				]),
			reducer: sessionsReducer,
			environment: SessionEnvironment()
		)
		
		let scene = SessionsViewController()
		scene.store = testStore
		
		assertSnapshot(matching: scene, as: .image(on: .iPhoneX), record: record)
	}
	
	func testGameSessionCard() {
		let track = Track(id: 1, name: "song", playerId: 1, artistName: "bob", lyrics: "this is the bobby song")
		let track_1 = Track(id: 2, name: "song 2", playerId: 2, artistName: "bob 2", lyrics: "")
		let track_2 = Track(id: 3, name: "song 1", playerId: 1, artistName: "bob", lyrics: "")
		
		let initialValue: GameViewState = .init(
			artists: [
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
		
		let gameSessionEnvironment: GameBootstrapEnvironment = .mock(
			getTopSongs: { () -> Effect<Result<[Track], GenericError>> in
				.just(.success([]))
			},
			getLyrics: { track in
				.just(.success(trackLyricsLens.set("some song", track)))
			},
			getArtists: { () -> Effect<Result<[Artist], GenericError>> in
				.just(.success([]))
			}
		)
		
		let environment: GameViewEnvironment = .init(
			bootstrap: gameSessionEnvironment,
			game: GameEnvironment(),
			login: .mock()
		)
		
		let testStore = Store(
			initialValue: initialValue,
			reducer: gameSessionViewReducer,
			environment: environment
		)
		
		let scene = HomeViewController()
		scene.store = testStore
		scene.shuffle = false
		
		testStore.send(.game(.start(false)))
		
		assertSnapshot(matching: scene, as: .image(on: .iPhoneX), record: record)
	}
	
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
		
		let artist: Artist = .mock(id: 1, name: "bob")
		
		let response: [Track] = [
			.init(id: 1, name: "song", playerId: 1, artistName: "Bob", lyrics: "")
		]
		
		let gameSessionEnvironment: GameBootstrapEnvironment = .mock(
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
		
		let testStore = Store(
			initialValue: initialValue,
			reducer: gameSessionViewReducer,
			environment: environment
		)
		
		let scene = HomeViewController()
		scene.store = testStore
		
		assertSnapshot(matching: scene, as: .image(on: .iPhoneX), record: record)
	}
}
