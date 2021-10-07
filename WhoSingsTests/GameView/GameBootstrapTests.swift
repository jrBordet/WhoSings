//
//  GameSessionTests.swift
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

class GameBootstrapTests: XCTestCase {
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	func testBootstrap() {
		let initialValue: GameBootstrapState = .empty
		
		let artist: Artist = .mock(id: 1, name: "bob")
		
		let response: [Track] = [
			.init(id: 1, name: "song", playerId: 1, artistName: "Bob", lyrics: "")
		]
		
		let environment: GameBootstrapEnvironment =
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
		
		assert(
			initialValue: initialValue,
			reducer: gameBoostrapReducer,
			environment: environment,
			steps: Step(.send, GameBootstrapAction.bootstrap, { state in
				state.isLoading = true
			}),
			Step(.receive, .getTracksResponse(Result<[Track], GenericError>.success([.init(id: 1, name: "song", playerId: 1, artistName: "Bob", lyrics: "")])), { state in
				state.tracksCount = 1
			}),
			Step(.receive, .getArtistsResponse(.success([artist])), { state in
				state.artists = [
					artist
				]
			}),
			Step(.receive, .getLyricsResponse(.success(.init(id: 1, name: "song", playerId: 1, artistName: "Bob", lyrics: "some song"))), { state in
				state.tracks = [
					.init(id: 1, name: "song", playerId: 1, artistName: "Bob", lyrics: "some song")
				]
				
				state.bootstrapCompleted = true
				state.isLoading = false
			})
		)
		
	}

}
